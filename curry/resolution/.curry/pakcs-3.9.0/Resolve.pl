%PAKCS3.9 swi9 VARIABLESHARING

:-noSingletonWarnings.
:-noRedefineWarnings.
:-noDiscontiguousWarnings.

:-importModule('Control.Search.AllValues').
:-importModule('Data.List').
:-importModule('Facts').
:-importModule('FactsCyclic').
:-importModule('MoonshineChain').
:-importModule('Prelude').

:-curryModule('Resolve').


%%%%%%%%%%%% function types %%%%%%%%%%%%%%%%%%%
:-multifile functiontype/6.
:-dynamic functiontype/6.
functiontype('Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23','_inst#Prelude.Data#Resolve.Derivation#',1,'Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23','_impl#===#Prelude.Data#Resolve.Derivation#',2,'Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve._impl\'23aValue\'23Prelude.Data\'23Resolve.Derivation\'23','_impl#aValue#Prelude.Data#Resolve.Derivation#',0,'Resolve._impl\'23aValue\'23Prelude.Data\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23','_inst#Prelude.Show#Resolve.Derivation#',1,'Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve._impl\'23show\'23Prelude.Show\'23Resolve.Derivation\'23','_impl#show#Prelude.Show#Resolve.Derivation#',0,'Resolve._impl\'23show\'23Prelude.Show\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23','_impl#showsPrec#Prelude.Show#Resolve.Derivation#',2,'Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve._impl\'23showList\'23Prelude.Show\'23Resolve.Derivation\'23','_impl#showList#Prelude.Show#Resolve.Derivation#',0,'Resolve._impl\'23showList\'23Prelude.Show\'23Resolve.Derivation\'23',nofix,notype).
functiontype('Resolve.itemId',itemId,0,'Resolve.itemId',nofix,notype).
functiontype('Resolve.itemKindValue',itemKindValue,1,'Resolve.itemKindValue',nofix,notype).
functiontype('Resolve.directDepOf',directDepOf,1,'Resolve.directDepOf',nofix,notype).
functiontype('Resolve.dependsTrans',dependsTrans,2,'Resolve.dependsTrans',nofix,notype).
functiontype('Resolve.transDepOf',transDepOf,1,'Resolve.transDepOf',nofix,notype).
functiontype('Resolve.checkable',checkable,1,'Resolve.checkable',nofix,notype).
functiontype('Resolve.abstractOnly',abstractOnly,1,'Resolve.abstractOnly',nofix,notype).
functiontype('Resolve.blocked',blocked,1,'Resolve.blocked',nofix,notype).
functiontype('Resolve.blockedItem',blockedItem,0,'Resolve.blockedItem',nofix,notype).
functiontype('Resolve.derivationIO',derivationIO,1,'Resolve.derivationIO',nofix,notype).
functiontype('Resolve.derivationIO._\'23lambda4','Resolve.derivationIO._#lambda4',2,'Resolve.derivationIO._\'23lambda4',nofix,notype).
functiontype('Resolve.derivationIO._\'23lambda4._\'23lambda6','Resolve.derivationIO._#lambda4._#lambda6',3,'Resolve.derivationIO._\'23lambda4._\'23lambda6',nofix,notype).
functiontype('Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9','Resolve.derivationIO._#lambda4._#lambda6._#lambda9',4,'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9',nofix,notype).
functiontype('Resolve.derivationsIO',derivationsIO,1,'Resolve.derivationsIO',nofix,notype).
functiontype('Resolve.derivationsIO._\'23lambda13','Resolve.derivationsIO._#lambda13',2,'Resolve.derivationsIO._\'23lambda13',nofix,notype).
functiontype('Resolve.derivationsIO._\'23lambda13._\'23lambda15','Resolve.derivationsIO._#lambda13._#lambda15',2,'Resolve.derivationsIO._\'23lambda13._\'23lambda15',nofix,notype).
functiontype('Resolve.printDerivation',printDerivation,1,'Resolve.printDerivation',nofix,notype).
functiontype('Resolve.printDerivation._\'23lambda18','Resolve.printDerivation._#lambda18',2,'Resolve.printDerivation._\'23lambda18',nofix,notype).
functiontype('Resolve.printNode',printNode,2,'Resolve.printNode',nofix,notype).
functiontype('Resolve.printNodes',printNodes,2,'Resolve.printNodes',nofix,notype).
functiontype('Resolve.moonTrans',moonTrans,2,'Resolve.moonTrans',nofix,notype).
functiontype('Resolve.moonTransDepOf',moonTransDepOf,1,'Resolve.moonTransDepOf',nofix,notype).
functiontype('Resolve.cycTransN',cycTransN,3,'Resolve.cycTransN',nofix,notype).
functiontype('Resolve.cycReachTarget',cycReachTarget,2,'Resolve.cycReachTarget',nofix,notype).
functiontype('Resolve.main',main,0,'Resolve.main',nofix,notype).
functiontype('Resolve.main._\'23lambda26','Resolve.main._#lambda26',1,'Resolve.main._\'23lambda26',nofix,notype).
functiontype('Resolve.main._\'23lambda26._\'23lambda28','Resolve.main._#lambda26._#lambda28',2,'Resolve.main._\'23lambda26._\'23lambda28',nofix,notype).
functiontype('Resolve.main._\'23lambda26._\'23lambda28._\'23lambda30','Resolve.main._#lambda26._#lambda28._#lambda30',2,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda30',nofix,notype).
functiontype('Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31','Resolve.main._#lambda26._#lambda28._#lambda31',1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31',nofix,notype).
functiontype('Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33','Resolve.main._#lambda26._#lambda28._#lambda31._#lambda33',1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33',nofix,notype).
functiontype('Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35','Resolve.main._#lambda26._#lambda28._#lambda31._#lambda33._#lambda35',1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35',nofix,notype).
functiontype('Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35._\'23lambda37','Resolve.main._#lambda26._#lambda28._#lambda31._#lambda33._#lambda35._#lambda37',1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35._\'23lambda37',nofix,notype).
functiontype('Resolve.itemId._\'23caseor0','Resolve.itemId._#caseor0',2,'Resolve.itemId._\'23caseor0',nofix,notype).
functiontype('Resolve.itemKindValue._\'23caseor0','Resolve.itemKindValue._#caseor0',2,'Resolve.itemKindValue._\'23caseor0',nofix,notype).
functiontype('Resolve.directDepOf._\'23caseor0','Resolve.directDepOf._#caseor0',2,'Resolve.directDepOf._\'23caseor0',nofix,notype).
functiontype('Resolve.dependsTrans._\'23caseor0','Resolve.dependsTrans._#caseor0',1,'Resolve.dependsTrans._\'23caseor0',nofix,notype).
functiontype('Resolve.transDepOf._\'23caseor0','Resolve.transDepOf._#caseor0',2,'Resolve.transDepOf._\'23caseor0',nofix,notype).
functiontype('Resolve.checkable._\'23caseor0','Resolve.checkable._#caseor0',1,'Resolve.checkable._\'23caseor0',nofix,notype).
functiontype('Resolve.abstractOnly._\'23caseor0','Resolve.abstractOnly._#caseor0',1,'Resolve.abstractOnly._\'23caseor0',nofix,notype).
functiontype('Resolve.blocked._\'23caseor0','Resolve.blocked._#caseor0',1,'Resolve.blocked._\'23caseor0',nofix,notype).
functiontype('Resolve.blockedItem._\'23caseor0','Resolve.blockedItem._#caseor0',2,'Resolve.blockedItem._\'23caseor0',nofix,notype).
functiontype('Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0','Resolve.derivationIO._#lambda4._#lambda6._#caseor0',1,'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0',nofix,notype).
functiontype('Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0','Resolve.derivationIO._#lambda4._#lambda6._#lambda9._#caseor0',1,'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0',nofix,notype).
functiontype('Resolve.moonTrans._\'23caseor0','Resolve.moonTrans._#caseor0',1,'Resolve.moonTrans._\'23caseor0',nofix,notype).
functiontype('Resolve.moonTransDepOf._\'23caseor0','Resolve.moonTransDepOf._#caseor0',2,'Resolve.moonTransDepOf._\'23caseor0',nofix,notype).
functiontype('Resolve.cycTransN._\'23caseor0','Resolve.cycTransN._#caseor0',1,'Resolve.cycTransN._\'23caseor0',nofix,notype).
functiontype('Resolve.cycReachTarget._\'23caseor0','Resolve.cycReachTarget._#caseor0',2,'Resolve.cycReachTarget._\'23caseor0',nofix,notype).

%%%%%%%%%%%% constructor types %%%%%%%%%%%%%%%%%%%
:-multifile constructortype/7.
:-dynamic constructortype/7.
constructortype('Resolve.Node','Node',5,'Node',0,notype,[]).

%%%%%%%%%%%% function definitions %%%%%%%%%%%%%%%%%%%
'Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23'(_8273964,_8273966,_8273968,_8273970):-freeze(_8273968,'blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23'(_8273964,_8273966,_8273968,_8273970)).
'blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23'(_8274050,_8274742,_8274748,_8274754):-hnf(_8274050,_8276992,_8274748,_8277004),'blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23_1'(_8276992,_8274742,_8277004,_8274754).

'blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23_1'(_8277558,_8277560,_8277562,_8277564):-freeze(_8277562,'blocked_blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23_1'(_8277558,_8277560,_8277562,_8277564)).
'blocked_blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23_1'('Prelude.()','Prelude._Dict\'23Data'(partcall(2,'Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23',[]),'Resolve._impl\'23aValue\'23Prelude.Data\'23Resolve.Derivation\'23'),_8277910,_8277910):-!.
'blocked_blocked_Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23_1'('FAIL'(_8279560),'FAIL'(_8279560),_8279574,_8279574):-nonvar(_8279560).

'Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23'(_8281886,_8281888,_8281890,_8281892,_8281894):-freeze(_8281892,'blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23'(_8281886,_8281888,_8281890,_8281892,_8281894)).
'blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23'(_8281982,_8282000,_8284732,_8284738,_8284744):-hnf(_8281982,_8287422,_8284738,_8287440),'blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1'(_8287422,_8282000,_8284732,_8287440,_8284744).

'blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1'(_8288074,_8288076,_8288078,_8288080,_8288082):-freeze(_8288080,'blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1'(_8288074,_8288076,_8288078,_8288080,_8288082)).
'blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1'('Resolve.Node'(_8282116,_8282134,_8282152,_8282170,_8282188),_8282000,_8289066,_8289072,_8289078):-!,hnf(_8282000,_8292506,_8289072,_8292548),'blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1_Resolve.Node_6'(_8292506,_8282116,_8282134,_8282152,_8282170,_8282188,_8289066,_8292548,_8289078).

'blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1_Resolve.Node_6'(_8293370,_8293372,_8293374,_8293376,_8293378,_8293380,_8293382,_8293384,_8293386):-freeze(_8293384,'blocked_blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1_Resolve.Node_6'(_8293370,_8293372,_8293374,_8293376,_8293378,_8293380,_8293382,_8293384,_8293386)).
'blocked_blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1_Resolve.Node_6'('Resolve.Node'(_8282334,_8282352,_8282370,_8282388,_8282406),_8282116,_8282134,_8282152,_8282170,_8282188,_8293840,_8293846,_8293852):-!,hnf('Prelude.&&'('Prelude.&&'('Prelude.&&'('Prelude.&&'('Prelude._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[]),_8282116,_8282334),'Prelude._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[]),_8282134,_8282352)),'Prelude._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[]),_8282152,_8282370)),'Prelude._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[]),_8282170,_8282388)),'Prelude._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23',[]),_8282188,_8282406)),_8293840,_8293846,_8293852).
'blocked_blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1_Resolve.Node_6'('FAIL'(_8301950),_8282116,_8282134,_8282152,_8282170,_8282188,'FAIL'(_8301950),_8301964,_8301964):-nonvar(_8301950).
'blocked_blocked_Resolve._impl\'23\'3D\'3D\'3D\'23Prelude.Data\'23Resolve.Derivation\'23_1'('FAIL'(_8302060),_8282000,'FAIL'(_8302060),_8302074,_8302074):-nonvar(_8302060).

'Resolve._impl\'23aValue\'23Prelude.Data\'23Resolve.Derivation\'23'(_8304424,_8304426,_8304428):-freeze(_8304426,'blocked_Resolve._impl\'23aValue\'23Prelude.Data\'23Resolve.Derivation\'23'(_8304424,_8304426,_8304428)).
'blocked_Resolve._impl\'23aValue\'23Prelude.Data\'23Resolve.Derivation\'23'('Resolve.Node'('Prelude._impl\'23aValue\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[])),'Prelude._impl\'23aValue\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[])),'Prelude._impl\'23aValue\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[])),'Prelude._impl\'23aValue\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Data\'23Prelude.Char\'23',[])),'Prelude._impl\'23aValue\'23Prelude.Data\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Resolve._inst\'23Prelude.Data\'23Resolve.Derivation\'23',[]))),_8305358,_8305358).

'Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23'(_8312190,_8312192,_8312194,_8312196):-freeze(_8312194,'blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23'(_8312190,_8312192,_8312194,_8312196)).
'blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23'(_8312276,_8313052,_8313058,_8313064):-hnf(_8312276,_8315302,_8313058,_8315314),'blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23_1'(_8315302,_8313052,_8315314,_8313064).

'blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23_1'(_8315868,_8315870,_8315872,_8315874):-freeze(_8315872,'blocked_blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23_1'(_8315868,_8315870,_8315872,_8315874)).
'blocked_blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23_1'('Prelude.()','Prelude._Dict\'23Show'('Resolve._impl\'23show\'23Prelude.Show\'23Resolve.Derivation\'23',partcall(2,'Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23',[]),'Resolve._impl\'23showList\'23Prelude.Show\'23Resolve.Derivation\'23'),_8316220,_8316220):-!.
'blocked_blocked_Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23_1'('FAIL'(_8318348),'FAIL'(_8318348),_8318362,_8318362):-nonvar(_8318348).

'Resolve._impl\'23show\'23Prelude.Show\'23Resolve.Derivation\'23'(_8320628,_8320630,_8320632):-freeze(_8320630,'blocked_Resolve._impl\'23show\'23Prelude.Show\'23Resolve.Derivation\'23'(_8320628,_8320630,_8320632)).
'blocked_Resolve._impl\'23show\'23Prelude.Show\'23Resolve.Derivation\'23'(_8320800,_8320806,_8320812):-hnf(partcall(1,'Prelude._def\'23show\'23Prelude.Show',[partcall(1,'Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23',[])]),_8320800,_8320806,_8320812).

'Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23'(_8324376,_8324378,_8324380,_8324382,_8324384):-freeze(_8324382,'blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23'(_8324376,_8324378,_8324380,_8324382,_8324384)).
'blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23'(_8324472,_8324490,_8330548,_8330554,_8330560):-hnf(_8324490,_8333238,_8330554,_8333256),'blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23_2'(_8333238,_8324472,_8330548,_8333256,_8330560).

'blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23_2'(_8333890,_8333892,_8333894,_8333896,_8333898):-freeze(_8333896,'blocked_blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23_2'(_8333890,_8333892,_8333894,_8333896,_8333898)).
'blocked_blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23_2'('Resolve.Node'(_8324606,_8324624,_8324642,_8324660,_8324678),_8324472,_8334320,_8334326,_8334332):-!,hnf('Prelude.showParen'('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3C\'23Prelude.Ord\'23Prelude.Int\'23',10),_8324472),'Prelude..'(partcall(1,'Prelude.showString',[['^N','^o','^d','^e','^ ']]),'Prelude..'('Prelude.apply'('Prelude._impl\'23showsPrec\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[]),11),_8324606),'Prelude..'(partcall(1,'Prelude.showString',[['^ ']]),'Prelude..'('Prelude.apply'('Prelude._impl\'23showsPrec\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[]),11),_8324624),'Prelude..'(partcall(1,'Prelude.showString',[['^ ']]),'Prelude..'('Prelude.apply'('Prelude._impl\'23showsPrec\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[]),11),_8324642),'Prelude..'(partcall(1,'Prelude.showString',[['^ ']]),'Prelude..'('Prelude.apply'('Prelude._impl\'23showsPrec\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[]),11),_8324660),'Prelude..'(partcall(1,'Prelude.showString',[['^ ']]),'Prelude.apply'('Prelude._impl\'23showsPrec\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23',[]),11),_8324678))))))))))),_8334320,_8334326,_8334332).
'blocked_blocked_Resolve._impl\'23showsPrec\'23Prelude.Show\'23Resolve.Derivation\'23_2'('FAIL'(_8348046),_8324472,'FAIL'(_8348046),_8348060,_8348060):-nonvar(_8348046).

'Resolve._impl\'23showList\'23Prelude.Show\'23Resolve.Derivation\'23'(_8350486,_8350488,_8350490):-freeze(_8350488,'blocked_Resolve._impl\'23showList\'23Prelude.Show\'23Resolve.Derivation\'23'(_8350486,_8350488,_8350490)).
'blocked_Resolve._impl\'23showList\'23Prelude.Show\'23Resolve.Derivation\'23'(_8350658,_8350664,_8350670):-hnf('Prelude._def\'23showList\'23Prelude.Show'(partcall(1,'Resolve._inst\'23Prelude.Show\'23Resolve.Derivation\'23',[])),_8350658,_8350664,_8350670).

'Resolve.itemId'(_8352536,_8352538,_8352540):-freeze(_8352538,'blocked_Resolve.itemId'(_8352536,_8352538,_8352540)).
'blocked_Resolve.itemId'(_8353070,_8353076,_8353082):-makeShare(_8352622,_8353214),hnf('Resolve.itemId._\'23caseor0'('Facts.item'(_8353214,_8352640,_8352658),_8353214),_8353070,_8353076,_8353082).

'Resolve.itemKindValue'(_8355444,_8355446,_8355448,_8355450):-freeze(_8355448,'blocked_Resolve.itemKindValue'(_8355444,_8355446,_8355448,_8355450)).
'blocked_Resolve.itemKindValue'(_8355530,_8355982,_8355988,_8355994):-makeShare(_8355576,_8356158),hnf('Resolve.itemKindValue._\'23caseor0'('Facts.item'(_8355530,_8355558,_8356158),_8356158),_8355982,_8355988,_8355994).

'Resolve.directDepOf'(_8358402,_8358404,_8358406,_8358408):-freeze(_8358406,'blocked_Resolve.directDepOf'(_8358402,_8358404,_8358406,_8358408)).
'blocked_Resolve.directDepOf'(_8358488,_8358846,_8358852,_8358858):-makeShare(_8358516,_8358972),hnf('Resolve.directDepOf._\'23caseor0'('Facts.dependsOn'(_8358488,_8358972),_8358972),_8358846,_8358852,_8358858).

'Resolve.dependsTrans'(_8361116,_8361118,_8361120,_8361122,_8361124):-freeze(_8361122,'blocked_Resolve.dependsTrans'(_8361116,_8361118,_8361120,_8361122,_8361124)).
'blocked_Resolve.dependsTrans'(_8361212,_8361230,_8363528,_8363534,_8363540):-hnf('Facts.dependsOn'(_8361212,_8361230),_8364856,_8363534,_8364822),'blocked_Resolve.dependsTrans_or1_ComplexCase'(_8364856,_8361212,_8361230,_8363528,_8364822,_8363540).

'blocked_Resolve.dependsTrans_or1_ComplexCase'(_8365290,_8365292,_8365294,_8365296,_8365298,_8365300):-freeze(_8365298,freeze(_8365290,'blocked_blocked_Resolve.dependsTrans_or1_ComplexCase'(_8365290,_8365292,_8365294,_8365296,_8365298,_8365300))).
'blocked_blocked_Resolve.dependsTrans_or1_ComplexCase'('Prelude.True',_8361212,_8361230,'Prelude.True',_8365700,_8365700).
'blocked_blocked_Resolve.dependsTrans_or1_ComplexCase'('Prelude.False',_8361212,_8361230,_8366656,_8366662,_8366668):-!,hnf(reportFailure4PAKCS('Resolve.dependsTrans',['Prelude.False']),_8366656,_8366662,_8366668).
'blocked_blocked_Resolve.dependsTrans_or1_ComplexCase'('FAIL'(_8368014),_8361212,_8361230,'FAIL'(_8368014),_8368028,_8368028).
'blocked_Resolve.dependsTrans'(_8361212,_8361230,_8368090,_8368096,_8368102):-makeShare(_8361976,_8368266),hnf('Resolve.dependsTrans._\'23caseor0'('Prelude.&&'('Facts.dependsOn'(_8361212,_8368266),'Resolve.dependsTrans'(_8368266,_8361230))),_8368090,_8368096,_8368102).

'Resolve.transDepOf'(_8370956,_8370958,_8370960,_8370962):-freeze(_8370960,'blocked_Resolve.transDepOf'(_8370956,_8370958,_8370960,_8370962)).
'blocked_Resolve.transDepOf'(_8371042,_8371400,_8371406,_8371412):-makeShare(_8371070,_8371526),hnf('Resolve.transDepOf._\'23caseor0'('Resolve.dependsTrans'(_8371042,_8371526),_8371526),_8371400,_8371406,_8371412).

'Resolve.checkable'(_8373574,_8373576,_8373578,_8373580):-freeze(_8373578,'blocked_Resolve.checkable'(_8373574,_8373576,_8373578,_8373580)).
'blocked_Resolve.checkable'(_8373660,_8376618,_8376624,_8376630):-makeShare(_8373706,_8376858),hnf('Resolve.checkable._\'23caseor0'('Prelude.&&'('Facts.item'(_8373660,_8373688,_8376858),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'2F\'3D\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])),_8376858),['^a','^b','^s','^t','^r','^a','^c','^t',^-,'^o','^n','^l','^y']))),_8376618,_8376624,_8376630).

'Resolve.abstractOnly'(_8383186,_8383188,_8383190,_8383192):-freeze(_8383190,'blocked_Resolve.abstractOnly'(_8383186,_8383188,_8383190,_8383192)).
'blocked_Resolve.abstractOnly'(_8383272,_8385646,_8385652,_8385658):-hnf('Resolve.abstractOnly._\'23caseor0'('Facts.item'(_8383272,_8383300,['^a','^b','^s','^t','^r','^a','^c','^t',^-,'^o','^n','^l','^y'])),_8385646,_8385652,_8385658).

'Resolve.blocked'(_8390096,_8390098,_8390100,_8390102):-freeze(_8390100,'blocked_Resolve.blocked'(_8390096,_8390098,_8390100,_8390102)).
'blocked_Resolve.blocked'(_8390182,_8392164,_8392170,_8392176):-hnf('Resolve.abstractOnly'(_8390182),_8393298,_8392170,_8393270),'blocked_Resolve.blocked_or1_ComplexCase'(_8393298,_8390182,_8392164,_8393270,_8392176).

'blocked_Resolve.blocked_or1_ComplexCase'(_8393700,_8393702,_8393704,_8393706,_8393708):-freeze(_8393706,freeze(_8393700,'blocked_blocked_Resolve.blocked_or1_ComplexCase'(_8393700,_8393702,_8393704,_8393706,_8393708))).
'blocked_blocked_Resolve.blocked_or1_ComplexCase'('Prelude.True',_8390182,'Prelude.True',_8394100,_8394100).
'blocked_blocked_Resolve.blocked_or1_ComplexCase'('Prelude.False',_8390182,_8394952,_8394958,_8394964):-!,hnf(reportFailure4PAKCS('Resolve.blocked',['Prelude.False']),_8394952,_8394958,_8394964).
'blocked_blocked_Resolve.blocked_or1_ComplexCase'('FAIL'(_8396176),_8390182,'FAIL'(_8396176),_8396190,_8396190).
'blocked_Resolve.blocked'(_8390182,_8396244,_8396250,_8396256):-makeShare(_8390858,_8396374),hnf('Resolve.blocked._\'23caseor0'('Prelude.&&'('Facts.dependsOn'(_8390182,_8396374),'Resolve.blocked'(_8396374))),_8396244,_8396250,_8396256).

'Resolve.blockedItem'(_8398862,_8398864,_8398866):-freeze(_8398864,'blocked_Resolve.blockedItem'(_8398862,_8398864,_8398866)).
'blocked_Resolve.blockedItem'(_8399634,_8399640,_8399646):-makeShare(_8398948,_8399796),hnf('Resolve.blockedItem._\'23caseor0'('Prelude.&&'('Facts.item'(_8399796,_8398966,_8398984),'Resolve.blocked'(_8399796)),_8399796),_8399634,_8399640,_8399646).

'Resolve.derivationIO'(_8402556,_8402558,_8402560,_8402562):-freeze(_8402560,'blocked_Resolve.derivationIO'(_8402556,_8402558,_8402560,_8402562)).
'blocked_Resolve.derivationIO'(_8402642,_8403232,_8403238,_8403244):-makeShare(_8402642,_8403328),hnf('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.directDepOf'(_8403328))),partcall(1,'Resolve.derivationIO._\'23lambda4',[_8403328])),_8403232,_8403238,_8403244).

'Resolve.derivationIO._\'23lambda4'(_8406908,_8406910,_8406912,_8406914,_8406916):-freeze(_8406914,'blocked_Resolve.derivationIO._\'23lambda4'(_8406908,_8406910,_8406912,_8406914,_8406916)).
'blocked_Resolve.derivationIO._\'23lambda4'(_8407004,_8407022,_8408024,_8408030,_8408036):-makeShare(_8407050,_8408234),makeShare(_8407004,_8408254),hnf('Prelude.cond'(letrec4PAKCS(_8408234,_8407022),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.itemKindValue'(_8408254))),partcall(1,'Resolve.derivationIO._\'23lambda4._\'23lambda6',[_8408234,_8408254]))),_8408024,_8408030,_8408036).

'Resolve.derivationIO._\'23lambda4._\'23lambda6'(_8413374,_8413376,_8413378,_8413380,_8413382,_8413384):-freeze(_8413382,'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6'(_8413374,_8413376,_8413378,_8413380,_8413382,_8413384)).
'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6'(_8413480,_8413498,_8413516,_8414920,_8414926,_8414932):-makeShare(_8413544,_8415304),makeShare(_8413562,_8415324),makeShare(_8413498,_8415344),hnf('Prelude.cond'(letrec4PAKCS(_8415304,_8413516),'Prelude.cond'(letrec4PAKCS(_8415324,'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0'(_8415304)),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.derivationsIO'(_8415344)),partcall(1,'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9',[_8415344,_8413480,_8415324])))),_8414920,_8414926,_8414932).

'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9'(_8422082,_8422084,_8422086,_8422088,_8422090,_8422092,_8422094):-freeze(_8422092,'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9'(_8422082,_8422084,_8422086,_8422088,_8422090,_8422092,_8422094)).
'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9'(_8422198,_8422216,_8422234,_8422252,_8427534,_8427540,_8427546):-makeShare(_8422280,_8428110),makeShare(_8422298,_8428130),makeShare(_8422216,_8428150),hnf('Prelude.cond'(letrec4PAKCS(_8428110,_8422252),'Prelude.cond'(letrec4PAKCS(_8428130,'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0'('Prelude.null'(_8422234))),'Prelude.apply'('Prelude._impl\'23return\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.Node'(_8428150,_8428130,'Prelude.++'(['^X','^ ',^:,^=,'^ '],_8428150),'Prelude.++'(['^k','^i','^n','^d',^=],'Prelude.++'(_8422198,['^ ','^(','^i','^t','^e','^m','^ ','^f','^a','^c','^t','^)'])),_8428110)))),_8427534,_8427540,_8427546).

'Resolve.derivationsIO'(_8438818,_8438820,_8438822,_8438824):-freeze(_8438822,'blocked_Resolve.derivationsIO'(_8438818,_8438820,_8438822,_8438824)).
'blocked_Resolve.derivationsIO'(_8438904,_8440034,_8440040,_8440046):-hnf(_8438904,_8441168,_8440040,_8441180),'blocked_Resolve.derivationsIO_1'(_8441168,_8440034,_8441180,_8440046).

'blocked_Resolve.derivationsIO_1'(_8441548,_8441550,_8441552,_8441554):-freeze(_8441552,'blocked_blocked_Resolve.derivationsIO_1'(_8441548,_8441550,_8441552,_8441554)).
'blocked_blocked_Resolve.derivationsIO_1'([],_8441790,_8441796,_8441802):-hnf('Prelude.apply'('Prelude._impl\'23return\'23Prelude.Monad\'23Prelude.IO\'23',[]),_8441790,_8441796,_8441802).
'blocked_blocked_Resolve.derivationsIO_1'([_8439288|_8439306],_8442972,_8442978,_8442984):-!,hnf('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.derivationIO'(_8439288)),partcall(1,'Resolve.derivationsIO._\'23lambda13',[_8439306])),_8442972,_8442978,_8442984).
'blocked_blocked_Resolve.derivationsIO_1'('FAIL'(_8444962),'FAIL'(_8444962),_8444976,_8444976):-nonvar(_8444962).

'Resolve.derivationsIO._\'23lambda13'(_8446404,_8446406,_8446408,_8446410,_8446412):-freeze(_8446410,'blocked_Resolve.derivationsIO._\'23lambda13'(_8446404,_8446406,_8446408,_8446410,_8446412)).
'blocked_Resolve.derivationsIO._\'23lambda13'(_8446500,_8446518,_8447366,_8447372,_8447378):-makeShare(_8446546,_8447536),hnf('Prelude.cond'(letrec4PAKCS(_8447536,_8446518),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.derivationsIO'(_8446500)),partcall(1,'Resolve.derivationsIO._\'23lambda13._\'23lambda15',[_8447536]))),_8447366,_8447372,_8447378).

'Resolve.derivationsIO._\'23lambda13._\'23lambda15'(_8452170,_8452172,_8452174,_8452176,_8452178):-freeze(_8452176,'blocked_Resolve.derivationsIO._\'23lambda13._\'23lambda15'(_8452170,_8452172,_8452174,_8452176,_8452178)).
'blocked_Resolve.derivationsIO._\'23lambda13._\'23lambda15'(_8452266,_8452284,_8452964,_8452970,_8452976):-makeShare(_8452312,_8453130),hnf('Prelude.cond'(letrec4PAKCS(_8453130,_8452284),'Prelude.apply'('Prelude._impl\'23return\'23Prelude.Monad\'23Prelude.IO\'23',[_8452266|_8453130])),_8452964,_8452970,_8452976).

'Resolve.printDerivation'(_8456300,_8456302,_8456304,_8456306):-freeze(_8456304,'blocked_Resolve.printDerivation'(_8456300,_8456302,_8456304,_8456306)).
'blocked_Resolve.printDerivation'(_8456386,_8460084,_8460090,_8460096):-makeShare(_8456386,_8460272),hnf('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^B','^E','^G','^I','^N',^-,'^D','^E','^R','^I','^V','^A','^T','^I','^O','^N','^ '],_8460272))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.derivationIO'(_8460272)),partcall(1,'Resolve.printDerivation._\'23lambda18',[_8460272]))),_8460084,_8460090,_8460096).

'Resolve.printDerivation._\'23lambda18'(_8468510,_8468512,_8468514,_8468516,_8468518):-freeze(_8468516,'blocked_Resolve.printDerivation._\'23lambda18'(_8468510,_8468512,_8468514,_8468516,_8468518)).
'blocked_Resolve.printDerivation._\'23lambda18'(_8468606,_8468624,_8472020,_8472026,_8472032):-makeShare(_8468652,_8472256),hnf('Prelude.cond'(letrec4PAKCS(_8472256,_8468624),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.printNode'(0,_8472256)),'Prelude.putStrLn'('Prelude.++'(['^E','^N','^D',^-,'^D','^E','^R','^I','^V','^A','^T','^I','^O','^N','^ '],_8468606)))),_8472020,_8472026,_8472032).

'Resolve.printNode'(_8479006,_8479008,_8479010,_8479012,_8479014):-freeze(_8479012,'blocked_Resolve.printNode'(_8479006,_8479008,_8479010,_8479012,_8479014)).
'blocked_Resolve.printNode'(_8479102,_8479120,_8488382,_8488388,_8488394):-hnf(_8479120,_8489380,_8488388,_8489398),'blocked_Resolve.printNode_2'(_8489380,_8479102,_8488382,_8489398,_8488394).

'blocked_Resolve.printNode_2'(_8489750,_8489752,_8489754,_8489756,_8489758):-freeze(_8489756,'blocked_blocked_Resolve.printNode_2'(_8489750,_8489752,_8489754,_8489756,_8489758)).
'blocked_blocked_Resolve.printNode_2'('Resolve.Node'(_8479236,_8479254,_8479272,_8479290,_8479308),_8479102,_8490180,_8490186,_8490192):-!,makeShare(_8479102,_8490736),hnf('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'('Prelude.apply'('Prelude.concat','Prelude.replicate'(_8490736,['^ ','^ '])),'Prelude.++'(['^N','^O','^D','^E','^ ','^i','^t','^e','^m',^=],'Prelude.++'(_8479236,'Prelude.++'(['^ ','^c','^l','^a','^u','^s','^e',^=],'Prelude.++'(_8479254,'Prelude.++'(['^ ','^s','^u','^b','^s','^t',^=,'^"'],'Prelude.++'(_8479272,'Prelude.++'(['^"'],'Prelude.++'(['^ ','^p','^r','^e','^m','^i','^s','^e',^=,'^"'],'Prelude.++'(_8479290,['^"'])))))))))))),'Resolve.printNodes'('Prelude._impl\'23\'2B\'23Prelude.Num\'23Prelude.Int\'23'(_8490736,1),_8479308)),_8490180,_8490186,_8490192).
'blocked_blocked_Resolve.printNode_2'('FAIL'(_8505374),_8479102,'FAIL'(_8505374),_8505388,_8505388):-nonvar(_8505374).

'Resolve.printNodes'(_8506264,_8506266,_8506268,_8506270,_8506272):-freeze(_8506270,'blocked_Resolve.printNodes'(_8506264,_8506266,_8506268,_8506270,_8506272)).
'blocked_Resolve.printNodes'(_8506360,_8506378,_8507638,_8507644,_8507650):-hnf(_8506378,_8508672,_8507644,_8508690),'blocked_Resolve.printNodes_2'(_8508672,_8506360,_8507638,_8508690,_8507650).

'blocked_Resolve.printNodes_2'(_8509048,_8509050,_8509052,_8509054,_8509056):-freeze(_8509054,'blocked_blocked_Resolve.printNodes_2'(_8509048,_8509050,_8509052,_8509054,_8509056)).
'blocked_blocked_Resolve.printNodes_2'([],_8506360,_8509300,_8509306,_8509312):-hnf('Prelude.apply'('Prelude._impl\'23return\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.()'),_8509300,_8509306,_8509312).
'blocked_blocked_Resolve.printNodes_2'([_8506762|_8506780],_8506360,_8510594,_8510600,_8510606):-!,makeShare(_8506360,_8510760),hnf('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.printNode'(_8510760,_8506762)),'Resolve.printNodes'(_8510760,_8506780)),_8510594,_8510600,_8510606).
'blocked_blocked_Resolve.printNodes_2'('FAIL'(_8512948),_8506360,'FAIL'(_8512948),_8512962,_8512962):-nonvar(_8512948).

'Resolve.moonTrans'(_8513800,_8513802,_8513804,_8513806,_8513808):-freeze(_8513806,'blocked_Resolve.moonTrans'(_8513800,_8513802,_8513804,_8513806,_8513808)).
'blocked_Resolve.moonTrans'(_8513896,_8513914,_8516272,_8516278,_8516284):-hnf('MoonshineChain.moonDependsOn'(_8513896,_8513914),_8517492,_8516278,_8517458),'blocked_Resolve.moonTrans_or1_ComplexCase'(_8517492,_8513896,_8513914,_8516272,_8517458,_8516284).

'blocked_Resolve.moonTrans_or1_ComplexCase'(_8517908,_8517910,_8517912,_8517914,_8517916,_8517918):-freeze(_8517916,freeze(_8517908,'blocked_blocked_Resolve.moonTrans_or1_ComplexCase'(_8517908,_8517910,_8517912,_8517914,_8517916,_8517918))).
'blocked_blocked_Resolve.moonTrans_or1_ComplexCase'('Prelude.True',_8513896,_8513914,'Prelude.True',_8518318,_8518318).
'blocked_blocked_Resolve.moonTrans_or1_ComplexCase'('Prelude.False',_8513896,_8513914,_8519256,_8519262,_8519268):-!,hnf(reportFailure4PAKCS('Resolve.moonTrans',['Prelude.False']),_8519256,_8519262,_8519268).
'blocked_blocked_Resolve.moonTrans_or1_ComplexCase'('FAIL'(_8520578),_8513896,_8513914,'FAIL'(_8520578),_8520592,_8520592).
'blocked_Resolve.moonTrans'(_8513896,_8513914,_8520654,_8520660,_8520666):-makeShare(_8514660,_8520830),hnf('Resolve.moonTrans._\'23caseor0'('Prelude.&&'('MoonshineChain.moonDependsOn'(_8513896,_8520830),'Resolve.moonTrans'(_8520830,_8513914))),_8520654,_8520660,_8520666).

'Resolve.moonTransDepOf'(_8523696,_8523698,_8523700,_8523702):-freeze(_8523700,'blocked_Resolve.moonTransDepOf'(_8523696,_8523698,_8523700,_8523702)).
'blocked_Resolve.moonTransDepOf'(_8523782,_8524140,_8524146,_8524152):-makeShare(_8523810,_8524266),hnf('Resolve.moonTransDepOf._\'23caseor0'('Resolve.moonTrans'(_8523782,_8524266),_8524266),_8524140,_8524146,_8524152).

'Resolve.cycTransN'(_8526344,_8526346,_8526348,_8526350,_8526352,_8526354):-freeze(_8526352,'blocked_Resolve.cycTransN'(_8526344,_8526346,_8526348,_8526350,_8526352,_8526354)).
'blocked_Resolve.cycTransN'(_8526450,_8526468,_8526486,_8529586,_8529592,_8529598):-hnf('FactsCyclic.cycDependsOn'(_8526468,_8526486),_8530820,_8529592,_8530780),'blocked_Resolve.cycTransN_or1_ComplexCase'(_8530820,_8526450,_8526468,_8526486,_8529586,_8530780,_8529598).

'blocked_Resolve.cycTransN_or1_ComplexCase'(_8531238,_8531240,_8531242,_8531244,_8531246,_8531248,_8531250):-freeze(_8531248,freeze(_8531238,'blocked_blocked_Resolve.cycTransN_or1_ComplexCase'(_8531238,_8531240,_8531242,_8531244,_8531246,_8531248,_8531250))).
'blocked_blocked_Resolve.cycTransN_or1_ComplexCase'('Prelude.True',_8526450,_8526468,_8526486,'Prelude.True',_8531658,_8531658).
'blocked_blocked_Resolve.cycTransN_or1_ComplexCase'('Prelude.False',_8526450,_8526468,_8526486,_8532670,_8532676,_8532682):-!,hnf(reportFailure4PAKCS('Resolve.cycTransN',['Prelude.False']),_8532670,_8532676,_8532682).
'blocked_blocked_Resolve.cycTransN_or1_ComplexCase'('FAIL'(_8534066),_8526450,_8526468,_8526486,'FAIL'(_8534066),_8534080,_8534080).
'blocked_Resolve.cycTransN'(_8526450,_8526468,_8526486,_8534150,_8534156,_8534162):-makeShare(_8526450,_8534424),makeShare(_8527232,_8534444),hnf('Resolve.cycTransN._\'23caseor0'('Prelude.&&'('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'23Prelude.Ord\'23Prelude.Int\'23',_8534424),0),'Prelude.&&'('FactsCyclic.cycDependsOn'(_8526468,_8534444),'Resolve.cycTransN'('Prelude._impl\'23\'2D\'23Prelude.Num\'23Prelude.Int\'23'(_8534424,1),_8534444,_8526486)))),_8534150,_8534156,_8534162).

'Resolve.cycReachTarget'(_8539314,_8539316,_8539318,_8539320,_8539322):-freeze(_8539320,'blocked_Resolve.cycReachTarget'(_8539314,_8539316,_8539318,_8539320,_8539322)).
'blocked_Resolve.cycReachTarget'(_8539410,_8539428,_8539856,_8539862,_8539868):-makeShare(_8539456,_8540040),hnf('Resolve.cycReachTarget._\'23caseor0'('Resolve.cycTransN'(_8539410,_8539428,_8540040),_8540040),_8539856,_8539862,_8539868).

'Resolve.main'(_8542078,_8542080,_8542082):-freeze(_8542080,'blocked_Resolve.main'(_8542078,_8542080,_8542082)).
'blocked_Resolve.main'(_8542586,_8542592,_8542598):-hnf('Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.itemId')),partcall(1,'Resolve.main._\'23lambda26',[])),_8542586,_8542592,_8542598).

'Resolve.main._\'23lambda26'(_8545374,_8545376,_8545378,_8545380):-freeze(_8545378,'blocked_Resolve.main._\'23lambda26'(_8545374,_8545376,_8545378,_8545380)).
'blocked_Resolve.main._\'23lambda26'(_8545460,_8548922,_8548928,_8548934):-makeShare(_8545488,_8549220),makeShare(_8545506,_8549240),hnf('Prelude.cond'(letrec4PAKCS(_8549220,_8545460),'Prelude.cond'(letrec4PAKCS(_8549240,'Prelude.apply'('Data.List.sort'(partcall(1,'Prelude._inst\'23Prelude.Ord\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Ord\'23Prelude.Char\'23',[])])),'Data.List.nub'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])]),_8549220))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^A','^L','^L',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),_8549240)))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.blockedItem')),partcall(1,'Resolve.main._\'23lambda26._\'23lambda28',[_8549240]))))),_8548922,_8548928,_8548934).

'Resolve.main._\'23lambda26._\'23lambda28'(_8560320,_8560322,_8560324,_8560326,_8560328):-freeze(_8560326,'blocked_Resolve.main._\'23lambda26._\'23lambda28'(_8560320,_8560322,_8560324,_8560326,_8560328)).
'blocked_Resolve.main._\'23lambda26._\'23lambda28'(_8560416,_8560434,_8570328,_8570334,_8570340):-makeShare(_8560462,_8570954),makeShare(_8560480,_8570974),makeShare(_8564002,_8570994),hnf('Prelude.cond'(letrec4PAKCS(_8570954,_8560434),'Prelude.cond'(letrec4PAKCS(_8570974,'Prelude.apply'('Data.List.sort'(partcall(1,'Prelude._inst\'23Prelude.Ord\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Ord\'23Prelude.Char\'23',[])])),'Data.List.nub'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])]),_8570954))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^B','^L','^O','^C','^K','^E','^D',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),_8570974)))),'Prelude.cond'(letrec4PAKCS(_8570994,'Prelude.filter'(partcall(1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda30',[_8570974]),_8560416)),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^R','^E','^S','^O','^L','^V','^A','^B','^L','^E',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),_8570994)))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.transDepOf'(['^M','^O','^N',^-,'^h','^o','^m','^o','^m','^o','^r','^p','^h','^i','^s','^m']))),partcall(1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31',[]))))))),_8570328,_8570334,_8570340).

'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda30'(_8593464,_8593466,_8593468,_8593470,_8593472):-freeze(_8593470,'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda30'(_8593464,_8593466,_8593468,_8593470,_8593472)).
'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda30'(_8593560,_8593578,_8594084,_8594090,_8594096):-hnf('Prelude.not'('Prelude.apply'('Prelude.elem'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])]),_8593578),_8593560)),_8594084,_8594090,_8594096).

'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31'(_8598042,_8598044,_8598046,_8598048):-freeze(_8598046,'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31'(_8598042,_8598044,_8598046,_8598048)).
'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31'(_8598128,_8607278,_8607284,_8607290):-makeShare(_8598156,_8607616),hnf('Prelude.cond'(letrec4PAKCS(_8607616,_8598128),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^T','^R','^A','^N','^S','^ ','^M','^O','^N',^-,'^h','^o','^m','^o','^m','^o','^r','^p','^h','^i','^s','^m',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),'Prelude.apply'('Data.List.sort'(partcall(1,'Prelude._inst\'23Prelude.Ord\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Ord\'23Prelude.Char\'23',[])])),'Data.List.nub'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])]),_8607616)))))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.transDepOf'(['^M','^O','^N',^-,'^c','^h','^a','^r','^a','^c','^t','^e','^r',^-,'^c','^o','^m','^p','^a','^t']))),partcall(1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33',[])))),_8607278,_8607284,_8607290).

'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33'(_8626840,_8626842,_8626844,_8626846):-freeze(_8626844,'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33'(_8626840,_8626842,_8626844,_8626846)).
'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33'(_8626926,_8641690,_8641696,_8641702):-makeShare(_8626954,_8642172),hnf('Prelude.cond'(letrec4PAKCS(_8642172,_8626926),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^T','^R','^A','^N','^S','^ ','^M','^O','^N',^-,'^c','^h','^a','^r','^a','^c','^t','^e','^r',^-,'^c','^o','^m','^p','^a','^t',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),'Prelude.apply'('Data.List.sort'(partcall(1,'Prelude._inst\'23Prelude.Ord\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Ord\'23Prelude.Char\'23',[])])),'Data.List.nub'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])]),_8642172)))))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.printDerivation'(['^M','^O','^N',^-,'^c','^h','^a','^r','^a','^c','^t','^e','^r',^-,'^c','^o','^m','^p','^a','^t'])),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Resolve.printDerivation'(['^G','^E','^O',^-,'^r','^e','^c','^o','^n','^s','^t','^r','^u','^c','^t','^i','^o','^n'])),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.moonTransDepOf'(['^G','^r','^a','^d','^e','^d','^D','^i','^m']))),partcall(1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35',[])))))),_8641690,_8641696,_8641702).

'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35'(_8670468,_8670470,_8670472,_8670474):-freeze(_8670472,'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35'(_8670468,_8670470,_8670472,_8670474)).
'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35'(_8670554,_8677310,_8677316,_8677322):-makeShare(_8670582,_8677586),hnf('Prelude.cond'(letrec4PAKCS(_8677586,_8670554),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^M','^O','^O','^N','^C','^H','^A','^I','^N','^ ','^T','^R','^A','^N','^S','^ ','^G','^r','^a','^d','^e','^d','^D','^i','^m',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),'Prelude.apply'('Data.List.sort'(partcall(1,'Prelude._inst\'23Prelude.Ord\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Ord\'23Prelude.Char\'23',[])])),'Data.List.nub'(partcall(1,'Prelude._inst\'23Prelude.Eq\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Eq\'23Prelude.Char\'23',[])]),_8677586)))))),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'3D\'23Prelude.Monad\'23Prelude.IO\'23','Control.Search.AllValues.getAllValues'('Resolve.cycReachTarget'(5,['^a']))),partcall(1,'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35._\'23lambda37',[])))),_8677310,_8677316,_8677322).

'Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35._\'23lambda37'(_8694948,_8694950,_8694952,_8694954):-freeze(_8694952,'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35._\'23lambda37'(_8694948,_8694950,_8694952,_8694954)).
'blocked_Resolve.main._\'23lambda26._\'23lambda28._\'23lambda31._\'23lambda33._\'23lambda35._\'23lambda37'(_8695034,_8724274,_8724280,_8724286):-makeShare(_8695062,_8725136),hnf('Prelude.cond'(letrec4PAKCS(_8725136,_8695034),'Prelude.apply'('Prelude.apply'('Prelude._impl\'23\'3E\'3E\'23Prelude.Monad\'23Prelude.IO\'23','Prelude.putStrLn'('Prelude.++'(['^B','^O','^U','^N','^D','^E','^D','^ ','^C','^Y','^C','^L','^I','^C',^:,'^ ','^c','^y','^c','^T','^r','^a','^n','^s','^N','^ ','^5','^ ','^f','^r','^o','^m','^ ','^"','^a','^"',^:,'^ '],'Prelude.apply'('Prelude._impl\'23show\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23'(partcall(1,'Prelude._inst\'23Prelude.Show\'23\'5B\'5D\'230\'23\'23',[partcall(1,'Prelude._inst\'23Prelude.Show\'23Prelude.Char\'23',[])])),_8725136)))),'Prelude.putStrLn'(['^B','^O','^U','^N','^D','^E','^D','^ ','^C','^Y','^C','^L','^I','^C','^ ','^N','^O','^T','^E',^:,'^ ','^f','^u','^e','^l',^-,'^b','^o','^u','^n','^d','^e','^d','^ ','^c','^l','^o','^s','^u','^r','^e','^ ','^o','^v','^e','^r','^ ','^t','^h','^e','^ ','^c','^y','^c','^l','^i','^c','^ ','^f','^a','^c','^t','^s','^ ','^a',^<,^-,^>,'^b','^ ','^t','^e','^r','^m','^i','^n','^a','^t','^e','^d','^;','^ ','^t','^h','^e','^ ','^u','^n','^b','^o','^u','^n','^d','^e','^d','^ ','^c','^l','^o','^s','^u','^r','^e','^ ','^o','^v','^e','^r','^ ','^t','^h','^e','^ ','^s','^a','^m','^e','^ ','^f','^a','^c','^t','^s','^ ','^d','^o','^e','^s','^ ','^n','^o','^t','^ ','^t','^e','^r','^m','^i','^n','^a','^t','^e',^.]))),_8724274,_8724280,_8724286).

'Resolve.itemId._\'23caseor0'(_8766652,_8766654,_8766656,_8766658,_8766660):-freeze(_8766658,'blocked_Resolve.itemId._\'23caseor0'(_8766652,_8766654,_8766656,_8766658,_8766660)).
'blocked_Resolve.itemId._\'23caseor0'(_8766748,_8766766,_8767556,_8767562,_8767568):-hnf(_8766748,_8768878,_8767562,_8768896),'blocked_Resolve.itemId._\'23caseor0_1'(_8768878,_8766766,_8767556,_8768896,_8767568).

'blocked_Resolve.itemId._\'23caseor0_1'(_8769308,_8769310,_8769312,_8769314,_8769316):-freeze(_8769314,freeze(_8769308,'blocked_blocked_Resolve.itemId._\'23caseor0_1'(_8769308,_8769310,_8769312,_8769314,_8769316))).
'blocked_blocked_Resolve.itemId._\'23caseor0_1'('Prelude.True',_8766766,_8769702,_8769708,_8769714):-hnf(_8766766,_8769702,_8769708,_8769714).
'blocked_blocked_Resolve.itemId._\'23caseor0_1'('Prelude.False',_8766766,_8770472,_8770478,_8770484):-!,hnf(reportFailure4PAKCS('Resolve.itemId._\'23caseor0',['Prelude.False']),_8770472,_8770478,_8770484).
'blocked_blocked_Resolve.itemId._\'23caseor0_1'('FAIL'(_8771744),_8766766,'FAIL'(_8771744),_8771758,_8771758).

'Resolve.itemKindValue._\'23caseor0'(_8773152,_8773154,_8773156,_8773158,_8773160):-freeze(_8773158,'blocked_Resolve.itemKindValue._\'23caseor0'(_8773152,_8773154,_8773156,_8773158,_8773160)).
'blocked_Resolve.itemKindValue._\'23caseor0'(_8773248,_8773266,_8774098,_8774104,_8774110):-hnf(_8773248,_8775672,_8774104,_8775690),'blocked_Resolve.itemKindValue._\'23caseor0_1'(_8775672,_8773266,_8774098,_8775690,_8774110).

'blocked_Resolve.itemKindValue._\'23caseor0_1'(_8776144,_8776146,_8776148,_8776150,_8776152):-freeze(_8776150,freeze(_8776144,'blocked_blocked_Resolve.itemKindValue._\'23caseor0_1'(_8776144,_8776146,_8776148,_8776150,_8776152))).
'blocked_blocked_Resolve.itemKindValue._\'23caseor0_1'('Prelude.True',_8773266,_8776538,_8776544,_8776550):-hnf(_8773266,_8776538,_8776544,_8776550).
'blocked_blocked_Resolve.itemKindValue._\'23caseor0_1'('Prelude.False',_8773266,_8777350,_8777356,_8777362):-!,hnf(reportFailure4PAKCS('Resolve.itemKindValue._\'23caseor0',['Prelude.False']),_8777350,_8777356,_8777362).
'blocked_blocked_Resolve.itemKindValue._\'23caseor0_1'('FAIL'(_8778706),_8773266,'FAIL'(_8778706),_8778720,_8778720).

'Resolve.directDepOf._\'23caseor0'(_8780038,_8780040,_8780042,_8780044,_8780046):-freeze(_8780044,'blocked_Resolve.directDepOf._\'23caseor0'(_8780038,_8780040,_8780042,_8780044,_8780046)).
'blocked_Resolve.directDepOf._\'23caseor0'(_8780134,_8780152,_8780972,_8780978,_8780984):-hnf(_8780134,_8782474,_8780978,_8782492),'blocked_Resolve.directDepOf._\'23caseor0_1'(_8782474,_8780152,_8780972,_8782492,_8780984).

'blocked_Resolve.directDepOf._\'23caseor0_1'(_8782934,_8782936,_8782938,_8782940,_8782942):-freeze(_8782940,freeze(_8782934,'blocked_blocked_Resolve.directDepOf._\'23caseor0_1'(_8782934,_8782936,_8782938,_8782940,_8782942))).
'blocked_blocked_Resolve.directDepOf._\'23caseor0_1'('Prelude.True',_8780152,_8783328,_8783334,_8783340):-hnf(_8780152,_8783328,_8783334,_8783340).
'blocked_blocked_Resolve.directDepOf._\'23caseor0_1'('Prelude.False',_8780152,_8784128,_8784134,_8784140):-!,hnf(reportFailure4PAKCS('Resolve.directDepOf._\'23caseor0',['Prelude.False']),_8784128,_8784134,_8784140).
'blocked_blocked_Resolve.directDepOf._\'23caseor0_1'('FAIL'(_8785460),_8780152,'FAIL'(_8785460),_8785474,_8785474).

'Resolve.dependsTrans._\'23caseor0'(_8786830,_8786832,_8786834,_8786836):-freeze(_8786834,'blocked_Resolve.dependsTrans._\'23caseor0'(_8786830,_8786832,_8786834,_8786836)).
'blocked_Resolve.dependsTrans._\'23caseor0'(_8786916,_8787756,_8787762,_8787768):-hnf(_8786916,_8789286,_8787762,_8789298),'blocked_Resolve.dependsTrans._\'23caseor0_1'(_8789286,_8787756,_8789298,_8787768).

'blocked_Resolve.dependsTrans._\'23caseor0_1'(_8789738,_8789740,_8789742,_8789744):-freeze(_8789742,freeze(_8789738,'blocked_blocked_Resolve.dependsTrans._\'23caseor0_1'(_8789738,_8789740,_8789742,_8789744))).
'blocked_blocked_Resolve.dependsTrans._\'23caseor0_1'('Prelude.True','Prelude.True',_8790128,_8790128).
'blocked_blocked_Resolve.dependsTrans._\'23caseor0_1'('Prelude.False',_8790924,_8790930,_8790936):-!,hnf(reportFailure4PAKCS('Resolve.dependsTrans._\'23caseor0',['Prelude.False']),_8790924,_8790930,_8790936).
'blocked_blocked_Resolve.dependsTrans._\'23caseor0_1'('FAIL'(_8792194),'FAIL'(_8792194),_8792208,_8792208).

'Resolve.transDepOf._\'23caseor0'(_8793480,_8793482,_8793484,_8793486,_8793488):-freeze(_8793486,'blocked_Resolve.transDepOf._\'23caseor0'(_8793480,_8793482,_8793484,_8793486,_8793488)).
'blocked_Resolve.transDepOf._\'23caseor0'(_8793576,_8793594,_8794408,_8794414,_8794420):-hnf(_8793576,_8795874,_8794414,_8795892),'blocked_Resolve.transDepOf._\'23caseor0_1'(_8795874,_8793594,_8794408,_8795892,_8794420).

'blocked_Resolve.transDepOf._\'23caseor0_1'(_8796328,_8796330,_8796332,_8796334,_8796336):-freeze(_8796334,freeze(_8796328,'blocked_blocked_Resolve.transDepOf._\'23caseor0_1'(_8796328,_8796330,_8796332,_8796334,_8796336))).
'blocked_blocked_Resolve.transDepOf._\'23caseor0_1'('Prelude.True',_8793594,_8796722,_8796728,_8796734):-hnf(_8793594,_8796722,_8796728,_8796734).
'blocked_blocked_Resolve.transDepOf._\'23caseor0_1'('Prelude.False',_8793594,_8797516,_8797522,_8797528):-!,hnf(reportFailure4PAKCS('Resolve.transDepOf._\'23caseor0',['Prelude.False']),_8797516,_8797522,_8797528).
'blocked_blocked_Resolve.transDepOf._\'23caseor0_1'('FAIL'(_8798836),_8793594,'FAIL'(_8798836),_8798850,_8798850).

'Resolve.checkable._\'23caseor0'(_8800092,_8800094,_8800096,_8800098):-freeze(_8800096,'blocked_Resolve.checkable._\'23caseor0'(_8800092,_8800094,_8800096,_8800098)).
'blocked_Resolve.checkable._\'23caseor0'(_8800178,_8801000,_8801006,_8801012):-hnf(_8800178,_8802422,_8801006,_8802434),'blocked_Resolve.checkable._\'23caseor0_1'(_8802422,_8801000,_8802434,_8801012).

'blocked_Resolve.checkable._\'23caseor0_1'(_8802856,_8802858,_8802860,_8802862):-freeze(_8802860,freeze(_8802856,'blocked_blocked_Resolve.checkable._\'23caseor0_1'(_8802856,_8802858,_8802860,_8802862))).
'blocked_blocked_Resolve.checkable._\'23caseor0_1'('Prelude.True','Prelude.True',_8803246,_8803246).
'blocked_blocked_Resolve.checkable._\'23caseor0_1'('Prelude.False',_8804024,_8804030,_8804036):-!,hnf(reportFailure4PAKCS('Resolve.checkable._\'23caseor0',['Prelude.False']),_8804024,_8804030,_8804036).
'blocked_blocked_Resolve.checkable._\'23caseor0_1'('FAIL'(_8805258),'FAIL'(_8805258),_8805272,_8805272).

'Resolve.abstractOnly._\'23caseor0'(_8806620,_8806622,_8806624,_8806626):-freeze(_8806624,'blocked_Resolve.abstractOnly._\'23caseor0'(_8806620,_8806622,_8806624,_8806626)).
'blocked_Resolve.abstractOnly._\'23caseor0'(_8806706,_8807546,_8807552,_8807558):-hnf(_8806706,_8809076,_8807552,_8809088),'blocked_Resolve.abstractOnly._\'23caseor0_1'(_8809076,_8807546,_8809088,_8807558).

'blocked_Resolve.abstractOnly._\'23caseor0_1'(_8809528,_8809530,_8809532,_8809534):-freeze(_8809532,freeze(_8809528,'blocked_blocked_Resolve.abstractOnly._\'23caseor0_1'(_8809528,_8809530,_8809532,_8809534))).
'blocked_blocked_Resolve.abstractOnly._\'23caseor0_1'('Prelude.True','Prelude.True',_8809918,_8809918).
'blocked_blocked_Resolve.abstractOnly._\'23caseor0_1'('Prelude.False',_8810714,_8810720,_8810726):-!,hnf(reportFailure4PAKCS('Resolve.abstractOnly._\'23caseor0',['Prelude.False']),_8810714,_8810720,_8810726).
'blocked_blocked_Resolve.abstractOnly._\'23caseor0_1'('FAIL'(_8811984),'FAIL'(_8811984),_8811998,_8811998).

'Resolve.blocked._\'23caseor0'(_8813156,_8813158,_8813160,_8813162):-freeze(_8813160,'blocked_Resolve.blocked._\'23caseor0'(_8813156,_8813158,_8813160,_8813162)).
'blocked_Resolve.blocked._\'23caseor0'(_8813242,_8814052,_8814058,_8814064):-hnf(_8813242,_8815402,_8814058,_8815414),'blocked_Resolve.blocked._\'23caseor0_1'(_8815402,_8814052,_8815414,_8814064).

'blocked_Resolve.blocked._\'23caseor0_1'(_8815824,_8815826,_8815828,_8815830):-freeze(_8815828,freeze(_8815824,'blocked_blocked_Resolve.blocked._\'23caseor0_1'(_8815824,_8815826,_8815828,_8815830))).
'blocked_blocked_Resolve.blocked._\'23caseor0_1'('Prelude.True','Prelude.True',_8816214,_8816214).
'blocked_blocked_Resolve.blocked._\'23caseor0_1'('Prelude.False',_8816980,_8816986,_8816992):-!,hnf(reportFailure4PAKCS('Resolve.blocked._\'23caseor0',['Prelude.False']),_8816980,_8816986,_8816992).
'blocked_blocked_Resolve.blocked._\'23caseor0_1'('FAIL'(_8818190),'FAIL'(_8818190),_8818204,_8818204).

'Resolve.blockedItem._\'23caseor0'(_8819514,_8819516,_8819518,_8819520,_8819522):-freeze(_8819520,'blocked_Resolve.blockedItem._\'23caseor0'(_8819514,_8819516,_8819518,_8819520,_8819522)).
'blocked_Resolve.blockedItem._\'23caseor0'(_8819610,_8819628,_8820448,_8820454,_8820460):-hnf(_8819610,_8821950,_8820454,_8821968),'blocked_Resolve.blockedItem._\'23caseor0_1'(_8821950,_8819628,_8820448,_8821968,_8820460).

'blocked_Resolve.blockedItem._\'23caseor0_1'(_8822410,_8822412,_8822414,_8822416,_8822418):-freeze(_8822416,freeze(_8822410,'blocked_blocked_Resolve.blockedItem._\'23caseor0_1'(_8822410,_8822412,_8822414,_8822416,_8822418))).
'blocked_blocked_Resolve.blockedItem._\'23caseor0_1'('Prelude.True',_8819628,_8822804,_8822810,_8822816):-hnf(_8819628,_8822804,_8822810,_8822816).
'blocked_blocked_Resolve.blockedItem._\'23caseor0_1'('Prelude.False',_8819628,_8823604,_8823610,_8823616):-!,hnf(reportFailure4PAKCS('Resolve.blockedItem._\'23caseor0',['Prelude.False']),_8823604,_8823610,_8823616).
'blocked_blocked_Resolve.blockedItem._\'23caseor0_1'('FAIL'(_8824936),_8819628,'FAIL'(_8824936),_8824950,_8824950).

'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0'(_8827122,_8827124,_8827126,_8827128):-freeze(_8827126,'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0'(_8827122,_8827124,_8827126,_8827128)).
'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0'(_8827208,_8828968,_8828974,_8828980):-hnf(_8827208,_8831362,_8828974,_8831374),'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0_1'(_8831362,_8828968,_8831374,_8828980).

'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0_1'(_8831958,_8831960,_8831962,_8831964):-freeze(_8831962,freeze(_8831958,'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0_1'(_8831958,_8831960,_8831962,_8831964))).
'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0_1'([_8827324|_8827342],_8832234,_8832240,_8832246):-hnf(_8827324,_8832234,_8832240,_8832246).
'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0_1'([],['^u','^n','^k','^n','^o','^w','^n'],_8833100,_8833100):-!.
'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23caseor0_1'('FAIL'(_8835080),'FAIL'(_8835080),_8835094,_8835094).

'Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0'(_8837666,_8837668,_8837670,_8837672):-freeze(_8837670,'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0'(_8837666,_8837668,_8837670,_8837672)).
'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0'(_8837752,_8843092,_8843098,_8843104):-hnf(_8837752,_8845918,_8843098,_8845930),'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0_1'(_8845918,_8843092,_8845930,_8843104).

'blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0_1'(_8846586,_8846588,_8846590,_8846592):-freeze(_8846590,freeze(_8846586,'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0_1'(_8846586,_8846588,_8846590,_8846592))).
'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0_1'('Prelude.True',['^d','^e','^r','^i','^v','^a','^t','^i','^o','^n',^-,'^b','^a','^s','^e'],_8846976,_8846976).
'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0_1'('Prelude.False',['^d','^e','^r','^i','^v','^a','^t','^i','^o','^n',^-,'^s','^t','^e','^p'],_8850948,_8850948):-!.
'blocked_blocked_Resolve.derivationIO._\'23lambda4._\'23lambda6._\'23lambda9._\'23caseor0_1'('FAIL'(_8854616),'FAIL'(_8854616),_8854630,_8854630).

'Resolve.moonTrans._\'23caseor0'(_8855864,_8855866,_8855868,_8855870):-freeze(_8855868,'blocked_Resolve.moonTrans._\'23caseor0'(_8855864,_8855866,_8855868,_8855870)).
'blocked_Resolve.moonTrans._\'23caseor0'(_8855950,_8856772,_8856778,_8856784):-hnf(_8855950,_8858194,_8856778,_8858206),'blocked_Resolve.moonTrans._\'23caseor0_1'(_8858194,_8856772,_8858206,_8856784).

'blocked_Resolve.moonTrans._\'23caseor0_1'(_8858628,_8858630,_8858632,_8858634):-freeze(_8858632,freeze(_8858628,'blocked_blocked_Resolve.moonTrans._\'23caseor0_1'(_8858628,_8858630,_8858632,_8858634))).
'blocked_blocked_Resolve.moonTrans._\'23caseor0_1'('Prelude.True','Prelude.True',_8859018,_8859018).
'blocked_blocked_Resolve.moonTrans._\'23caseor0_1'('Prelude.False',_8859796,_8859802,_8859808):-!,hnf(reportFailure4PAKCS('Resolve.moonTrans._\'23caseor0',['Prelude.False']),_8859796,_8859802,_8859808).
'blocked_blocked_Resolve.moonTrans._\'23caseor0_1'('FAIL'(_8861030),'FAIL'(_8861030),_8861044,_8861044).

'Resolve.moonTransDepOf._\'23caseor0'(_8862468,_8862470,_8862472,_8862474,_8862476):-freeze(_8862474,'blocked_Resolve.moonTransDepOf._\'23caseor0'(_8862468,_8862470,_8862472,_8862474,_8862476)).
'blocked_Resolve.moonTransDepOf._\'23caseor0'(_8862564,_8862582,_8863420,_8863426,_8863432):-hnf(_8862564,_8865030,_8863426,_8865048),'blocked_Resolve.moonTransDepOf._\'23caseor0_1'(_8865030,_8862582,_8863420,_8865048,_8863432).

'blocked_Resolve.moonTransDepOf._\'23caseor0_1'(_8865508,_8865510,_8865512,_8865514,_8865516):-freeze(_8865514,freeze(_8865508,'blocked_blocked_Resolve.moonTransDepOf._\'23caseor0_1'(_8865508,_8865510,_8865512,_8865514,_8865516))).
'blocked_blocked_Resolve.moonTransDepOf._\'23caseor0_1'('Prelude.True',_8862582,_8865902,_8865908,_8865914):-hnf(_8862582,_8865902,_8865908,_8865914).
'blocked_blocked_Resolve.moonTransDepOf._\'23caseor0_1'('Prelude.False',_8862582,_8866720,_8866726,_8866732):-!,hnf(reportFailure4PAKCS('Resolve.moonTransDepOf._\'23caseor0',['Prelude.False']),_8866720,_8866726,_8866732).
'blocked_blocked_Resolve.moonTransDepOf._\'23caseor0_1'('FAIL'(_8868088),_8862582,'FAIL'(_8868088),_8868102,_8868102).

'Resolve.cycTransN._\'23caseor0'(_8869344,_8869346,_8869348,_8869350):-freeze(_8869348,'blocked_Resolve.cycTransN._\'23caseor0'(_8869344,_8869346,_8869348,_8869350)).
'blocked_Resolve.cycTransN._\'23caseor0'(_8869430,_8870252,_8870258,_8870264):-hnf(_8869430,_8871674,_8870258,_8871686),'blocked_Resolve.cycTransN._\'23caseor0_1'(_8871674,_8870252,_8871686,_8870264).

'blocked_Resolve.cycTransN._\'23caseor0_1'(_8872108,_8872110,_8872112,_8872114):-freeze(_8872112,freeze(_8872108,'blocked_blocked_Resolve.cycTransN._\'23caseor0_1'(_8872108,_8872110,_8872112,_8872114))).
'blocked_blocked_Resolve.cycTransN._\'23caseor0_1'('Prelude.True','Prelude.True',_8872498,_8872498).
'blocked_blocked_Resolve.cycTransN._\'23caseor0_1'('Prelude.False',_8873276,_8873282,_8873288):-!,hnf(reportFailure4PAKCS('Resolve.cycTransN._\'23caseor0',['Prelude.False']),_8873276,_8873282,_8873288).
'blocked_blocked_Resolve.cycTransN._\'23caseor0_1'('FAIL'(_8874510),'FAIL'(_8874510),_8874524,_8874524).

'Resolve.cycReachTarget._\'23caseor0'(_8875948,_8875950,_8875952,_8875954,_8875956):-freeze(_8875954,'blocked_Resolve.cycReachTarget._\'23caseor0'(_8875948,_8875950,_8875952,_8875954,_8875956)).
'blocked_Resolve.cycReachTarget._\'23caseor0'(_8876044,_8876062,_8876900,_8876906,_8876912):-hnf(_8876044,_8878510,_8876906,_8878528),'blocked_Resolve.cycReachTarget._\'23caseor0_1'(_8878510,_8876062,_8876900,_8878528,_8876912).

'blocked_Resolve.cycReachTarget._\'23caseor0_1'(_8878988,_8878990,_8878992,_8878994,_8878996):-freeze(_8878994,freeze(_8878988,'blocked_blocked_Resolve.cycReachTarget._\'23caseor0_1'(_8878988,_8878990,_8878992,_8878994,_8878996))).
'blocked_blocked_Resolve.cycReachTarget._\'23caseor0_1'('Prelude.True',_8876062,_8879382,_8879388,_8879394):-hnf(_8876062,_8879382,_8879388,_8879394).
'blocked_blocked_Resolve.cycReachTarget._\'23caseor0_1'('Prelude.False',_8876062,_8880200,_8880206,_8880212):-!,hnf(reportFailure4PAKCS('Resolve.cycReachTarget._\'23caseor0',['Prelude.False']),_8880200,_8880206,_8880212).
'blocked_blocked_Resolve.cycReachTarget._\'23caseor0_1'('FAIL'(_8881568),_8876062,'FAIL'(_8881568),_8881582,_8881582).

:-costCenters(['']).




%%%%% Number of shared variables: 37

