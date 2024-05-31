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
/*	%let _FlYr_1516_ = 2015-16;
	%let _FlYr_1617_ = 2016-17;
	%let _FlYr_1718_ = 2017-18;
	%let _FlYr_1819_ = 2018-19;
	%let _FlYr_1920_ = 2019-20;
	%let _FlYr_2021_ = 2020-21;	*/
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
		var SS_TOT SEM_TOTSS SS_SRC1 SEM_SRC1 SS_SRC2 SEM_SRC2 SS_SRC3 SEM_SRC3
			%if %eval("&Subj."="ELA") %then %do;
				SS_SRC4 SEM_SRC4
			%end;
			;
		class GradeLevelWhenAssessed ;
		tables GradeLevelWhenAssessed = '' all='Total' * F=comma8. , all='Number of Students' * F=comma8.
			(SS_TOT = 'Total Score Mean' SEM_TOTSS = 'Total Score SEM'
				SS_SRC1 = 'Claim 1 Mean' SEM_SRC1 = 'Claim 1 SEM'
				%if %eval("&Subj."="ELA") %then %do;
					SS_SRC3 = 'Claim 2 Mean' SEM_SRC3 = 'Claim 2 SEM'
					SS_SRC2 = 'Claim 3 Mean' SEM_SRC2 = 'Claim 3 SEM'
					SS_SRC4 = 'Claim 4 Mean' SEM_SRC4 = 'Claim 4 SEM'
				%end;
				%else %do;
					SS_SRC2 = 'Claim 2 & 4 Mean' SEM_SRC2 = 'Claim 2 & 4 SEM'
					SS_SRC3 = 'Claim 3 Mean' SEM_SRC3 = 'Claim 3 SEM'
				%end;
				)  * (Mean = '' * F=5.0) / BOX = 'Grade';
	run;
	ods &odstype. close;
%mend WriteSumrySS;

%macro ComptDmo(inDS, VarName, VarVal, MacVar);
	%global &MacVar. ;
	proc sql noprint;
		select count(*) into :&MacVar.
		from &inDS.
		where &VarName. = "&VarVal.";
	quit;
%mend ComptDmo;

%macro WriteDemos(ELAinDS, MathinDS, ST, Yr, outFyle, outType);
	*** Develop Ethnicity table *** ;
	%ComptDmo(&ELAinDS., AmericanIndianOrAlaskaNative, Yes, EAIoANVal);
	%ComptDmo(&ELAinDS., Asian, Yes, EAsnVal);
	%ComptDmo(&ELAinDS., BlackorAfricanAmerican, Yes, EBlkVal);
	%ComptDmo(&ELAinDS., HispanicOrLatinoEthnicity, Yes, EHispVal);
	%ComptDmo(&ELAinDS., NativeHawaiianOrOtherPacificIsla, Yes, ENHoOPIVal);
	%ComptDmo(&ELAinDS., DemographicRaceTwoOrMoreRaces, Yes, ETwoOrMrVal);
	%ComptDmo(&ELAinDS., White, Yes, EWhtVal);
	%ComptDmo(&MathinDS., AmericanIndianOrAlaskaNative, Yes, MAIoANVal);
	%ComptDmo(&MathinDS., Asian, Yes, MAsnVal);
	%ComptDmo(&MathinDS., BlackorAfricanAmerican, Yes, MBlkVal);
	%ComptDmo(&MathinDS., HispanicOrLatinoEthnicity, Yes, MHispVal);
	%ComptDmo(&MathinDS., NativeHawaiianOrOtherPacificIsla, Yes, MNHoOPIVal);
	%ComptDmo(&MathinDS., DemographicRaceTwoOrMoreRaces, Yes, MTwoOrMrVal);
	%ComptDmo(&MathinDS., White, Yes, MWhtVal);
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
	*** Develop School Group Table *** ;
	%ComptDmo(&ELAinDS., EconomicDisadvantageStatus, Yes, EEconDisVal);
	%ComptDmo(&ELAinDS., IDEAIndicator, Yes, EIEPVal);
	%ComptDmo(&ELAinDS., LEPStatus, Yes, ELEPVal);
	%ComptDmo(&ELAinDS., Section504Status, Yes, ES504Val);
	%ComptDmo(&MathinDS., EconomicDisadvantageStatus, Yes, MEconDisVal);
	%ComptDmo(&MathinDS., IDEAIndicator, Yes, MIEPVal);
	%ComptDmo(&MathinDS., LEPStatus, Yes, MLEPVal);
	%ComptDmo(&MathinDS., Section504Status, Yes, MS504Val);
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
		tables GradeLevelWhenAssessed / missing noprint out=&Subj._ASL (drop=percent);
		where AssessmentAccommodation like '%TDS_ASL1%';
	run;
	***	Need to program Braille count acquisition	*** ;
	proc freq data=&inDS.;
		tables GradeLevelWhenAssessed / missing noprint out=&Subj._Braille (drop=percent);
		%if %eval("&ST."="DE") %then %do;
			where AssessmentAccommodation like '%Braille_1%';
		%end;
		%else %do;
			where AssessmentAccommodation like '%Braille%';
		%end;
	run;
	%if &Subj.=Math %then %do;
		*** Math has Spanish Translation and Translated Glossary as well as ASL and Braille *** ;
		proc sql;
			create table _SpnTrns_ as
			select * from &inDS.
			where ((AssessmentAccommodation like 'ESN,%') or (AssessmentAccommodation like '%,ESN,%'));
		quit;
		proc freq data=_SpnTrns_;
			tables GradeLevelWhenAssessed / missing noprint out=&Subj._SpanTrans (drop=percent);
		run;
		proc sql;
			create table _TrnsGlss_ as
			select * from &inDS.
			where ((AssessmentAccommodation like '%TDS_WL_ArabicGloss%') or (AssessmentAccommodation like '%TDS_WL_CantoneseGloss%')
				or (AssessmentAccommodation like '%TDS_WL_TagalGloss%') or (AssessmentAccommodation like '%TDS_WL_KoreanGloss%')
				or (AssessmentAccommodation like '%TDS_WL_MandarinGloss%') or (AssessmentAccommodation like '%TDS_WL_PunjabiGloss%')
				or (AssessmentAccommodation like '%TDS_WL_RussianGloss%') or (AssessmentAccommodation like '%TDS_WL_ESNGlossary%')
				or (AssessmentAccommodation like '%TDS_WL_UkrainianGloss%') or (AssessmentAccommodation like '%TDS_WL_VietnameseGloss%'));
		quit;
		proc freq data=_TrnsGlss_;
			tables GradeLevelWhenAssessed / missing noprint out=&Subj._TransGloss (drop=percent);
		run;
		data Math_Accessbls (rename=(GradeLevelWhenAssessed=Grade));
			merge Math_ASL (rename=(count=asl)) Math_Braille (rename=(count=Braille))
						Math_SpanTrans (rename=(count=SpanTrans))
						Math_TransGloss (rename=(count=TransGloss));
			by GradeLevelWhenAssessed;
		run;
	%end;
	%else %if &Subj.=ELA %then %do;
		*** merge ASL and Braille for ELA *** ;
		data ELA_Accessbls (rename=(GradeLevelWhenAssessed=Grade));
			merge ELA_ASL (rename=(count=asl)) ELA_Braille (rename=(count=Braille));
			by GradeLevelWhenAssessed;
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
		tables GradeLevelWhenAssessed / missing noprint out=&Subj._PP (drop=percent);
		where TestMode = 'P';
	run;
	proc print data=&Subj._PP (rename=(count=PP GradeLevelWhenAssessed=Grade)) noobs;
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