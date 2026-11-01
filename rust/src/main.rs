//! monster: std-only orchestration CLI for the MONSTER-BRIDGE engine.
//! Semantics mirror monster_bridge/src/bridge.py (scan / export / validate).

use std::collections::{BTreeMap, HashMap, HashSet};
use std::fs;
use std::io::Write;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::{Duration, Instant};

// ---------------------------------------------------------------- SHA-256

const SHA_K: [u32; 64] = [
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
];

pub fn sha256_hex(data: &[u8]) -> String {
    let mut h: [u32; 8] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
    ];
    let bitlen = (data.len() as u64).wrapping_mul(8);
    let mut msg = data.to_vec();
    msg.push(0x80);
    while msg.len() % 64 != 56 {
        msg.push(0);
    }
    msg.extend_from_slice(&bitlen.to_be_bytes());
    for chunk in msg.chunks_exact(64) {
        let mut w = [0u32; 64];
        for i in 0..16 {
            w[i] = u32::from_be_bytes([chunk[4 * i], chunk[4 * i + 1], chunk[4 * i + 2], chunk[4 * i + 3]]);
        }
        for i in 16..64 {
            let s0 = w[i - 15].rotate_right(7) ^ w[i - 15].rotate_right(18) ^ (w[i - 15] >> 3);
            let s1 = w[i - 2].rotate_right(17) ^ w[i - 2].rotate_right(19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16]
                .wrapping_add(s0)
                .wrapping_add(w[i - 7])
                .wrapping_add(s1);
        }
        let (mut a, mut b, mut c, mut d, mut e, mut f, mut g, mut hh) =
            (h[0], h[1], h[2], h[3], h[4], h[5], h[6], h[7]);
        for i in 0..64 {
            let s1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let ch = (e & f) ^ ((!e) & g);
            let t1 = hh
                .wrapping_add(s1)
                .wrapping_add(ch)
                .wrapping_add(SHA_K[i])
                .wrapping_add(w[i]);
            let s0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let maj = (a & b) ^ (a & c) ^ (b & c);
            let t2 = s0.wrapping_add(maj);
            hh = g; g = f; f = e; e = d.wrapping_add(t1);
            d = c; c = b; b = a; a = t1.wrapping_add(t2);
        }
        h[0] = h[0].wrapping_add(a); h[1] = h[1].wrapping_add(b);
        h[2] = h[2].wrapping_add(c); h[3] = h[3].wrapping_add(d);
        h[4] = h[4].wrapping_add(e); h[5] = h[5].wrapping_add(f);
        h[6] = h[6].wrapping_add(g); h[7] = h[7].wrapping_add(hh);
    }
    let mut out = String::with_capacity(64);
    for v in h.iter() {
        out.push_str(&format!("{:08x}", v));
    }
    out
}

// ---------------------------------------------------------------- matcher

/// Pattern families in bridge.py PATTERNS insertion order.
/// A '.' in an alternative is the regex any-char (except newline) wildcard;
/// every other character is a literal, matched case-insensitively.
pub const FAMILIES: [(&str, &[&str]); 3] = [
    ("moonshine", &["moonshine", "hauptmodul", "vertex.operator", "modular", "j.invariant"]),
    ("monster", &["monster.group", "sporadic", "character.table", "representation"]),
    ("lie", &["lie.algebra", "lie.group", "jacobi.identity", "tangent.space", "manifold"]),
];

fn chars_lower_eq(a: char, b: char) -> bool {
    a.to_lowercase().eq(b.to_lowercase())
}

/// True when `pattern` (with '.' wildcards) matches `text` at char offset `start`.
fn match_at(text: &[char], start: usize, pattern: &[char]) -> bool {
    if start + pattern.len() > text.len() {
        return false;
    }
    for (i, p) in pattern.iter().enumerate() {
        let t = text[start + i];
        if *p == '.' {
            if t == '\n' {
                return false;
            }
        } else if !chars_lower_eq(*p, t) {
            return false;
        }
    }
    true
}

pub fn alternative_matches(text: &str, alternative: &str) -> bool {
    let t: Vec<char> = text.chars().collect();
    let p: Vec<char> = alternative.chars().collect();
    if p.is_empty() {
        return true;
    }
    if p.len() > t.len() {
        return false;
    }
    for start in 0..=(t.len() - p.len()) {
        if match_at(&t, start, &p) {
            return true;
        }
    }
    false
}

/// Domains whose pattern matches `line`, in bridge.py family order.
pub fn classify_line(line: &str) -> Vec<&'static str> {
    let mut out = Vec::new();
    for (name, alts) in FAMILIES.iter() {
        if alts.iter().any(|a| alternative_matches(line, a)) {
            out.push(*name);
        }
    }
    out
}

// ---------------------------------------------------------------- JSON

#[derive(Debug, Clone, PartialEq)]
pub enum Json {
    Null,
    Bool(bool),
    Int(i64),
    Float(f64),
    Str(String),
    Arr(Vec<Json>),
    Obj(Vec<(String, Json)>),
}

impl Json {
    pub fn get(&self, key: &str) -> Option<&Json> {
        match self {
            Json::Obj(pairs) => pairs.iter().find(|(k, _)| k == key).map(|(_, v)| v),
            _ => None,
        }
    }
    pub fn as_str(&self) -> Option<&str> {
        match self { Json::Str(s) => Some(s), _ => None }
    }
    pub fn as_int(&self) -> Option<i64> {
        match self { Json::Int(n) => Some(*n), Json::Float(f) if f.fract() == 0.0 => Some(*f as i64), _ => None }
    }
}

/// Escape a string exactly as Python json.dumps(..., ensure_ascii=False) does.
pub fn python_json_escape(s: &str) -> String {
    let mut out = String::with_capacity(s.len() + 2);
    for ch in s.chars() {
        match ch {
            '"' => out.push_str("\\\""),
            '\\' => out.push_str("\\\\"),
            '\n' => out.push_str("\\n"),
            '\r' => out.push_str("\\r"),
            '\t' => out.push_str("\\t"),
            '\u{0008}' => out.push_str("\\b"),
            '\u{000c}' => out.push_str("\\f"),
            c if (c as u32) < 0x20 => out.push_str(&format!("\\u{:04x}", c as u32)),
            c => out.push(c),
        }
    }
    out
}

/// Standard JSON string escaping (for stdout objects).
pub fn json_escape(s: &str) -> String {
    python_json_escape(s)
}

pub fn json_write(v: &Json) -> String {
    let mut out = String::new();
    write_json(v, &mut out);
    out
}

fn write_json(v: &Json, out: &mut String) {
    match v {
        Json::Null => out.push_str("null"),
        Json::Bool(b) => out.push_str(if *b { "true" } else { "false" }),
        Json::Int(n) => out.push_str(&n.to_string()),
        Json::Float(f) => {
            if f.is_finite() {
                out.push_str(&format!("{}", f));
            } else {
                out.push_str("null");
            }
        }
        Json::Str(s) => {
            out.push('"');
            out.push_str(&json_escape(s));
            out.push('"');
        }
        Json::Arr(items) => {
            out.push('[');
            for (i, it) in items.iter().enumerate() {
                if i > 0 { out.push(','); }
                write_json(it, out);
            }
            out.push(']');
        }
        Json::Obj(pairs) => {
            out.push('{');
            for (i, (k, val)) in pairs.iter().enumerate() {
                if i > 0 { out.push(','); }
                out.push('"');
                out.push_str(&json_escape(k));
                out.push_str("\":");
                write_json(val, out);
            }
            out.push('}');
        }
    }
}

pub fn jstr(s: &str) -> Json { Json::Str(s.to_string()) }
pub fn jobj(pairs: Vec<(&str, Json)>) -> Json {
    Json::Obj(pairs.into_iter().map(|(k, v)| (k.to_string(), v)).collect())
}

struct JsonParser<'a> {
    chars: Vec<char>,
    pos: usize,
    _src: &'a str,
}

impl<'a> JsonParser<'a> {
    fn new(src: &'a str) -> Self {
        JsonParser { chars: src.chars().collect(), pos: 0, _src: src }
    }
    fn peek(&self) -> Option<char> { self.chars.get(self.pos).copied() }
    fn bump(&mut self) -> Option<char> {
        let c = self.peek();
        if c.is_some() { self.pos += 1; }
        c
    }
    fn skip_ws(&mut self) {
        while matches!(self.peek(), Some(' ') | Some('\t') | Some('\n') | Some('\r')) { self.pos += 1; }
    }
    fn expect(&mut self, c: char) -> Result<(), String> {
        self.skip_ws();
        if self.bump() == Some(c) { Ok(()) } else { Err(format!("expected '{}' at offset {}", c, self.pos)) }
    }
    fn parse_value(&mut self) -> Result<Json, String> {
        self.skip_ws();
        match self.peek() {
            Some('{') => self.parse_object(),
            Some('[') => self.parse_array(),
            Some('"') => Ok(Json::Str(self.parse_string()?)),
            Some('t') => self.parse_lit("true", Json::Bool(true)),
            Some('f') => self.parse_lit("false", Json::Bool(false)),
            Some('n') => self.parse_lit("null", Json::Null),
            Some(c) if c == '-' || c.is_ascii_digit() => self.parse_number(),
            other => Err(format!("unexpected character {:?} at offset {}", other, self.pos)),
        }
    }
    fn parse_lit(&mut self, lit: &str, val: Json) -> Result<Json, String> {
        for c in lit.chars() {
            if self.bump() != Some(c) { return Err(format!("invalid literal at offset {}", self.pos)); }
        }
        Ok(val)
    }
    fn parse_number(&mut self) -> Result<Json, String> {
        let start = self.pos;
        if self.peek() == Some('-') { self.pos += 1; }
        while matches!(self.peek(), Some(c) if c.is_ascii_digit()) { self.pos += 1; }
        let mut is_float = false;
        if self.peek() == Some('.') {
            is_float = true;
            self.pos += 1;
            while matches!(self.peek(), Some(c) if c.is_ascii_digit()) { self.pos += 1; }
        }
        if matches!(self.peek(), Some('e') | Some('E')) {
            is_float = true;
            self.pos += 1;
            if matches!(self.peek(), Some('+') | Some('-')) { self.pos += 1; }
            while matches!(self.peek(), Some(c) if c.is_ascii_digit()) { self.pos += 1; }
        }
        let text: String = self.chars[start..self.pos].iter().collect();
        if text.is_empty() || text == "-" { return Err("invalid number".to_string()); }
        if is_float {
            text.parse::<f64>().map(Json::Float).map_err(|e| e.to_string())
        } else {
            text.parse::<i64>().map(Json::Int).map_err(|e| e.to_string())
        }
    }
    fn parse_hex4(&mut self) -> Result<u32, String> {
        let mut v: u32 = 0;
        for _ in 0..4 {
            let c = self.bump().ok_or("truncated \\u escape")?;
            let d = c.to_digit(16).ok_or("invalid \\u escape")?;
            v = v * 16 + d;
        }
        Ok(v)
    }
    fn parse_string(&mut self) -> Result<String, String> {
        if self.bump() != Some('"') { return Err("expected string".to_string()); }
        let mut out = String::new();
        loop {
            let c = self.bump().ok_or("unterminated string")?;
            match c {
                '"' => return Ok(out),
                '\\' => {
                    let e = self.bump().ok_or("unterminated escape")?;
                    match e {
                        '"' => out.push('"'),
                        '\\' => out.push('\\'),
                        '/' => out.push('/'),
                        'b' => out.push('\u{0008}'),
                        'f' => out.push('\u{000c}'),
                        'n' => out.push('\n'),
                        'r' => out.push('\r'),
                        't' => out.push('\t'),
                        'u' => {
                            let hi = self.parse_hex4()?;
                            if (0xD800..0xDC00).contains(&hi) {
                                if self.bump() != Some('\\') || self.bump() != Some('u') {
                                    return Err("invalid surrogate pair".to_string());
                                }
                                let lo = self.parse_hex4()?;
                                if !(0xDC00..0xE000).contains(&lo) {
                                    return Err("invalid low surrogate".to_string());
                                }
                                let cp = 0x10000 + ((hi - 0xD800) << 10) + (lo - 0xDC00);
                                out.push(char::from_u32(cp).ok_or("invalid code point")?);
                            } else if (0xDC00..0xE000).contains(&hi) {
                                return Err("lone low surrogate".to_string());
                            } else {
                                out.push(char::from_u32(hi).ok_or("invalid code point")?);
                            }
                        }
                        _ => return Err(format!("invalid escape '\\{}'", e)),
                    }
                }
                c if (c as u32) < 0x20 => return Err("unescaped control character in string".to_string()),
                c => out.push(c),
            }
        }
    }
    fn parse_array(&mut self) -> Result<Json, String> {
        self.bump();
        let mut items = Vec::new();
        self.skip_ws();
        if self.peek() == Some(']') { self.pos += 1; return Ok(Json::Arr(items)); }
        loop {
            items.push(self.parse_value()?);
            self.skip_ws();
            match self.bump() {
                Some(',') => continue,
                Some(']') => return Ok(Json::Arr(items)),
                other => return Err(format!("expected ',' or ']' got {:?}", other)),
            }
        }
    }
    fn parse_object(&mut self) -> Result<Json, String> {
        self.bump();
        let mut pairs = Vec::new();
        self.skip_ws();
        if self.peek() == Some('}') { self.pos += 1; return Ok(Json::Obj(pairs)); }
        loop {
            self.skip_ws();
            let key = self.parse_string()?;
            self.expect(':')?;
            let val = self.parse_value()?;
            pairs.push((key, val));
            self.skip_ws();
            match self.bump() {
                Some(',') => continue,
                Some('}') => return Ok(Json::Obj(pairs)),
                other => return Err(format!("expected ',' or '}}' got {:?}", other)),
            }
        }
    }
}

pub fn parse_json(src: &str) -> Result<Json, String> {
    let mut p = JsonParser::new(src);
    let v = p.parse_value()?;
    p.skip_ws();
    if p.pos != p.chars.len() {
        return Err(format!("trailing data at offset {}", p.pos));
    }
    Ok(v)
}

// ---------------------------------------------------------------- records

#[derive(Debug, Clone)]
pub struct Record {
    pub id: String,
    pub source: String,
    pub path: String,
    pub sha256: String,
    pub line: i64,
    pub domain: String,
    pub expression: String,
    pub status: String,
}

pub fn read_jsonl(path: &Path) -> Result<Vec<Record>, String> {
    let content = fs::read_to_string(path).map_err(|e| format!("cannot read {}: {}", path.display(), e))?;
    let mut records = Vec::new();
    for (idx, line) in content.split_terminator('\n').enumerate() {
        let line = line.strip_suffix('\r').unwrap_or(line);
        if line.is_empty() {
            return Err(format!("empty line {} in {}", idx + 1, path.display()));
        }
        let v = parse_json(line).map_err(|e| format!("invalid JSON on line {}: {}", idx + 1, e))?;
        let get_str = |k: &str| -> Result<String, String> {
            v.get(k).and_then(|x| x.as_str()).map(|s| s.to_string())
                .ok_or_else(|| format!("record on line {} missing string field '{}'", idx + 1, k))
        };
        records.push(Record {
            id: get_str("id")?,
            source: get_str("source")?,
            path: get_str("path")?,
            sha256: get_str("sha256")?,
            line: v.get("line").and_then(|x| x.as_int())
                .ok_or_else(|| format!("record on line {} missing integer field 'line'", idx + 1))?,
            domain: get_str("domain")?,
            expression: get_str("expression")?,
            status: v.get("status").and_then(|x| x.as_str()).unwrap_or("candidate").to_string(),
        });
    }
    Ok(records)
}

/// Format one record exactly as Python json.dumps with default separators.
pub fn record_json_line(r: &Record) -> String {
    format!(
        "{{\"id\": \"{}\", \"source\": \"{}\", \"path\": \"{}\", \"sha256\": \"{}\", \"line\": {}, \"domain\": \"{}\", \"expression\": \"{}\", \"status\": \"{}\"}}",
        python_json_escape(&r.id),
        python_json_escape(&r.source),
        python_json_escape(&r.path),
        python_json_escape(&r.sha256),
        r.line,
        python_json_escape(&r.domain),
        python_json_escape(&r.expression),
        python_json_escape(&r.status),
    )
}

// ---------------------------------------------------------------- XML (v1 fixed shape)

#[derive(Debug, Clone)]
pub struct XmlElem {
    pub tag: String,
    pub attrs: Vec<(String, String)>,
    pub children: Vec<XmlElem>,
    pub text: String,
}

impl XmlElem {
    pub fn attr(&self, name: &str) -> Option<&str> {
        self.attrs.iter().find(|(k, _)| k == name).map(|(_, v)| v.as_str())
    }
    pub fn child(&self, tag: &str) -> Option<&XmlElem> {
        self.children.iter().find(|c| c.tag == tag)
    }
    pub fn child_text(&self, tag: &str) -> Option<String> {
        self.child(tag).map(|c| c.text.clone())
    }
    pub fn children_named<'a>(&'a self, tag: &'a str) -> impl Iterator<Item = &'a XmlElem> + 'a {
        self.children.iter().filter(move |c| c.tag == tag)
    }
}

fn xml_unescape(s: &str) -> Result<String, String> {
    let mut out = String::with_capacity(s.len());
    let chars: Vec<char> = s.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        if chars[i] == '&' {
            let mut j = i + 1;
            let mut ent = String::new();
            while j < chars.len() && chars[j] != ';' {
                ent.push(chars[j]);
                j += 1;
                if ent.len() > 12 { return Err("entity reference too long".to_string()); }
            }
            if j >= chars.len() { return Err("unterminated entity reference".to_string()); }
            match ent.as_str() {
                "amp" => out.push('&'),
                "lt" => out.push('<'),
                "gt" => out.push('>'),
                "quot" => out.push('"'),
                "apos" => out.push('\''),
                _ if ent.starts_with("#x") || ent.starts_with("#X") => {
                    let cp = u32::from_str_radix(&ent[2..], 16).map_err(|_| "bad numeric entity".to_string())?;
                    out.push(char::from_u32(cp).ok_or("bad numeric entity")?);
                }
                _ if ent.starts_with('#') => {
                    let cp: u32 = ent[1..].parse().map_err(|_| "bad numeric entity".to_string())?;
                    out.push(char::from_u32(cp).ok_or("bad numeric entity")?);
                }
                _ => return Err(format!("unknown entity &{};", ent)),
            }
            i = j + 1;
        } else {
            out.push(chars[i]);
            i += 1;
        }
    }
    Ok(out)
}

struct XmlParser {
    chars: Vec<char>,
    pos: usize,
}

impl XmlParser {
    fn new(src: &str) -> Self { XmlParser { chars: src.chars().collect(), pos: 0 } }
    fn peek(&self) -> Option<char> { self.chars.get(self.pos).copied() }
    fn starts_with(&self, s: &str) -> bool {
        let sc: Vec<char> = s.chars().collect();
        if self.pos + sc.len() > self.chars.len() { return false; }
        self.chars[self.pos..self.pos + sc.len()] == sc[..]
    }
    fn consume(&mut self, s: &str) -> bool {
        if self.starts_with(s) { self.pos += s.chars().count(); true } else { false }
    }
    fn skip_misc(&mut self) -> Result<(), String> {
        loop {
            while matches!(self.peek(), Some(c) if c.is_whitespace()) { self.pos += 1; }
            if self.consume("<?") {
                self.skip_until("?>")?;
            } else if self.consume("<!--") {
                self.skip_until("-->")?;
            } else if self.consume("<!DOCTYPE") || self.consume("<!doctype") {
                self.skip_until(">")?;
            } else {
                return Ok(());
            }
        }
    }
    fn skip_until(&mut self, end: &str) -> Result<(), String> {
        while self.pos < self.chars.len() {
            if self.consume(end) { return Ok(()); }
            self.pos += 1;
        }
        Err(format!("unterminated section, expected '{}'", end))
    }
    fn parse_name(&mut self) -> Result<String, String> {
        let mut name = String::new();
        while let Some(c) = self.peek() {
            if c.is_alphanumeric() || matches!(c, '_' | '-' | '.' | ':') {
                name.push(c);
                self.pos += 1;
            } else { break; }
        }
        if name.is_empty() { Err(format!("expected element name at offset {}", self.pos)) } else { Ok(name) }
    }
    fn parse_element(&mut self) -> Result<XmlElem, String> {
        if !self.consume("<") { return Err(format!("expected '<' at offset {}", self.pos)); }
        let tag = self.parse_name()?;
        let mut attrs: Vec<(String, String)> = Vec::new();
        loop {
            while matches!(self.peek(), Some(c) if c.is_whitespace()) { self.pos += 1; }
            if self.consume("/>") {
                return Ok(XmlElem { tag, attrs, children: Vec::new(), text: String::new() });
            }
            if self.consume(">") { break; }
            let aname = self.parse_name()?;
            while matches!(self.peek(), Some(c) if c.is_whitespace()) { self.pos += 1; }
            if !self.consume("=") { return Err(format!("expected '=' after attribute {}", aname)); }
            while matches!(self.peek(), Some(c) if c.is_whitespace()) { self.pos += 1; }
            let quote = self.bump_req().ok_or("unterminated tag")?;
            if quote != '"' && quote != '\'' { return Err("attribute value must be quoted".to_string()); }
            let mut raw = String::new();
            loop {
                let c = self.bump_req().ok_or("unterminated attribute value")?;
                if c == quote { break; }
                if c == '<' { return Err("'<' in attribute value".to_string()); }
                raw.push(c);
            }
            let value = xml_unescape(&raw)?;
            if attrs.iter().any(|(k, _)| *k == aname) {
                return Err(format!("duplicate attribute {}", aname));
            }
            attrs.push((aname, value));
        }
        let mut children: Vec<XmlElem> = Vec::new();
        let mut text = String::new();
        loop {
            if self.pos >= self.chars.len() {
                return Err(format!("unterminated element <{}>", tag));
            }
            if self.consume("</") {
                let close = self.parse_name()?;
                while matches!(self.peek(), Some(c) if c.is_whitespace()) { self.pos += 1; }
                if !self.consume(">") { return Err("expected '>' in closing tag".to_string()); }
                if close != tag { return Err(format!("mismatched closing tag </{}> for <{}>", close, tag)); }
                return Ok(XmlElem { tag, attrs, children, text });
            } else if self.consume("<!--") {
                self.skip_until("-->")?;
            } else if self.consume("<![CDATA[") {
                let start = self.pos;
                self.skip_until("]]>")?;
                let raw: String = self.chars[start..self.pos - 3].iter().collect();
                text.push_str(&raw);
            } else if self.consume("<?") {
                self.skip_until("?>")?;
            } else if self.peek() == Some('<') {
                children.push(self.parse_element()?);
            } else {
                let start = self.pos;
                while self.pos < self.chars.len() && self.chars[self.pos] != '<' {
                    self.pos += 1;
                }
                let raw: String = self.chars[start..self.pos].iter().collect();
                text.push_str(&xml_unescape(&raw)?);
            }
        }
    }
    fn bump_req(&mut self) -> Option<char> {
        let c = self.peek();
        if c.is_some() { self.pos += 1; }
        c
    }
}

pub fn parse_xml(src: &str) -> Result<XmlElem, String> {
    let mut p = XmlParser::new(src);
    p.skip_misc()?;
    let root = p.parse_element()?;
    p.skip_misc()?;
    if p.pos != p.chars.len() {
        return Err("trailing content after root element".to_string());
    }
    Ok(root)
}

/// Escape element text the way ElementTree does (&, <, >, and CR as a char ref).
pub fn xml_escape_text(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for c in s.chars() {
        match c {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '\r' => out.push_str("&#13;"),
            c => out.push(c),
        }
    }
    out
}

/// Escape an attribute value the way ElementTree does.
pub fn xml_escape_attr(s: &str) -> String {
    let mut out = String::with_capacity(s.len());
    for c in s.chars() {
        match c {
            '&' => out.push_str("&amp;"),
            '<' => out.push_str("&lt;"),
            '>' => out.push_str("&gt;"),
            '"' => out.push_str("&quot;"),
            '\r' => out.push_str("&#13;"),
            '\n' => out.push_str("&#10;"),
            '\t' => out.push_str("&#09;"),
            c => out.push(c),
        }
    }
    out
}

// ---------------------------------------------------------------- dependency graph

/// Kahn topological sort with document-order tie-breaking.
/// Returns Err with the sorted ids left in/behind a cycle when the graph is cyclic.
pub fn topo_sort(ids: &[String], deps: &HashMap<String, Vec<String>>) -> Result<Vec<String>, Vec<String>> {
    let mut indeg: HashMap<String, usize> = HashMap::new();
    let mut dependents: HashMap<String, Vec<String>> = HashMap::new();
    for id in ids {
        let d = deps.get(id).cloned().unwrap_or_default();
        indeg.insert(id.clone(), d.len());
        for dep in d {
            dependents.entry(dep).or_default().push(id.clone());
        }
    }
    let mut order: Vec<String> = Vec::new();
    let mut done: HashSet<String> = HashSet::new();
    while order.len() < ids.len() {
        let mut progressed = false;
        for id in ids {
            if done.contains(id) { continue; }
            if indeg.get(id).copied().unwrap_or(0) == 0 {
                done.insert(id.clone());
                order.push(id.clone());
                progressed = true;
                if let Some(list) = dependents.get(id) {
                    for nxt in list {
                        if let Some(v) = indeg.get_mut(nxt) { *v -= 1; }
                    }
                }
            }
        }
        if !progressed {
            let mut remaining: Vec<String> = ids.iter().filter(|i| !done.contains(*i)).cloned().collect();
            remaining.sort();
            return Err(remaining);
        }
    }
    Ok(order)
}

// ---------------------------------------------------------------- errors / exit codes

struct CmdErr { code: i32, message: String }
impl CmdErr {
    fn usage(m: impl Into<String>) -> Self { CmdErr { code: 2, message: m.into() } }
    fn logic(m: impl Into<String>) -> Self { CmdErr { code: 1, message: m.into() } }
}

fn print_json(v: &Json) {
    println!("{}", json_write(v));
}

fn fail(err: CmdErr, extra: Vec<(&str, Json)>) -> i32 {
    let mut pairs: Vec<(&str, Json)> = vec![("error", jstr(&err.message))];
    pairs.extend(extra);
    print_json(&jobj(pairs));
    err.code
}

// ---------------------------------------------------------------- commands

const EXTENSIONS: [&str; 7] = ["txt", "tex", "wl", "m", "lean", "als", "curry"];

fn collect_files(dir: &Path, out: &mut Vec<PathBuf>) -> Result<(), CmdErr> {
    let entries = fs::read_dir(dir).map_err(|e| CmdErr::usage(format!("cannot read directory {}: {}", dir.display(), e)))?;
    let mut paths: Vec<PathBuf> = entries.filter_map(|e| e.ok().map(|e| e.path())).collect();
    paths.sort();
    for p in paths {
        let md = fs::metadata(&p).map_err(|e| CmdErr::usage(format!("cannot stat {}: {}", p.display(), e)))?;
        if md.is_dir() {
            collect_files(&p, out)?;
        } else if md.is_file() {
            if let Some(ext) = p.extension().and_then(|e| e.to_str()) {
                if EXTENSIONS.contains(&ext.to_ascii_lowercase().as_str()) {
                    out.push(p);
                }
            }
        }
    }
    Ok(())
}

fn cmd_scan(args: &[String]) -> i32 {
    if args.len() < 2 {
        return fail(CmdErr::usage("usage: monster scan <root> <out.jsonl> [--max-hits N]"), vec![]);
    }
    let root_arg = PathBuf::from(&args[0]);
    let out_path = PathBuf::from(&args[1]);
    let mut max_hits: i64 = 1_000_000;
    let mut i = 2;
    while i < args.len() {
        if args[i] == "--max-hits" {
            if i + 1 >= args.len() {
                return fail(CmdErr::usage("--max-hits requires a value"), vec![]);
            }
            match args[i + 1].parse::<i64>() {
                Ok(n) if n >= 0 => max_hits = n,
                _ => return fail(CmdErr::usage("--max-hits must be a non-negative integer"), vec![]),
            }
            i += 2;
        } else {
            return fail(CmdErr::usage(format!("unknown scan argument: {}", args[i])), vec![]);
        }
    }
    let root = match fs::canonicalize(&root_arg) {
        Ok(p) => p,
        Err(e) => return fail(CmdErr::usage(format!("cannot resolve root {}: {}", root_arg.display(), e)), vec![]),
    };
    let mut files: Vec<PathBuf> = Vec::new();
    if let Err(e) = collect_files(&root, &mut files) { return fail(e, vec![]); }
    // bridge.py sorts Path objects; Python pathlib ordering compares
    // path components lexicographically, and so does Rust's Path Ord.
    files.sort();
    let mut dest = match fs::File::create(&out_path) {
        Ok(f) => f,
        Err(e) => return fail(CmdErr::usage(format!("cannot create {}: {}", out_path.display(), e)), vec![]),
    };
    let mut count: i64 = 0;
    for (idx, path) in files.iter().enumerate() {
        let source = format!("s{}", idx + 1);
        let bytes = match fs::read(path) {
            Ok(b) => b,
            Err(e) => return fail(CmdErr::usage(format!("cannot read {}: {}", path.display(), e)), vec![]),
        };
        let checksum = sha256_hex(&bytes);
        let rel = path.strip_prefix(&root).unwrap_or(path);
        let rel_str = rel.to_string_lossy().replace('\\', "/");
        let text_raw = String::from_utf8_lossy(&bytes).into_owned();
        let text = text_raw.replace("\r\n", "\n").replace('\r', "\n");
        if text.is_empty() { continue; }
        for (lineno, piece) in text.split_inclusive('\n').enumerate() {
            let expression = piece.trim_end_matches('\n');
            let domains = classify_line(expression);
            for domain in domains {
                if count >= max_hits {
                    print_json(&jobj(vec![("command", jstr("scan")), ("records", Json::Int(count)), ("output", jstr(&out_path.to_string_lossy()))]));
                    return 0;
                }
                count += 1;
                let rec = Record {
                    id: format!("c{}", count),
                    source: source.clone(),
                    path: rel_str.clone(),
                    sha256: checksum.clone(),
                    line: (lineno + 1) as i64,
                    domain: domain.to_string(),
                    expression: expression.to_string(),
                    status: "candidate".to_string(),
                };
                if writeln!(dest, "{}", record_json_line(&rec)).is_err() {
                    return fail(CmdErr::usage("failed writing output file"), vec![]);
                }
            }
        }
    }
    print_json(&jobj(vec![("command", jstr("scan")), ("records", Json::Int(count)), ("output", jstr(&out_path.to_string_lossy()))]));
    0
}

fn cmd_normalize(args: &[String]) -> i32 {
    if args.len() != 2 {
        return fail(CmdErr::usage("usage: monster normalize <in.jsonl> <out.xml>"), vec![]);
    }
    let records = match read_jsonl(Path::new(&args[0])) {
        Ok(r) => r,
        Err(e) => return fail(CmdErr::logic(e), vec![]),
    };
    // bridge.py export(): first-appearance source order + collision check.
    let mut seen: Vec<(String, String, String)> = Vec::new();
    let mut seen_map: HashMap<String, (String, String)> = HashMap::new();
    for r in &records {
        let key = (r.path.clone(), r.sha256.clone());
        if let Some(prev) = seen_map.get(&r.source) {
            if *prev != key {
                return fail(CmdErr::logic("source identifier collision"), vec![]);
            }
        } else {
            seen_map.insert(r.source.clone(), key.clone());
            seen.push((r.source.clone(), key.0, key.1));
        }
    }
    let mut xml = String::new();
    xml.push_str("<?xml version='1.0' encoding='utf-8'?>\n");
    xml.push_str("<research version=\"1\">\n");
    for (sid, path, sha) in &seen {
        xml.push_str(&format!("  <source id=\"{}\" path=\"{}\" sha256=\"{}\" />\n",
            xml_escape_attr(sid), xml_escape_attr(path), xml_escape_attr(sha)));
    }
    for r in &records {
        xml.push_str(&format!("  <claim id=\"{}\" source=\"{}\" line=\"{}\" domain=\"{}\" status=\"candidate\">\n",
            xml_escape_attr(&r.id), xml_escape_attr(&r.source), r.line, xml_escape_attr(&r.domain)));
        if r.expression.is_empty() {
            xml.push_str("    <expression />\n");
        } else {
            xml.push_str(&format!("    <expression>{}</expression>\n", xml_escape_text(&r.expression)));
        }
        xml.push_str("    <assumptions>Uninterpreted extracted text; not a proven formula</assumptions>\n");
        xml.push_str("  </claim>\n");
    }
    xml.push_str("</research>");
    if let Err(e) = fs::write(&args[1], &xml) {
        return fail(CmdErr::usage(format!("cannot write {}: {}", args[1], e)), vec![]);
    }
    print_json(&jobj(vec![("command", jstr("normalize")), ("claims", Json::Int(records.len() as i64)), ("output", jstr(&args[1]))]));
    0
}

fn domain_counts(records: &[Record]) -> Json {
    let mut counts: BTreeMap<String, i64> = BTreeMap::new();
    for (name, _) in FAMILIES.iter() { counts.insert(name.to_string(), 0); }
    for r in records { *counts.entry(r.domain.clone()).or_insert(0) += 1; }
    Json::Obj(counts.into_iter().map(|(k, v)| (k, Json::Int(v))).collect())
}

fn cmd_classify(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster classify <in.jsonl>"), vec![]);
    }
    let records = match read_jsonl(Path::new(&args[0])) {
        Ok(r) => r,
        Err(e) => return fail(CmdErr::logic(e), vec![]),
    };
    let mut counts: BTreeMap<String, i64> = BTreeMap::new();
    for (name, _) in FAMILIES.iter() { counts.insert(name.to_string(), 0); }
    // Re-derive domains per scanned line: records sharing one
    // (source, path, line) are one line with several domain hits,
    // exactly as scan assigns them.
    let mut seen_lines: HashSet<(String, String, i64)> = HashSet::new();
    for r in &records {
        let key = (r.source.clone(), r.path.clone(), r.line);
        if !seen_lines.insert(key) { continue; }
        for d in classify_line(&r.expression) {
            *counts.get_mut(d).expect("family key present") += 1;
        }
    }
    let total: i64 = counts.values().sum();
    print_json(&jobj(vec![
        ("command", jstr("classify")),
        ("records", Json::Int(records.len() as i64)),
        ("total", Json::Int(total)),
        ("counts", Json::Obj(counts.into_iter().map(|(k, v)| (k, Json::Int(v))).collect())),
    ]));
    0
}

fn load_claims_xml(path: &str) -> Result<XmlElem, CmdErr> {
    let content = fs::read_to_string(path)
        .map_err(|e| CmdErr::usage(format!("cannot read {}: {}", path, e)))?;
    parse_xml(&content).map_err(|e| CmdErr::logic(format!("malformed XML: {}", e)))
}

const ALLOWED_STATUSES: [&str; 4] = ["candidate", "rejected", "bounded", "verified"];
const PROOF_TOOLS: [&str; 4] = ["lean", "coq", "agda", "isabelle"];

fn is_hex64(s: &str) -> bool {
    s.len() == 64 && s.chars().all(|c| c.is_ascii_hexdigit() && !c.is_ascii_uppercase())
}

/// bridge.py validate() semantics; returns claim count or the exact error message.
pub fn validate_claims(root: &XmlElem) -> Result<usize, String> {
    if root.tag != "research" || root.attr("version") != Some("1") {
        return Err("invalid root or schema version".to_string());
    }
    let sources: HashSet<&str> = root.children_named("source").filter_map(|s| s.attr("id")).collect();
    let claims: Vec<&XmlElem> = root.children_named("claim").collect();
    let ids: Vec<Option<&str>> = claims.iter().map(|c| c.attr("id")).collect();
    let id_set: HashSet<&str> = ids.iter().filter_map(|i| *i).collect();
    if ids.len() != id_set.len() || ids.iter().any(|i| i.map(|s| s.is_empty()).unwrap_or(true)) {
        return Err("duplicate or missing claim identifiers".to_string());
    }
    for c in &claims {
        let cid = c.attr("id").unwrap_or("");
        if !c.attr("source").map(|s| sources.contains(s)).unwrap_or(false) {
            return Err(format!("unknown source: {}", cid));
        }
        if !c.attr("status").map(|s| ALLOWED_STATUSES.contains(&s)).unwrap_or(false) {
            return Err(format!("invalid status: {}", cid));
        }
        let expr_ok = c.child_text("expression").map(|t| !t.is_empty()).unwrap_or(false);
        let asm_ok = c.child_text("assumptions").map(|t| !t.is_empty()).unwrap_or(false);
        if !expr_ok || !asm_ok {
            return Err(format!("missing expression/assumptions: {}", cid));
        }
        for d in c.children_named("dependency") {
            if !d.attr("ref").map(|r| id_set.contains(r)).unwrap_or(false) {
                return Err(format!("missing dependency: {}", cid));
            }
        }
        if c.attr("status") == Some("verified") {
            let ok = c.children_named("evidence").any(|e| {
                e.attr("tool").map(|t| PROOF_TOOLS.contains(&t)).unwrap_or(false)
                    && e.attr("status") == Some("verified")
                    && e.attr("artifact_sha256").map(is_hex64).unwrap_or(false)
            });
            if !ok {
                return Err(format!("unsubstantiated verified status: {}", cid));
            }
        }
    }
    Ok(claims.len())
}

fn cmd_verify(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster verify <claims.xml>"), vec![]);
    }
    let root = match load_claims_xml(&args[0]) {
        Ok(r) => r,
        Err(e) => {
            let code = e.code;
            print_json(&jobj(vec![("valid", Json::Bool(false)), ("error", jstr(&e.message))]));
            return code;
        }
    };
    match validate_claims(&root) {
        Ok(n) => {
            print_json(&jobj(vec![("valid", Json::Bool(true)), ("claims", Json::Int(n as i64))]));
            0
        }
        Err(msg) => {
            print_json(&jobj(vec![("valid", Json::Bool(false)), ("error", jstr(&msg))]));
            1
        }
    }
}

fn cmd_resolve(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster resolve <claims.xml>"), vec![]);
    }
    let root = match load_claims_xml(&args[0]) {
        Ok(r) => r,
        Err(e) => return fail(e, vec![]),
    };
    if root.tag != "research" || root.attr("version") != Some("1") {
        return fail(CmdErr::logic("invalid root or schema version"), vec![]);
    }
    let claims: Vec<&XmlElem> = root.children_named("claim").collect();
    let mut ids: Vec<String> = Vec::new();
    for c in &claims {
        match c.attr("id") {
            Some(id) if !id.is_empty() => ids.push(id.to_string()),
            _ => return fail(CmdErr::logic("duplicate or missing claim identifiers"), vec![]),
        }
    }
    let mut uniq = HashSet::new();
    for id in &ids {
        if !uniq.insert(id.clone()) {
            return fail(CmdErr::logic("duplicate or missing claim identifiers"), vec![]);
        }
    }
    let mut deps: HashMap<String, Vec<String>> = HashMap::new();
    for c in &claims {
        let cid = c.attr("id").unwrap_or("").to_string();
        let mut list: Vec<String> = Vec::new();
        for d in c.children_named("dependency") {
            match d.attr("ref") {
                Some(r) if uniq.contains(r) => list.push(r.to_string()),
                _ => return fail(CmdErr::logic(format!("missing dependency: {}", cid)), vec![]),
            }
        }
        deps.insert(cid, list);
    }
    match topo_sort(&ids, &deps) {
        Ok(order) => {
            let derivations: Vec<Json> = order.iter().map(|id| {
                jobj(vec![
                    ("claim", jstr(id)),
                    ("clause", jstr("dependency")),
                    ("dependencies", Json::Arr(deps.get(id).cloned().unwrap_or_default().iter().map(|d| jstr(d)).collect())),
                ])
            }).collect();
            print_json(&jobj(vec![
                ("command", jstr("resolve")),
                ("order", Json::Arr(order.iter().map(|i| jstr(i)).collect())),
                ("derivations", Json::Arr(derivations)),
            ]));
            0
        }
        Err(cycle_nodes) => {
            print_json(&jobj(vec![
                ("error", jstr("dependency cycle detected")),
                ("cycle", Json::Arr(cycle_nodes.iter().map(|i| jstr(i)).collect())),
            ]));
            1
        }
    }
}

fn cmd_evaluate(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster evaluate <in.jsonl>"), vec![]);
    }
    let records = match read_jsonl(Path::new(&args[0])) {
        Ok(r) => r,
        Err(e) => return fail(CmdErr::logic(e), vec![]),
    };
    let per_domain = domain_counts(&records);
    let mut per_source: BTreeMap<String, i64> = BTreeMap::new();
    let mut files: HashSet<String> = HashSet::new();
    for r in &records {
        *per_source.entry(r.source.clone()).or_insert(0) += 1;
        files.insert(r.path.clone());
    }
    print_json(&jobj(vec![
        ("command", jstr("evaluate")),
        ("records", Json::Int(records.len() as i64)),
        ("per_domain", per_domain),
        ("per_source", Json::Obj(per_source.into_iter().map(|(k, v)| (k, Json::Int(v))).collect())),
        ("distinct_files", Json::Int(files.len() as i64)),
    ]));
    0
}

/// Count items by kind for one family value in families.json.
/// Accepted shapes: an array of items, or an object holding an
/// "items"/"members"/"contracts" array. Item kind = its "kind" field,
/// "string" for bare strings, "object" for kindless objects.
pub fn family_kind_counts(value: &Json) -> Result<BTreeMap<String, i64>, String> {
    let items: &Vec<Json> = match value {
        Json::Arr(a) => a,
        Json::Obj(_) => {
            let mut found: Option<&Vec<Json>> = None;
            for key in ["items", "members", "contracts"] {
                if let Some(Json::Arr(a)) = value.get(key) { found = Some(a); break; }
            }
            found.ok_or("family entry has no items array")?
        }
        _ => return Err("family entry must be an array or an object".to_string()),
    };
    let mut counts: BTreeMap<String, i64> = BTreeMap::new();
    for item in items {
        let kind = match item {
            Json::Obj(_) => item.get("kind").and_then(|k| k.as_str()).unwrap_or("object").to_string(),
            Json::Str(_) => "string".to_string(),
            _ => return Err("family item must be an object or a string".to_string()),
        };
        *counts.entry(kind).or_insert(0) += 1;
    }
    Ok(counts)
}

pub fn contract_counts(doc: &Json) -> Result<BTreeMap<String, BTreeMap<String, i64>>, String> {
    let root = match doc.get("families") {
        Some(f) => f,
        None => doc,
    };
    let mut out: BTreeMap<String, BTreeMap<String, i64>> = BTreeMap::new();
    match root {
        Json::Obj(pairs) => {
            for (name, value) in pairs {
                out.insert(name.clone(), family_kind_counts(value)
                    .map_err(|e| format!("family '{}': {}", name, e))?);
            }
        }
        Json::Arr(entries) => {
            for entry in entries {
                let name = entry.get("name").or_else(|| entry.get("family"))
                    .and_then(|n| n.as_str()).ok_or("family entry missing 'name'")?;
                out.insert(name.to_string(), family_kind_counts(entry)
                    .map_err(|e| format!("family '{}': {}", name, e))?);
            }
        }
        _ => return Err("families document must be an object or an array".to_string()),
    }
    if out.is_empty() {
        return Err("families document contains no families".to_string());
    }
    Ok(out)
}

fn cmd_contract(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster contract <families.json>"), vec![]);
    }
    let content = match fs::read_to_string(&args[0]) {
        Ok(c) => c,
        Err(e) => return fail(CmdErr::usage(format!("cannot read {}: {}", args[0], e)), vec![]),
    };
    let doc = match parse_json(&content) {
        Ok(d) => d,
        Err(e) => return fail(CmdErr::logic(format!("malformed JSON: {}", e)), vec![]),
    };
    match contract_counts(&doc) {
        Ok(families) => {
            let fam_json = Json::Obj(families.iter().map(|(name, kinds)| {
                let total: i64 = kinds.values().sum();
                (name.clone(), jobj(vec![
                    ("total", Json::Int(total)),
                    ("by_kind", Json::Obj(kinds.iter().map(|(k, v)| (k.clone(), Json::Int(*v))).collect())),
                ]))
            }).collect());
            print_json(&jobj(vec![("command", jstr("contract")), ("families", fam_json)]));
            0
        }
        Err(e) => fail(CmdErr::logic(e), vec![]),
    }
}

fn home_dir() -> PathBuf {
    std::env::var_os("HOME").map(PathBuf::from).unwrap_or_else(|| PathBuf::from("/home/hatch"))
}

fn cmd_counterexample(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster counterexample <module.als>"), vec![]);
    }
    let module_path = PathBuf::from(&args[0]);
    let stem = module_path.file_stem().and_then(|s| s.to_str()).unwrap_or("").to_string();
    let file_name = module_path.file_name().and_then(|s| s.to_str()).unwrap_or("").to_string();
    let mut candidates: Vec<PathBuf> = vec![
        PathBuf::from("alloy/results.txt"),
        PathBuf::from("../alloy/results.txt"),
        home_dir().join("workspace/monster-engine/alloy/results.txt"),
    ];
    candidates.dedup();
    for cand in &candidates {
        if let Ok(content) = fs::read_to_string(cand) {
            for line in content.lines() {
                let l = line.trim();
                if !l.is_empty() && (l.contains(&stem) && !stem.is_empty() || l.contains(&file_name) && !file_name.is_empty()) {
                    print_json(&jobj(vec![
                        ("command", jstr("counterexample")),
                        ("module", jstr(&args[0])),
                        ("status", jstr("BOUNDED")),
                        ("result", jstr(l)),
                        ("source", jstr(&cand.to_string_lossy())),
                    ]));
                    return 0;
                }
            }
            print_json(&jobj(vec![
                ("command", jstr("counterexample")),
                ("module", jstr(&args[0])),
                ("status", jstr("UNSUPPORTED")),
                ("reason", jstr(&format!("no recorded Alloy result for this module in {}", cand.display()))),
            ]));
            return 1;
        }
    }
    print_json(&jobj(vec![
        ("command", jstr("counterexample")),
        ("module", jstr(&args[0])),
        ("status", jstr("UNSUPPORTED")),
        ("reason", jstr("no Alloy results file (alloy/results.txt) found; no solver run was attempted")),
    ]));
    1
}

fn cmd_report(args: &[String]) -> i32 {
    if args.len() != 1 {
        return fail(CmdErr::usage("usage: monster report <dir>"), vec![]);
    }
    let base = PathBuf::from(&args[0]);
    if !base.is_dir() {
        return fail(CmdErr::usage(format!("not a directory: {}", args[0])), vec![]);
    }
    let mut artifacts: Vec<Json> = Vec::new();
    let add_file = |rel: &str, full: &Path, artifacts: &mut Vec<Json>| {
        if full.is_file() {
            let sha = fs::read(full).map(|b| sha256_hex(&b)).unwrap_or_default();
            artifacts.push(jobj(vec![
                ("path", jstr(rel)),
                ("present", Json::Bool(true)),
                ("sha256", jstr(&sha)),
            ]));
        } else {
            artifacts.push(jobj(vec![
                ("path", jstr(rel)),
                ("present", Json::Bool(false)),
                ("sha256", Json::Null),
            ]));
        }
    };
    // reports/*.md
    let reports_dir = base.join("reports");
    let mut md_files: Vec<PathBuf> = Vec::new();
    if reports_dir.is_dir() {
        if let Ok(rd) = fs::read_dir(&reports_dir) {
            for e in rd.flatten() {
                let p = e.path();
                if p.is_file() && p.extension().and_then(|x| x.to_str()) == Some("md") {
                    md_files.push(p);
                }
            }
        }
    }
    md_files.sort();
    if md_files.is_empty() {
        artifacts.push(jobj(vec![
            ("path", jstr("reports/*.md")),
            ("present", Json::Bool(false)),
            ("sha256", Json::Null),
        ]));
    } else {
        for p in &md_files {
            let name = p.file_name().unwrap_or_default().to_string_lossy().to_string();
            add_file(&format!("reports/{}", name), p, &mut artifacts);
        }
    }
    add_file("alloy/results.txt", &base.join("alloy/results.txt"), &mut artifacts);
    // benchmarks/*.txt
    let bench_dir = base.join("benchmarks");
    let mut txt_files: Vec<PathBuf> = Vec::new();
    if bench_dir.is_dir() {
        if let Ok(rd) = fs::read_dir(&bench_dir) {
            for e in rd.flatten() {
                let p = e.path();
                if p.is_file() && p.extension().and_then(|x| x.to_str()) == Some("txt") {
                    txt_files.push(p);
                }
            }
        }
    }
    txt_files.sort();
    if txt_files.is_empty() {
        artifacts.push(jobj(vec![
            ("path", jstr("benchmarks/*.txt")),
            ("present", Json::Bool(false)),
            ("sha256", Json::Null),
        ]));
    } else {
        for p in &txt_files {
            let name = p.file_name().unwrap_or_default().to_string_lossy().to_string();
            add_file(&format!("benchmarks/{}", name), p, &mut artifacts);
        }
    }
    let present = artifacts.iter().filter(|a| a.get("present") == Some(&Json::Bool(true))).count();
    print_json(&jobj(vec![
        ("command", jstr("report")),
        ("directory", jstr(&args[0])),
        ("artifacts", Json::Arr(artifacts)),
        ("present", Json::Int(present as i64)),
    ]));
    0
}

// ---------------------------------------------------------------- doctor

fn clean_version_output(raw: &str) -> String {
    // Strip ANSI escape sequences, then prefer a line mentioning
    // "version"; otherwise take the first non-empty line.
    let mut cleaned_lines: Vec<String> = Vec::new();
    for line in raw.lines() {
        let mut s = String::new();
        let mut chars = line.chars();
        while let Some(c) = chars.next() {
            if c == '\u{001b}' {
                // skip until final byte of the escape sequence
                for n in chars.by_ref() {
                    if n.is_ascii_alphabetic() || n == 'm' { break; }
                }
            } else {
                s.push(c);
            }
        }
        let s = s.trim().to_string();
        if !s.is_empty() { cleaned_lines.push(s); }
    }
    for l in &cleaned_lines {
        if l.to_lowercase().contains("version") { return l.clone(); }
    }
    cleaned_lines.into_iter().next().unwrap_or_default()
}

fn run_with_timeout(cmd: &mut Command, timeout: Duration) -> Option<String> {
    cmd.stdout(Stdio::piped()).stderr(Stdio::piped());
    let mut child = cmd.spawn().ok()?;
    let start = Instant::now();
    loop {
        match child.try_wait() {
            Ok(Some(_)) => {
                let out = child.wait_with_output().ok()?;
                let stdout = String::from_utf8_lossy(&out.stdout).into_owned();
                if !stdout.trim().is_empty() {
                    return Some(clean_version_output(&stdout));
                }
                let stderr = String::from_utf8_lossy(&out.stderr).into_owned();
                if !stderr.trim().is_empty() {
                    return Some(clean_version_output(&stderr));
                }
                return Some(String::new());
            }
            Ok(None) => {
                if start.elapsed() > timeout {
                    let _ = child.kill();
                    let _ = child.wait();
                    return None;
                }
                std::thread::sleep(Duration::from_millis(20));
            }
            Err(_) => return None,
        }
    }
}

fn probe_cmd(prog: &str, arg: &str) -> (bool, Option<String>) {
    let mut c = Command::new(prog);
    c.arg(arg);
    match run_with_timeout(&mut c, Duration::from_secs(3)) {
        Some(v) => (true, if v.is_empty() { None } else { Some(v) }),
        None => (false, None),
    }
}

fn probe_path_binary(path: &Path, arg: &str) -> (bool, Option<String>) {
    if !path.is_file() {
        return (false, None);
    }
    let mut c = Command::new(path);
    c.arg(arg);
    match run_with_timeout(&mut c, Duration::from_secs(3)) {
        Some(v) => (true, if v.is_empty() { None } else { Some(v) }),
        None => (true, None),
    }
}

fn find_pakcs() -> Option<PathBuf> {
    if let Ok(out) = Command::new("which").arg("pakcs").output() {
        if out.status.success() {
            let s = String::from_utf8_lossy(&out.stdout).trim().to_string();
            if !s.is_empty() { return Some(PathBuf::from(s)); }
        }
    }
    let tools = home_dir().join("workspace/.tools");
    fn walk(dir: &Path, depth: usize) -> Option<PathBuf> {
        if depth > 3 { return None; }
        if let Ok(rd) = fs::read_dir(dir) {
            for e in rd.flatten() {
                let p = e.path();
                if p.is_file() && p.file_name().and_then(|n| n.to_str()) == Some("pakcs") {
                    return Some(p);
                }
                if p.is_dir() {
                    if let Some(found) = walk(&p, depth + 1) { return Some(found); }
                }
            }
        }
        None
    }
    walk(&tools, 0)
}

fn tool_json(avail: bool, version: Option<String>) -> Json {
    jobj(vec![
        ("available", Json::Bool(avail)),
        ("version", version.map(|v| Json::Str(v)).unwrap_or(Json::Null)),
    ])
}

fn cmd_doctor(_args: &[String]) -> i32 {
    let home = home_dir();
    let elan_bin = home.join(".elan/bin");
    let mut tools: Vec<(String, Json)> = Vec::new();
    let (a, v) = probe_cmd("lean", "--version");
    let (a, v) = if a { (a, v) } else { probe_path_binary(&elan_bin.join("lean"), "--version") };
    tools.push(("lean".to_string(), tool_json(a, v)));
    let (a, v) = probe_cmd("lake", "--version");
    let (a, v) = if a { (a, v) } else { probe_path_binary(&elan_bin.join("lake"), "--version") };
    tools.push(("lake".to_string(), tool_json(a, v)));
    let (a, v) = probe_cmd("cargo", "--version");
    tools.push(("cargo".to_string(), tool_json(a, v)));
    let (a, v) = probe_cmd("rustc", "--version");
    tools.push(("rustc".to_string(), tool_json(a, v)));
    let (a, v) = probe_cmd("gcc", "--version");
    tools.push(("gcc".to_string(), tool_json(a, v)));
    let (a, v) = probe_cmd("java", "-version");
    let (a, v) = if a { (a, v) } else {
        // Temurin JDK kept under ~/workspace/.tools on this machine.
        let mut found = (false, None);
        if let Ok(rd) = fs::read_dir(home.join("workspace/.tools")) {
            for e in rd.flatten() {
                let p = e.path().join("bin/java");
                if p.is_file() {
                    found = probe_path_binary(&p, "-version");
                    if found.0 { break; }
                }
            }
        }
        found
    };
    tools.push(("java".to_string(), tool_json(a, v)));
    let jar = PathBuf::from("/home/hatch/workspace/hcalc-counter/alloy.jar");
    let jar_alt = home.join("workspace/hcalc-counter/alloy.jar");
    let jar_present = jar.is_file() || jar_alt.is_file();
    tools.push(("alloy_jar".to_string(), tool_json(jar_present, None)));
    let uiua_path = home.join("workspace/.tools/uiua/uiua");
    let (a, v) = probe_path_binary(&uiua_path, "--version");
    tools.push(("uiua".to_string(), tool_json(a, v)));
    let (a, v) = probe_cmd("mathics", "--version");
    let (a, v) = if a { (a, v) } else { probe_path_binary(&home.join("workspace/.tools/mathics-venv/bin/mathics"), "--version") };
    tools.push(("mathics".to_string(), tool_json(a, v)));
    let (a, v) = probe_path_binary(&home.join("workspace/.tools/highs/bin/highs"), "--version");
    let (a, v) = if a { (a, v) } else { probe_cmd("highs", "--version") };
    tools.push(("highs".to_string(), tool_json(a, v)));
    let pakcs = match find_pakcs() {
        Some(p) => {
            let (_, v) = probe_path_binary(&p, "--version");
            (true, v)
        }
        None => (false, None),
    };
    tools.push(("pakcs".to_string(), tool_json(pakcs.0, pakcs.1)));
    print_json(&jobj(vec![
        ("command", jstr("doctor")),
        ("tools", Json::Obj(tools)),
    ]));
    0
}

// ---------------------------------------------------------------- main

fn usage_json() -> i32 {
    print_json(&jobj(vec![
        ("error", jstr("usage: monster <scan|normalize|classify|resolve|contract|counterexample|verify|evaluate|report|doctor> [args]")),
    ]));
    2
}

fn main() {
    let argv: Vec<String> = std::env::args().collect();
    if argv.len() < 2 {
        std::process::exit(usage_json());
    }
    let cmd = argv[1].as_str();
    let args: Vec<String> = argv[2..].to_vec();
    let code = match cmd {
        "scan" => cmd_scan(&args),
        "normalize" => cmd_normalize(&args),
        "classify" => cmd_classify(&args),
        "resolve" => cmd_resolve(&args),
        "contract" => cmd_contract(&args),
        "counterexample" => cmd_counterexample(&args),
        "verify" => cmd_verify(&args),
        "evaluate" => cmd_evaluate(&args),
        "report" => cmd_report(&args),
        "doctor" => cmd_doctor(&args),
        _ => usage_json(),
    };
    std::process::exit(code);
}

// ---------------------------------------------------------------- tests

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sha256_empty() {
        assert_eq!(sha256_hex(b""), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
    }

    #[test]
    fn sha256_abc() {
        assert_eq!(sha256_hex(b"abc"), "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad");
    }

    #[test]
    fn sha256_long() {
        assert_eq!(
            sha256_hex(b"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),
            "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
        );
    }

    #[test]
    fn matcher_wildcard_cases() {
        assert!(alternative_matches("the j invariant here", "j.invariant"));
        assert!(alternative_matches("J-Invariant", "j.invariant"));
        assert!(alternative_matches("a vertex operator algebra", "vertex.operator"));
        assert!(alternative_matches("VERTEX OPERATOR", "vertex.operator"));
        assert!(classify_line("the j invariant here").contains(&"moonshine"));
    }

    #[test]
    fn matcher_substring_and_miss() {
        assert!(alternative_matches("modularity", "modular"));
        assert!(classify_line("modularity").contains(&"moonshine"));
        assert!(classify_line("a line with no keywords").is_empty());
        assert!(classify_line("ordinary prose about cooking").is_empty());
        assert!(classify_line("Monster group").contains(&"monster"));
        assert!(classify_line("Lie algebra and the Jacobi identity").contains(&"lie"));
    }

    #[test]
    fn matcher_dot_is_any_char_not_optional() {
        assert!(!alternative_matches("jinvar", "j.invariant"));
        assert!(!alternative_matches("vertexoperator", "vertex.operator"));
        assert!(alternative_matches("lieXalgebra", "lie.algebra"));
    }

    #[test]
    fn json_escaping() {
        assert_eq!(json_escape("a\"b\\c"), "a\\\"b\\\\c");
        assert_eq!(json_escape("line\nbreak"), "line\\nbreak");
        assert_eq!(json_escape("tab\there"), "tab\\there");
        assert_eq!(json_escape("\u{0001}"), "\\u0001");
        assert_eq!(json_escape("café"), "café");
    }

    #[test]
    fn json_roundtrip() {
        let src = "{\"id\": \"c1\", \"line\": 3, \"ok\": true, \"x\": null}";
        let v = parse_json(src).expect("parse");
        assert_eq!(v.get("id").and_then(|x| x.as_str()), Some("c1"));
        assert_eq!(v.get("line").and_then(|x| x.as_int()), Some(3));
        assert!(parse_json("{bad json").is_err());
        assert!(parse_json("{\"a\": 1} trailing").is_err());
    }

    #[test]
    fn cycle_detected_three_cycle() {
        let ids: Vec<String> = vec!["a".into(), "b".into(), "c".into()];
        let mut deps: HashMap<String, Vec<String>> = HashMap::new();
        deps.insert("a".into(), vec!["b".into()]);
        deps.insert("b".into(), vec!["c".into()]);
        deps.insert("c".into(), vec!["a".into()]);
        assert!(topo_sort(&ids, &deps).is_err());
    }

    #[test]
    fn dag_toposorts() {
        let ids: Vec<String> = vec!["a".into(), "b".into(), "c".into()];
        let mut deps: HashMap<String, Vec<String>> = HashMap::new();
        deps.insert("a".into(), vec!["b".into()]);
        deps.insert("b".into(), vec!["c".into()]);
        deps.insert("c".into(), vec![]);
        let order = topo_sort(&ids, &deps).expect("dag");
        assert_eq!(order, vec!["c".to_string(), "b".to_string(), "a".to_string()]);
    }

    #[test]
    fn xml_escape_checks() {
        assert_eq!(xml_escape_text("a & b < c"), "a &amp; b &lt; c");
        assert_eq!(xml_escape_attr("x\"y"), "x&quot;y");
    }

    #[test]
    fn contract_fixture_counts() {
        let doc = parse_json("{\"families\": {\"moonshine\": [{\"kind\": \"function\"}, {\"kind\": \"function\"}, {\"kind\": \"table\"}]}}")
            .expect("parse");
        let counts = contract_counts(&doc).expect("counts");
        assert_eq!(counts["moonshine"]["function"], 2);
        assert_eq!(counts["moonshine"]["table"], 1);
    }

    #[test]
    fn validate_rejects_unsubstantiated_verified() {
        let xml = "<research version=\"1\"><source id=\"s1\" path=\"a.txt\" sha256=\"x\" /><claim id=\"c1\" source=\"s1\" line=\"1\" domain=\"lie\" status=\"verified\"><expression>e</expression><assumptions>a</assumptions></claim></research>";
        let root = parse_xml(xml).expect("xml");
        assert!(validate_claims(&root).is_err());
    }

    #[test]
    fn validate_accepts_candidate() {
        let xml = "<research version=\"1\"><source id=\"s1\" path=\"a.txt\" sha256=\"x\" /><claim id=\"c1\" source=\"s1\" line=\"1\" domain=\"lie\" status=\"candidate\"><expression>e</expression><assumptions>a</assumptions></claim></research>";
        let root = parse_xml(xml).expect("xml");
        assert_eq!(validate_claims(&root).expect("valid"), 1);
    }
}
