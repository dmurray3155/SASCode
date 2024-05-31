/*==================================================================================================*
 | Program	:	ASTD_AIR_Assmbl_StudLvl.sas																														|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 13		Initial development																																|
 *==================================================================================================*/
 
%let wrkHere=E:\SBAC\AnnualStudTest\1819\AIR;
libname libHere "&wrkHere.";

%let dlvryRt=E:\SBAC\AnnualStudTest\1819\DLVRY\AIR\Stud;
libname dlvrLib "&dlvryRt.";

%macro ProcYNFlds(fldName);
	&fldName._n = substr(&fldName., 1, 1);
	if &fldName._n not in ('Y', 'N') then &fldName._ = '';
%mend ProcYNFlds;

%macro WrapBySt(ST);
	%macro WrapBySbj(Sbj);
		%SetDSLabel;
		data TmpAIRStud (compress=yes drop=Sex HispanicOrLatinoEthnicity AmericanIndianOrAlaskaNative
				BlackOrAfricanAmerican White NativeHawaiianOrOtherPacificIsla Asian DemographicRaceTwoOrMoreRaces
				AssessmentAcademicSubject IDEAIndicator LEPStatus Section504Status EconomicDisadvantageStatus
				AssessmentSessionActualStartDate);
			set libHere.&ST._&Sbj._stud_1819;
			/*	Sex HispanicOrLatinoEthnicity AmericanIndianOrAlaskaNative BlackOrAfricanAmerican White
				NativeHawaiianOrOtherPacificIsla Asian DemographicRaceTwoOrMoreRaces
				IDEAIndicator LEPStatus Section504Status EconomicDisadvantageStatus	*/
			format Sex_n HispanicOrLatinoEthnicity_n AmericanIndianOrAlaskaNative_n
				BlackOrAfricanAmerican_n White_n NatHawaiianOrOtherPacificIsla_n Asian_n
				DemographicRaceTwoOrMoreRaces_n IDEAIndicator_n LEPStatus_n Section504Status_n
				EconomicDisadvantageStatus_n $1. subject $4. ActualStartDateDlm $19.;
			Sex_n = substr(Sex, 1, 1);
			if Sex_n not in ('M', 'F') then Sex_n = '';
			%ProcYNFlds(HispanicOrLatinoEthnicity);
			%ProcYNFlds(AmericanIndianOrAlaskaNative);
			%ProcYNFlds(BlackOrAfricanAmerican);
			%ProcYNFlds(White);
			NatHawaiianOrOtherPacificIsla_n = substr(NativeHawaiianOrOtherPacificIsla, 1, 1);
			if NatHawaiianOrOtherPacificIsla_n not in ('Y', 'N') then NatHawaiianOrOtherPacificIsla_n = '';
			%ProcYNFlds(Asian);
			%ProcYNFlds(DemographicRaceTwoOrMoreRaces);
			%ProcYNFlds(IDEAIndicator);
			%ProcYNFlds(LEPStatus);
			%ProcYNFlds(Section504Status);
			%ProcYNFlds(EconomicDisadvantageStatus);
			subject = upcase("&Sbj.");
			if index(AssessmentAccommodation, 'TDS_ASL1') > 0 then TDS_ASL1 = 1;
			else TDS_ASL1 = 0;
			if ((index(AssessmentAccommodation, 'ESN,') > 0) or (index(AssessmentAccommodation, ',ESN,') > 0)) then ESN = 1;
			else ESN = 0;
			%if %eval("&ST." = "DE") %then %do;
				if index(AssessmentAccommodation, 'Braille_1') > 0 then BrailleType_ct4 = 1;
				else BrailleType_ct4 = 0;
			%end;
			%else %do;
				if index(AssessmentAccommodation, 'Braille') > 0 then BrailleType_ct4 = 1;
				else BrailleType_ct4 = 0;
			%end;
			if ( (index(AssessmentAccommodation, 'TDS_WL_ArabicGloss') > 0) or (index(AssessmentAccommodation, 'TDS_WL_CantoneseGloss') > 0)
				or (index(AssessmentAccommodation, 'TDS_WL_TagalGloss') > 0) or (index(AssessmentAccommodation, 'TDS_WL_KoreanGloss') > 0)
				or (index(AssessmentAccommodation, 'TDS_WL_MandarinGloss') > 0) or (index(AssessmentAccommodation, 'TDS_WL_PunjabiGloss') > 0)
				or (index(AssessmentAccommodation, 'TDS_WL_RussianGloss') > 0) or (index(AssessmentAccommodation, 'TDS_WL_ESNGlossary') > 0)
				or (index(AssessmentAccommodation, 'TDS_WL_UkrainianGloss') > 0) or (index(AssessmentAccommodation, 'TDS_WL_VietnameseGloss') > 0)
				) then WL_Gloss_mult = 1;
			else WL_Gloss_mult = 0;
			if ((index(AssessmentAccommodation, 'NEA_') > 0) or (index(AssessmentAccommodation, 'NEDS_'))) then Any_Gloss = 1;
			else Any_Gloss = 0;
			if length(AssessmentSessionActualStartDate) = 12 then 
				ActualStartDateDlm = compress(substr(AssessmentSessionActualStartDate, 5, 4)||'-'||
					substr(AssessmentSessionActualStartDate, 1, 2)||'-'||substr(AssessmentSessionActualStartDate, 3, 2)||
					'T'||substr(AssessmentSessionActualStartDate, 9, 2)||':'||substr(AssessmentSessionActualStartDate, 11, 2));
			else if length(AssessmentSessionActualStartDate) = 14 then 
				ActualStartDateDlm = compress(substr(AssessmentSessionActualStartDate, 5, 4)||'-'||
					substr(AssessmentSessionActualStartDate, 1, 2)||'-'||substr(AssessmentSessionActualStartDate, 3, 2)||
					'T'||substr(AssessmentSessionActualStartDate, 9, 2)||':'||substr(AssessmentSessionActualStartDate, 11, 2)||
					':'||substr(AssessmentSessionActualStartDate, 13, 2));
			else ActualStartDateDlm = 'There was an error';
		run;
		data TmpAIRStud2 (compress=yes);
			set TmpAIRStud;
			rename Sex_n = Sex		HispanicOrLatinoEthnicity_n = HispanicOrLatinoEthnicity
					AmericanIndianOrAlaskaNative_n = AmericanIndianOrAlaskaNative
					BlackOrAfricanAmerican_n = BlackOrAfricanAmerican		white_n = white
					NatHawaiianOrOtherPacificIsla_n = NativeHawaiianOrOtherPacificIsla Asian_n = Asian
					DemographicRaceTwoOrMoreRaces_n = DemographicRaceTwoOrMoreRaces 
					IDEAIndicator_n = IDEAIndicator		LEPStatus_n = LEPStatus
					Section504Status_n = Section504Status
					EconomicDisadvantageStatus_n = EconomicDisadvantageStatus;
		run;
		%SAS_Merge(TmpAIRStud2,
							libHere.&ST._&Sbj._itmaug4std (drop=StudentIdentifier),
							oppKey,
							work.&ST._&Sbj._TR_Stud (compress=yes));
		proc sql;
			create table dlvrLib.air_&ST._&Sbj._student_level_2019 (compress=yes label="&DSLabel.") as
			select "&ST." as StateID, ResponsibleDistrictIdentifier as districtCode,
					ResponsibleSchoolIdentifier as schoolCode, studentIdentifier, sex, 
					HispanicOrLatinoEthnicity, AmericanIndianOrAlaskaNative, BlackOrAfricanAmerican,
					White, NativeHawaiianOrOtherPacificIsla, Asian, DemographicRaceTwoOrMoreRaces,
					IDEAIndicator, LEPStatus, Section504Status, EconomicDisadvantageStatus, Subject,
					AssessmentLevelForWhichDesigned, GradeLevelWhenAssessed, TestStatus, TestMode,
					theta_tot as TotalTheta, SS_TOT as ScaleScore, performance_Level as ScaleScoreAchievementLevel,
					sem_tot_theta as sem_theta, sem_totSS as sem_ScaleScore,
					theta_src1 as Claim1Theta, 
					%if &Sbj.=ela %then %do;
						theta_src3 as Claim2Theta, theta_src2 as Claim3Theta, theta_src4 as Claim4Theta, SS_SRC1 as Claim1Score,
						SS_SRC3 as Claim2Score, SS_SRC2 as Claim3Score, ss_src4 as Claim4Score, sem_src1 as Claim1SEM,
						sem_src3 as Claim2SEM, sem_src2 as Claim3SEM, sem_src4 as Claim4SEM, PL_SRC1 as Claim1AchievementLevel,
						pl_src3 as Claim2AchievementLevel, pl_src2 as Claim3AchievementLevel, pl_src4 as Claim4AchievementLevel,
					%end;
					%else %if &Sbj.=math %Then %do;
						theta_src2 as Claim2Theta, theta_src3 as Claim3Theta, . as Claim4Theta, SS_SRC1 as Claim1Score,
						ss_src2 as Claim2Score, ss_src3 as Claim3Score, . as Claim4Score, sem_src1 as Claim1SEM,
						sem_src2 as Claim2SEM, sem_src3 as Claim3SEM, . as Claim4SEM, PL_SRC1 as Claim1AchievementLevel,
						PL_SRC2 as Claim2AchievementLevel, PL_SRC3 as Claim3AchievementLevel, . as Claim4AchievementLevel,
					%end;
					oppKey, TDS_ASL1, ESN, BrailleType_ct4, WL_Gloss_mult, Any_Gloss,
					ActualStartDateDlm as AssessmentSessionActualStartDate, '' as CATitem1time,
					'' as PTitem1time, CATitem1sequence, PTitem1sequence					
			from work.&ST._&Sbj._TR_Stud;
		quit;
	%mend WrapBySbj;
		%WrapBySbj(ela);				%WrapBySbj(math);
%mend WrapBySt;
	%WrapBySt(DE);				%WrapBySt(HI);				%WrapBySt(ID);				%WrapBySt(OR);
	%WrapBySt(SD);				%WrapBySt(USVI);			%WrapBySt(VT);				%WrapBySt(WA);