/* Adapted from EFT_Merge/2022-23/read_itid_ittyp.sas (repo). That file's own primary logic is
   left commented out by the author ("used by importETSCSV.sas"); this bundle un-comments it,
   since it's the file's documented main purpose (read itemid_itemtype.csv into a permanent
   library, then summarize item counts by type). The hardcoded D:\SBAC\... libname path is
   replaced with a relative WORK-library path, and itemid_itemtype.csv is written inline below
   (no PII -- just item id / item type pairs, matching the two-column shape the INPUT statement
   expects) rather than read from the vendor delivery folder. */
%let wrkhere = .;
libname IACal "&wrkhere.";
%let DSName = IACal.itemid_itemtype_2223;

data _null_;
	file "itemid_itemtype.csv";
	put "10234,MC";
	put "10235,MC";
	put "10236,CR";
	put "10237,MC";
	put "10238,TE";
	put "10239,CR";
	put "10240,MC";
	put "10241,TE";
run;

data &DSName.;
	format itemid 6.0 itemtype $6. ;
	infile "itemid_itemtype.csv"
			LRECL=32767		FIRSTOBS=1			ENCODING="WLATIN1"
			DLM='2c'x		MISSOVER		DSD ;
	input itemid itemtype $;
run;

%GetNow;
Title "Check contents of &DSName. [&now.]";
proc print data=&DSName. (obs=50);
run;

%TotalRec(inDS=&DSName.);
proc sql;
	Title1 "Check contents of &DSName. [&now.] -- total observations in &DSName.: &NumObs.";
	select distinct itemtype, count(*) as frequency
	from &DSName.
	group by itemtype order by itemtype;
quit;
