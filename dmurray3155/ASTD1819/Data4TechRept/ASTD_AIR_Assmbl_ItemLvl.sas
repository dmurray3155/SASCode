/*==================================================================================================*
 | Program	:	ASTD_AIR_Assemble_ItemLvl.sas																													|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|	
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 20		Initial development.																															|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\AIR;
libname libHere "&wrkHere.";
%let dlvrHere=E:\SBAC\AnnualStudTest\1819\DLVRY\AIR\Item;
libname dlvryItm "&dlvrHere.";

%macro AssignFileNames;
	%global DE_ela_ItemFile DE_math_ItemFile HI_ela_ItemFile HI_math_ItemFile
					ID_ela_ItemFile ID_math_ItemFile OR_ela_ItemFile OR_math_ItemFile
					SD_ela_ItemFile SD_math_ItemFile USVI_ela_ItemFile USVI_math_ItemFile
					VT_ela_ItemFile VT_math_ItemFile WA_ela_3_ItemFile WA_math_3_ItemFile
					WA_ela_4_ItemFile WA_math_4_ItemFile WA_ela_5_ItemFile WA_math_5_ItemFile
					WA_ela_6_ItemFile WA_math_6_ItemFile WA_ela_7_ItemFile WA_math_7_ItemFile
					WA_ela_8_ItemFile WA_math_8_ItemFile WA_ela_11_ItemFile WA_math_11_ItemFile;
	%let DE_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191002164852.txt;
	%let DE_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191003134656.txt;
	%let HI_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191007163023.txt;
	%let HI_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191002163752.txt;
	%let ID_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191010200248.txt;
	%let ID_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191011102135.txt;
	%let OR_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191015113026.txt;
	%let OR_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191015220958.txt;
	%let SD_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191007170958.txt;
	%let SD_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191007232513.txt;
	%let USVI_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191007164339.txt;
	%let USVI_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191002104907.txt;
	%let VT_ela_ItemFile=G3ThroughG11_ELA_ProductionItemCapture_20191001214047.txt;
	%let VT_math_ItemFile=G3ThroughG11_Math_ProductionItemCapture_20191002125133.txt;
	%let WA_ela_3_ItemFile=G3_ELA_ProductionItemCapture_20191015113539.txt;
	%let WA_math_3_ItemFile=G3_Math_ProductionItemCapture_20191015123219.txt;
	%let WA_ela_4_ItemFile=G4_ELA_ProductionItemCapture_20191017143609.txt;
	%let WA_math_4_ItemFile=G4_Math_ProductionItemCapture_20191015160609.txt;
	%let WA_ela_5_ItemFile=G5_ELA_ProductionItemCapture_20191017152801.txt;
	%let WA_math_5_ItemFile=G5_Math_ProductionItemCapture_20191017162604.txt;
	%let WA_ela_6_ItemFile=G6_ELA_ProductionItemCapture_20191018084829.txt;
	%let WA_math_6_ItemFile=G6_Math_ProductionItemCapture_20191018084917.txt;
	%let WA_ela_7_ItemFile=G7_ELA_ProductionItemCapture_20191017102755.txt;
	%let WA_math_7_ItemFile=G7_Math_ProductionItemCapture_20191017112307.txt;
	%let WA_ela_8_ItemFile=G8_ELA_ProductionItemCapture_20191018095554.txt;
	%let WA_math_8_ItemFile=G8_Math_ProductionItemCapture_20191018095520.txt;
	%let WA_ela_11_ItemFile=G11_ELA_ProductionItemCapture_20191018105220.txt;
	%let WA_math_11_ItemFile=G11_Math_ProductionItemCapture_20191018105250.txt;
%mend AssignFileNames;

%AssignFileNames;
%macro WrapBySt(ST);
	%macro WrapBySbj(Sbj);
		proc sql;
			create table BaseJoin (compress=yes) as 
			select itm.studentidentifier, itm.itemId, itm.itemOrdr, itm.segmentId, itm.ItemLifeStg,
				itm.PageNumber, itm.NbrItemVisits, itm.StdntRspnsTime, itm.AssessmentItemType,
				itm.ScoringDimension, itm.AssessmentItemResponseScoreValue, itm.OppKey,
				stdnt.AssessmentLevelForWhichDesigned as Grade
			from libHere.&ST._&Sbj._item_1819 as itm
			left join libHere.&ST._&Sbj._stud_1819 as stdnt
			on itm.oppKey = stdnt.oppKey;
		quit;
		%SetDSLabel;
		data IL19 (compress=yes);
			set BaseJoin;
			format studentIdentifier $68.	fileName $64. memberName $2. subject $4.;
			%if %eval("&ST." = "WA") %then %do;
				%do Grd=3 %to 11;
					if Grade = &Grd. then fileName = "&&&&&ST._&Sbj._&Grd._ItemFile.";
				%end;
			%end;
			%else %do;
				fileName = "&&&&&ST._&Sbj._ItemFile.";
			%end;
			memberName = "&ST.";
			if scoringDimension in ('EP', 'C') then do;
				AssessmentItemType = 'WER';
				if scoringDimension = 'EP' then ScoringDimension = 'D';
			end;
			subject = "&Sbj.";
			keep studentIdentifier itemId ItemOrdr SegmentId PageNumber NbrItemVisits
				StdntRspnsTime AssessmentItemType AssessmentItemResponseScoreValue 
				subject Grade oppKey ScoringDimension ItemLifeStg fileName memberName;
		run;
		proc sql;
			create table dlvryItm.air_&ST._&Sbj._item_level (compress=yes label="&DSLabel.") as
			select StudentIdentifier, itemId as AssessmentItemIdentifier,
				ItemOrdr as ItemOrder, SegmentId, ItemLifeStg, PageNumber, NbrItemVisits, 
				StdntRspnsTime, AssessmentItemType, ScoringDimension as scoreDimension,
				AssessmentItemResponseScoreValue, fileName, memberName, subject, grade, oppKey
			from IL19
			order by grade, StudentIdentifier, ItemOrder;
		quit;
	%mend WrapBySbj;
		%WrapBySbj(ela);				%WrapBySbj(math);
%mend WrapBySt;
	%WrapBySt(DE);				%WrapBySt(HI);				%WrapBySt(ID);				%WrapBySt(OR);
	%WrapBySt(SD);				%WrapBySt(USVI);			%WrapBySt(VT);				%WrapBySt(WA);