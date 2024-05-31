/*==================================================================================================*
 | Program	:	ReadNVMainStud.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|
 | Macros		: %ReadMVStud and %ReadNVClaims stored in SAS Code module ReadNVStudMacDef.sas					|
 |						As well as some from D.M.'s toolbox.sas and those developed in this code base.				|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 21		Initial development																																|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\DRC\NV;
libName libHere "&wrkHere.";

%macro ReadNVDataFiles;
	%include "&wrkHere.\ReadNVStudMacDef.sas";
	%ReadNVStud(&wrkHere.\Smarter_No_PII.csv,
				libHere.Smarter_No_PII);

%*	%ReadNVClaims(&wrkHere.\Claim_Level_ SEM_Smarter_Student_ELA.csv,
				libHere.Claim_SEM_ELA);

%*	%ReadNVClaims(&wrkHere.\Claim_Level_ SEM_Smarter_Student_MATH.csv,
				libHere.Claim_SEM_MATH);
%mend ReadNVDataFiles;
	%ReadNVDataFiles;

%macro GetItemIDXWlks;
	%SetDSLabel;
	libname ItemIDs xlsx "&wrkHere.\ItemID_Crosswalk_2019.xlsx";
	data libHere.CAT_items (label="&DSLabel.");
		set ItemIDs.'CAT Form Items'n;
	run;
	data libHere.PT_items (label="&DSLabel.");
		set ItemIDs.'PT Form Items'n;
	run;
	data libHere.FF_items (label="&DSLabel.");
		set ItemIDs.'Fixed Form Items'n;
	run;
%mend GetItemIDXWlks;
%*	%GetItemIDXWlks;