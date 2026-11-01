%PAKCS3.9 swi9 VARIABLESHARING

:-noSingletonWarnings.
:-noRedefineWarnings.
:-noDiscontiguousWarnings.

:-importModule('Prelude').

:-curryModule('FactsCyclic').


%%%%%%%%%%%% function types %%%%%%%%%%%%%%%%%%%
:-multifile functiontype/6.
:-dynamic functiontype/6.
functiontype('FactsCyclic.cycDependsOn',cycDependsOn,2,'FactsCyclic.cycDependsOn',nofix,notype).

%%%%%%%%%%%% constructor types %%%%%%%%%%%%%%%%%%%
:-multifile constructortype/7.
:-dynamic constructortype/7.

%%%%%%%%%%%% function definitions %%%%%%%%%%%%%%%%%%%
'FactsCyclic.cycDependsOn'(_5427734,_5427736,_5427738,_5427740,_5427742):-freeze(_5427740,'blocked_FactsCyclic.cycDependsOn'(_5427734,_5427736,_5427738,_5427740,_5427742)).
'blocked_FactsCyclic.cycDependsOn'(_5427830,_5427848,_5433164,_5433170,_5433176):-hnf(_5427830,_5434414,_5433170,_5434432),'blocked_FactsCyclic.cycDependsOn_1'(_5434414,_5427848,_5433164,_5434432,_5433176).

'blocked_FactsCyclic.cycDependsOn_1'(_5434826,_5434828,_5434830,_5434832,_5434834):-freeze(_5434832,'blocked_blocked_FactsCyclic.cycDependsOn_1'(_5434826,_5434828,_5434830,_5434832,_5434834)).
'blocked_blocked_FactsCyclic.cycDependsOn_1'([_5427964|_5427982],_5427848,_5435590,_5435596,_5435602):-!,hnf(_5427964,_5437320,_5435596,_5437344),'blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1'(_5437320,_5427982,_5427848,_5435590,_5437344,_5435602).

'blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1'(_5437848,_5437850,_5437852,_5437854,_5437856,_5437858):-freeze(_5437856,'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1'(_5437848,_5437850,_5437852,_5437854,_5437856,_5437858)).
'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1'('^a',_5427982,_5427848,_5438362,_5438368,_5438374):-hnf(_5427982,_5440574,_5438368,_5440592),'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1'(_5440574,_5427848,_5438362,_5440592,_5438374).

'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1'(_5441148,_5441150,_5441152,_5441154,_5441156):-freeze(_5441154,'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1'(_5441148,_5441150,_5441152,_5441154,_5441156)).
'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1'([],_5427848,_5442046,_5442052,_5442058):-!,hnf(_5427848,_5444718,_5442052,_5444730),'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1'(_5444718,_5442046,_5444730,_5442058).

'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1'(_5445374,_5445376,_5445378,_5445380):-freeze(_5445378,'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1'(_5445374,_5445376,_5445378,_5445380)).
'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1'([_5428300|_5428318],_5446368,_5446374,_5446380):-!,hnf(_5428300,_5449530,_5446374,_5449548),'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1'(_5449530,_5428318,_5446368,_5449548,_5446380).

'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1'(_5450284,_5450286,_5450288,_5450290,_5450292):-freeze(_5450290,'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1'(_5450284,_5450286,_5450288,_5450290,_5450292)).
'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1'('^b',_5428318,_5451028,_5451034,_5451040):-hnf(_5428318,_5454672,_5451034,_5454684),'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1_^b_1'(_5454672,_5451028,_5454684,_5451040).

'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1_^b_1'(_5455472,_5455474,_5455476,_5455478):-freeze(_5455476,'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1_^b_1'(_5455472,_5455474,_5455476,_5455478)).
'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1_^b_1'([],'Prelude.True',_5455922,_5455922):-!.
'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1_^b_1'([_5428638|_5428656],_5456964,_5456970,_5456976):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[_5428638|_5428656]]),_5456964,_5456970,_5456976).
'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1_^b_1'('FAIL'(_5458792),'FAIL'(_5458792),_5458806,_5458806).
'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1_[|]_1'('FAIL'(_5458858),_5428318,'FAIL'(_5458858),_5458872,_5458872):-nonvar(_5458858).
'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1'([],_5459098,_5459104,_5459110):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[]]),_5459098,_5459104,_5459110).
'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1_[]_1'('FAIL'(_5460430),'FAIL'(_5460430),_5460444,_5460444).
'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1'([_5429716|_5429734],_5427848,_5460686,_5460692,_5460698):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[_5429716|_5429734]]),_5460686,_5460692,_5460698).
'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^a_1'('FAIL'(_5462348),_5427848,'FAIL'(_5462348),_5462362,_5462362).
'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1'('^b',_5427982,_5427848,_5462836,_5462842,_5462848):-hnf(_5427982,_5465048,_5462842,_5465066),'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1'(_5465048,_5427848,_5462836,_5465066,_5462848).

'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1'(_5465622,_5465624,_5465626,_5465628,_5465630):-freeze(_5465628,'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1'(_5465622,_5465624,_5465626,_5465628,_5465630)).
'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1'([],_5427848,_5466520,_5466526,_5466532):-!,hnf(_5427848,_5469192,_5466526,_5469204),'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1'(_5469192,_5466520,_5469204,_5466532).

'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1'(_5469848,_5469850,_5469852,_5469854):-freeze(_5469852,'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1'(_5469848,_5469850,_5469852,_5469854)).
'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1'([_5430536|_5430554],_5470842,_5470848,_5470854):-!,hnf(_5430536,_5474004,_5470848,_5474022),'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1'(_5474004,_5430554,_5470842,_5474022,_5470854).

'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1'(_5474758,_5474760,_5474762,_5474764,_5474766):-freeze(_5474764,'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1'(_5474758,_5474760,_5474762,_5474764,_5474766)).
'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1'('^a',_5430554,_5475502,_5475508,_5475514):-hnf(_5430554,_5479146,_5475508,_5479158),'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1_^a_1'(_5479146,_5475502,_5479158,_5475514).

'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1_^a_1'(_5479946,_5479948,_5479950,_5479952):-freeze(_5479950,'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1_^a_1'(_5479946,_5479948,_5479950,_5479952)).
'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1_^a_1'([],'Prelude.True',_5480396,_5480396):-!.
'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1_^a_1'([_5430874|_5430892],_5481438,_5481444,_5481450):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[_5430874|_5430892]]),_5481438,_5481444,_5481450).
'blocked_blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1_^a_1'('FAIL'(_5483266),'FAIL'(_5483266),_5483280,_5483280).
'blocked_blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1_[|]_1'('FAIL'(_5483332),_5430554,'FAIL'(_5483332),_5483346,_5483346):-nonvar(_5483332).
'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1'([],_5483572,_5483578,_5483584):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[]]),_5483572,_5483578,_5483584).
'blocked_blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1_[]_1'('FAIL'(_5484904),'FAIL'(_5484904),_5484918,_5484918).
'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1'([_5431952|_5431970],_5427848,_5485160,_5485166,_5485172):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[_5431952|_5431970]]),_5485160,_5485166,_5485172).
'blocked_blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1_^b_1'('FAIL'(_5486822),_5427848,'FAIL'(_5486822),_5486836,_5486836).
'blocked_blocked_blocked_FactsCyclic.cycDependsOn_1_[|]_1'('FAIL'(_5486896),_5427982,_5427848,'FAIL'(_5486896),_5486910,_5486910):-nonvar(_5486896).
'blocked_blocked_FactsCyclic.cycDependsOn_1'([],_5427848,_5487144,_5487150,_5487156):-!,hnf(reportFailure4PAKCS('FactsCyclic.cycDependsOn',[[]]),_5487144,_5487150,_5487156).
'blocked_blocked_FactsCyclic.cycDependsOn_1'('FAIL'(_5488310),_5427848,'FAIL'(_5488310),_5488324,_5488324).

:-costCenters(['']).




%%%%% Number of shared variables: 0

