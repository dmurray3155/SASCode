/*==================================================================================================*
 | Program	:	DevCATAdminData.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	From TDF (or pull list), develop data that will be written to XML for CAT Admin				|
 |						package.																																							|
 | Macros		: ... as well as small, often used tools from my toolbox.																|
 | Notes		:	Input datasets may vary based on time-frame.  From 18-19 onward test definition       |
 |						files represented the draft item pool.  Prior to that it was called the pull list.		|
 | Usage		:	Applicable to test packaging > summative > admin package(s)														|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2020 08 16		Initial development. 																															|
 *==================================================================================================*/
 
 %let wrkHere = C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\CATAdminPackage;
 libname libHere "&wrkHere.";
 
 *** source data library for 17-18 *** ;
 /*	For reference of identifying a range, see this page:
 		https://communities.sas.com/t5/SAS-Programming/specifying-variable-names-row-using-libname-xlsx/td-p/466604	*/
 proc import datafile="&wrkHere.\1718_Lists\17-18_ELA.CAT.SUMMATIVE.TestsAndItems.xlsx"
 		out = libHere.ELACAT1718Items dbms = xlsx range = 'Test Items$A2:0';
 run;

/*	Targets to read:
		17-18_ELA.CAT.SUMMATIVE.TestsAndItems.xlsx
			Test Items 
			Tests
		17-18_MATH.CAT.SUMMATIVE.TestsAndItems.xlsx
			Test Items 
			Tests
		17-18_PT.SUMMATIVE.TestsAndItems.xlsx
			Test Items 
			Tests																						*/