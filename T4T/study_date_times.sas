
%macro ConT4T;
	server="analyticsaurora-cluster.cluster-cimuvo5urx1e.us-west-2.rds.amazonaws.com"
	port=5432 database=t4t user=dmurray
	password="{SAS004}70C77B5C28AB1C0D08B92DB91E465FE4E886F34B598E14AF"
%mend ConT4T;
%macro SetT4T;
	/*	Set LibName to access data from TCD system	*/
	libname t4t postgres %ConT4T;
%mend SetT4T;

%SetT4T;

proc sql;
	create table timediff as
	select aur_id, monthyear, member, login, lastloginpt, lastloginiso8601,
		lastloginiso8601 - lastloginpt as time_diff
	from t4t.app_use_rept
	where monthyear = 'Jan2022';
quit;

%GetSnow;
Title1 "Study of date / time stamp values in t4t.app_use_rept [&now.]";
Title2 "time_diff = lastloginiso8601 - lastloginpt";
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