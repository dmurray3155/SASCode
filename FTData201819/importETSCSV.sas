/*==================================================================================================*
 | Program	:	importETSCSV.sas																																			|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Build CSV import job for ETS source data CSV files.																		|
 | Macros		: 																																											|
 | Notes		:	The target CSV file is one created by CAItemDataFromXML.py.														|
 | Usage		:	Applicable to Measurement Inc IA And calibration data preparation work.								|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2018 11 24		Initial development. This deliberate engineering is because I found that the SAS	|
 |								Enterprise Guide importer produced results with inconsistent formats.							|
 |	2019 10 16		This was migrated to the 1819 project location and modified for use here.  Major	|
 |								change is the additional generic variables under opportunity to convey guids for	|
 |								CAT and PT portions in the ETS TRT data (look for guid*** variables).							|
 *==================================================================================================*/
%let workhere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819;
%include "&workhere.\SetSessionEnv.sas";
options nosymbolgen nomprint nomlogic;

%macro VarFmtLst;
	stateabbreviation $2.
	syend BEST2.
	subject $4.
	grade $2.
	oppId $16.
	oppKey $36.
	OverallThStr $8.
	OverallThetaScore 8.4
	OverallSSStr $6.
	OverallScaleScore 4.0
	componVal1 $16.
	componContext1 $3.
	componVal1Num 16.0
	componVal2 $16.
	componContext2 $2.
	componVal2Num 16.0
	guidVal1 $36.
	guidContext1 $3.
	guidVal2 $36.
	guidContext2 $3.
	studentId $64.
	itemPosition BEST2.
	itemPageNumber BEST2.
	itemPageTime BEST8.
	itemPageVisits BEST3.
	itemNumberVisits BEST3.
	itemFormat $4.
	itemAdminDateTime $23.
	itemId $14.
	itemOper BEST1.
	itemDropped BEST1.
	itemIsSelected BEST1.
	itemScore $2.
	itemScoreStatus $9.
	itemMimeType     $CHAR12.
	itemSegmentId    $CHAR58.
	itmSubScoreDim   $CHAR9.
	itmScorePoint    $CHAR4.
	itmScoreCC       $CHAR3.
	itmScoreInfoStatus $CHAR8.
	itmSubScrDimA    $CHAR2.
	itmSubScrCCDimA  $CHAR2.
	itmSubScrDimAStatus $CHAR9.
	itmSubScrDimB    $CHAR2.
	itmSubScrCCDimB  $CHAR2.
	itmSubScrDimBStatus $CHAR9.
	itmSubScrDimC    $CHAR2.
	itmSubScrCCDimC  $CHAR2.
	itmSubScrDimCStatus $CHAR9.
	itmSubScrDimD    $CHAR2.
	itmSubScrCCDimD  $CHAR2.
	itmSubScrDimDStatus $CHAR9.
	itemRespDate     $CHAR25.
	itemRespType     $CHAR2.
	itemRespKey      $CHAR38.
	itemRespPre			 $712.
	itemResponse     $CHAR24.
	catBool					 BEST1.
	EBSR_Part1 			 $11.
	EBSR_Part2 			 $11.;
%mend VarFmtLst;

%macro importETS(CntGrd);
	%SetDSLabel;
	data bigwork.&CntGrd._ETSSrc (compress=yes label="&DSLabel.");
		length stateabbreviation $ 2
					syend 4										subject $ 4								grade $ 2
					oppID $ 16								oppKey $ 36								OverallThStr $ 8
					overallThetaScore 8				OverallSSStr $ 6
					overallScaleScore 4				componVal1 $ 16						componVal1Num 8
					componVal2 $ 16						componVal2Num 8
					componContext1 $ 3				componContext2 $ 2				guidVal1 $ 36
					guidContext1 $ 3					guidVal2 $ 36							guidContext2 $ 3
					studentId $ 64
					itemPosition 3						itemPageNumber 3					itemPageTime 8
					itemPageVisits 3					itemNumberVisits 3				itemFormat $ 4
					itemAdminDateTime $ 23		itemId $ 14								itemOper 3
					itemDropped 3							itemIsSelected 3					itemScore $ 2
					itemScoreStatus $ 9				itemMimeType $ 10					itemSegmentId $ 56
					itmSubScoreDim $ 7				itmScorePoint $ 2					itmScoreCC $ 1
					itmScoreInfoStatus $ 8		itmSubScrDimA $ 2					itmSubScrCCDimA $ 1
					itmSubScrDimAStatus $ 9		itmSubScrDimB $ 2					itmSubScrCCDimB $ 1
					itmSubScrDimBStatus $ 9		itmSubScrDimC $ 2					itmSubScrCCDimC $ 1
					itmSubScrDimCStatus $ 9		itmSubScrDimD $ 2					itmSubScrCCDimD $ 1
					itmSubScrDimDStatus $ 9		itemRespDate $ 23					itemRespType $ 4
					itemRespKey $ 36					itemRespPre $ 712.				itemResponse $ 24
					catBool 3									EBSR_Part1 $ 11						EBSR_Part2 $ 11;
		format	%VarFmtLst; ;
		informat	%VarFmtLst; ;
		infile "&workhere.\ETSCSV\&CntGrd._18-19_ItemData_.csv" lrecl=1200 firstobs=2 dlm=',' dsd;
		input stateabbreviation $  syend   subject $  grade $  oppId $  oppKey $  OverallThStr $  OverallSSStr $
					componVal1 $  componContext1 $  componVal2 $  componContext2 $ guidVal1 $  guidContext1 $
					guidVal2 $  guidContext2 $  studentId $
					itemPosition  itemPageNumber  itemPageTime  itemPageVisits  itemNumberVisits
					itemFormat $  itemAdminDateTime $  itemId $  itemOper  itemDropped  itemIsSelected
					itemScore $  itemScoreStatus $  itemMimeType $  itemSegmentId $  itmSubScoreDim $
					itmScorePoint $  itmScoreCC $  itmScoreInfoStatus $  itmSubScrDimA $  itmSubScrCCDimA  $
					itmSubScrDimAStatus $  itmSubScrDimB $  itmSubScrCCDimB $  itmSubScrDimBStatus $
					itmSubScrDimC $  itmSubScrCCDimC $  itmSubScrDimCStatus $  itmSubScrDimD $
					itmSubScrCCDimD $  itmSubScrDimDStatus $  itemRespDate $  itemRespType $  itemRespKey $
					itemRespPre $;
		/* Parse item response pieces	*/
		if itemFormat = 'EBSR' then do;
			/*	Remove the itemResponse open and close tags to unify the structure of the two parts		*/
			itemRespPre = tranwrd(itemRespPre, '<itemResponse>', '');
			itemRespPre = trim(left(tranwrd(itemRespPre, '</itemResponse>', '')));
			/*	Split the two parts	*/
			if substr(itemRespPre, 1, 45) = '<response id="choiceInteraction_1.RESPONSE"/>' then EBSR_Split_Loc = 46;
			else EBSR_Split_Loc = index(itemRespPre, '</response><response id="choiceInteraction_2.RESPONSE"') + 11;
			EBSR_Part1_str=substr(itemRespPre, 1, EBSR_Split_Loc - 1);
			EBSR_Part2_str=substr(itemRespPre, EBSR_Split_Loc);
			%do prt = 1 %to 2;
				RespFieldLen = length(EBSR_Part&prt._str);
				select(RespFieldLen);
					when(1) EBSR_Part&prt. = '';
					when(45) EBSR_Part&prt. = '';
					when(98) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 79, 1));
					when(141) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 79, 1)||'|'||substr(EBSR_Part&prt._str, 122, 1));
					when(184) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 79, 1)||'|'||substr(EBSR_Part&prt._str, 122, 1)||'|'||substr(EBSR_Part&prt._str, 165, 1));
					when(227) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 79, 1)||'|'||substr(EBSR_Part&prt._str, 122, 1)||'|'||substr(EBSR_Part&prt._str, 165, 1)||'|'||
										substr(EBSR_Part&prt._str, 208, 1));
					when(270) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 79, 1)||'|'||substr(EBSR_Part&prt._str, 122, 1)||'|'||substr(EBSR_Part&prt._str, 165, 1)||'|'||
										substr(EBSR_Part&prt._str, 208, 1)||'|'||substr(EBSR_Part&prt._str, 251, 1));
					when(313) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 79, 1)||'|'||substr(EBSR_Part&prt._str, 122, 1)||'|'||substr(EBSR_Part&prt._str, 165, 1)||'|'||
										substr(EBSR_Part&prt._str, 208, 1)||'|'||substr(EBSR_Part&prt._str, 251, 1)||'|'||substr(EBSR_Part&prt._str, 294, 1));
					otherwise do;
						EBSR_Part&prt. = "PROB.E&prt.";
						put "Problem with field length for EBSR part &prt.: " studentId ' - ' itemId ' - ' RespFieldLen ;
					end;
				end;		/*	select		*/
			%end;
			itemResponse = compress(EBSR_Part1||';'||EBSR_Part2);
		end;
		else if itemFormat in ('MC', 'MS') then do;
			itemRespPre = tranwrd(itemRespPre, '<itemResponse>', '');
			itemRespPre = trim(left(tranwrd(itemRespPre, '</itemResponse>', '')));
			RespFieldLen = length(itemRespPre);
			select(RespFieldLen);
				when(1) itemResponse = '';
				when(45) itemResponse = '';
				when(98) itemResponse = compress(substr(itemRespPre, 79, 1));
				when(141) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1));
				when(184) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1)||'|'||substr(itemRespPre, 165, 1));
				when(227) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1)||'|'||substr(itemRespPre, 165, 1)||'|'||
									substr(itemRespPre, 208, 1));
				when(270) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1)||'|'||substr(itemRespPre, 165, 1)||'|'||
									substr(itemRespPre, 208, 1)||'|'||substr(itemRespPre, 251, 1));
				when(313) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1)||'|'||substr(itemRespPre, 165, 1)||'|'||
									substr(itemRespPre, 208, 1)||'|'||substr(itemRespPre, 251, 1)||'|'||substr(itemRespPre, 294, 1));
				when(356) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1)||'|'||substr(itemRespPre, 165, 1)||'|'||
									substr(itemRespPre, 208, 1)||'|'||substr(itemRespPre, 251, 1)||'|'||substr(itemRespPre, 294, 1)||'|'||substr(itemRespPre, 337, 1));
				when(399) itemResponse = compress(substr(itemRespPre, 79, 1)||'|'||substr(itemRespPre, 122, 1)||'|'||substr(itemRespPre, 165, 1)||'|'||
									substr(itemRespPre, 208, 1)||'|'||substr(itemRespPre, 251, 1)||'|'||substr(itemRespPre, 294, 1)||'|'||substr(itemRespPre, 337, 1)||'|'||
									substr(itemRespPre, 380, 1));
				otherwise do;
					itemResponse = "PROB";
					put "Problem with field length for: " studentId ' - ' itemId ' - ' RespFieldLen;
				end;
			end;		/*	select		*/
		end;
		else do;
			itemResponse = compress(itemRespPre);
		end;
		oppKey = upcase(oppKey);
		componval1Num = put(componval1, 16.0);
		componval2Num = put(componval2, 16.0);
		catBool = ifn(index(ItemSegmentId, 'CAT') > 0, 1, 0);
		/*	Line above is equivalent to two lines below.  Tip is featured in this webpage: */
		/*	https://www.quanticate.com/blog/4-sas-tips-in-clinical-programming	*/
		/*	if index(ItemSegmentId, 'ADAPTIVE') > 0 then catBool = 1;
				else catBool=0;  */
		if OverallThStr = 'NS' then overallThetaScore = .;
		else overallThetaScore = put(overallThStr, 8.4);
		if OverallSSStr = 'NS' then OverallScaleScore = .;
		else overallScaleScore = put(overallSSStr, 4.0);
		drop OverallThStr overallSSStr ItemRespPre
			 EBSR_Split_Loc EBSR_Part1_str EBSR_Part2_str EBSR_Part1 EBSR_Part2 RespFieldLen;
	run;
	/*	Create indices for more rapid search returns in downstream processing	*/
	proc datasets library=bigwork;
		modify &CntGrd._ETSSrc;
		index create guidVal1;
		index create itemId;
	run;
%mend importETS;
%*	%importETS(ela03);
%*	%importETS(ela04);
%*	%importETS(math03);
%*	%importETS(ela05);
%*	%importETS(math07);
%*	%importETS(math08);
%*	%importETS(math04);
%*	%importETS(math05);
%*	%importETS(ela07);
%*	%importETS(ela06);
%*	%importETS(math06);
%*	%importETS(math11);
%*	%importETS(ela08);
%*	%importETS(ela11);
