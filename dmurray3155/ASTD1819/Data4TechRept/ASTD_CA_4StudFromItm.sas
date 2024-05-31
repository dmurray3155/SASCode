/*==================================================================================================*
 | Program	:	ASTD_CA_4StudFromItm.sas																															|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	This logic harvests the first CAT postion, first CAT admin time, first PT position,		|
 |						and first PT admin time from the item-level data (from FT analysis).									|
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:	The downstream target of the SAS dataset created by this logic is the student-level		|
 |						data file for psychometricians for technical reporting.																|
 |						Apply this when I have time:																													|
 |						https://www.ultraedit.com/support/tutorials-power-tips/ultraedit/sas.html							|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 10		Initial development																																|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\ETS;
libname libHere "&wrkHere.";

%let wrkFT=E:\SBAC\1819\IA_Calib;
%macro WrapBySG(SubjGrd);
	/*	Need to create a dataset of first item position and admin time per test segment (CAT
			vs. PT) per student.  Those four fields are included in the student-level data export	*/
	libname SGLib "&wrkFT.\&SubjGrd.";
	data ItmFlds4StudData (compress = yes);
		set SGLib.&SubjGrd._etssrc;
		format CATPT $3. studentId2 $68.;
		if index(ItemSegmentId, 'CAT') > 0 then CATPT = 'CAT';
		if index(ItemSegmentId, 'Perf') > 0 then CATPT = 'PT';
		studentId2 = compress('CA_'||studentId);
		keep studentId2 oppkey CATPT itemPosition itemAdminDateTime;
	run;
	proc sort data = ItmFlds4StudData (compress = yes);
		by studentId2 CATPT itemPosition;
	run;
	data libHere.&SubjGrd._ItmAug4Std (compress=yes rename=(studentId2 = studentId));
		set ItmFlds4StudData;
		retain CATitem1Sequence CATitem1Time;
		by studentId2 CATPT itemPosition;
		if first.CATPT then do;
			if CATPT = 'CAT' then do;
				CATitem1Sequence = ItemPosition;
				CATitem1Time = itemAdminDateTime;
			end;
			else if CATPT = 'PT' then do;
				PTitem1Sequence = ItemPosition;
				PTitem1Time = itemAdminDateTime;
				output;
			end;
		end;
		drop ItemPosition itemAdminDateTime CATPT;
	run;
%mend WrapBySG;
%WrapBySG(ela03);				%WrapBySG(ela04);				%WrapBySG(ela05);				%WrapBySG(ela06);
%WrapBySG(ela07);				%WrapBySG(ela08);				%WrapBySG(ela11);
%WrapBySG(math03);			%WrapBySG(math04);			%WrapBySG(math05);			%WrapBySG(math06);
%WrapBySG(math07);			%WrapBySG(math08);			%WrapBySG(math11);