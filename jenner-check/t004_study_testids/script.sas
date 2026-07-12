/* Adapted from FTData201819/Study_TestIDs.sas (repo). The %StudyTstIDs macro (PROC FREQ over
   AIR-source and ETS-source vendor response tables, cross-tabbing client name against TestId,
   then a one-way frequency of itemSegmentId) is unmodified. The %include "SetSessionEnv.sas" and
   its hardcoded OneDrive libname are replaced with a WORK-library assignment, and
   libhere.ela03_AIRSrc / libhere.ela03_ETSSrc are built inline from small mock rows (no PII --
   synthetic client/test/item identifiers matching the vendor delivery column names used
   throughout this repo's EFT_Merge and FTData201819 import scripts) instead of the real AIR/ETS
   CSV deliveries. */
libname libhere ".";

data libhere.ela03_AIRSrc;
	length transformed_clientname $12 TestId $10;
	input transformed_clientname $ TestId $;
	datalines;
CA-LEA001 ELA03-SUM
CA-LEA001 ELA03-SUM
CA-LEA002 ELA03-SUM
CA-LEA002 ELA03-ICA
NV-LEA010 ELA03-SUM
NV-LEA010 ELA03-SUM
NV-LEA011 ELA03-ICA
OR-LEA020 ELA03-SUM
;
run;

data libhere.ela03_ETSSrc;
	length itemSegmentId $12;
	input itemSegmentId $;
	datalines;
SEG-ELA03-1
SEG-ELA03-1
SEG-ELA03-2
SEG-ELA03-2
SEG-ELA03-2
SEG-ELA03-3
;
run;

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
