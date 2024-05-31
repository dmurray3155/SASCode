/*==================================================================================================*
 | Program	:	ASTD_CA_Assemble_ItemLvl.sas																													|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|	
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 13		Initial development.																															|
 *==================================================================================================*/
 
%let wrkHere=E:\SBAC\AnnualStudTest\1819\DLVRY\ETS\Item;
libname dlvryItm "&wrkHere.";
%let CalStb=E:\SBAC\1819\IA_Calib;

%macro WrapBySbjGd(SbjGd);
	%SetDSLabel;
	libname CalLib "&CalStb.\&SbjGd.";
	data IL19 (compress=yes);
		set CalLib.&SbjGd._etssrc;
		retain studentId itemId itemPosition itemSegmentId itemOper itemPageNumber 
				itemPageVisits itemPageTime itemFormat itemScore oppId subject grade oppKey;
		format studentIdentifier $68. scoreDimension $1. AssessmentItemResponseScoreValue 3.0
				ItemLifeStg $1. AssessmentItemIdentifier 8.0 fileName $24. memberName $2. gradeNum 3.0;
		if itemOper = 1 then ItemLifeStg = 'O';
		else if itemOper = 0 then ItemLifeStg = 'F';
		AssessmentItemIdentifier = scan(itemId, 2, '-');
		fileName = compress(oppId||'.xml');
		memberName = 'CA';
		gradeNum = put(grade, 3.0);
		studentIdentifier = compress('CA_'||studentId);
		if itemFormat = 'WER' then do;
			scoreDimension = 'C';
			AssessmentItemResponseScoreValue = put(itmSubScrDimC, 3.0);
			output;
			scoreDimension = 'D';
			AssessmentItemResponseScoreValue = put(itmSubScrDimD, 3.0);
			output;
		end;
		else do;
			scoreDimension = '';
			AssessmentItemResponseScoreValue = put(itemScore, 3.0);
			output;
		end;
		keep studentIdentifier itemPosition itemSegmentId itemPageNumber itemPageVisits
			itemPageTime itemFormat itemScore oppId subject gradeNum oppKey scoreDimension
			AssessmentItemResponseScoreValue scoreDimension ItemLifeStg
			AssessmentItemIdentifier fileName memberName;
	run;
	proc sql;
		create table dlvryItm.ets_item_level_2019_&SbjGd. (compress=yes label="&DSLabel.") as
		select StudentIdentifier, AssessmentItemIdentifier, itemPosition as ItemOrder, 
			itemSegmentId as SegmentID, ItemLifeStg, itemPageNumber as PageNumber,
			itemPageVisits as NbrItemVisits, itemPageTime as StdntRspnsTime,
			itemFormat as AssessmentItemType, scoreDimension, AssessmentItemResponseScoreValue, 
			fileName, memberName, subject, gradeNum as grade, oppKey
		from IL19;
	quit;
%mend WrapBySbjGd;
/*	%WrapBySbjGd(ela03);				%WrapBySbjGd(ela04);				%WrapBySbjGd(ela05);
	%WrapBySbjGd(ela06);				%WrapBySbjGd(ela07);				%WrapBySbjGd(ela08);
	%WrapBySbjGd(ela11);
	%WrapBySbjGd(math03);				%WrapBySbjGd(math04);				%WrapBySbjGd(math05);
	%WrapBySbjGd(math06);				%WrapBySbjGd(math07);				%WrapBySbjGd(math08);
	%WrapBySbjGd(math11);		*/