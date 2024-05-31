/*==================================================================================================*
 | Program	:	ASTD_CA_Assemble_StudLvl.sas																													|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 11		Initial development (yeah.  Saturday.  sigh!)																			|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\ETS;
libname libHere "&wrkHere.";

%macro RenameTheVars;
	rename stateabbreviation = StateId
				districtId = districtCode
				schoolId = schoolCode
				studentId = studentIdentifier
				oppStatus = testStatus
				oppStartDate = AssmntSessActualStartDateTime
				overallThetaScore = TotalTheta
				overallScaleScore = ScaleScore
				overallPerformanceLevel = ScaleScoreAchievementLevel
				overallScaleScoreSE = SEM_ScaleScore
				%do clm=1 %to 4;
					claim&clm.ScaleScore = Claim&clm.Score
					claim&clm.ScaleScoreSE = Claim&clm.SEM
					claim&clm.PerformanceLevel = claim&clm.AchievementLevel
				%end;
				;
%mend RenameTheVars;

%Common_Fmts;
%let DlvryStub=E:\SBAC\AnnualStudTest\1819\DLVRY\ETS\Stud;
libname dlvrylib "&DlvryStub.";
%macro WrapBySubjGrd(SubjGrd);
	%SetDSLabel;
	%SAS_Merge(libHere.tab_&SubjGrd._18_19_stddata,
							libHere.&SubjGrd._itmaug4std (drop=oppkey), 
							studentId,
							dlvrylib.&SubjGrd._TR_Stud (compress=yes label="&DSLabel."));
	data dlvrylib.&SubjGrd._TR_Stud (compress=yes label="&DSLabel.");
		set dlvrylib.&SubjGrd._TR_Stud (drop=syend);
			if sex='Male' then sex = 'M';
			else if sex='Female' then sex = 'F';
			if index(testId, '-DEI-') > 0 then testMode = 'P';
		*	if testId like '%-DEI-%' then testMode = 'P';	**;
			else testMode = 'O';
			HispanicOrLatinoEthnicity = put(substr(compress(put(ethnicityvalue, binary8.)), 1, 1), $fmt_YN.);
			AmericanIndianOrAlaskaNative = put(substr(compress(put(ethnicityvalue, binary8.)), 2, 1), $fmt_YN.);
			Asian = put(substr(compress(put(ethnicityvalue, binary8.)), 3, 1), $fmt_YN.);
			BlackOrAfricanAmerican = put(substr(compress(put(ethnicityvalue, binary8.)), 4, 1), $fmt_YN.);
			White = put(substr(compress(put(ethnicityvalue, binary8.)), 5, 1), $fmt_YN.);
			NativeHawaiianOrOtherPacificIsl = put(substr(compress(put(ethnicityvalue, binary8.)), 6, 1), $fmt_YN.);
			DemographicRaceTwoOrMoreRaces = put(substr(compress(put(ethnicityvalue, binary8.)), 7, 1), $fmt_YN.);
			Filipino = put(substr(compress(put(ethnicityvalue, binary8.)), 8, 1), $fmt_YN.);
			IDEAIndicator = put(substr(compress(put(educationsubgroupvalue, binary7.)), 1, 1), $fmt_YN.);
			LEPStatus = put(substr(compress(put(educationsubgroupvalue, binary7.)), 2, 1), $fmt_YN.);
		*	IEP = put(substr(compress(put(educationsubgroupvalue, binary7.)), 3, 1), $fmt_YN.);
			Section504Status = put(substr(compress(put(educationsubgroupvalue, binary7.)), 4, 1), $fmt_YN.);
			EconomicDisadvantageStatus = put(substr(compress(put(educationsubgroupvalue, binary7.)), 5, 1), $fmt_YN.);
	/*	Migrant = put(substr(compress(put(educationsubgroupvalue, binary7.)), 6, 1), $fmt_YN.);
			HomeSchool = put(substr(compress(put(educationsubgroupvalue, binary7.)), 7, 1), $fmt_YN.);	*/
			SEM_Theta = '';
			%do clm=1 %to 4;
				Claim&clm.Theta = '';
			%end;
			if accomASL = 'TDS_ASL1' then TDS_ASL1 = 1;
			else TDS_ASL1 = 0;
			if accomSpanTrans = 'ESN' then ESN = 1;
			else ESN = 0;
			if accomBraille in ('TDS_BT_ECN', 'TDS_BT_UCN', 'TDS_BT_ECL', 'TDS_BT_UCL',
										'TDS_BT_UCT', 'TDS_BT_UXN', 'TDS_BT_UXL') then BrailleType_ct4 = 1;
			else BrailleType_ct4 = 0;
			if ((index(accomTransGloss, 'Arabic') > 0) or (index(accomTransGloss, 'Cantonese') > 0)
				or (index(accomTransGloss, 'Tagal') > 0) or (index(accomTransGloss, 'Korean') > 0)
				or (index(accomTransGloss, 'Mandarin') > 0) or (index(accomTransGloss, 'Punjabi') > 0)
				or (index(accomTransGloss, 'Russian') > 0) or (index(accomTransGloss, '_ESNGloss') > 0)
				or (index(accomTransGloss, 'Ukrainian') > 0) or (index(accomTransGloss, 'Vietnamese') > 0))
					then WL_Gloss_mult = 1;
			else WL_Gloss_mult = 0;
			if ((accomNEA ne 'NEA0') or (accomNEDS ne 'NEDS0')) then Any_Gloss = 1;
			else Any_Gloss = 0;
			%RenameTheVars;
			drop ethnicityvalue educationsubgroupvalue languagecode englishlanguageproficiencylevel
					firstentrydateintousschool limitedenglishproficiencyentryda oppId districtName schoolName
					studentGroupName /* IEP Migrant HomeSchool */ accomASL accomSpanTrans accomBraille
					accomTransGloss accomNEA accomNEDS ;
	run; 
%mend WrapBySubjGrd;
/*
	%WrapBySubjGrd(ela03);				%WrapBySubjGrd(ela04);				%WrapBySubjGrd(ela05);
	%WrapBySubjGrd(ela06);				%WrapBySubjGrd(ela07);				%WrapBySubjGrd(ela08);
	%WrapBySubjGrd(ela11);
	%WrapBySubjGrd(math03);				%WrapBySubjGrd(math04);				%WrapBySubjGrd(math05);
	%WrapBySubjGrd(math06);				%WrapBySubjGrd(math07);				%WrapBySubjGrd(math08);
	%WrapBySubjGrd(math11);		*/

%macro FinalPolish(sg);
	%SetDSLabel;
	proc sql;
		create table dlvrylib.ets_student_level_2019_&sg. (compress=yes label="&DSLabel.") as 
		select stateId, districtCode, schoolCode, studentIdentifier, sex, HispanicOrLatinoEthnicity,
				AmericanIndianOrAlaskaNative, BlackOrAfricanAmerican, white, NativeHawaiianOrOtherPacificIsl,
				asian, DemographicRaceTwoOrMoreRaces, IDEAIndicator, LEPStatus, Section504Status, 
				EconomicDisadvantageStatus, Subject, assessmentLevelForWhichDesigned, gradeLevelWhenAssessed,
				testStatus, testMode, TotalTheta, scaleScore, ScaleScoreAchievementLevel, claim1Theta,
				claim2Theta, claim3Theta, claim4Theta, claim1Score, claim2Score, claim3Score, claim4Score, 
				oppKey, SEM_Theta, claim1SEM, claim2SEM, claim3SEM, claim4SEM, claim1AchievementLevel, 
				claim2AchievementLevel, claim3AchievementLevel, claim4AchievementLevel, TDS_ASL1, ESN,
				BrailleType_ct4, WL_Gloss_mult, Any_Gloss, SEM_ScaleScore, AssmntSessActualStartDateTime,
				CATitem1time, PTitem1time, CATitem1sequence, PTitem1sequence
		from dlvrylib.&sg._TR_Stud;
	quit;
%mend FinalPolish;
/*	%FinalPolish(ela03);				%FinalPolish(ela04);				%FinalPolish(ela05);
	%FinalPolish(ela06);				%FinalPolish(ela07);				%FinalPolish(ela08);
	%FinalPolish(ela11);
	%FinalPolish(math03);				%FinalPolish(math04);				%FinalPolish(math05);
	%FinalPolish(math06);				%FinalPolish(math07);				%FinalPolish(math08);
	%FinalPolish(math11);	*/

%macro AssembleAllETS;
	%SetDSLabel;
	data dlvrylib.ets_student_level_2019 (compress=yes label="&DSLabel.");
		set dlvrylib.ets_student_level_2019_ela03		dlvrylib.ets_student_level_2019_ela04
				dlvrylib.ets_student_level_2019_ela05 	dlvrylib.ets_student_level_2019_ela06 
				dlvrylib.ets_student_level_2019_ela07 	dlvrylib.ets_student_level_2019_ela08 
				dlvrylib.ets_student_level_2019_ela11 	dlvrylib.ets_student_level_2019_math03
				dlvrylib.ets_student_level_2019_math04	dlvrylib.ets_student_level_2019_math05
				dlvrylib.ets_student_level_2019_math06	dlvrylib.ets_student_level_2019_math07
				dlvrylib.ets_student_level_2019_math08	dlvrylib.ets_student_level_2019_math11 ;
	run;	
%mend AssembleAllETS;
%*	%AssembleAllETS;