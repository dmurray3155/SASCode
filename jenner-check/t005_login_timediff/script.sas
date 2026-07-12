/* Adapted from T4T/study_date_times.sas (repo). The %SetT4T / %ConT4T connection macros (which
   embed a live database password) are dropped entirely -- t4t.app_use_rept is instead built
   inline below from small mock login-timestamp rows (no PII, synthetic user ids) with the same
   two datetime columns (lastloginpt, lastloginiso8601) the script studies. The PROC SQL time_diff
   computation, PROC FREQ, and the PROC CORR + ODS GRAPHICS scatter block are unmodified -- this is
   the file's own diagnostic for the Pacific-time-vs-ISO8601 timestamp drift bug documented in
   T4T/LoadCSV2DB.sas's amendment history ("had to fix the bug in processing data for the date /
   time field named t4t.lastloginpt"). Consecutive Title1/Title2 collapsed into one Title for
   engine compatibility. */

data t4t_app_use_rept;
	length monthyear $7 member $4 login $20;
	format lastloginpt lastloginiso8601 datetime20.;
	input aur_id monthyear $ member $ login $ lastloginpt_str $ lastloginiso8601_str $;
	lastloginpt = input(lastloginpt_str, datetime20.);
	lastloginiso8601 = input(lastloginiso8601_str, datetime20.);
	drop lastloginpt_str lastloginiso8601_str;
	datalines;
1 Jun2023 CA user01 05JUN23:14:02:00 05JUN23:21:02:00
2 Jun2023 CA user02 06JUN23:09:15:00 06JUN23:16:15:00
3 Jun2023 NV user03 07JUN23:11:30:00 07JUN23:18:30:00
4 Jun2023 OR user04 10JUN23:08:00:00 10JUN23:15:00:00
5 May2023 CA user05 20MAY23:10:00:00 20MAY23:17:00:00
;
run;

proc sql;
	create table timediff as
	select aur_id, monthyear, member, login, lastloginpt, lastloginiso8601,
		lastloginiso8601 - lastloginpt as time_diff
	from t4t_app_use_rept
	where monthyear = 'Jun2023';
quit;

%GetSnow;
Title1 "Study of date / time stamp values in t4t_app_use_rept [&now.] -- time_diff = lastloginiso8601 - lastloginpt";
proc freq data=timediff;
	tables time_diff;
	run;
footnote "The time_diff value changes at transition to / from daylight saving time";

ods graphics on;
proc corr data=timediff
          plots(maxpoints = 6600) = scatter ;
   var lastloginpt lastloginiso8601;
	 format lastloginpt datetime20.;
 run;
ods graphics off;
