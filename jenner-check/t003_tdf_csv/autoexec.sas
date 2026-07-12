/* cap input rows for the captured run */
options obs=100;

/* %GetNow from toolbox.sas (repo root) -- unmodified, referenced by ReadTDFCSV.sas's %StudyTDF */
%macro GetNow;
    %global now;
    %let time=%sysfunc(time(),timeampm11.);
    %let date=%sysfunc(date(),worddate12.);
    %let now=on &date. at &time;
%mend GetNow;

/* %VarFmtLst and %ReadTDFCSV -- unmodified from FFConfigSheets202021/ReadTDFCSV.sas (repo) */
%macro VarFmtLst;
	AssessmentType   $CHAR7.
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
	StimId           $CHAR1.
	Key              $CHAR4.
	ItemType         $CHAR4.
	ScoringEngine    $CHAR19.
	PerformanceTask  $CHAR2.
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
	Recoding_d1      $CHAR1.
	IRTa_d1          BEST7.
	IRTb_d1          BEST8.
	GPCd2_d1         BEST7.
	GPCd3_d1         BEST8.
	GPCd4_d1         $CHAR1.
	GPCd5_d1         $CHAR1.
	PrpCrt_d2        $CHAR1.
	ItemTotal_d2     $CHAR1.
	MaxRub_d2        $CHAR1.
	MaxScr_d2        $CHAR1.
	Recoding_d2      $CHAR1.
	IRTa_d2          $CHAR1.
	IRTb_d2          $CHAR1.
	GPCd2_d2         $CHAR1.
	GPCd3_d2         $CHAR1.
	GPCd4_d2         $CHAR1.
	GPCd5_d2         $CHAR1.
	iat_changes      $CHAR8.
	TDF_version   $CHAR20. ;
%mend VarFmtLst;

%macro ReadTDFCSV(infile, outDS);
	DATA &outDS.;
		LENGTH
			AssessmentType   $ 7
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
			StimId           $ 1
			Key              $ 4
			ItemType         $ 4
			ScoringEngine    $ 19
			PerformanceTask  $ 2
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
			Recoding_d1      $ 1
			IRTa_d1            8
			IRTb_d1            8
			GPCd2_d1           8
			GPCd3_d1           8
			GPCd4_d1         $ 1
			GPCd5_d1         $ 1
			PrpCrt_d2        $ 1
			ItemTotal_d2     $ 1
			MaxRub_d2        $ 1
			MaxScr_d2        $ 1
			Recoding_d2      $ 1
			IRTa_d2          $ 1
			IRTb_d2          $ 1
			GPCd2_d2         $ 1
			GPCd3_d2         $ 1
			GPCd4_d2         $ 1
			GPCd5_d2         $ 1
			iat_changes      $ 8
			TDF_version   $ 20 ;
    FORMAT %VarFmtLst;
    INFORMAT %VarFmtLst;
    INFILE "&infile."
        LRECL=32767
        FIRSTOBS=2
        ENCODING="WLATIN1"
        DLM='2c'x
        MISSOVER
        DSD ;
    INPUT
        AssessmentType   : $CHAR7.
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
        StimId           : $CHAR1.
        Key              : $CHAR4.
        ItemType         : $CHAR4.
        ScoringEngine    : $CHAR19.
        PerformanceTask  : $CHAR2.
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
        Recoding_d1      : $CHAR1.
        IRTa_d1          : ?? COMMA7.
        IRTb_d1          : ?? COMMA8.
        GPCd2_d1         : ?? COMMA7.
        GPCd3_d1         : ?? COMMA8.
        GPCd4_d1         : $CHAR1.
        GPCd5_d1         : $CHAR1.
        PrpCrt_d2        : $CHAR1.
        ItemTotal_d2     : $CHAR1.
        MaxRub_d2        : $CHAR1.
        MaxScr_d2        : $CHAR1.
        Recoding_d2      : $CHAR1.
        IRTa_d2          : $CHAR1.
        IRTb_d2          : $CHAR1.
        GPCd2_d2         : $CHAR1.
        GPCd3_d2         : $CHAR1.
        GPCd4_d2         : $CHAR1.
        GPCd5_d2         : $CHAR1.
        iat_changes      : $CHAR8.
        TDF_version   : $CHAR20. ;
	RUN;
%mend ReadTDFCSV;