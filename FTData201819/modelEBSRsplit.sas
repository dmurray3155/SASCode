options ls=150;
data testAIR;
	format fld_str $512.;
	fld_str = '{{{choiceInteraction_1.RESPONSE::choiceInteraction_1-choice-C}}}{{{choiceInteraction_2.RESPONSE::choiceInteraction_2-choice-E}}}';
	EBSR_Split_Loc = index(fld_str, '}}}{{{') + 3;
	EBSR_Part1 = substr(fld_str, 1, EBSR_Split_Loc - 1);
	EBSR_Part2 = substr(fld_str, EBSR_Split_Loc);
run;
proc print data=testAIR;
run;

data testETS;
	format fld_str $512.;
	fld_str = '<response id="choiceInteraction_1.RESPONSE"><value>choiceInteraction_1-choice-A</value></response><response id="choiceInteraction_2.RESPONSE"><value>choiceInteraction_2-choice-A</value></response>';
	EBSR_Split_Loc = index(fld_str, '</response><response id="choiceInteraction_2.RESPONSE">') + 11;
	EBSR_Part1 = substr(fld_str, 1, EBSR_Split_Loc - 1);
	EBSR_Part2 = substr(fld_str, EBSR_Split_Loc);
run;
proc print data=testETS;
run;

