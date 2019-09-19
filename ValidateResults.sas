%let wrkHere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IMRT\CheckWFS;
libname libHere "&wrkHere.";

libname XLPL XLSX "&wrkHere.\18-19 Pull List item status Tracker.xlsx";

/*
data libHere.SumELAItems;
	set XLPL.'Sum ELA items'n;
run;

data libHere.SumMathItems;
	set XLPL.'Math Sum items'n;
run;	*/

%macro ReadTheXL;
	%SetDSLabel;
	libname XLPL XLSX "&wrkHere.\18-19 Pull List item status Tracker.xlsx";
	data libHere.SumELAItems (compress=yes label="&DSLabel.");
		set XLPL.'Sum ELA items'n;
	run;
	data libHere.SumMathItems (compress=yes label="&DSLabel.");
		set XLPL.'Math Sum items'n;
	run;
%mend ReadTheXL;
%*	%ReadTheXL;

%macro MergeWFS2XL(Subj);
	%SetDSLabel;
	%SetIMRTPrd;
	proc sql;
		create table libHere.Sum&Subj._w_WFS (compress=yes label="&DSLabel.") as
		select xl.*, imrt.workflow_status
		from libHere.Sum&Subj.Items as xl, imrtprd.item as imrt
		where xl.id = imrt.id and imrt.classification = 'item';
	quit;
%mend MergeWFS2XL;
%*	%MergeWFS2XL(ELA);
%*	%MergeWFS2XL(Math);

%macro studyFlags(Subj);
	%GetNow;
	Title "Check WFS for &Subj in 18-19 Summative [&now.]";
	proc freq data=libhere.sum&Subj._w_wfs;
		tables AsmtType * Role * 'Current Status'n * workflow_status / list missing;
	run;
%mend studyFlags;
	%studyFlags(ELA);
	%studyFlags(Math);