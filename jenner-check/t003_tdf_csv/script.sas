/* Adapted from FFConfigSheets202021/ReadTDFCSV.sas (repo). %VarFmtLst and %ReadTDFCSV (the
   informat/input definitions matching the Test Definition File layout used to build fixed-form
   admin config sheets) are unmodified -- see autoexec.sas. This script writes a small, non-PII
   mock TDF CSV inline (5 item rows across ELA/MATH, grades 3 and 5, with real TDF field names:
   AssessmentType, Subject, StudentGrade, Claim, Target, DOK, WorkflowStatus, etc.) instead of
   reading from the author's SharePoint-synced Prebuild_TDF folder, then calls %ReadTDFCSV exactly
   as the file's own commented-out usage does, followed by a %StudyTDF-style PROC SQL/PROC PRINT
   summary (adapted from the file's own %StudyTDF macro further down) subsetting on Subject and
   StudentGrade the way the original does. */

data _null_;
	file "tdf_sample.csv";
	put "AssessmentType,AssessmentSubType,Subject,StudentGrade,FullTitle,ShortTitle,Sequence,SegmentPosition,SegmentDescription,ItemPosition,Role,ItemId,item_version,ItemGrade,StimId,Key,ItemType,ScoringEngine,PerformanceTask,AllowCalculator,Claim,Target,DetailedELAClaim2Target,DOK,Domain,WorkflowStatus";
	put "ICA,ELA,ELA,3,Grade 3 ELA Interim Comprehensive,ICA-ELA-03,1,1,Reading,1,Item,20145,1,3,,B,MC,PearsonAccessNext,,No,2,1,,2,Reading Informational,Item Approved for Operational Use";
	put "ICA,ELA,ELA,3,Grade 3 ELA Interim Comprehensive,ICA-ELA-03,2,1,Reading,2,Item,20146,1,3,,D,MC,PearsonAccessNext,,No,2,2,,3,Reading Literary,Item Approved for Operational Use";
	put "ICA,MATH,MATH,5,Grade 5 Math Interim Comprehensive,ICA-MATH-05,1,1,Number,1,Item,30871,2,5,,A,MC,PearsonAccessNext,,Yes,1,1,,2,Number and Operations,Item Approved for Operational Use";
	put "IAB,MATH,MATH,5,Grade 5 Math Interim Assessment Block,IAB-MATH-05-FR,1,1,Fractions,1,Item,30902,1,5,,C,MC,PearsonAccessNext,,Yes,3,1,,3,Fractions,Item Approved for Operational Use";
	put "IAB,MATH,MATH,5,Grade 5 Math Interim Assessment Block,IAB-MATH-05-FR,2,1,Fractions,2,Item,30903,1,5,,,CR,PearsonAccessNext,,Yes,3,2,,4,Fractions,Item In Development";
run;

libname libHere ".";
%ReadTDFCSV(tdf_sample.csv, libHere.TDF_sample);

%GetNow;
Title "Contents of libHere.TDF_sample [&now.]";
proc print data=libHere.TDF_sample (obs=50);
	var AssessmentType Subject StudentGrade ShortTitle ItemId ItemType Claim Target DOK WorkflowStatus;
run;

proc sql;
	Title "Grade 5 Math items where Subject=MATH and StudentGrade=5, ordered by ShortTitle, Sequence";
	select ShortTitle, Sequence, ItemId, ItemType, Claim, DOK, WorkflowStatus
	from libHere.TDF_sample
	where Subject="MATH" and StudentGrade=5
	order by ShortTitle, Sequence;
quit;
