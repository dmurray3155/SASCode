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
		file "&workhere.\MacDef\&CntGrd._AIRImport_FmtMacDef.sas";
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
				OutLyne = "%trim(&&field&fld..)"||' $18. ';
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
	%include "&workhere.\MacDef\&CntGrd._AIRImport_FmtMacDef.sas";
	%SetDSLabel;
	data libhere.&CntGrd._AIRSrc (compress=yes label="&DSLabel.");
		infile "&workhere.\AIRCSV\&TargetFyl." firstobs=2 lrecl=24000 dsd missover;
		format TestID $75. TestSubject $5. TestedGrade $2. vndr_test_event_ID 13.0
			tdsopportunityguid $36. COMPONENT_1_OPPKEY $36. COMPONENT_2_OPPKEY $36.
			COMPONENT_1_OPPID 8.0 COMPONENT_2_OPPID 8.0 transformed_clientname $20.
			EconomicDisadvantaged $3. Ethnicity 2.0 gender $6. PrimaryDisability $4.
			ELL $3. overall_thetascore 18.14 ;
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
		/* Here is where EBSR XML content is processed */
		%do fld = 17 %to &LastField.;
			%if %substr(%trim(&&field&fld..), 3, 2) = RV %then %do;
				if substr(&&field&fld.._str, 1, 17) = 'choiceInteraction' then do;
					
					
					%do rsp = 1 %to 6;
						searchStr = trim('<response id="EBSR')||trim("&rsp.")||trim('"><value>');
						SubStart = index(&&field&fld.._str, searchStr);
						if SubStart > 0 then do;
							&&field&fld.._str = substr(&&field&fld.._str, SubStart + 28);
							SubEnd = index(&&field&fld.._str, '</value></response>');
							%if &rsp.=1 %then %do;
								IR&rsp. = substr(&&field&fld.._str, 1, SubEnd - 1);
								&&field&fld.. = IR&rsp.;
							%end;
							%else %do;
								/*	Look for additional responses in EBSR2	*/
								SubMid = index(&&field&fld.._str, '</value><value>');
								if SubMid > 0 then do;
									%do mrsp = 1 %to 6;
										SubMid = index(&&field&fld.._str, '</value><value>');
										SubMEnd = index(&&field&fld.._str, '</value></response>');
										if SubMid > 0 then do;
											%if &mrsp. = 1 %then %do;
												IMR&mrsp. = substr(&&field&fld.._str, 1, SubMid - 1);
												&&field&fld.. = trim(&&field&fld..)||';'||trim(IMR&mrsp.);
											%end;
											%else %do;
												IMR&mrsp. = substr(&&field&fld.._str, 1, SubMid - 1);
												&&field&fld.. = trim(&&field&fld..)||'|'||trim(IMR&mrsp.);
											%end;
										end;
										else if SubMid = 0 and SubMEnd > 0 then do;
											IMR&mrsp. = substr(&&field&fld.._str, 1, 1);
											&&field&fld.. = trim(&&field&fld..)||'|'||trim(IMR&mrsp.);
										end;
										%if &mrsp. < 6 %then %do;
											&&field&fld.._str = substr(&&field&fld.._str, 17);
										%end;
									%end;
								end;
								else do;
									IR&rsp. = substr(&&field&fld.._str, 1, SubEnd - 1);
									&&field&fld.. = trim(&&field&fld..)||';'||trim(IR&rsp.);
								end;
							%end;
						end;
					%end;
					&&field&fld.. = tranwrd(&&field&fld.., 'A', '1');
					&&field&fld.. = tranwrd(&&field&fld.., 'B', '2');
					&&field&fld.. = tranwrd(&&field&fld.., 'C', '3');
					&&field&fld.. = tranwrd(&&field&fld.., 'D', '4');
					&&field&fld.. = tranwrd(&&field&fld.., 'E', '5');
					&&field&fld.. = tranwrd(&&field&fld.., 'F', '6');
				end;
				else if substr(&&field&fld.._str, 1, 20) = '{{{choiceInteraction' then do;
				end;
				
				else do;
					&&field&fld.. = compress(&&field&fld.._str);
				end;
			%end;
		%end;
		/* Now drop the wider RV fields after successfully processing the EBSR responses	*/
		drop
		%do fld = 17 %to &LastField.;
			%if %substr(%trim(&&field&fld..), 3, 2) = RV %then %do;
				&&field&fld.._str
			%end;
		%end;
			searchStr IR1 IR2 IR3 IR4 IR5 IR6 SubStart SubEnd 
			SubMid SubMEnd IMR1 IMR2 IMR3 IMR4 IMR5 IMR6;
	run;
	proc datasets library=libhere;
 	  modify &CntGrd._AIRSrc;
  	    index create transformed_clientname;
    	  index create tdsopportunityguid;
	run;
%mend ImprtAIR;
	%ImprtAIR(math03, Math_3_all_formats.csv);
%*	%ImprtAIR(math07, Math_7_all_formats.csv);
%* 	%ImprtAIR(math08, Math_8_all_formats.csv);
%*	%ImprtAIR(ela03, ELA_3_all_formats.csv);
%*	%ImprtAIR(ela04, ELA_4_all_formats.csv);
%*	%ImprtAIR(ela05, ELA_5_all_formats.csv);
%*	%ImprtAIR(math04, Math_4_all_formats.csv);
%*	%ImprtAIR(math05, Math_5_all_formats.csv);
%*	%ImprtAIR(ela07, ELA_7_all_formats.csv);
%*	%ImprtAIR(ela06, ELA_6_all_formats.csv);
%*	%ImprtAIR(math06, Math_6_all_formats.csv);
%*	%ImprtAIR(math11, Math_HS_all_formats.csv);
%*	%ImprtAIR(ela08, ELA_8_all_formats.csv);
%*	%ImprtAIR(ela11, ELA_HS_all_formats.csv);
