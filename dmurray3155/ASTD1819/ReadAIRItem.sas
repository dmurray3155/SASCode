/* --------------------------------------------------------------------
   Code generated by a SAS task
   
   Generated on Thursday, December 12, 2019 at 12:41:17 PM
   By task:     Import Data Wizard
   
   Source file: C:\Users\Donald Murray\OneDrive - Smarter Balanced
   UCSC\Summary
   Tables\1819\G3ThroughG11_Math_ProductionItemCapture_20191002104907.
   txt
   Server:      Local File System
   
   Output data: WORK.G3ThrG11_Math_ProdItem_VI
   Server:      Local
   -------------------------------------------------------------------- */

%macro ItemVarFmtLst;
	AssessmentSubtestResultDateCreat BEST16.
	AssessmentItemIdentifier $CHAR12.
	AssessmentItemType $CHAR5.
	RespTypCd        $CHAR1.
	Response         $CHAR20000.
	AssessmentItemResponseScoreValue BEST2.
	ItemOrdr         BEST2.
	AssessmentFormNumber $CHAR57.
	SegmentID        $CHAR67.
	VndrTstEvent_ID  BEST8.
	StudentIdentifier $CHAR43.
	ItemLifeStg      $CHAR1.
	PageNumber       BEST2.
	NbrItemVisits    BEST2.
	StdntRspnsTime   BEST8.
	ScoringDimension $CHAR2.
	Scr_Rater1       BEST1.
	Scr_Rater2       BEST1.
	Scr_Rater3       $CHAR1.
	CC_Rater1        $CHAR1.
	CC_Rater2        $CHAR1.
	CC_Rater3        $CHAR1.
	CC_Reso          $CHAR1.
	ID_Rater1        BEST5.
	ID_Rater2        BEST5.
	ID_Rater3        $CHAR1.
	OppKey           $CHAR36.
	itemId						BEST8.
%mend ItemVarFmtLst;

%macro ReadAIRItem(ST, Subj, FylNm, outDS, Encdng);
	%SetDSLabel;
	DATA &outDS. (compress=yes label="&DSLabel.");
    LENGTH
        AssessmentSubtestResultDateCreat   8
        AssessmentItemIdentifier $ 12
        AssessmentItemType $ 5
        RespTypCd        $ 1
        Response         $ 20000
        AssessmentItemResponseScoreValue   8
        ItemOrdr           8
        AssessmentFormNumber $ 57
        SegmentID        $ 67
        VndrTstEvent_ID    8
        StudentIdentifier $ 43
        ItemLifeStg      $ 1
        PageNumber         8
        NbrItemVisits      8
        StdntRspnsTime     8
        ScoringDimension $ 2
        Scr_Rater1         8
        Scr_Rater2         8
        Scr_Rater3       $ 1
        CC_Rater1        $ 1
        CC_Rater2        $ 1
        CC_Rater3        $ 1
        CC_Reso          $ 1
        ID_Rater1          8
        ID_Rater2          8
        ID_Rater3        $ 1
        OppKey           $ 36
        itemId						8;
    LABEL
        AssessmentSubtestResultDateCreat = "AssessmentSubtestResultDateCreated" ;
    FORMAT %ItemVarFmtLst;
    INFORMAT %ItemVarFmtLst;
    INFILE "&FylNm."
        LRECL=32767
        FIRSTOBS=2
        ENCODING="&Encdng."
        DLM='7c'x
        MISSOVER
        DSD ;
    INPUT
        AssessmentSubtestResultDateCreat : ?? BEST16.
        AssessmentItemIdentifier : $CHAR12.
        AssessmentItemType : $CHAR5.
        RespTypCd        : $CHAR1.
        Response         : $CHAR20000.
        AssessmentItemResponseScoreValue : ?? BEST2.
        ItemOrdr         : ?? BEST2.
        AssessmentFormNumber : $CHAR57.
        SegmentID        : $CHAR67.
        VndrTstEvent_ID  : ?? BEST8.
        StudentIdentifier : $CHAR43.
        ItemLifeStg      : $CHAR1.
        PageNumber       : ?? BEST2.
        NbrItemVisits    : ?? BEST2.
        StdntRspnsTime   : ?? BEST8.
        ScoringDimension : $CHAR2.
        Scr_Rater1       : ?? BEST1.
        Scr_Rater2       : ?? BEST1.
        Scr_Rater3       : $CHAR1.
        CC_Rater1        : $CHAR1.
        CC_Rater2        : $CHAR1.
        CC_Rater3        : $CHAR1.
        CC_Reso          : $CHAR1.
        ID_Rater1        : ?? BEST5.
        ID_Rater2        : ?? BEST5.
        ID_Rater3        : $CHAR1.
        OppKey           : $CHAR36. ;
      itemId = put(scan(AssessmentItemIdentifier, 2, '-'), 8.0);
	RUN;
%mend ReadAIRItem;
