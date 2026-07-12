/* Adapted from ValidateResults.sas (repo root). The %studyFlags macro (a 4-way PROC FREQ
   cross-tab, including a name-literal column 'Current Status'n, exactly as the author wrote it)
   is unmodified. %ReadTheXL / %MergeWFS2XL (which read a local XLSX pull-list tracker and join to
   a live Postgres item-workflow database) are not called -- libhere.sumELA_w_WFS is instead built
   inline from small mock rows (no PII) carrying the same four columns (AsmtType, Role,
   'Current Status'n, workflow_status) that studyFlags cross-tabulates, matching the item
   workflow-status tracking this script exists to validate. */
libname libhere ".";

data libhere.sumELA_w_WFS;
	length AsmtType $4 Role $8 workflow_status $20;
	input AsmtType $ Role $ 'Current Status'n $ workflow_status $;
	datalines;
SUM Item Active Item_Approved
SUM Item Active Item_Approved
SUM Item Retired Item_Retired
SUM Stim Active Item_Approved
ICA Item Active Item_In_Review
ICA Item Active Item_Approved
;
run;

%macro studyFlags(Subj);
	%GetNow;
	Title "Check WFS for &Subj in 18-19 Summative [&now.]";
	proc freq data=libhere.sum&Subj._w_wfs;
		tables AsmtType * Role * 'Current Status'n * workflow_status / list missing;
	run;
%mend studyFlags;
	%studyFlags(ELA);
