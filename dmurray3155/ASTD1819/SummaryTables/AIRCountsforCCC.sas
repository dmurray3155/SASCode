%let wrkHere=E:\SBAC\AnnualStudTest\1819\AIR;
libName libHere "&wrkHere.";

%include "E:\SBAC\AnnualStudTest\ReadAIRItem.sas";
%include "E:\SBAC\AnnualStudTest\ReadAIRStudent.sas";

%macro NonWAAIRStates(ST, Subj, YMD, encd);
	%if %eval("&ST."="OR") %then %do;
		/*	This is to manage non-standard data file names for OR student data	*/
		%ReadAIRStud(&ST., &Subj.,
			&wrkHere.\&ST.\&Subj. Examinee for SB.txt,
			libHere.&ST._&Subj._Stud_1819, wlatin1);
	%end;
	%else %do;
		%ReadAIRStud(&ST., &Subj.,
			&wrkHere.\&ST.\G3ThroughG11_&Subj._ProductionExaminee_&YMD..txt,
			libHere.&ST._&Subj._Stud_1819, wlatin1);
	%end;
	%ReadAIRItem(&ST., &Subj.,
		&wrkHere.\&ST.\G3ThroughG11_&Subj._ProductionItemCapture_&YMD..txt,
		libHere.&ST._&Subj._Item_1819, &encd.);
%mend NonWAAIRStates;
	%NonWAAIRStates(DE, ELA, 20191002164852, wlatin1);
	%NonWAAIRStates(DE, Math, 20191003134656, wlatin1);
	%NonWAAIRStates(HI, ELA, 20191007163023, wlatin1);
	%NonWAAIRStates(HI, Math, 20191002163752, wlatin1);
	%NonWAAIRStates(ID, ELA, 20191010200248, wlatin1);
	%NonWAAIRStates(ID, Math, 20191011102135, wlatin1);
	%NonWAAIRStates(OR, ELA, 20191015113026, wlatin1);
	%NonWAAIRStates(OR, Math, 20191015220958, wlatin1);
	%NonWAAIRStates(SD, ELA, 20191007170958, wlatin1);
	%NonWAAIRStates(SD, Math, 20191007232513, wlatin1);
	%NonWAAIRStates(USVI, ELA, 20191007164339, wlatin1);
	%NonWAAIRStates(USVI, Math, 20191002104907, wlatin1);
	%NonWAAIRStates(VT, ELA, 20191001214047, utf-8);
	%NonWAAIRStates(VT, Math, 20191002125133, utf-8);

/*	WA requires processing by grade	*/
%macro WrpBySbj(Subj);
	%macro WrpByGrd(Grd, YMD_ELA, YMD_Math);
		%let WAFldrRt=&wrkHere.\WA;
		%ReadAIRStud(WA, &Subj., 
			&WAFldrRt.\&Subj.\&Grd.\&Grd._&Subj._ProductionExaminee_&&YMD_&Subj...txt,
			WA_&Subj._&Grd._Stud_1819, wlatin1);
		%ReadAIRItem(WA, &Subj., 
			&WAFldrRt.\&Subj.\&Grd.\&Grd._&Subj._ProductionItemCapture_&&YMD_&Subj...txt,
			WA_&Subj._&Grd._Item_1819, wlatin1);
	%mend WrpByGrd;
		%WrpByGrd(G3, 20191015113539, 20191015123219);		%WrpByGrd(G4, 20191017143609, 20191015160609);
		%WrpByGrd(G5, 20191017152801, 20191017162604);		%WrpByGrd(G6, 20191018084829, 20191018084917);
		%WrpByGrd(G7, 20191017102755, 20191017112307);		%WrpByGrd(G8, 20191018095554, 20191018095520);
		%WrpByGrd(G11, 20191018105220, 20191018105250);
	%SetDSLabel;
	%macro WrapByScope(Scp);
		data libhere.WA_&Subj._&Scp._1819 (compress=yes label="&DSLabel.");
			set WA_&Subj._G3_&Scp._1819	WA_&Subj._G4_&Scp._1819	WA_&Subj._G5_&Scp._1819
					WA_&Subj._G6_&Scp._1819	WA_&Subj._G7_&Scp._1819	WA_&Subj._G8_&Scp._1819
					WA_&Subj._G11_&Scp._1819 ;
		run;
	%mend WrapByScope;
		%WrapByScope(Item);		%WrapByScope(Stud);
%mend WrpBySbj;
	%WrpBySbj(ELA);
	%WrpBySbj(Math);

%macro CmptCounts(ST, Subj);
	%SetIMRTPrd;
	proc sql;
		create table &ST._&Subj._IDs (compress=yes) as
		select sas.studentidentifier as studId, imrt.associated_stimulus_id as assoc_stim_Id
		from libhere.&ST._&Subj._Item_1819 as sas, imrtprd.item as imrt
		where sas.itemId = imrt.id;
	quit;
	proc freq data=&ST._&Subj._IDs ;
		tables assoc_stim_Id / missing noprint nopercent 
			 out=&ST._&Subj._StimIDs_and_Counts;
	run;
	%GetSnow;
	title "FD of StimID for &ST._&Subj. [&now.]";
	proc print data=&ST._&Subj._StimIDs_and_Counts;
		where assoc_stim_Id ne .;
	run;
%mend CmptCounts;
%*	%CmptCounts(DE, ELA);
%*	%CmptCounts(DE, Math);
%*	%CmptCounts(HI, ELA);
%*	%CmptCounts(HI, Math);
%*	%CmptCounts(ID, ELA);
%*	%CmptCounts(ID, Math);
%*	%CmptCounts(OR, ELA);
%*	%CmptCounts(OR, Math);
%*	%CmptCounts(SD, ELA);
%*	%CmptCounts(SD, Math);
%*	%CmptCounts(USVI, ELA);
%*	%CmptCounts(USVI, Math);
%*	%CmptCounts(VT, ELA);
%*	%CmptCounts(VT, Math);