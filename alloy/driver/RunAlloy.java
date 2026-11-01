import edu.mit.csail.sdg.parser.CompUtil;
import edu.mit.csail.sdg.translator.A4Options;
import edu.mit.csail.sdg.translator.TranslateAlloyToKodkod;
import edu.mit.csail.sdg.alloy4.A4Reporter;
import edu.mit.csail.sdg.ast.Module;
import edu.mit.csail.sdg.ast.Command;
import edu.mit.csail.sdg.ast.CommandScope;
import edu.mit.csail.sdg.ast.Sig;
import edu.mit.csail.sdg.ast.Sig.Field;
import edu.mit.csail.sdg.translator.A4Solution;
import edu.mit.csail.sdg.translator.A4TupleSet;
import java.io.File;

/**
 * RunAlloy — headless Alloy 6 driver for the MONSTER-BRIDGE Phase 5 suite.
 *
 * Usage: java -cp <classes>:<alloy.jar> RunAlloy <file.als>
 *
 * For each command in the file it prints one machine-readable line:
 *   RESULT file=<name> label=<label> kind=<check|run> scope="<scope>"
 *          result=<SAT|UNSAT|ERROR> ms=<elapsed> summary="<instance summary>"
 * and finally one line: ALLOY_OK file=<name>
 *
 * Semantics of the result token:
 *   - for a "run"  command: SAT means an instance was found, UNSAT means none
 *     exists within the recorded scope.
 *   - for a "check" command: SAT means a counterexample to the assertion was
 *     found within the recorded scope; UNSAT means no counterexample exists
 *     within the recorded scope (a bounded result, not an unrestricted proof).
 *
 * The instance summary for a SAT result lists, per reachable signature, the
 * number of atoms in the instance, and per field the number of tuples.
 * This build of Alloy (6, 2025-01-09) takes the solver as a SATFactory:
 * opt.solver = kodkod.engine.satlab.SATFactory.DEFAULT.
 */
public class RunAlloy {

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "'")
                .replace("\n", " ").replace("\r", " ");
    }

    private static String strip(String label) {
        return label == null ? "" : label.replace("this/", "");
    }

    private static String scopeString(Module world, Command c) {
        StringBuilder sb = new StringBuilder();
        try {
            if (c.overall >= 0) sb.append("overall<=").append(c.overall);
            for (Sig s : world.getAllReachableSigs()) {
                CommandScope cs = null;
                try { cs = c.getScope(s); } catch (Throwable ignored) { }
                if (cs != null) {
                    if (sb.length() > 0) sb.append(", ");
                    sb.append(strip(s.label)).append(cs.isExact ? "=" : "<=")
                      .append(cs.startingScope);
                }
            }
            sb.append(", Int=").append(c.bitwidth >= 0
                ? String.valueOf(c.bitwidth) : "4(default)").append("bits");
            if (c.maxseq > 0) sb.append(", seq<=").append(c.maxseq);
        } catch (Throwable t) {
            return "overall=" + c.overall + ", Int=" + c.bitwidth + "bits";
        }
        return sb.toString();
    }

    private static String instanceSummary(Module world, A4Solution sol) {
        StringBuilder sb = new StringBuilder();
        for (Sig s : world.getAllReachableSigs()) {
            String lbl = strip(s.label);
            if (lbl.equals("univ") || lbl.equals("Int") || lbl.equals("seq/Int")
                    || lbl.equals("String") || lbl.equals("none")) continue;
            try {
                A4TupleSet ts = sol.eval(s);
                if (ts != null) {
                    if (sb.length() > 0) sb.append(", ");
                    sb.append(strip(s.label)).append("=").append(ts.size());
                }
            } catch (Throwable ignored) { }
        }
        for (Sig s : world.getAllReachableSigs()) {
            for (Field f : s.getFields()) {
                try {
                    A4TupleSet ts = sol.eval(f);
                    if (ts != null && ts.size() > 0) {
                        sb.append(", ").append(strip(s.label)).append(".")
                          .append(f.label).append("=").append(ts.size());
                    }
                } catch (Throwable ignored) { }
            }
        }
        return sb.toString();
    }

    public static void main(String[] args) throws Exception {
        String path = args[0];
        String fname = new File(path).getName();
        Module world;
        try {
            world = CompUtil.parseEverything_fromFile(null, null, path);
        } catch (Throwable t) {
            System.out.println("RESULT file=" + fname
                + " label=<parse> kind=error scope=\"\" result=ERROR ms=0 summary=\""
                + esc(String.valueOf(t.getMessage())) + "\"");
            System.out.println("ALLOY_OK file=" + fname);
            return;
        }
        A4Options opt = new A4Options();
        opt.solver = kodkod.engine.satlab.SATFactory.DEFAULT;
        for (Command c : world.getAllCommands()) {
            String kind = c.check ? "check" : "run";
            String scope = scopeString(world, c);
            long t0 = System.nanoTime();
            try {
                A4Solution sol = TranslateAlloyToKodkod.execute_command(
                    A4Reporter.NOP, world.getAllReachableSigs(), c, opt);
                long ms = (System.nanoTime() - t0) / 1000000L;
                boolean sat = sol.satisfiable();
                String summary = sat ? instanceSummary(world, sol) : "";
                System.out.println("RESULT file=" + fname
                    + " label=" + c.label
                    + " kind=" + kind
                    + " scope=\"" + esc(scope) + "\""
                    + " result=" + (sat ? "SAT" : "UNSAT")
                    + " ms=" + ms
                    + " summary=\"" + esc(summary) + "\"");
            } catch (Throwable t) {
                long ms = (System.nanoTime() - t0) / 1000000L;
                System.out.println("RESULT file=" + fname
                    + " label=" + c.label
                    + " kind=" + kind
                    + " scope=\"" + esc(scope) + "\""
                    + " result=ERROR ms=" + ms
                    + " summary=\"" + esc(String.valueOf(t.getMessage())) + "\"");
            }
            System.out.flush();
        }
        System.out.println("ALLOY_OK file=" + fname);
    }
}
