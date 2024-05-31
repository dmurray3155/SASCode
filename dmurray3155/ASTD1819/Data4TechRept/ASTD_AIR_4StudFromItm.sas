/*==================================================================================================*
 | Program	:	ASTD_AIR_4StudFromItm.sas																															|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	This logic harvests the first CAT postion, and first PT position from the item-level	|
 |						data.																																									|
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:	The downstream target of the SAS dataset created by this logic is the student-level		|
 |						data file for psychometricians for technical reporting.																|
 |						Apply this when I have time:																													|
 |						https://www.ultraedit.com/support/tutorials-power-tips/ultraedit/sas.html							|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 17		Initial development (logic copied from the CA version and translated to AIR)			|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\AIR;
libname libHere "&wrkHere.";

%macro WrapByState(ST);
	%macro WrapBySubj(Sbj);
		/*	Need to create a dataset of first item position per test segment (CAT
				vs. PT) per student.  Those two fields are included in the student-level data export	*/

	data ItmFlds4StudData (compress = yes);
		set libHere.&ST._&Sbj._item_1819;
		format CATPT $3. ;
		if index(AssessmentFormNumber, 'Perf') > 0 then CATPT = 'PT';
		else CATPT = 'CAT';
		keep studentIdentifier oppkey CATPT ItemOrdr;
	run;
	proc sort data = ItmFlds4StudData (compress = yes);
		by studentIdentifier CATPT ItemOrdr;
	run;
	data libHere.&ST._&Sbj._ItmAug4Std (compress=yes rename=(studentId2 = studentId));
		set ItmFlds4StudData;
		retain CATitem1Sequence ;
		by studentIdentifier CATPT ItemOrdr;
		if first.CATPT then do;
			if CATPT = 'CAT' then do;
				CATitem1Sequence = ItemOrdr;
			end;
			else if CATPT = 'PT' then do;
				PTitem1Sequence =  ItemOrdr;
				output;
			end;
		end;
		drop ItemOrdr CATPT;
	run;
	%mend WrapBySubj(Sbj);
		%WrapBySubj(ela);			%WrapBySubj(math);
%mend WrapByState(ST);
	%WrapByState(DE);				%WrapByState(HI);				%WrapByState(ID);				%WrapByState(OR);
	%WrapByState(SD);				%WrapByState(USVI);			%WrapByState(VT);				%WrapByState(WA);