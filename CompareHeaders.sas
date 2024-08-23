/*==================================================================================================*
 | Program	:	CompareHeaders.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	To avoid making the assumption of no changes to the contents of data files, 					|
 |						perform a comparison between a current data file header and its corresponding					|
 |						file header from the previous cycle.																									|
 | Macros		: CompareFileHeaders - This is the outer wrapper macro.																	|
 |							parameters:																																					|
 |								thisfile - full path and file reference of current file.													|
 |								lastfile - full path and file reference of corresponding file from previous				|
 |														cycle.																																|
 |								delim - the character used as delimiter in both files.														|
 |								headmaxlen - integer value of maximum record length of both files.								|
 |						ReadFile - This is a submacro within the outer wrapper macro that reads in each 			|
 |												header row and parses the fields.																					|
 |							parameters:																																					|
 |								fileref - path and file reference																									|
 |								outDS - name of output dataset (can be two-level)																	|
 |								hdmxlen - local alias for headmaxlen																							|
 |								rptrslt - optional boolean to print out result set prior to analysis (0 or 1)			|
 |						... as well as small, often used tools from my toolbox.																|
 | Notes		:	Applicable to early detection of changes to source data files between current and 		|
 |						past cycles.																																					|
 | Usage		:	See sample macro execution at bottom of code file.																		|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2024 08 22		Initial development. 																															|
 *==================================================================================================*/
 %let wrkhere = Z:\ASTD\2023_24\NV\ETL;
 
options ls = 150;
%macro CompareFileHeaders(thisfile, lastfile, delim, headmaxlen);
	%macro ReadFile(fileref, outDS, hdmxlen, rptrslt);
		data headDS;
			length headline $&headmaxlen. ;
			infile "&fileref." firstobs = 1 lrecl = &hdmxlen. dlm='~';
			input headline $ ;
			if _n_ = 1;
			numflds = countc(headline, ',') + 1;
			call symput('nmflds', numflds);
		run;
		%let nmflds = &nmflds.;
		data &outDS.;
			set headDS;
			do i = 1 to &nmflds;
				indx = i;
				field = scan(headline, i, ',');
				output;
			end;
			keep indx field;
		run;
		%if %eval(&rptrslt. = 1) %then %do;
			%GetSnow;
			Title "Contents of &outDS.  [&now.]";
			proc print data = &outDS.;
			run;
		%end;
	%mend ReadFile;
		%ReadFile(&thisfile., thisDS, &headmaxlen., 0);
		%ReadFile(&lastfile., lastDS, &headmaxlen., 0);
	*** Compare the lists of fields in the two headers *** ;
	%GetSnow;
	proc sql;
		Title1 "Fields in thisfile and not lastfile [&now.]";
		Title2 "   thisfile = &thisfile.";
		Title3 "   lastfile = &lastfile.";
		select * from thisDS where thisDS.field not in (select field from lastDS);
		Title1 "Fields in &lastfile. and not &thisfile. [&now.]";
		select * from lastDS where lastDS.field not in (select field from thisDS);
	quit;
%mend CompareFileHeaders;
	%CompareFileHeaders(&wrkhere.\Summative_2024StateDataFile_NO_PII.csv, 
			Z:\ASTD\2022_23\NV\Summative_2023StateDataFile_NO_PII.csv, ',', 2500);