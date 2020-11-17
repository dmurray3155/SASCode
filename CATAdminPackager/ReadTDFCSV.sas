/*==================================================================================================*
 | Program :	ReadTDFCSV.sas																																				|
 | Author	 :	Don Murray (for Smarter Balanced)																											|
 | Purpose :	Create SAS datasets from the available TDF files.																			|
 | Macros  : 	Some from my toolbox.sas as well as those developed in this code base.								|
 | Notes	 :	This a re-design of the TDF read process to read the original CSV and not have 				|
 |						to save a xlsx first.  In this edition I also built in a year range macro component		|
 |						(YrRng) to make it more easily applicable across years.																|
 | Usage	 :	Applicable to fixed-form admin package building for the 2020-21 test packaging work.	|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date.....		....description................................................................		|
 |	2019 04 08		Initial development.																															|
 |	2019 12 19		Copied from 2019-20 project folder to 2020-21 project folder.	 Earlier version		|
 |								of this code is ReadTDFs.sas																											|
 |	2020 08 21		Copied from Config Sheet work location to CAT Admin Packager location.  This 			|
 |								application will be the first one toward summative.																|
 *==================================================================================================*/

%let wrkHere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\CATAdminPackage;
libname libHere "&wrkHere.";

/*	Target to local copy of 2020-21 Prebuild_TDF SharePoint folder for TDFs	*/
%* %let SrcFylFldr=C:\Users\Donald Murray\Smarter Balanced UCSC\System Design - Prebuild_TDF (1);
%* %let SrcFylFldr=C:\Users\Donald Murray\Smarter Balanced UCSC\System Design - 2020-21;
%* %let SrcFylFldr=C:\Users\Donald Murray\Smarter Balanced UCSC\System Design - TDF_Archive;	/* For 2020-05-11 Run	*/
%* %let SrcFylFldr=C:\Users\Donald Murray\Smarter Balanced UCSC\System Design - Current_TDF;	/* For 2020-07-21 Run	*/
	/*	For CAT Admin Packager work in Aug. 2020-07-21*/
	%let SrcFylFldr=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\CATAdminPackage;

%macro ReadTDF(FylName);
/*	libname XLTDF XLSX "&UniRoot./&WrkHere./&FylName..xlsx";	*/
	libname XLTDF XLSX "&WrkHere.\&FylName..xlsx";
	data WrkData.&FylName.;
		set XLTDF.in;
	run;
%mend ReadTDF;
/*	%ReadTDF(TDF_2019_20_IAB_v01);
		%ReadTDF(TDF_2019_20_ICA_v01);
		%ReadTDF(TDF_2019_20_FIAB_v01);
		%ReadTDF(TDF_2019_20_FIAB_v06);
		%ReadTDF(TDF_2019_20_IAB_v08);
		%ReadTDF(TDF_2019_20_ICA_v07);
		%ReadTDF(TDF_2019_20_ICA_v13);
		%ReadTDF(TDF_2019_20_Practice_v02);
		%ReadTDF(TDF_2019_20_Training_v03);
		%ReadTDF(TDF_2019_20_FIAB_v12);		*/

%macro VarFmtLst;
	AssessmentType   $CHAR9.
	AssessmentSubType $CHAR3.
	Subject          $CHAR4.
	StudentGrade     BEST2.
	FullTitle        $CHAR56.
	ShortTitle       $CHAR16.
	Sequence         BEST2.
	SegmentPosition  BEST1.
	SegmentDescription $CHAR6.
	ItemPosition     BEST2.
	Role             $CHAR11.
	ItemId           BEST6.
	item_version     BEST5.
	ItemGrade        BEST2.
	StimId           BEST6.
	Key              $CHAR4.
	ItemType         $CHAR4.
	ScoringEngine    $CHAR19.
	PerformanceTask  $CHAR3.
	AllowCalculator  $CHAR3.
	Claim            BEST1.
	Target           $CHAR1.
	DetailedELAClaim2Target $CHAR2.
	DOK              BEST1.
	Domain           $CHAR5.
	WorkflowStatus   $CHAR26.
	PassageLength    $CHAR1.
	TargetGroup      $CHAR20.
	SRC              $CHAR5.
	BraillePool      $CHAR1.
	SpanishPool      $CHAR1.
	TranslatedGlossaryPool $CHAR1.
	IllustratedGlossaryPool $CHAR1.
	ASLPool          $CHAR1.
	anyflag_d1       $CHAR5.
	anyflag_d2       $CHAR1.
	Ftyear           BEST4.
	PrpCrt_d1        BEST13.
	ItemTotal_d1     BEST12.
	MaxRub_d1        BEST1.
	MaxScr_d1        BEST1.
	Recoding_d1      $CHAR12.
	IRTa_d1          BEST8.
	IRTb_d1          BEST8.
	GPCd2_d1         BEST8.
	GPCd3_d1         BEST8.
	GPCd4_d1         BEST8.
	GPCd5_d1         BEST8.
	PrpCrt_d2        BEST13.
	ItemTotal_d2     BEST12.
	MaxRub_d2        BEST1.
	MaxScr_d2        BEST1.
	Recoding_d2      $CHAR12.
	IRTa_d2          BEST8.
	IRTb_d2          BEST8.
	GPCd2_d2         BEST8.
	GPCd3_d2         BEST8.
	GPCd4_d2         BEST8.
	GPCd5_d2         BEST8.
	iat_changes      $CHAR24.
	TDF_version   $CHAR20. ;
%mend VarFmtLst;

%macro ReadTDFCSV(infile, outDS);
	DATA &outDS.;
		LENGTH
			AssessmentType   $ 9
			AssessmentSubType $ 3
			Subject          $ 4
			StudentGrade       8
			FullTitle        $ 56
			ShortTitle       $ 16
			Sequence           8
			SegmentPosition    8
			SegmentDescription $ 6
			ItemPosition       8
			Role             $ 11
			ItemId             8
			item_version       8
			ItemGrade          8
			StimId           	 8
			Key              $ 4
			ItemType         $ 4
			ScoringEngine    $ 19
			PerformanceTask  $ 3
			AllowCalculator  $ 3
			Claim              8
			Target           $ 1
			DetailedELAClaim2Target $ 2
			DOK                8
			Domain           $ 5
			WorkflowStatus   $ 26
			PassageLength    $ 1
			TargetGroup      $ 20
			SRC              $ 5
			BraillePool      $ 1
			SpanishPool      $ 1
			TranslatedGlossaryPool $ 1
			IllustratedGlossaryPool $ 1
			ASLPool          $ 1
			anyflag_d1       $ 5
			anyflag_d2       $ 1
			Ftyear             8
			PrpCrt_d1          8
			ItemTotal_d1       8
			MaxRub_d1          8
			MaxScr_d1          8
			Recoding_d1      $ 12
			IRTa_d1            8
			IRTb_d1            8
			GPCd2_d1           8
			GPCd3_d1           8
			GPCd4_d1           8
			GPCd5_d1           8
			PrpCrt_d2          8
			ItemTotal_d2       8
			MaxRub_d2          8
			MaxScr_d2          8
			Recoding_d2      $ 12
			IRTa_d2            8
			IRTb_d2            8
			GPCd2_d2           8
			GPCd3_d2           8
			GPCd4_d2           8
			GPCd5_d2           8
			iat_changes      $ 24
			TDF_version      $ 20 ;
    FORMAT %VarFmtLst;
    INFORMAT %VarFmtLst;
    INFILE "&infile."
        LRECL=32767
        FIRSTOBS=2
        ENCODING="UTF-8"
        DLM='2c'x
        MISSOVER
        DSD ;
    INPUT
        AssessmentType   : $CHAR9.
        AssessmentSubType : $CHAR3.
        Subject          : $CHAR4.
        StudentGrade     : ?? BEST2.
        FullTitle        : $CHAR56.
        ShortTitle       : $CHAR16.
        Sequence         : ?? BEST2.
        SegmentPosition  : ?? BEST1.
        SegmentDescription : $CHAR6.
        ItemPosition     : ?? BEST2.
        Role             : $CHAR11.
        ItemId           : ?? BEST6.
        item_version     : ?? COMMA5.
        ItemGrade        : ?? BEST2.
        StimId           : ?? BEST6.
        Key              : $CHAR4.
        ItemType         : $CHAR4.
        ScoringEngine    : $CHAR19.
        PerformanceTask  : $CHAR3.
        AllowCalculator  : $CHAR3.
        Claim            : ?? BEST1.
        Target           : $CHAR1.
        DetailedELAClaim2Target : $CHAR2.
        DOK              : ?? BEST1.
        Domain           : $CHAR5.
        WorkflowStatus   : $CHAR26.
        PassageLength    : $CHAR1.
        TargetGroup      : $CHAR20.
        SRC              : $CHAR5.
        BraillePool      : $CHAR1.
        SpanishPool      : $CHAR1.
        TranslatedGlossaryPool : $CHAR1.
        IllustratedGlossaryPool : $CHAR1.
        ASLPool          : $CHAR1.
        anyflag_d1       : $CHAR5.
        anyflag_d2       : $CHAR1.
        Ftyear           : ?? BEST4.
        PrpCrt_d1        : ?? COMMA13.
        ItemTotal_d1     : ?? COMMA12.
        MaxRub_d1        : ?? BEST1.
        MaxScr_d1        : ?? BEST1.
        Recoding_d1      : $CHAR12.
        IRTa_d1          : ?? COMMA8.
        IRTb_d1          : ?? COMMA8.
        GPCd2_d1         : ?? COMMA8.
        GPCd3_d1         : ?? COMMA8.
        GPCd4_d1         : ?? COMMA8.
        GPCd5_d1         : ?? COMMA8.
        PrpCrt_d2        : ?? COMMA13.
        ItemTotal_d2     : ?? COMMA12.
        MaxRub_d2        : ?? BEST1.
        MaxScr_d2        : ?? BEST1.
        Recoding_d2      : $CHAR12.
        IRTa_d2          : ?? COMMA8.
        IRTb_d2          : ?? COMMA8.
        GPCd2_d2         : ?? COMMA8.
        GPCd3_d2         : ?? COMMA8.
        GPCd4_d2         : ?? COMMA8.
        GPCd5_d2         : ?? COMMA8.
        iat_changes      : $CHAR24.
        TDF_version   : $CHAR20. ;
	RUN;
%mend ReadTDFCSV;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_FIAB_v04.csv, libHere.TDF_2020_21_FIAB_v04);	*** First for 2020-21 - developed: 2019-12-19	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_FIAB_v05.csv, libHere.TDF_2020_21_FIAB_v05);	*** Next for 2020-21 - Re-Runs: 2020-01-15	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_FIAB_v09.csv, libHere.TDF_2020_21_FIAB_v09);	*** Next for 2020-21 - Re-Runs: 2020-02-14	*** ;
%*	%ReadTDFCSV(&WrkHere.\tdf_2020-21_fiab_v10_MVEdit.csv, libHere.TDF_2020_21_FIAB_v10_MV);	*** Next for 2020-21 - Re-Runs: 2020-03-20	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_FIAB_v11.csv, libHere.TDF_2020_21_FIAB_v11);	*** Next for 2020-21 - Re-Runs: 2020-04-08	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_FIAB_v12.csv, libHere.TDF_2020_21_FIAB_v12);	*** Next for 2020-21 - Re-Runs: 2020-04-08	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_FIAB_v14.csv, libHere.TDF_2020_21_FIAB_v14);	*** Next for 2020-21 - Re-Runs: 2020-04-30	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\TDF_2020-21_IAB_v07.csv, libHere.TDF_2020_21_IAB_v07);	*** Next for 2020-21 - Re-Runs: 2020-05-11	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\tdf_2020-21_ica_v09.csv, libHere.TDF_2020_21_ICA_v09);	*** Next for 2020-21 - Re-Runs: 2020-07-21	*** ;
%*	%ReadTDFCSV(&SrcFylFldr.\tdf_2020-21_iab_v13.csv, libHere.TDF_2020_21_IAB_v13);	*** Next for 2020-21 - Re-Runs: 2020-07-21	*** ;
		%ReadTDFCSV(&SrcFylFldr.\TDF_2019-20_Summative_v27.csv, libHere.TDF_2019_20_summative_v27);	*** CAT Admin Packager work: Aug. 2020	*** ;

%macro StudyTDF(YrRng, TSubType, vrsn, Subj, Grd, ShrtTytl);
	proc sql;
/*	select distinct ShortTitle, FullTitle, SegmentDescription
		from libHere.TDF_&YrRng._&TSubType._v&vrsn.
		where Subject="&Subj." and ItemGrade=&Grd.
		order by ShortTitle, FullTitle, SegmentDescription
		%if &Subj.=MATH %then %do;
			descending
		%end;
		;	*/
		create table ThisSub as
		select * from libHere.TDF_&YrRng._&TSubType._v&vrsn.
		where Subject="&Subj." and StudentGrade=&Grd.
		%if &TSubType.=FIAB or &TSubType.=IAB or &TSubType.=Practice %then %do;
			and ShortTitle="&ShrtTytl."
		%end;
		%if &TSubType.=Practice or &TSubType.=Training %then %do;
			order by SegmentPosition, ItemPosition;
		%end;
		%else %do;
			order by ShortTitle, Sequence;
		%end;
	quit;
	%GetNow;
	Title1 "TDF_&YrRng._&TSubType._v01.sas7bdat where Subject=&Subj., ItemGrade=&Grd.";
	Title2 "   &now.";
	proc print data=ThisSub;
	run;
%mend StudyTDF;
/*	%StudyTDF(ICA, ELA, 8);
	%StudyTDF(ICA, MATH, 8);
	%StudyTDF(FIAB, 01, ELA, 5);
	%StudyTDF(IAB, 02, ELA, 3, ListenInterpet);
	%StudyTDF(IAB, 02, ELA, 3, Perf-Opinion-Beetles);
	%StudyTDF(IAB, 02, ELA, 5, Perf-Narrative-Whales);
 	%StudyTDF(Practice, 01, MATH, 8, PRAC);	** for Practice the only expected values for ShortTitle are PRAC and PRAC-Perf 	** ;
	%StudyTDF(Practice, 01, ELA, 5, PRAC);
	%StudyTDF(Practice, 01, ELA, 5, PRAC-Perf);
  %StudyTDF(Training, 01, MATH, 6, TRN);
	%StudyTDF(IAB, 04, ELA, 7, Editing);
	%StudyTDF(FIAB, 12, ELA, 3);
	%StudyTDF(FIAB, 12, ELA, 4);
	%StudyTDF(FIAB, 12, ELA, 5);
	%StudyTDF(FIAB, 12, ELA, 6);
	%StudyTDF(FIAB, 12, ELA, 8);	*/
	/*	These are from FIAB v04 in 2020-21	*/
/*	%StudyTDF(2020_21, FIAB, 04, ELA, 3, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 3, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, ELA, 3, WriteOpinion);
	%StudyTDF(2020_21, FIAB, 04, ELA, 4, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 4, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, ELA, 4, WriteOpinion);
	%StudyTDF(2020_21, FIAB, 04, ELA, 5, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 5, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, ELA, 5, WriteOpinion);
	%StudyTDF(2020_21, FIAB, 04, ELA, 6, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 6, WriteArgue);
	%StudyTDF(2020_21, FIAB, 04, ELA, 6, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, ELA, 7, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 7, WriteArgue);
	%StudyTDF(2020_21, FIAB, 04, ELA, 7, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, ELA, 8, Editing);
	%StudyTDF(2020_21, FIAB, 04, ELA, 8, LangVocab);
	%StudyTDF(2020_21, FIAB, 04, ELA, 8, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 8, WriteArgue);
	%StudyTDF(2020_21, FIAB, 04, ELA, 8, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, ELA, 11, ResearchEvidence);
	%StudyTDF(2020_21, FIAB, 04, ELA, 11, WriteArgue);
	%StudyTDF(2020_21, FIAB, 04, ELA, 11, WriteExplanatory);
	%StudyTDF(2020_21, FIAB, 04, MATH, 3, TAOA);
	%StudyTDF(2020_21, FIAB, 04, MATH, 3, TGMD);
	%StudyTDF(2020_21, FIAB, 04, MATH, 3, TIJMD);
	%StudyTDF(2020_21, FIAB, 04, MATH, 4, TBOA);
	%StudyTDF(2020_21, FIAB, 04, MATH, 4, TCOA);
	%StudyTDF(2020_21, FIAB, 04, MATH, 4, TDNBT);
	%StudyTDF(2020_21, FIAB, 04, MATH, 4, TENBT);
	%StudyTDF(2020_21, FIAB, 04, MATH, 4, TGNF);
	%StudyTDF(2020_21, FIAB, 04, MATH, 5, TCNBT);
	%StudyTDF(2020_21, FIAB, 04, MATH, 5, TGHMD);
	%StudyTDF(2020_21, FIAB, 04, MATH, 5, TIHMD);
	%StudyTDF(2020_21, FIAB, 04, MATH, 6, TCNS);
	%StudyTDF(2020_21, FIAB, 04, MATH, 6, TDNSInt);
	%StudyTDF(2020_21, FIAB, 04, MATH, 6, TDNSRat);
	%StudyTDF(2020_21, FIAB, 04, MATH, 6, TEEE);
	%StudyTDF(2020_21, FIAB, 04, MATH, 7, TFG);
	%StudyTDF(2020_21, FIAB, 04, MATH, 8, TIG);
	%StudyTDF(2020_21, FIAB, 04, MATH, 11, TGCEDLinExp);
	%StudyTDF(2020_21, FIAB, 04, MATH, 11, TGCEDQuad);
	%StudyTDF(2020_21, FIAB, 04, MATH, 11, TJREIDLinEXP);
	%StudyTDF(2020_21, FIAB, 04, MATH, 11, TMNIFBFQuad);	*/

%macro FDSubNameGrades(YrRng, TSubType, vrsn);
	options ls=135;
	%GetSnow;
	Title "&YrRng. &TSubType. - v&vrsn. [&now.]";
	proc freq data=libHere.TDF_&YrRng._&TSubType._v&vrsn. ;
		tables Subject * StudentGrade * ShortTitle * FullTitle * SegmentDescription / list missing nocum nopercent out=&TSubType._FDs;
	run;
	libname XLFDs XLSX "&WrkHere.\Yr&YrRng._&TSubType._v&vrsn._FDs.xlsx";
	data XLFDs.Yr&YrRng._&TSubType._v&vrsn.;
		set &TSubType._FDs;
	run;
%mend FDSubNameGrades;
/*	%FDSubNameGrades(FIAB, 01);
		%FDSubNameGrades(IAB, 02);
		%FDSubNameGrades(ICA, 03);
		%FDSubNameGrades(Practice, 02);
		%FDSubNameGrades(Training, 02);
		%FDSubNameGrades(FIAB, 12);	*/

%*	%FDSubNameGrades(2020_21, FIAB, 04);
%*	%FDSubNameGrades(2020_21, FIAB, 05);
%*	%FDSubNameGrades(2020_21, FIAB, 09);
%*	%FDSubNameGrades(2020_21, FIAB, 10);
%*	%FDSubNameGrades(2020_21, FIAB, 11);
%*	%FDSubNameGrades(2020_21, FIAB, 12);
%*	%FDSubNameGrades(2020_21, ICA, 09);
%*	%FDSubNameGrades(2020_21, IAB, 13);
		%FDSubNameGrades(2019_20, summative, 27);
