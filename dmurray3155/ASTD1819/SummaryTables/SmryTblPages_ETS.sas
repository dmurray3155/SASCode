%macro StateName(ST);
	%global _StNm_&ST._;
	%let _StNm_CA_ = California;
	%let _StNm_DE_ = Delaware;
	%let _StNm_HI_ = Hawaii;
	%let _StNm_ID_ = Idaho;
	%let _StNm_OR_ = Oregon;
	%let _StNm_SD_ = South Dakota;
	%let _StNm_USVI_ = U.S. Virgin Islands;
	%let _StNm_VT_ = Vermont;
	%let _StNm_WA_ = Washington;
%mend StateName;

%macro SubjName(Subj);
	%global _SubjNm_&Subj._;
	%let _SubjNm_ELA_ = ELA/Literacy;
	%let _SubjNm_Math_ = Mathematics;
%mend SubjName;

%macro FullYear(yr);
	%global _FlYr_&yr._;
	%let _FlYr_&yr._ = 20%substr(&yr., 1, 2)-%substr(&yr., 3, 2);
%mend FullYear;

%macro WriteSumrySS(Subj, inDS, ST, Yr, outFyle, outType);
	%StateName(&ST.);		%SubjName(&Subj.);		%FullYear(&Yr.);
	%if &outType=xlsx %then %let odstype=EXCEL;
	%else %let odstype=&outType.;
	ods &odstype. file="&outFyle." options(embedded_titles='yes' start_at='2,1');
	/*	Use proc tabulate to create the Scaled Scores page	*/
	Title1 "&&_StNm_&ST._. &&_FlYr_&Yr._.";
	Title2 "Scaled Scores";
	Title3 "&&_SubjNm_&Subj._.";
	proc tabulate data=&inDS.;
		var overallScaleScore overallScaleScoreSE claim1ScaleScore claim1ScaleScoreSE
				claim2ScaleScore claim2ScaleScoreSE claim3ScaleScore claim3ScaleScoreSE
			%if %eval("&Subj."="ELA") %then %do;
				claim4ScaleScore claim4ScaleScoreSE
			%end;
			;
		class grade ;
		tables grade = '' all='Total' * F=comma8. , all='Number of Students' * F=comma8.
			(overallScaleScore = 'Total Score Mean' overallScaleScoreSE = 'Total Score SEM'
				claim1ScaleScore = 'Claim 1 Mean' claim1ScaleScoreSE = 'Claim 1 SEM'
				%if %eval("&Subj."="ELA") %then %do;
					claim2ScaleScore = 'Claim 2 Mean' claim2ScaleScoreSE = 'Claim 2 SEM'
					claim3ScaleScore = 'Claim 3 Mean' claim3ScaleScoreSE = 'Claim 3 SEM'
					claim4ScaleScore = 'Claim 4 Mean' claim4ScaleScoreSE = 'Claim 4 SEM'
				%end;
				%else %do;
					claim2ScaleScore = 'Claim 2 & 4 Mean' claim2ScaleScoreSE = 'Claim 2 & 4 SEM'
					claim3ScaleScore = 'Claim 3 Mean' claim3ScaleScoreSE = 'Claim 3 SEM'
				%end;
				)  * (Mean = '' * F=5.0) / BOX = 'Grade';
	run;
	ods &odstype. close;
%mend WriteSumrySS;

%macro DecodeEthnVec(fieldName, binVecPos);
	binvec = compress(put(ethnicityValue, binary8.));
	&fieldName. = put(substr(binvec, &binVecPos., 1), $fmt_YN.);
%mend DecodeEthnVec;

%macro DecodeSchlSubGrpVec(fieldName, binVecPos);
	binvec = compress(put(educationSubgroupValue, binary7.));
	&fieldName. = put(substr(binvec, &binVecPos., 1), $fmt_YN.);
%mend DecodeSchlSubGrpVec;

%macro ComptDmo(inDS, VarName, VarVal, MacVar);
	%global &MacVar. ;
	proc sql noprint;
		select count(*) into :&MacVar.
		from &inDS.
		where &VarName. = "&VarVal.";
	quit;
%mend ComptDmo;

%macro WriteDemos(ELAinDS, MathinDS, ST, Yr, outFyle, outType);
	proc format;
   	value $fmt_YN
    	   '0'='No'
     	  '1'='Yes'
    	other =' ' ;
	run;
	data &ELAinDS. (compress=yes);
		set &ELAinDS.;
		%DecodeEthnVec(HispYN, 1);
		%DecodeEthnVec(AmerIndYN, 2);
		%DecodeEthnVec(AsianYN, 3);
		%DecodeEthnVec(BlackYN, 4);
		%DecodeEthnVec(WhiteYN, 5);
		%DecodeEthnVec(NatHawaiianYN, 6);
		%DecodeEthnVec(TwoOrMoreYN, 7);
	run;
	*** Develop Ethnicity table for ELA *** ;
	%ComptDmo(&ELAinDS., AmerIndYN, Yes, EAIoANVal);
	%ComptDmo(&ELAinDS., AsianYN, Yes, EAsnVal);
	%ComptDmo(&ELAinDS., BlackYN, Yes, EBlkVal);
	%ComptDmo(&ELAinDS., HispYN, Yes, EHispVal);
	%ComptDmo(&ELAinDS., NatHawaiianYN, Yes, ENHoOPIVal);
	%ComptDmo(&ELAinDS., TwoOrMoreYN, Yes, ETwoOrMrVal);
	%ComptDmo(&ELAinDS., WhiteYN, Yes, EWhtVal);
	data &MathinDS. (compress=yes);
		set &MathinDS.;
		%DecodeEthnVec(HispYN, 1);
		%DecodeEthnVec(AmerIndYN, 2);
		%DecodeEthnVec(AsianYN, 3);
		%DecodeEthnVec(BlackYN, 4);
		%DecodeEthnVec(WhiteYN, 5);
		%DecodeEthnVec(NatHawaiianYN, 6);
		%DecodeEthnVec(TwoOrMoreYN, 7);
	run;
	*** Develop Ethnicity table for Math *** ;
	%ComptDmo(&MathinDS., AmerIndYN, Yes, MAIoANVal);
	%ComptDmo(&MathinDS., AsianYN, Yes, MAsnVal);
	%ComptDmo(&MathinDS., BlackYN, Yes, MBlkVal);
	%ComptDmo(&MathinDS., HispYN, Yes, MHispVal);
	%ComptDmo(&MathinDS., NatHawaiianYN, Yes, MNHoOPIVal);
	%ComptDmo(&MathinDS., TwoOrMoreYN, Yes, MTwoOrMrVal);
	%ComptDmo(&MathinDS., WhiteYN, Yes, MWhtVal);
	data EthnTable;
		format REName $32. ELAFrqs MathFrqs comma12.;
		REName = 'American Indian/Alaska Native';		ELAFrqs = &EAIoANVal.;		MathFrqs = &MAIoANVal.;		output;
		REName = 'Asian';		ELAFrqs = &EAsnVal.;		MathFrqs = &MAsnVal.;		output;
		REName = 'Black';		ELAFrqs = &EBlkVal.;		MathFrqs = &MBlkVal.;		output;
		REName = 'Hispanic Latino';		ELAFrqs = &EHispVal.;		MathFrqs = &MHispVal.;		output;
		REName = 'Hawaiian or Pacific Islander';		ELAFrqs = &ENHoOPIVal.;		MathFrqs = &MNHoOPIVal.;		output;
		REName = 'Mixed';		ELAFrqs = &ETwoOrMrVal.;		MathFrqs = &MTwoOrMrVal.;		output;
		REName = 'Caucasian';		ELAFrqs = &EWhtVal.;		MathFrqs = &MWhtVal.;		output;
		REName = 'Total';		ELAFrqs = sum(&EAIoANVal., &EAsnVal., &EBlkVal., &EHispVal., &ENHoOPIVal., &ETwoOrMrVal., &EWhtVal.);
			MathFrqs = sum(&MAIoANVal., &MAsnVal., &MBlkVal., &MHispVal., &MNHoOPIVal., &MTwoOrMrVal., &MWhtVal.);		output;
		label REName='Race/Ethnicity' ELAFrqs='ELA/Literacy' MathFrqs='Mathematics';
	run;
	*** Develop Gender Table *** ;
	%ComptDmo(&ELAinDS., Sex, Female, EFVal);
	%ComptDmo(&ELAinDS., Sex, Male, EMVal);
	%ComptDmo(&MathinDS., Sex, Female, MFVal);
	%ComptDmo(&MathinDS., Sex, Male, MMVal);
	data GendTable;
		format SxName $9. ELAFrqs MathFrqs comma12.;
		SxName = 'Female';	ELAFrqs = &EFVal.;	MathFrqs = &MFVal.;		output;
		SxName = 'Male';	ELAFrqs = &EMVal.;		MathFrqs = &MMVal.;		output;
		SxName = 'Total';		ELAFrqs = sum(&EFVal., &EMVal.);		MathFrqs = sum(&MFVal., &MMVal.);		output;
		label SxName='Gender' ELAFrqs='ELA/Literacy' MathFrqs='Mathematics';
	run;
	data &ELAinDS. (compress=yes);
		set &ELAinDS.;
		%DecodeSchlSubGrpVec(EconDisadvYN, 5);
		%DecodeSchlSubGrpVec(IDEAYN, 1);
		%DecodeSchlSubGrpVec(LEPYN, 2);
		%DecodeSchlSubGrpVec(Sec504YN, 4);
	run;
	*** Develop School Group Table for ELA *** ;
	%ComptDmo(&ELAinDS., EconDisadvYN, Yes, EEconDisVal);
	%ComptDmo(&ELAinDS., IDEAYN, Yes, EIEPVal);
	%ComptDmo(&ELAinDS., LEPYN, Yes, ELEPVal);
	%ComptDmo(&ELAinDS., Sec504YN, Yes, ES504Val);
	data &MathinDS. (compress=yes);
		set &MathinDS.;
		%DecodeSchlSubGrpVec(EconDisadvYN, 5);
		%DecodeSchlSubGrpVec(IDEAYN, 1);
		%DecodeSchlSubGrpVec(LEPYN, 2);
		%DecodeSchlSubGrpVec(Sec504YN, 4);
	run;
	*** Develop School Group Table for Math *** ;
	%ComptDmo(&MathinDS., EconDisadvYN, Yes, MEconDisVal);
	%ComptDmo(&MathinDS., IDEAYN, Yes, MIEPVal);
	%ComptDmo(&MathinDS., LEPYN, Yes, MLEPVal);
	%ComptDmo(&MathinDS., Sec504YN, Yes, MS504Val);
	data SchlGrpTable;
		format SGName $24. ELAFrqs MathFrqs comma12.;
		SGName = 'Economic Disadvantage';		ELAFrqs = &EEconDisVal.;		MathFrqs = &MEconDisVal.;		output;
		SGName = 'IEP';		ELAFrqs = &EIEPVal.;		MathFrqs = &MIEPVal.;		output;
		SGName = 'LEP';		ELAFrqs = &ELEPVal.;		MathFrqs = &MLEPVal.;		output;
		SGName = '504';		ELAFrqs = &ES504Val.;		MathFrqs = &MS504Val.;		output;
		label SGName='Student Program*' ELAFrqs='ELA/Literacy' MathFrqs='Mathematics';
	run;
	%StateName(&ST.);		%FullYear(&Yr.);
	%if &outType=xlsx %then %let odstype=EXCEL;
	%else %let odstype=&outType.;
	ods &odstype. file="&outFyle." options(embedded_titles='yes' embedded_footnotes='yes' start_at='2,1');
	Title1 "&&_StNm_&ST._. &&_FlYr_&Yr._.";
	Title2 "Student Demographics";
	Footnote "Total may not represent the total number of students since students can choose multiple race/ethnicity";
	proc print data=EthnTable noobs label;
	run;
	Title1;		Title2;		Footnote;
	proc print data=GendTable noobs label;
	run;
	Footnote "*Programs are not mutually exclusive.  The count for each program is based on totals above.";
	proc print data=SchlGrpTable noobs label;
	run;
	ods &odstype. close;
%mend WriteDemos;

%macro WriteAccessbs(Subj, inDS, ST, Yr, outFyle, outType);
	%StateName(&ST.);		%SubjName(&Subj.);		%FullYear(&Yr.);
	%if &outType=xlsx %then %let odstype=EXCEL;
	%else %let odstype=&outType.;
	ods &odstype. file="&outFyle." options(embedded_titles='yes' start_at='2,1');
	Title1 "&&_StNm_&ST._. &&_FlYr_&Yr._.";
	Title2 "Scaled Scores";
	Title3 "&&_SubjNm_&Subj._.";
	proc freq data=&inDS.;
		tables grade / missing noprint out=&Subj._ASL (drop=percent);
		where accomASL = 'TDS_ASL1';
	run;
	***	Need to program Braille count acquisition	*** ;
	proc freq data=&inDS.;
		tables grade / missing noprint out=&Subj._Braille (drop=percent);
		where accomBraille in ('TDS_BT_ECN', 'TDS_BT_UCN', 'TDS_BT_ECL', 'TDS_BT_UCL', 'TDS_BT_UCT', 'TDS_BT_UXN', 'TDS_BT_UXL');
	run;
	%if &Subj.=Math %then %do;
		*** Math has Spanish Translation and Translated Glossary as well as ASL and Braille *** ;
		proc sql;
			create table _SpnTrns_ as
			select * from &inDS.
			where accomSpanTrans = 'ESN';
		quit;
		proc freq data=_SpnTrns_;
			tables grade / missing noprint out=&Subj._SpanTrans (drop=percent);
		run;
		proc sql;
			create table _TrnsGlss_ as
			select * from &inDS.
			where ((accomTransGloss like 'TDS_WL_ArabicGloss%') or (accomTransGloss like 'TDS_WL_CantoneseGloss%')
				or (accomTransGloss like 'TDS_WL_TagalGloss%') or (accomTransGloss like 'TDS_WL_KoreanGloss%')
				or (accomTransGloss like 'TDS_WL_MandarinGloss%') or (accomTransGloss like 'TDS_WL_PunjabiGloss%')
				or (accomTransGloss like 'TDS_WL_RussianGloss%') or (accomTransGloss like 'TDS_WL_ESNGlossary%')
				or (accomTransGloss like 'TDS_WL_UkrainianGloss%') or (accomTransGloss like 'TDS_WL_VietnameseGloss%'));
		quit;
		proc freq data=_TrnsGlss_;
			tables grade / missing noprint out=&Subj._TransGloss (drop=percent);
		run;
		data Math_Accessbls ;
			merge Math_ASL (rename=(count=asl)) Math_Braille (rename=(count=Braille))
						Math_SpanTrans (rename=(count=SpanTrans))
						Math_TransGloss (rename=(count=TransGloss));
			by grade;
		run;
	%end;
	%else %if &Subj.=ELA %then %do;
		*** merge ASL and Braille for ELA *** ;
		data ELA_Accessbls ;
			merge ELA_ASL (rename=(count=asl)) ELA_Braille (rename=(count=Braille));
			by grade;
		run;
	%end;
	proc print data=&Subj._Accessbls noobs;
	run;
	ods &odstype. close;
%mend WriteAccessbs;

%macro WritePP(Subj, inDS, ST, Yr, outFyle, outType);
	%StateName(&ST.);		%SubjName(&Subj.);		%FullYear(&Yr.);
	%if &outType=xlsx %then %let odstype=EXCEL;
	%else %let odstype=&outType.;
	ods &odstype. file="&outFyle." options(embedded_titles='yes' start_at='2,1');
	Title1 "&&_StNm_&ST._. &&_FlYr_&Yr._.";
	Title2 "Scaled Scores";
	Title3 "&&_SubjNm_&Subj._.";
	proc freq data=&inDS.;
		tables grade / missing noprint out=&Subj._PP (drop=percent);
	*	where testMode = 'paper';
		where testId like '%-DEI-%';
	run;
	proc print data=&Subj._PP (rename=(count=PP)) noobs;
	run;
	ods &odstype. close;
%mend WritePP;

%macro DataDict(Vendor, ST, Yr, outFyle, outType);
	libname thislib "E:\SBAC\AnnualStudTest\&Yr.\AIR";
	%if &outType=xlsx %then %let odstype=EXCEL;
	%else %let odstype=&outType.;
	ods &odstype. file="&outFyle." options(embedded_titles='yes' start_at='2,1');
	title1 'Data Dictionary';
	title2;
	proc print data=thislib.AIRDD_SD1718 noobs label;
	run;
	ods &odstype. close;
%mend DataDict;