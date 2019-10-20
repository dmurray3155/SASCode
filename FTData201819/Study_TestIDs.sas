%let workhere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819;
%include "&workhere.\SetSessionEnv.sas";

options ls=135;


%macro StudyTstIDs(CntGrd);
	%GetNow;
	Title "libhere.&CntGrd._AIRSrc [&now.]";
	proc freq data=libhere.&CntGrd._AIRSrc;
		tables transformed_clientname * TestId / list missing;
	run;

	%GetNow;
	Title "libhere.&CntGrd._ETSSrc [&now.]";
	proc freq data=libhere.&CntGrd._ETSSrc;
		tables itemSegmentId / missing;
	run;
%mend StudyTstIDs;
		%StudyTstIDs(ela03);
%*	%StudyTstIDs(ela05);
%*	%StudyTstIDs(math04);
%*	%StudyTstIDs(math05);
%*	%StudyTstIDs(ela07);
%*	%StudyTstIDs(ela06);
%*	%StudyTstIDs(math06);
%*	%StudyTstIDs(math11);
%*	%StudyTstIDs(ela08);
%*	%StudyTstIDs(ela11);

/*
math03_airsrc  has 71,942 cases
math03_airsrc2 has 63,247 cases
LIBHERE.MATH03_L1MERGED_20181127 has 46,507 observations	*/
/*
math07_airsrc  has 177,432 cases
math07_airsrc2 has 168,191 cases
LIBHERE.MATH07_L1MERGED_20181128 has 126,358 observations	*/
/*
math08_airsrc  has 189,724 cases
math08_airsrc2 has 180,570 cases
LIBHERE.MATH08_L1MERGED_20181129 has 126,358 observations	*/
/*
ela03_airsrc  has 131,334 cases
ela03_airsrc2 has 122,712 cases
LIBHERE.ELA03_L1MERGED_20181204 has 91,927 observations	*/

%macro ReptNumCases(DS);
	%TotalRec(inDS=&DS.);
	%put Total Records in dataset &DS.: &NumObs.;
%mend ReptNumCases;

%*	%ReptNumCases(libhere.math08_airsrc);
%*	%ReptNumCases(libhere.math08_airsrc2);
%*	%ReptNumCases(libhere.math08_l1merged_20181129);
%*	%ReptNumCases(libhere.ela03_airsrc);
%*	%ReptNumCases(libhere.ela03_airsrc2);

