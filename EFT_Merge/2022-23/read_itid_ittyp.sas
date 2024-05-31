/*==================================================================================================*
 | Program	:	read_itid_ittyp.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Read CSV file named itemid_itemtype.csv to a permanent SAS dataset for use by 				|
 |						importETSCSV.sas.																																			|
 | Macros		: 																																											|
 | Notes		:																																												|
 | Usage		:	Applicable to Measurement Inc IA And calibration data preparation work.								|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2024 02 25		Initial logic development.																												|
 *==================================================================================================*/

%let wrkhere = D:\SBAC\2022_23\IA_Calib;
libname IACal "&wrkhere.";
%let DSName = IACal.itemid_itemtype_2223;

/*
%SetDSLabel;
data &DSName. (label = "&DSLabel.");
	format itemid 6.0 itemtype $6. ;
	infile "&wrkhere.\ETSCSV\itemid_itemtype.csv"
			LRECL=32767		FIRSTOBS=2			ENCODING="WLATIN1"
			DLM='2c'x		MISSOVER		DSD ;
	input itemid itemtype $;
run;

%GetNow;
Title "Check contents of &DSName. [&now.]";
proc print data=&DSName. (obs=50);
run;

%TotalRec(inDS=&DSName.);
proc sql;
	Title1 "Check contents of &DSName. [&now.]";
	Title2 "Total observations in &DSName.: &NumObs.";
	select distinct itemtype, count(*) as frequency
	from &DSName.
	group by itemtype order by itemtype;
quit;
*/

%macro build_itemid_itemtype_logic;
	options nomprint nomlogic nosymbolgen;
	%TotalRec(inDS=IACal.itemid_itemtype_2223);
	%TransMac(DSName=IACal.itemid_itemtype_2223, VarName=itemid, Prefx=itid);
	%TransMac(DSName=IACal.itemid_itemtype_2223, VarName=itemtype, Prefx=ittyp);
	data _null_;
		file "&wrkhere.\itidittyp_logic.sas";
		format outlyn $84.;
		outlyn = '%macro itidittyp_logic;';
		put outlyn;
		%do rn = 1 %to &NumObs.;
			%if %eval(&rn. = 1) %then %do;
				outlyn = '09'x || "if itemkey = &&&itid&rn.. then itemtype = ""&&&ittyp&rn.."" ;";
			%end;
			%else %do;
				outlyn = '09'x || "else if itemkey = &&&itid&rn.. then itemtype = ""&&&ittyp&rn.."" ;";
			%end;
			put outlyn;
		%end;
		outlyn = '%mend itidittyp_logic;';
		put outlyn;
	run;
%mend build_itemid_itemtype_logic;
	%build_itemid_itemtype_logic;