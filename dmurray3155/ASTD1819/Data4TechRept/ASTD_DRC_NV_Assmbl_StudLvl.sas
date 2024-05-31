/*==================================================================================================*
 | Program	:	ReadNVMainStud.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|
 | Macros		: %ReadMVStud and %ReadNVClaims stored in SAS Code module ReadNVStudMacDef.sas					|
 |						As well as some from D.M.'s toolbox.sas and those developed in this code base.				|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 21		Initial development																																|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\DRC\NV;
libName libHere "&wrkHere.";

%let dlvryRt=E:\SBAC\AnnualStudTest\1819\DLVRY\DRC\Stud;
libname dlvrLib "&dlvryRt.";

%macro ProcessStudLvl;
	%let dlvrHere=E:\SBAC\AnnualStudTest\1819\DLVRY\DRC;
	libName dlvrSLib "&dlvrHere.\Stud" ;
	%Common_Fmts;
	data StudentData (compress=yes);
		format stateId $2. state_unique_id_str $14.;
		set libHere.smarter_no_pii;
		format HispanicOrLatinoEthnicity AmericanIndianOrAlaskaNative BlackOrAfricanAmerican
			White NativeHawaiianOrOtherPacificIsla Asian DemographicRaceTwoOrMoreRaces
			Sex IDEAIndicator LEPStatus EconomicDisadvantageStatus $1. ;
		stateId = 'NV';
		state_unique_id_str = compress('NV_'||state_unique_id);
		if gender = 'N' then sex = '';
		else sex = gender;
		HispanicOrLatinoEthnicity = 'N';
		AmericanIndianOrAlaskaNative = 'N';
		BlackOrAfricanAmerican = 'N';
		White = 'N';
		NativeHawaiianOrOtherPacificIsla = 'N';
		Asian = 'N';
		DemographicRaceTwoOrMoreRaces = 'N';
		select(ethnicity);
			when("H") HispanicOrLatinoEthnicity = 'Y';
			when("I") AmericanIndianOrAlaskaNative = 'Y';
			when("B") BlackOrAfricanAmerican = 'Y';
			when("C") White = 'Y';
			when("P") NativeHawaiianOrOtherPacificIsla = 'Y';
			when("A") Asian = 'Y';
			when("M") DemographicRaceTwoOrMoreRaces = 'Y';
			otherwise ;
		end;
		IDEAIndicator = put(iep, fmt_YN.);
		LEPStatus = put(lep, fmt_YN.);
		EconomicDisadvantageStatus = put(frl, fmt_YN.);
		keep stateId report_dist_num report_sch_num state_unique_id_str Sex HispanicOrLatinoEthnicity
			AmericanIndianOrAlaskaNative BlackOrAfricanAmerican White NativeHawaiianOrOtherPacificIsla
			Asian DemographicRaceTwoOrMoreRaces IDEAIndicator LEPStatus EconomicDisadvantageStatus ;
	run;
	%macro WrapBySubj(Subj);
		data Stud&Subj.Data (compress = yes);
			set libHere.smarter_no_pii;
			format subject $4. state_unique_id_str $14. testStatus $12. testMode $1.
					AssessmentSessionActualStartTime datetime18.;
			subject = "&Subj." ;
			state_unique_id_str = compress('NV_'||state_unique_id);
			Section504Status = &Subj._iep_accommodation;
			if ((&Subj._tc_invalidation_CAT = 'INV') or (&Subj._tc_invalidation_PT = 'INV')) then testStatus = 'invalidated';
			else do;
				if ((&Subj._participation_status = 1) and (&Subj._attemptedness_status = 1)) then testStatus = 'completed';
				else testStatus = '';
			end;
			if &Subj._pod = 1 then testMode = 'P';
			else testMode = 'O';
			TotalTheta = .;
			%do clm=1 %to 4;
				Claim&clm.Theta = .;
			%end;
			%if %eval("&Subj." = "math") %then %do;
				&Subj._C2_performance_level = .;
			%end;
			SEM_Theta = .;
			oppKey = .;
			ESN = .;
			WL_Gloss_mult = .;
			Any_Gloss = .;
			%if %eval("&Subj." = "ela") %then %do;
				AssessmentSessionActualStartTime = min(&Subj._cat_test_start_date_time, &Subj._pt_part1_start_date_time, &Subj._pt_part2_start_date_time);
			%end;
			%else %if %eval("&Subj." = "math") %then %do;
				AssessmentSessionActualStartTime = min(&Subj._cat_test_start_date_time, &Subj._pt_start_date_time);
			%end;
			CATitem1time = .;
			PTitem1time = .;
			CATitem1sequence = .;
			PTitem1sequence = .;
			keep state_unique_id_str subject grade_level testStatus testMode TotalTheta &Subj._scale_score 
				&Subj._achievement_level &Subj._sem_value Section504Status AssessmentSessionActualStartTime
				%do clm=1 %to 4; Claim&clm.Theta &Subj._C&clm._performance_level %end;
				oppKey &Subj._video_sign_language ESN &Subj._braille oppKey ESN WL_Gloss_mult Any_Gloss SEM_Theta
				CATitem1time PTitem1time CATitem1sequence PTitem1sequence &Subj._lithocode_CAT &Subj._lithocode_PT
				slug_key;
		run;
		proc sort data = libhere.claim_sem_&Subj. out = claim_sem_temp (compress=yes);
			by grade lithocode_CAT lithocode_PT slug_key Claims;
		run;
		data Claim&Subj.Data (compress = yes);
			set claim_sem_temp;
			format Claim1Score Claim2Score Claim3Score Claim4Score 4.0
					Claim1SEM Claim2SEM Claim3SEM Claim4SEM 3.0 ;
			retain Subject Grade Claim1Score Claim1SEM Claim2Score Claim2SEM Claim3Score Claim3SEM
							Slug_key lithocode_CAT lithocode_PT;
			select (Claims);
				when('C1') do;
					Claim1Score = Scale_score;
					Claim1SEM = SEM;
				end;
				when('C2') do;
					Claim2Score = Scale_score;
					Claim2SEM = SEM;
				end;
				when('C3') do;
					Claim3Score = Scale_score;
					Claim3SEM = SEM;
				end;
				when('C4') do;
					Claim4Score = Scale_score;
					Claim4SEM = SEM;
					output;
				end;
				otherwise ;
			end;
			keep Subject Grade Claim1Score Claim2Score Claim3Score Claim4Score Claim1SEM Claim2SEM Claim3SEM Claim4SEM
						Slug_key lithocode_CAT lithocode_PT;
		run;
		%SetDSLabel;
		proc sql;
			create table drc_nv_&Subj._student_init (compress=yes) as 
			select sd.stateId, sd.report_dist_num as districtCode, sd.report_sch_num as schoolCode,
					sd.state_unique_id_str as studentIdentifier, sd.sex, sd.HispanicOrLatinoEthnicity,
					sd.AmericanIndianOrAlaskaNative, sd.BlackOrAfricanAmerican, sd.White,
					sd.NativeHawaiianOrOtherPacificIsla, sd.Asian, sd.DemographicRaceTwoOrMoreRaces,
					sd.IDEAIndicator, sd.LEPStatus, ssd.Section504Status, sd.EconomicDisadvantageStatus,
					ssd.subject, ssd.grade_level as AssessmentLevelForWhichDesigned,
					ssd.grade_level as GradeLevelWhenAssessed, ssd.testStatus, ssd.testMode, ssd.TotalTheta,
					ssd.&Subj._scale_score as ScaleScore, ssd.&Subj._achievement_level as ScaleScoreAchievementLevel,
					ssd.&Subj._sem_value as SEM_ScaleScore, ssd.SEM_Theta, ssd.oppKey, ssd.Claim1Theta, ssd.Claim2Theta,
					ssd.Claim3Theta, ssd.Claim4Theta,
					%do cl=1 %to 4; ssd.&Subj._C&cl._performance_level as Claim&cl.AchievementLevel, %end;
					ssd.&Subj._video_sign_language as TDS_ASL1, ssd.ESN, ssd.&Subj._braille as BrailleType_ct4,
					ssd.WL_Gloss_mult, ssd.Any_Gloss, ssd.AssessmentSessionActualStartTime, ssd.CATitem1time,
					ssd.PTitem1time, ssd.CATitem1sequence, ssd.PTitem1sequence, ssd.slug_key, ssd.&Subj._lithocode_CAT,
					ssd.&Subj._lithocode_PT
			from StudentData as sd, Stud&Subj.Data as ssd
			where sd.state_unique_id_str = ssd.state_unique_id_str;
		quit;
		proc sql;
			create table dlvrLib.drc_nv_&Subj._student_2019 (compress=yes label="&DSLabel.") as 
			select sd.stateId, sd.districtCode, sd.schoolCode,
					sd.studentIdentifier, sd.sex, sd.HispanicOrLatinoEthnicity,
					sd.AmericanIndianOrAlaskaNative, sd.BlackOrAfricanAmerican, sd.White,
					sd.NativeHawaiianOrOtherPacificIsla, sd.Asian, sd.DemographicRaceTwoOrMoreRaces,
					sd.IDEAIndicator, sd.LEPStatus, sd.Section504Status, sd.EconomicDisadvantageStatus,
					sd.subject, sd.AssessmentLevelForWhichDesigned,
					sd.GradeLevelWhenAssessed, sd.testStatus, sd.testMode, sd.TotalTheta,
					sd.ScaleScore, sd.ScaleScoreAchievementLevel,
					sd.SEM_ScaleScore, sd.SEM_Theta, sd.oppKey, sd.Claim1Theta, sd.Claim2Theta,
					sd.Claim3Theta, sd.Claim4Theta, csd.Claim1Score, csd.Claim2Score, csd.Claim3Score,
					csd.Claim4Score, csd.Claim1SEM, csd.Claim2SEM, csd.Claim3SEM, csd.Claim4SEM,
					%do cl=1 %to 4; sd.Claim&cl.AchievementLevel, %end;
					sd.TDS_ASL1, sd.ESN, sd.BrailleType_ct4,
					sd.WL_Gloss_mult, sd.Any_Gloss, sd.AssessmentSessionActualStartTime, sd.CATitem1time,
					sd.PTitem1time, sd.CATitem1sequence, sd.PTitem1sequence
			from drc_nv_&Subj._student_init as sd
			left join Claim&Subj.Data as csd
			on sd.slug_key = csd.Slug_key and sd.&Subj._lithocode_CAT = csd.lithocode_CAT
			and sd.&Subj._lithocode_PT = csd.lithocode_PT
/*			, Stud&Subj.Data as ssd, Claim&Subj.Data as csd
			where sd.state_unique_id_str = ssd.state_unique_id_str and ssd.slug_key = csd.Slug_key
				and ssd.&Subj._lithocode_CAT = csd.lithocode_CAT and ssd.&Subj._lithocode_PT = csd.lithocode_PT	*/
			order by sd.GradeLevelWhenAssessed, sd.&Subj._lithocode_CAT, sd.&Subj._lithocode_PT;
		quit;
/*	From StudentData	*/
/*	keep stateId report_dist_num report_sch_num state_unique_id Sex HispanicOrLatinoEthnicity
			AmericanIndianOrAlaskaNative BlackOrAfricanAmerican White NativeHawaiianOrOtherPacificIsla
			Asian DemographicRaceTwoOrMoreRaces IDEAIndicator LEPStatus EconomicDisadvantageStatus ;	*/

/*	From Stud&Subj.Data	*/
/*			keep state_unique_id subject Section504Status grade_level testStatus testMode TotalTheta &Subj._scale_score 
				&Subj._achievement_level &Subj._sem_value %do clm=1 %to 4; Claim&clm.Theta &Subj._C&clm._performance_level %end;
				oppKey &Subj._video_sign_language ESN &Subj._braille oppKey ESN WL_Gloss_mult Any_Gloss AssessmentSessionActualStartTime
				CATitem1time PTitem1time CATitem1sequence PTitem1sequence ;	*/

/*	From Claim&Subj.Data	*/
/* 			keep Subject Grade Claim1Score Claim2Score Claim3Score Claim4Score Claim1SEM Claim2SEM Claim3SEM Claim4SEM
						Slug_key lithocode_CAT lithocode_PT;		*/
	%mend WrapBySubj;
		%WrapBySubj(ela);
		%WrapBySubj(math);
%mend ProcessStudLvl;
	%ProcessStudLvl;
