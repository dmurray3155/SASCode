/*==================================================================================================*
 | Program	:	LoadCSV2DB.sas																																				|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	From TDF (or pull list), develop data that will be written to XML for CAT Admin				|
 |						package.																																							|
 | Macros		: ConT4T - sets connection parameters to the t4t database in Aurora (PostAdmin)					|
 |						SetT4T - defines the t4t library using postgres engine and ConT4T connection 					|
 |											parameters.																																	|
 |						ProcessTotalLogins - reads the TotalLogins CSV data and keeps the records that do not	|
 |										already exist in t4t.total_logins.																						|
 |							parameters:																																					|
 |								Load2DB - Set to 1 to load the target records to t4t.total_logins									|
 |									(default is zero)																																|
 |						ReadMonthly - reads the monthly ApplicationUsageReportST.csv files.										|
 |							parameters:																																					|
 |								ST - two letter state reference - see which files must be read.										|
 |								insrt - set to 1 to load the target records to t4t.app_use_rept.									|
 |									(otherwise set to zero)																													|
 |						... as well as small, often used tools from my toolbox.																|
 | Notes		:	Applicable to tools for teachers (T4T) login and user activity summary reporting.			|
 |						Baseline month year was August of 2021.  We receive a TotalNumberofLogins.csv each		|
 |						month. For monthly activities the entire TotalNumberofLogins.csv is read and only 		|
 | 						the records that do not already exist in t4t.total_logins are added.									|
 | Usage		:	1. Set the global macro variable monYear to the correct value for the target month 		|
 |								and year.																																					|
 |						2. Make sure the macro calls for ProcessTotalLogins and ReadMonthly are properly 			|
 |								structured.																																				|
 |						3. (optional) Execute study_date_times.sas in order to validate that the date / time	|
 |								values were processed correctly and consistently.																	|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2021 09 13		Initial development. 																															|
 |	2021 10 01		Loaded Sep2021 data.  Also had to fix the bug in processing data for the date /		|
 |								time field named t4t.lastloginpt.																									|
 |	2021 11 04		Loaded Oct2021 data.																															|
 |	2021 12 07		Loading Nov2021 data.  State membership will only be from TotalNumberLogins.csv		|
 |	2022 01 04		Load Dec2021 data.																																|
 |	2022 03 02		Load Feb2022 data.																																|
 |	2022 04 04		Load Mar2022 data.																																|
 |	2022 05 05		Load Apr2022 data.																																|
 |	2022 06 06		Load May2022 data.																																|
 |	2022 07 01		Load Jun2022 data.																																|
 |	2022 08 02		Load Jul2022 data.																																|
 |	2022 09 06		Load Aug2022 data (VT data no longer included).																		|
 |	2022 10 06		Load Sep2022 data.																																|
 |	2022 11 07		Load Oct2022 data.																																|
 |	2022 12 02		Load Nov2022 data.																																|
 |	2023 01 04		Load Dec2022 data.																																|
 |	2023 02 05		Load Jan2023 data.																																|
 |	2023 03 03		Load Feb2023 data.																																|
 |	2023 04 05		Load Mar2023 data.																																|
 |	2023 05 03		Load Apr2023 data.																																|
 |	2023 06 05		Load May2023 data.																																|
 |	2023 07 06		Load Jun2023 data.																																|
 *==================================================================================================*/

%let sysroot=C:\Users\Donald Murray;
%let wrkHere=&sysroot.\OneDrive - Smarter Balanced UCSC\T4T Summary;
%* %let srcFldr=&sysroot.\Smarter Balanced UCSC\System Design - T4T summary;
%let srcFldr=&sysroot.\OneDrive - Smarter Balanced UCSC\T4T Summary;

%global monYear;
%let monYear = Jun2023;				/* !!!!! <<<<<====----====<<<<< !!!!!	*/
%let monYr_id = 23;						/* !!!!! <<<<<====----====<<<<< !!!!!	*/

%macro ConT4T;
	server="analyticsaurora-cluster.cluster-cimuvo5urx1e.us-west-2.rds.amazonaws.com"
	port=5432 database=t4t user=dmurray
	password="{SAS004}70C77B5C28AB1C0D08B92DB91E465FE4E886F34B598E14AF"
%mend ConT4T;
%macro SetT4T;
	/*	Set LibName to access data from TCD system	*/
	libname t4t postgres %ConT4T;
%mend SetT4T;

%macro Insrt2myo;
	%SetT4T;
	proc sql;
		insert into t4t.monyr_order (my_id, monyear) values
			(&monYr_id., "&monYear.");
	quit;
%mend Insrt2myo;
%*	%Insrt2myo;

%macro ProcessTotalLogins(load2DB=0);
	filename TotalLog "&srcFldr.\&monYear.\TotalNumberofLogins.csv";
	data TotalLogins;
		format email $64. state_fld $32. state $4. ucemail $64.;
		infile TotalLog firstobs=2 dlm=',';
		input email $ state_fld $;
		state = substr(state_fld, 5, 2);
		ucemail = upcase(email);
	run;

	%GetSnow;
	Title "FD of state from TotalLogins [&now.]";
	proc freq data=TotalLogins;
		tables state;
	run;
	%ReptMulti(DSName=TotalLogins, VarName=ucemail);

	proc sql;
		create table TotalLogins2 as
		select distinct ucemail as email, state
		from TotalLogins;
	run;

	data TotalLogins3;
		set TotalLogins2;
		email = lowcase(email);
	run;
	%ReptMulti(DSName=TotalLogins3, VarName=email);

	%SetT4T;
	proc sql;
		create table TotalLogins4 as
		select email, state
		from TotalLogins3
		where email not in (select distinct email from t4t.total_logins);
		select max(tl_id) into :lastindx
		from t4t.total_logins;
	quit;

	data TotalLogins5;
		format indx 6.0;
		set TotalLogins4;
		format monYear $8.;
		indx = &lastindx. + _n_;
		monYear = "&monYear.";
	run;

	/*
	%GetSnow;
	Title "Contents of TotalLogins5 that are new to t4t.total_logins [&now.]";
	proc print data=TotalLogins5;
	run;	*/

	%if %eval(&load2DB. = 1) %then %do;
		%SetT4T;
		proc sql;
			insert into t4t.total_logins 
			select indx, email, state, monYear from TotalLogins5;
		quit;
	%end;

%mend ProcessTotalLogins;
	%ProcessTotalLogins(load2DB=1);

%macro StripLeadingSingleQuote(varName);
	if substr(dequote(&varName.), 1, 1) = "'" then &varName. = substr(dequote(&varName.), 2);
%mend StripLeadingSingleQuote;

/*	Here is where the monthly Application Usage Reports are processed		*/
%macro ReadMonthly(ST, insrt);
	filename inMonFyl "&srcFldr.\&monYear.\ApplicationUsageReport&ST..csv";
	data Mnthly;
		format person $32. Login $64. appUserName $64. NumLogins_Str $6. NumLogins 6.0 LastLogin_str $28. LastLogin DateTime20.
						LastLoginISO8601_str $30. LastLoginISO8601 E8601DT19. monthYear $8. /* member $4. */
						monp 3.0 dayp 3.0 yearp 4.0 hourp 3.0 minp 3.0 secp 3.0 datepart $10. timepart $8.;
		infile inMonFyl firstobs = 2 dlm = ',';
		input person $ Login $ appUserName $ NumLogins_Str $ LastLogin_str $ LastLoginISO8601_str $ ;
		%StripLeadingSingleQuote(person);
		%StripLeadingSingleQuote(Login);
		%StripLeadingSingleQuote(appUserName);
		if substr(dequote(NumLogins_Str), 1, 1) = "'" then NumLogins = put(substr(dequote(NumLogins_Str), 2), 6.0);
		else NumLogins = put(dequote(NumLogins_Str), 6.0);
		%StripLeadingSingleQuote(LastLogin_str);
*		put 'LastLogin_str: ' LastLogin_str;
		%StripLeadingSingleQuote(LastLoginISO8601_str);
*		put 'LastLoginISO8601_str: ' LastLoginISO8601_str;
		datepart = scan(LastLogin_str, 1, ' ');
		timepart = scan(LastLogin_str, 2, ' ');
		monp = put(scan(datepart, 1, '/'), 2.0);
		dayp = put(scan(datepart, 2, '/'), 2.0);
		yearp = put(scan(datepart, 3, '/'), 2.0) + 2000;
		hourp = put(scan(timepart, 1, ':'), 2.0);
		/*	Here is where the pacific time date / time bug was squashed		*/
		if index(LastLogin_str, ' PM ') > 0 then do;
			if hourp < 12 then hourp = hourp + 12;
		end;
		else if index(LastLogin_str, ' AM ') > 0 then do;
			if hourp = 12 then hourp = 0;
		end;
		minp = put(scan(timepart, 2, ':'), 2.0);
		secp = put(scan(timepart, 3, ':'), 2.0);
		LastLogin = dhms(mdy(monp, dayp, yearp), hourp, minp, secp);
		datepart = scan(LastLoginISO8601_str, 1, 'T');
		timepart = scan(scan(LastLoginISO8601_str, 2, 'T'), 1, '.');
		yearp = put(scan(datepart, 1, '-'), 4.0);
		monp = put(scan(datepart, 2, '-'), 2.0);
		dayp = put(scan(datepart, 3, '-'), 2.0);
		hourp = put(scan(timepart, 1, ':'), 2.0);
		minp = put(scan(timepart, 2, ':'), 2.0);
		secp = put(scan(timepart, 3, ':'), 2.0);
		LastLoginISO8601 = dhms(mdy(monp, dayp, yearp), hourp, minp, secp);
		monthYear = "&monYear.";
*		member = "&ST.";	/*	State needs to be retrieved from the TotalNumberofLogins.csv data (2021-12-07)		*/
		drop NumLogins_Str LastLoginISO8601_str LastLogin_str 
					monp dayp yearp hourp minp secp datepart timepart;
	run;
	%SetT4T;
	proc sql;
		create table monthly as
		select a.*, b.state as member
		from Mnthly as a, t4t.total_logins as b
		where upcase(a.Login) = upcase(b.email) ;
	quit;
	%if %eval("&ST." = "ZZ") %then %do;
		%let lastindx = 0;
	%end;
	%else %do;
		%SetT4T;
		proc sql;
			Title "Retrieve max aur_id value from t4t.app_use_rept.";
			select max(aur_id) into :lastindx
			from t4t.app_use_rept;
		quit;
	%end;
	data Monthly2;
		format indx 6.0;
		set monthly;
		indx = _n_ + &lastindx.;
	run;

	%GetSnow;
	Title "Quick look at Monthly data for &ST. [&now.]";
	proc print data=Monthly2 (obs=9);
	run;

	%if %eval(&insrt. = 1) %then %do;
		%SetT4T;
		proc sql;
			insert into t4t.app_use_rept
			select indx, person, Login, appUserName, NumLogins, LastLogin,
						LastLoginISO8601, monthYear, member
			from Monthly2;
		quit;
	%end;

%mend ReadMonthly;
	%ReadMonthly(CA, 1);		%ReadMonthly(CT, 1);
	%ReadMonthly(DE, 1);		%ReadMonthly(HI, 1);
	%ReadMonthly(ID, 1);		%ReadMonthly(IN, 1);
	%ReadMonthly(MI, 1);		%ReadMonthly(MT, 1);
	%ReadMonthly(NV, 1);		%ReadMonthly(OR, 1);
	%ReadMonthly(SD, 1);		%ReadMonthly(VI, 1);
	%ReadMonthly(WA, 1);
	
/*	%ReadMonthly(VT, 0);		*/