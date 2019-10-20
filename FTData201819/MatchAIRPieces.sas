/*==================================================================================================*
 | Program	:	MatchAIRPieces.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Join two student test segments (CAT and Perf) into one student test record.						|
 | Macros		: 																																											|
 | Notes		:	The two-stage merge described by Measurement Inc. results in one record per student		|
 |						per test segment (CAT vs. Perf). This job joins those two test segment ID pieces so		|
 |						the result is one record per student test.																						|
 | Usage		:	Applicable to Measurement Inc IA And calibration data preparation work.  This code		|
 |						is executed after importAIRCSV.sas is successfully executed.													|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2018 11 24		Initial development. An earlier version was created but run against deprecated		|
 |								results (&CntGrd._calib).																													|
 |	2019 10 18		Copied from the 1718 project location and edited for use here in 1819.						|
 *==================================================================================================*/
%let workhere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819;
%include "&workhere.\SetSessionEnv.sas";

/*	Begin by separating variables across PT and CAT items and plan a common merge key	*/
/*	Derive list of all PT Item IDs and whether they are OP / FT	*/
%macro MatchAIRPcs(CntGrd, PrntYN, Subj, Grd);
	proc sql;
		create table fastwrk.PTItemIDs_tdl1 as
		select distinct ItemOper, ItemFormat, ItemId
		from libhere.&CntGrd._ETSSrc
		where catBool = 0 and oppKey in
			(select tdsopportunityguid from libhere.&CntGrd._tdsopplist1);
		create table fastwrk.PTItemIDs_tdl2 as
		select distinct ItemOper, ItemFormat, ItemId
		from libhere.&CntGrd._ETSSrc as ets, libhere.d2018_sbac_ft_crosswalk as xwlk
		where catBool = 0 
			and ets.componval2num = xwlk.Orig_OppID and xwlk.opportunitykey in 
				(select tdsopportunityguid from libhere.&CntGrd._tdsopplist2);
	quit;	
	data PTItemIDs;
		set fastwrk.PTITemIDs_tdl1 fastwrk.PTITemIDs_tdl2;
	run;
	proc freq data=PTITemIDs;
		tables ItemOper * ItemFormat * ItemId / list missing
			noprint out=PTItemIDs_Dstl nopercent;
	run;
	data ETS_ItemFields;
		set PTItemIDs_Dstl;
		format ItemIDOnly $6. AIRItemField $18.;
		ItemIDOnly = scan(compress(ItemId, "'"), 2, '-');
		if ItemOper = 1 then ItLblStm = 'O_';
		else if ItemOper = 0 then ItLblStm = 'F_';
		else ItLblStm = 'Z_';
		if itemFormat='WER' then do;
			AIRItemField = compress(ItLblStm||ItemIDOnly||'_A');		output;
			AIRItemField = compress(ItLblStm||ItemIDOnly||'_B');		output;
			AIRItemField = compress(ItLblStm||ItemIDOnly||'_C');		output;
			AIRItemField = compress(ItLblStm||ItemIDOnly||'_D');		output;
		end;
		else do;
			AIRItemField = ItLblStm || ItemIDOnly;		output;
		end;
		ItemFormat = compress(ItemFormat, "'");
		if ItemFormat in ('MC', 'MS', 'EBSR') then do;
			AIRItemField = ItLblStm || 'RV_' || ItemIDOnly;
			output;
		end;
		keep ItemOper ItemFormat ItemId AIRItemField;
	run;
	%if &PrntYN = 1 %then %do;
		%GetNow;
		Title "PTITemIDs qual both 1 and 2 [&now.]";
		proc print data=ETS_ItemFields;
		run;
	%end;
	/*	Now qualify these against items referenced in the AIR item vector	*/
	proc contents data=libhere.&CntGrd._AIRSrc noprint out=AIRVars;
	run;
	proc sql;
		create table AIRIVars as
		select varnum, name
		from AIRVars 
		where ((name like 'F_%') or
				(name like 'O_%') or
				(name = 'tdsopportunityguid'))
		order by varnum;
	quit;
	%if &PrntYN = 1 %then %do;
		%GetNow;
		Title "AIR Field names [&now.]";
		proc print data=AIRIVars;
			var varnum name;
		run;
	%end;
	proc sql;
		create table PTFieldList as
		select AIRItemField
		from ETS_ItemFields
		where AIRItemField in (select name from AIRIVars);
	quit;
	%if &PrntYN = 1 %then %do;
		%GetNow;
		Title1 "These items are PT ones in the AIR item vector";
		Title2 "	[&now.]";
		proc print data=PTFieldList;
		run;
	%end;
	data _null_;
		format Outlyn $32.;
		set PTFieldList end = lastone;
		file "&CntGrd._PTFieldsMac.sas";
		if _n_ = 1 then do;
			Outlyn = '%macro '||"&CntGrd."||'_PTFM;';
			put Outlyn;
		end;
		Outlyn = AIRItemField;
		put @3 OutLyn;
		if lastone then do;
			Outlyn = '%mend '||"&CntGrd."||'_PTFM;';
			put Outlyn;
		end;
	run;
	%include "&workhere.\&CntGrd._PTFieldsMac.sas";
	/*	Build the two pieces of AIR data (ADAPTIVE and Perf) along with an appropriate
			ETS key that will be joined to form a complete test per kid	*/
	proc sql;
		create table fastwrk.CAAIRPerf (compress=yes) as
		select distinct air.*, ets.studentid
		from libhere.&CntGrd._AIRSrc as air, libhere.&CntGrd._ETSSrc as ets,
					libhere.d2018_sbac_ft_crosswalk as xwlk
		where air.TestId = "SBAC-Perf-EFT-&Subj.-&Grd." and air.tdsopportunityguid = xwlk.opportunitykey
			and	xwlk.Orig_OppID = ets.componval2Num and ets.catBool = 0;
	quit;
	data fastwrk.CAAIRPerf2 (compress=yes);
		set fastwrk.CAAIRPerf;
	/*	studentid = compress(studentid, "'");	*/
		keep studentid %&CntGrd._PTFM;
	run;
	proc sql;
		create table fastwrk.CAAIRCAT (compress=yes) as
		select distinct air.*, ets.studentid
		from libhere.&CntGrd._AIRSrc as air, libhere.&CntGrd._ETSSrc as ets
		where air.TestId = "SBAC-OP-ADAPTIVE-BP-EFT-&Subj.-&Grd."
			and	air.tdsopportunityguid = ets.oppKey and ets.catBool = 1;
	quit;
	data fastwrk.CAAIRCAT2 (compress=yes);
		set fastwrk.CAAIRCAT;
		studentid = compress(studentid, "'");
		drop %&CntGrd._PTFM; 
	run;
	proc sql;
		create table fastwrk.&CntGrd._AIRSrc2m (compress=yes) as
		select cat.*, perf.*
		from fastwrk.CAAIRCAT2 as cat, fastwrk.CAAIRPerf2 as perf
		where cat.studentid = perf.studentid;
	quit;	
	proc sql;
		create table fastwrk.&CntGrd._AIRCANonMatch (compress=yes) as
		select * from libhere.&CntGrd._AIRSrc
		where TestId = "SBAC-GEN-SUM-UD-&Subj.-CAT-&Grd." 	/*	Math-03, ela-03, ela-04, ela-05, math-04, math-05, ela-07, ela-06, ela-08, ela-11	*/
/*	where TestId = "SBAC-GEN-SUM-UD-&Subj.-CAT-&Grd."		*/					/*	Math-07	and Math-08 and math-06 and math-11 */
			and transformed_clientname = 'California';
		create table fastwrk.&CntGrd._AIRNonCA (compress=yes) as
		select * from libhere.&CntGrd._AIRSrc
		where transformed_clientname not = 'California';
	quit;
	%SetDSLabel;
	data libhere.&CntGrd._AIRSrc2 (compress=yes reuse=yes label="&DSLabel.");
		set libhere.&CntGrd._AIRSrc (obs=0) 
				fastwrk.&CntGrd._AIRCANonMatch
				fastwrk.&CntGrd._AIRSrc2m (drop=studentid)
				fastwrk.&CntGrd._AIRNonCA;
	run;	
	proc datasets library=libhere;
  	modify &CntGrd._AIRSrc2;
    index create transformed_clientname;
    index create tdsopportunityguid;
  run;
%mend MatchAIRPcs;
	%MatchAIRPcs(ela03, 0, ELA, 3);
%*	%MatchAIRPcs(math03, 0, MATH, 3);
%*	%MatchAIRPcs(math07, 0, MATH, 7);
%*	%MatchAIRPcs(math08, 0, MATH, 8);
%*	%MatchAIRPcs(ela04, 0, ELA, 4);
%*	%MatchAIRPcs(ela05, 0, ELA, 5);
%*	%MatchAIRPcs(math04, 0, MATH, 4);
%*	%MatchAIRPcs(math05, 0, MATH, 5);
%*	%MatchAIRPcs(ela07, 0, ELA, 7);
%*	%MatchAIRPcs(ela06, 0, ELA, 6);
%*	%MatchAIRPcs(math06, 0, MATH, 6);
%*	%MatchAIRPcs(math11, 0, MATH, 11);
%*	%MatchAIRPcs(ela08, 0, ELA, 8);
%*	%MatchAIRPcs(ela11, 0, ELA, 11);
