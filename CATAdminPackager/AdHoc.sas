%ClrBoth;
libname libhere 'C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\CATAdminPackage';
/*	%GetSnow;
Title "Check it [&now.]";
proc print data=libhere.tdf_2019_20_summative_v27;
	where itemId=14591;
run;	*/

libname imrt 'C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IMRT';
/*	proc sql;
	select count(*) from imrt.imrt_etypes_keys_20200824;
	select distinct itemType, count(*) as freq
	from imrt.imrt_etypes_keys_20200824
	where compress(subject)='ELA' and grade=6
	  and index(answerKey, 'A') > 0
	group by itemType;
quit;	*/

%GetSnow;
Title "FD of ScoringEngine [&now.]";
proc freq data=libhere.tdf_2019_20_summative_v27;
	tables ScoringEngine / missing;
run;

proc sql;
	select * from libhere.tdf_2019_20_summative_v27
	where compress(subject) = 'MATH' and StudentGrade in (4, 8)
		and ScoringEngine = 'HandScored'
		and index(FullTitle, 'CAT') > 0;
quit;
