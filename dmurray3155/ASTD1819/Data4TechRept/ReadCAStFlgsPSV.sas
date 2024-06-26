%let wrkHere=E:\SBAC\AnnualStudTest\1819\ETS;
libname libHere "&wrkHere.";

/* --------------------------------------------------------------------
   Code generated by a SAS task
   
   Generated on Wednesday, March 4, 2020 at 5:21:41 PM
   By task:     Import Data Wizard
   
   Source file: E:\SBAC\AnnualStudTest\1819\ETS\CA\tab_ELA03_18-
   19_StdFlgs.psv
   Server:      Local File System
   
   Output data: LIBHERE.tab_ELA03_18_19_StdFlgs
   Server:      Local
   -------------------------------------------------------------------- */

%macro VarFmtLstCAPSV;
	stateabbreviation $CHAR2.
	syend            BEST2.
	subject          $CHAR4.
	grade            BEST2.
	studentId        $CHAR63.
	sex              $CHAR6.
	ethnicityvalue   BEST3.
	educationsubgroupvalue BEST3.
	languagecode     $CHAR2.
	englishlanguageproficiencylevel $CHAR18.
	firstentrydateintousschool YYMMDD10.
	limitedenglishproficiencyentryda YYMMDD10.
	districtId       BEST14.
	districtName     $CHAR89.
	schoolId         BEST14.
	schoolName       $CHAR89.
	studentGroupName $CHAR3.
	oppId            BEST16.
	oppKey           $CHAR36.
	oppStatus        $CHAR11.
	oppValidity      $CHAR7.
	oppCompleteness  $CHAR8.
	testId			  $CHAR72.
	testMode			  $CHAR8.
	accomSpanTrans   $CHAR11.
	accomASL         $CHAR8.
	accomBraille     $CHAR10.
	accomTransGloss  $CHAR56.
	overallScaleScore 4.0
	overallScaleScoreSE 3.0
	overallPerformanceLevel 3.0
	overallThetaScore 8.4
	claim1ScaleScore 4.0
	claim1ScaleScoreSE 8.4
	claim1PerformanceLevel 3.0
	claim2ScaleScore 4.0
	claim2ScaleScoreSE 8.4
	claim2PerformanceLevel 3.0
	claim3ScaleScore 4.0
	claim3ScaleScoreSE 8.4
	claim3PerformanceLevel 3.0
	claim4ScaleScore 4.0
	claim4ScaleScoreSE 8.4
	claim4PerformanceLevel 3.0
%mend VarFmtLstCAPSV;

%macro ReadCAStFlgPSV(infyl, dsRef);
	%SetDSLabel;
	DATA &dsRef (compress=yes label="&DSLabel.");
    LENGTH
        stateabbreviation $ 2
        syend              8
        subject          $ 4
        grade              8
        studentId        $ 63
        sex              $ 6
        ethnicityvalue     8
        educationsubgroupvalue   8
        languagecode     $ 2
        englishlanguageproficiencylevel $ 18
        firstentrydateintousschool   8
        limitedenglishproficiencyentryda   8
        districtId         8
        districtName     $ 89
        schoolId           8
        schoolName       $ 89
        studentGroupName $ 3
        oppId              8
        oppKey           $ 36
        oppStatus        $ 11
        oppValidity      $ 7
        oppCompleteness  $ 8
		  testId				 $ 72
		  testMode			 $ 8
        accomSpanTrans   $ 11
        accomASL         $ 8
        accomBraille     $ 10
        accomTransGloss  $ 56
        overallScaleScore 8
        overallScaleScoreSE 8
        overallPerformanceLevel 8
        overallThetaScore 4
        claim1ScaleScore 8
        claim1ScaleScoreSE 8
        claim1PerformanceLevel 8
        claim2ScaleScore 8
        claim2ScaleScoreSE 8
        claim2PerformanceLevel 8
        claim3ScaleScore 8
        claim3ScaleScoreSE 8
        claim3PerformanceLevel 8
        claim4ScaleScore 8
        claim4ScaleScoreSE 8
        claim4PerformanceLevel 8 ;
    LABEL
        limitedenglishproficiencyentryda = "limitedenglishproficiencyentrydate" ;
    FORMAT %VarFmtLstCAPSV;
    INFORMAT %VarFmtLstCAPSV;
    INFILE "&infyl."
        LRECL=32767
        FIRSTOBS=2
        ENCODING="WLATIN1"
        DLM='7c'x
        MISSOVER
        DSD ;
    INPUT
        stateabbreviation : $CHAR2.
        syend            : ?? BEST2.
        subject          : $CHAR4.
        grade            : ?? BEST2.
        studentId        : $CHAR63.
        sex              : $CHAR6.
        ethnicityvalue   : ?? BEST3.
        educationsubgroupvalue : ?? BEST3.
        languagecode     : $CHAR2.
        englishlanguageproficiencylevel : $CHAR18.
        firstentrydateintousschool : ?? YYMMDD10.
        limitedenglishproficiencyentryda : ?? YYMMDD10.
        districtId       : ?? BEST14.
        districtName     : $CHAR89.
        schoolId         : ?? BEST14.
        schoolName       : $CHAR89.
        studentGroupName : $CHAR3.
        oppId            : ?? BEST16.
        oppKey           : $CHAR36.
        oppStatus        : $CHAR11.
        oppValidity      : $CHAR7.
        oppCompleteness  : $CHAR8.
		  testId				 : $CHAR72.
		  testMode			 : $CHAR8.
        accomSpanTrans   : $CHAR11.
        accomASL         : $CHAR8.
        accomBraille     : $CHAR10.
        accomTransGloss  : $CHAR56.
        overallScaleScore : ?? BEST8.
        overallScaleScoreSE : ?? BEST8.
        overallPerformanceLevel : ?? BEST3.
        overallThetaScore : ?? BEST8.
        claim1ScaleScore : ?? BEST8.
        claim1ScaleScoreSE : ?? BEST8.
        claim1PerformanceLevel : ?? BEST3.
        claim2ScaleScore : ?? BEST8.
        claim2ScaleScoreSE : ?? BEST8.
        claim2PerformanceLevel : ?? BEST3.
        claim3ScaleScore : ?? BEST8.
        claim3ScaleScoreSE : ?? BEST8.
        claim3PerformanceLevel : ?? BEST3.
        claim4ScaleScore : ?? BEST8.
        claim4ScaleScoreSE : ?? BEST8.
        claim4PerformanceLevel : ?? BEST3. ;
	RUN;
%mend ReadCAStFlgPSV;

%macro WrapBySubj(Subj);
	%macro WrapByGrd(Grd);
		%ReadCAStFlgPSV(&wrkHere.\CA\tab_&Subj.&Grd._18-19_StdFlgs.psv,
			libHere.tab_&Subj.&Grd._18_19_StdFlgs);
	%mend WrapByGrd;
		%WrapByGrd(03);		%WrapByGrd(04);		%WrapByGrd(05);
		%WrapByGrd(06);		%WrapByGrd(07);		%WrapByGrd(08);
		%WrapByGrd(11);
%mend WrapBySubj;
	%WrapBySubj(ELA);
	%WrapBySubj(MATH);

