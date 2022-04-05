/*==================================================================================================*
 | Program :	ReadTDF_TCD.sas																																				|
 | Author	 :	Don Murray (for Smarter Balanced)																											|
 | Purpose :	Create SAS datasets from the specified TDFs.																					|
 | Macros  : 	Some from my toolbox.sas as well as those developed in this code base.								|
 | Notes	 :	This a re-design of the TDF read process to read from the TCD database instead of			|
 |						from CSV files.																																				|
 | Usage	 :	Applicable to fixed-form admin package building.																			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date.....		....description................................................................		|
 |	2019 04 08		Initial development.																															|
 |	2019 12 19		Copied from 2019-20 project folder to 2020-21 project folder.	 Earlier version		|
 |								of this code is ReadTDFs.sas																											|
 |	2022 03 31		Copied from the 2020-21 project folder to here for use in 2022-23.  Earlier				|
 |								version was named ReadTDFCSV.sas.																									|
 *==================================================================================================*/

%let wrkHere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\SBTemp\FFConfig\2022-23;
libname libHere "&wrkHere.";

/*	Mark V. specified these two TDFs as sources for FF Config:
		2022-23_iab_v91 and 2022-23_ica_v89																		*/
		
%macro ConTCD;
	server="analyticsaurora-cluster.cluster-cimuvo5urx1e.us-west-2.rds.amazonaws.com"
	port=5432 database=tcd user=dmurray
	password="{SAS004}70C77B5C28AB1C0D08B92DB91E465FE4E886F34B598E14AF"
%mend ConTCD;
%macro SetTCD;
	/*	Set LibName to access data from TCD system	*/
	libname tcd postgres %ConTCD;
%mend SetTCD;

%macro InvestigateTDF;
	%SetTCD;
	proc sql;
		%GetSnow;
		Title "distinct tdf_key, admin_year for admin_year = 2022-23 [&now.]";
		select distinct tdf_key, admin_year, count(*) as freq
		from tcd.tdf 
		where admin_year = '2022-23'
		group by tdf_key, admin_year order by tdf_key, admin_year;
		Title "contents of apprvd_tdfs [&now.]";
		select * from tcd.apprvd_tdfs;
	quit;
%mend InvestigateTDF;
%*	%InvestigateTDF;

%macro RetrieveTargetTDF(tdf_key, outDS);
	%SetDSLabel;
	%SetTCD;
	proc sql;
		create table &outDS. (compress = yes label = "&DSLabel.") as
		select *
		from tcd.tdf
		where tdf_key = "&tdf_key.";
	quit;
%mend RetrieveTargetTDF;
%*	%RetrieveTargetTDF(2022-23_summative_v15, libHere.tdf_2022_23_summative_v15);
%*	%RetrieveTargetTDF(2022-23_summative_v32, libHere.tdf_2022_23_summative_v32);
%*	%RetrieveTargetTDF(2022-23_ica_v89, libHere.tdf_2022_23_ica_v89);
%*	%RetrieveTargetTDF(2022-23_iab_v91, libHere.tdf_2022_23_iab_v91);
		
%macro FDSubNameGrades(YrRng, TSubType, vrsn);
	options ls=135;
	%GetSnow;
	Title "&YrRng. &TSubType. - v&vrsn. [&now.]";
	proc freq data=libHere.TDF_&YrRng._&TSubType._v&vrsn. ;
		tables Subject * Student_Grade * Short_Title * Full_Title * Seg_Description / list missing nocum nopercent out=&TSubType._FDs;
	run;
	libname XLFDs XLSX "&WrkHere.\Yr&YrRng._&TSubType._v&vrsn._FDs.xlsx";
	data XLFDs.Yr&YrRng._&TSubType._v&vrsn.;
		set &TSubType._FDs;
	run;
%mend FDSubNameGrades;

%*	%FDSubNameGrades(2020_21, FIAB, 10);
%*	%FDSubNameGrades(2020_21, FIAB, 11);
%*	%FDSubNameGrades(2020_21, FIAB, 12);
%*	%FDSubNameGrades(2020_21, ICA, 09);
%*	%FDSubNameGrades(2020_21, IAB, 13);
%*	%FDSubNameGrades(2019_20, summative, 27);
%*	%FDSubNameGrades(2022_23, summative, 15);
%*	%FDSubNameGrades(2022_23, summative, 32);
%*	%FDSubNameGrades(2022_23, ICA, 89);
%*	%FDSubNameGrades(2022_23, IAB, 91);

%macro CheckFields(DSName);
	%TrimCharVars(&DSName., NowtheFD);
	options ls=135;
	%GetSnow;
	Title "Contents of &DSName. [&now.]";
	proc freq data=NowtheFD;
		tables subject * student_grade * tdf_type * asmt * asmt_subtype * role / list missing;
	run;
%mend CheckFields;
%*	%CheckFields(libHere.TDF_2022_23_ICA_v89);
%*	%CheckFields(libHere.TDF_2022_23_IAB_v91);

%macro BldMacCalls(DSName, itype);
	proc freq data = &DSName. ;
		tables role * tdf_version * subject * student_grade * short_title * admin_year /
				list noprint out=ForMacCalls;
	run;
	data &itype.MacCalls;
		set ForMacCalls;
		if role = "&itype.";
	run;
/*	%GetSnow;
	Title "Contents of &DSName. [&now.]";
	proc print data = ForMacCalls;
	run;	*/
	FileName MacCalls "&WrkHere.\MacCalls_&itype..sas";
	data _null_;
		set &itype.MacCalls;
		format outlyn $84.;
		file MacCalls;
		format admin_year2 $9.;
		if admin_year = '2022-23' then admin_year2 = '2022-2023';
		outlyn = '09'x || '%RunFullProc(' || compress(role) || ', ' || compress(tdf_version) || ', 1, ' ||
			compress(subject) || ', ' || compress(student_grade) || ', ' || compress(short_title) || ', ' ||
			compress(admin_year2) || ');' ;
/*	if ((compress(short_title) ne 'PT') and (index(compress(short_title), '-') = 0)) then do;		*/
		if (compress(short_title) ne 'PT') then do;
			if index(compress(short_title), '-') > 0 then do;
				put outlyn;
			end;
		end;
	run;
%mend BldMacCalls;
%*	%BldMacCalls(libHere.TDF_2022_23_ICA_v89, ica);
	%BldMacCalls(libHere.TDF_2022_23_IAB_v91, iab);
%*	%BldMacCalls(libHere.TDF_2022_23_IAB_v91, fiab);
	
/*	%RunFullProc(ICA, 03, 2, ELA, 7, FIXED, 2019-2020);	*/
/*	%RunFullProc(IAB, 13, 1, ELA, 4, LangVocab, 2020-2021);	*/