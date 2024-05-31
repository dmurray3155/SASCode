/*==================================================================================================*
 | Program	:	ASTD_DRC_NV_Assemble_ItemLvl.sas																											|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Write out SAS datasets for later assembly into final deliveries.											|	
 | Macros		: Some from D.M.'s toolbox.sas as well as those developed in this code base.						|
 | Notes		:																																												|
 | Usage		:	Applicable to management of annual student testing data for technical reporting.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2020 04 23		Initial development.																															|
 *==================================================================================================*/

%let wrkHere=E:\SBAC\AnnualStudTest\1819\DRC\NV;
libname libHere "&wrkHere.";
%let dlvrHere=E:\SBAC\AnnualStudTest\1819\DLVRY\DRC\Item;
libname dlvryItm "&dlvrHere.";

options ls=135;

%macro WrapBySbj(Subj);
	data BaseJoin (compress=yes);
		set libHere.smarter_no_pii;
		format state_unique_id_str $14. CAT_id_len CAT_Scr_len CAT_id_len_cmpt 3.0
				orig_score $1. nv_item_id 6.0;
		state_unique_id_str = compress('NV_'||state_unique_id);
		retain state_unique_id_str;
		CAT_Scr_len = length(&Subj._CAT_score_string);
		CAT_id_len = length(&Subj._CAT_item_id_string);
		CAT_id_len_cmpt = CAT_Scr_len * 6;
		if CAT_id_len = CAT_id_len_cmpt then ok = 1;
		else ok = 0;
		if ok = 1 then do;
			do itm = 1 to CAT_Scr_len;
				orig_score = substr(&Subj._CAT_score_string, itm, 1);
				nextItmIDStrt = ((itm - 1) * 6) + 1;
				nv_item_id = put(substr(&Subj._CAT_item_id_string, nextItmIDStrt, 6), 6.0);
				output;
			end;
		end;
		keep state_unique_id_str orig_score nv_item_id grade_level;
	run;
/*	%GetSnow;
	Title "Study of length of strings for &Subj. [&now.]";
	proc freq data=BaseJoin;
		tables ok ok * CAT_Scr_len * CAT_id_len * CAT_id_len_cmpt / list missing ; 
	run;
	proc print data=BaseJoin (obs = 200);
		var state_unique_id_str orig_score nv_item_id;
	run;	*/
	data cat_items_&Subj.;
		set libHere.cat_items;
		format grade 3.0 SBitemId 6.0;
		grade = put(substr(Level, 2), 3.0);
		SBitemId = put(scan(Value, 3, '-'), 6.0);
		if Test = upcase("&Subj.");
	run;
	proc sql;
		create table BaseJoin2 as
		select a.*, b.SBitemId
		from BaseJoin as a, cat_items_&Subj. as b 
		where a.grade_level = b.grade
			and a.nv_item_id = b.itemId;
	quit;
/*	%GetSnow;
	Title "Contents of BaseJoin2 for &Subj. [&now.]";
	proc print data=BaseJoin2 (obs = 200);
	run;	*/
	proc sql;
		create table BaseJoin3 as
		select c.*, d.ItemType
		from BaseJoin2 as c, libHere.meta1819 as d
		where c.SBitemId = d.itemId;
	quit;
/*	%GetSnow;
	Title "Contents of BaseJoin3 for &Subj. [&now.]";
	proc print data=BaseJoin3 (obs=200);
	run;	*/
	data Base4;
		set BaseJoin3;
		format finalScore 3.0;
		if itemType = 'MC' then do;
			if orig_score in ('A', 'B', 'C', 'D') then finalScore = 1;
			else finalScore = 0;
		end;
		else do;
			if orig_score in ('0', '1', '2', '3', '4', '5', '6') then finalScore = orig_score;
			else finalScore = 0;
		end;
	run;
	%let DSname=Base4;
	%GetSnow;
	Title "Contents of &DSname. for &Subj. [&now.]";
	proc print data=&DSname. (obs=250);
	run;
	proc freq data=&DSName.;
		tables itemType * orig_score * finalScore / list missing;
	run;
	%SetDSLabel;
	proc sql;
		create table dlvryItm.DRC_NV_&Subj._item_level (compress=yes label="&DSLabel.") as
		select state_unique_id_str as studentIdentifier, grade_level as grade,
		upcase("&Subj.") as Subject, 'NV' as MemberName, SBitemId as AssessmentItemIdentifier,
		itemType as AssessmentItemType, '' as ItemLifeStg, orig_score as originalScore,
		finalScore as AssessmentItemResponseScoreValue
		from Base4;
	quit;
%mend WrapBySbj;
	%WrapBySbj(ela);				%WrapBySbj(math);