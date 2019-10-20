/*==================================================================================================*
 | Program	:	importAIRCSV.sas																																			|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Build CSV import job for AIR source data CSV files.																		|
 | Macros		: 																																											|
 | Notes		:	The necessity of this code is because the import job references field names						|
 |					 	(including itemID references).  Those field names are different for each subject-			|
 |						grade.																																								|
 |				2019-10-01: The format of responses is different this year (2018-19) than it was last			|
 |						year (2017-18).																																				|
 | Usage		:	Applicable to Measurement Inc IA And calibration data preparation work.  This code		|
 |						should be run while pointed to one of 14 subject-grade CSV files provided by AIR.			|
 |						The result is a compressed SAS dataset that contains all fields presented by the 			|
 |						CSV.  The field names particular to each CSV are managed within a separate macro			|
 |						that is built, included, and executed in this job.   This work began under Smarter 		|
 |						Balanced for the first time in fall of 2018.																					|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2018 11 21		Initial development. This deliberate engineering is because I found that the SAS	|
 |								Enterprise Guide importer produced results with inconsistent formats.							|
 |	2018 12	01		Added logic to process EBSR response content from XML to #;# format (Saturday).		|
 |	2018 12 07		Amended EBSR logic to parse sub-responses within one EBSR construct.							|
 |	2019 10 01		Copied from 2017-18 project location (D:\SBAC\17-18\Calib) to 2018-19 project			|
 |								location (C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819)	|
 |								and modified for current application for 2018-19.																	|
 *==================================================================================================*/
%let workhere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819;
%include "&workhere.\SetSessionEnv.sas";
options nosymbolgen nomprint nomlogic;

%macro ImprtAIR(CntGrd, TargetFyl);
	options nosymbolgen nomprint nomlogic;
	/*	Begin with an import and analysis of header row of the target CSV	*/
	data HeaderRowDS;
		format headerRow $32765. numFields 4.0;			/* <<<===<<< This is not going to work */
		infile "&workhere.\AIRCSV\&TargetFyl." firstobs=1 obs=1 lrecl=45000 dlm='~';
		input headerRow $;
		numFields = count(headerRow, ',') + 1;
		call symput('LastField', numFields);
	run;
	/*	This data step assigns all of the field values to the field#### macro variables	*/
	data _null_;
		set HeaderRowDS;
		%do fld = 17 %to &LastField.;
			variable = compress(scan(headerRow, &fld., ","));
			call symput("field&fld.", variable);
		%end;
	run;
	/*	This data step builds the item level field format macro block	*/
	data _null_;
		format OutLyne $64.;
		file "&workhere.\AIRMacDef\&CntGrd._AIRImport_FmtMacDef.sas";
		%do fld = 17 %to &LastField.;
			%if &fld. = 17 %then %do;
				OutLyne = '%macro '||"&CntGrd."||'_Fmt;';
				put OutLyne;
				OutLyne = 'format ';
				put @3 OutLyne;
			%end;
			%if %substr(%trim(&&field&fld..), 3, 2) = RV %then %do;
				OutLyne = "%trim(&&field&fld..)"||'_str $512. ';
				put @3 OutLyne;
				OutLyne = "%trim(&&field&fld..)"||' $24. ';
				put @3 OutLyne;
			%end;
			%else %do;
				OutLyne = "%trim(&&field&fld..)"||' $3. ';
				put @3 OutLyne;
			%end;
			%if &fld. = &LastField. %then %do;
				OutLyne = ';';
				put @3 OutLyne;
				OutLyne = '%mend '||"&CntGrd."||'_Fmt;';
				put OutLyne;
			%end;
		%end;
	run;
	/*	This trims the field references	*/
	options nomprint nomlogic nosymbolgen;
	%do fld = 17 %to &LastField.;
		%let field&fld. = &&field&fld.. ;
	%end;
	options mprint mlogic symbolgen;
	%include "&workhere.\AIRMacDef\&CntGrd._AIRImport_FmtMacDef.sas";
	%SetDSLabel;
	data libhere.&CntGrd._AIRSrc (compress=yes label="&DSLabel.");
		infile "&workhere.\AIRCSV\&TargetFyl." firstobs=2 lrecl=24000 dsd missover;
		format TestID $75. TestSubject $5. TestedGrade $2. vndr_test_event_ID 13.0
			tdsopportunityguid $36. COMPONENT_1_OPPKEY $36. COMPONENT_2_OPPKEY $36.
			COMPONENT_1_OPPID 8.0 COMPONENT_2_OPPID 8.0 transformed_clientname $20.
			EconomicDisadvantaged $3. Ethnicity 2.0 gender $6. PrimaryDisability $4.
			ELL $3. overall_thetascore 18.14 EBSR_Part1 $312. EBSR_Part2 $312.;
		%&CntGrd._Fmt;
		input TestID $ TestSubject $ TestedGrade $  vndr_test_event_ID
			tdsopportunityguid $ COMPONENT_1_OPPKEY $ COMPONENT_2_OPPKEY $
			COMPONENT_1_OPPID COMPONENT_2_OPPID transformed_clientname $
			EconomicDisadvantaged $ Ethnicity gender $ PrimaryDisability $
			ELL $ overall_thetascore 
			%do fld = 17 %to &LastField.;
				%if %substr(%trim(&&field&fld..), 3, 2) = RV %then %do;
					%trim(&&field&fld.._str) $ 
				%end;
				%else %do;
					%trim(&&field&fld..) $ 
				%end;
			%end;
			;
		/* Here is where item response content is processed */
		%do fld = 17 %to &LastField.;
			%if %substr(%trim(&&field&fld..), 3, 2) = RV %then %do;
				if substr(&&field&fld.._str, 1, 17) = 'choiceInteraction' then do;
					fieldLen = length(&&field&fld.._str);
					select(fieldLen);
						when(28) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1));
						when(57) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1));
						when(86) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1)||'|'||
											substr(&&field&fld.._str, 86, 1));
						when(115) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1)||'|'||
											substr(&&field&fld.._str, 86, 1)||'|'||substr(&&field&fld.._str, 115, 1));
						when(144) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1)||'|'||
											substr(&&field&fld.._str, 86, 1)||'|'||substr(&&field&fld.._str, 115, 1)||'|'||substr(&&field&fld.._str, 144, 1));
						when(173) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1)||'|'||
											substr(&&field&fld.._str, 86, 1)||'|'||substr(&&field&fld.._str, 115, 1)||'|'||substr(&&field&fld.._str, 144, 1)||'|'||
											substr(&&field&fld.._str, 173, 1));
						when(202) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1)||'|'||
											substr(&&field&fld.._str, 86, 1)||'|'||substr(&&field&fld.._str, 115, 1)||'|'||substr(&&field&fld.._str, 144, 1)||'|'||
											substr(&&field&fld.._str, 173, 1)||'|'||substr(&&field&fld.._str, 202, 1));
						when(231) &&field&fld.. = compress(substr(&&field&fld.._str, 28, 1)||'|'||substr(&&field&fld.._str, 57, 1)||'|'||
											substr(&&field&fld.._str, 86, 1)||'|'||substr(&&field&fld.._str, 115, 1)||'|'||substr(&&field&fld.._str, 144, 1)||'|'||
											substr(&&field&fld.._str, 173, 1)||'|'||substr(&&field&fld.._str, 202, 1)||'|'||substr(&&field&fld.._str, 202, 1));
						otherwise do;
							&&field&fld.. = "PROB";
							put "Problem with field length for: &&field&fld.._str" ;
						end;
					end; /* select */
				end;
				else if substr(&&field&fld.._str, 1, 20) = '{{{choiceInteraction' then do;	/*	These are the EBSR item responses	*/
					/*	Split the two parts apart	*/
					EBSR_Split_Loc = index(&&field&fld.._str, '}}}{{{') + 3;
					EBSR_Part1_str=substr(&&field&fld.._str, 1, EBSR_Split_Loc - 1);
					EBSR_Part2_str=substr(&&field&fld.._str, EBSR_Split_Loc);
					%do prt = 1 %to 2;
						fieldLen = length(EBSR_Part&prt._str);
						select(fieldLen);
							when(64) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 61, 1));
							when(93) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 61, 1)||'|'||substr(EBSR_Part&prt._str, 90, 1));
							when(122) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 61, 1)||'|'||substr(EBSR_Part&prt._str, 90, 1)||'|'||substr(EBSR_Part&prt._str, 119, 1));
							when(151) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 61, 1)||'|'||substr(EBSR_Part&prt._str, 90, 1)||'|'||substr(EBSR_Part&prt._str, 119, 1)||'|'||
												substr(EBSR_Part&prt._str, 148, 1));
							when(180) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 61, 1)||'|'||substr(EBSR_Part&prt._str, 90, 1)||'|'||substr(EBSR_Part&prt._str, 119, 1)||'|'||
												substr(EBSR_Part&prt._str, 148, 1)||'|'||substr(EBSR_Part&prt._str, 177, 1));
							when(209) EBSR_Part&prt. = compress(substr(EBSR_Part&prt._str, 61, 1)||'|'||substr(EBSR_Part&prt._str, 90, 1)||'|'||substr(EBSR_Part&prt._str, 119, 1)||'|'||
												substr(EBSR_Part&prt._str, 148, 1)||'|'||substr(EBSR_Part&prt._str, 177, 1)||'|'||substr(EBSR_Part&prt._str, 206, 1));
							otherwise do;
								EBSR_Part&prt. = "PROB.E&prt.";
								put "Problem with field length for: &&field&fld.._str" ;
							end;
						end;	/*	select	*/
					%end;
					&&field&fld.. = compress(EBSR_Part1||';'||EBSR_Part2);
				end;
				else do;
					&&field&fld.. = compress(&&field&fld.._str);
				end;
				&&field&fld.. = tranwrd(&&field&fld.., 'A', '1');
				&&field&fld.. = tranwrd(&&field&fld.., 'B', '2');
				&&field&fld.. = tranwrd(&&field&fld.., 'C', '3');
				&&field&fld.. = tranwrd(&&field&fld.., 'D', '4');
				&&field&fld.. = tranwrd(&&field&fld.., 'E', '5');
				&&field&fld.. = tranwrd(&&field&fld.., 'F', '6');
				&&field&fld.. = tranwrd(&&field&fld.., 'G', '7');
				&&field&fld.. = tranwrd(&&field&fld.., 'H', '8');
			%end;
		%end;
		/* Now drop the wider RV fields after successfully processing the EBSR responses	*/
		drop
		%do fld = 17 %to &LastField.;
			%if %substr(%trim(&&field&fld..), 3, 2) = RV %then %do;
				&&field&fld.._str
			%end;
		%end;
		fieldLen EBSR_Split_Loc EBSR_Part1 EBSR_Part2 EBSR_Part1_str EBSR_Part2_str;
	run;
	proc datasets library=libhere;
 	  modify &CntGrd._AIRSrc;
  	    index create transformed_clientname;
    	  index create tdsopportunityguid;
	run;
%mend ImprtAIR;
%*	%ImprtAIR(ela03, ELA_3_all_formats.csv);
%*	%ImprtAIR(ela04, ELA_4_all_formats.csv);
%*	%ImprtAIR(math03, Math_3_all_formats.csv);
%*	%ImprtAIR(ela05, ELA_5_all_formats.csv);
%*	%ImprtAIR(ela06, ELA_6_all_formats.csv);
%*	%ImprtAIR(ela07, ELA_7_all_formats.csv);
%*	%ImprtAIR(ela08, ELA_8_all_formats.csv);
%*	%ImprtAIR(ela11, ELA_HS_all_formats.csv);
%*	%ImprtAIR(math04, Math_4_all_formats.csv);
%*	%ImprtAIR(math05, Math_5_all_formats.csv);
%*	%ImprtAIR(math06, Math_6_all_formats.csv);
%*	%ImprtAIR(math07, Math_7_all_formats.csv);
%* 	%ImprtAIR(math08, Math_8_all_formats.csv);
%*	%ImprtAIR(math11, Math_HS_all_formats.csv);
