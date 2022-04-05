/*==================================================================================================*
 | Program	:	BuildFFConfigSheet.sas																																|
 | Author	:	Don Murray (for Smarter Balanced)																												|
 | Purpose	:	From Test Definition File (a.k.a. TDF) write out Excel configuration sheet for 				|
 |				admin package creation.																																		|
 | Macros	: 	Some from my toolbox.sas as well as those developed in this code base.								|
 | Notes	:	Currently a TDF is per subtype.  FF admin config sheets are by subject, subtype,				|
 |				and grade. Therefore subsetting the TDF data by subject and grade is required. 						|
 |				This is a re-built version of this overall process since my original work Lenovo					|
 |				computer died last week.																																	|
 |				TestId (and other components) conventions:																								|
 |		https://ucsc-extension.atlassian.net/wiki/spaces/STP/pages/640254129/Test+ID+Conventions			|
 |		Apply this when I have time:																																	|
 |			https://www.ultraedit.com/support/tutorials-power-tips/ultraedit/sas.html										|
 | Usage	:	Applicable to fixed-form admin package building for the 19-20 test packaging work.			|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................	|
 |	2019 04 08		Initial development.																															|
 |	2019 04 23		ICA labels do not receive the 'High School' replacement for 'Grade 11'.						|
 |	2019 12 19		Copied from the 2019-20 project folder to this location, for 2020-21							|
 |	2022 03 31		Copied from 2020-21 project folder here for 2022-23.	This instance reads TDFs		|
 |								from the TCD.TDF table.  The forms to run are inferred from the contents of the		|
 |								TDFs. Mark V. specified to run based on all forms in 2022-23_iab_v91 and 					|
 |								2022-23_ica_v89.																																	|
 *==================================================================================================*/

options noxwait mlogic mprint symbolgen;

%let wrkHere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\SBTemp\FFConfig\2022-23;
libname wrkData "&wrkHere.";

%global Subj Grd TSubTyp IABShortTitle IABShortTitleSAS _AcadYear_  _FylName_
		_PackageId_		_TestId_ 	_TestId2_	_TestLabel_		_TestLabel2_
		_SegmentId_		_SegmentId2_	_SegmentIdB_	_SegmentId2B_
		_SegmentLabel_	_SegmentLabel2_		_SegmentLabelB_		_SegmentLabel2B_
		_SegmentFormId_		_SegmentFormId2_	_SegmentFormIdB_	_SegmentFormId2B_
		_vrsn_  _TestStructure_  _TSItemCounts_  IsThisAReRun
		NumTtlSegs NumShrtTitles _CntSpanPresTF_ WrkHere
		ExceptionalTestList NumExcepTests ExcepTest1 ExcepTest2 ExcepTest3 ExcepTest4;

%macro BlankOutTestSegFormIDs;
	%let _TestId_=;
	%let _TestLabel_=;
	%let _TestId2_=;
	%let _TestLabel2_=;
	%let _SegmentId_=;
	%let _SegmentLabel_=;
	%let _SegmentFormId_=;
	%let _SegmentIdB_=;
	%let _SegmentLabelB_=;
	%let _SegmentFormIdB_=;
	%let _SegmentId2_=;
	%let _SegmentLabel2_=;
	%let _SegmentFormId2_=;
	%let _SegmentId2B_=;
	%let _SegmentLabel2B_=;
	%let _SegmentFormId2B_=;
%mend BlankOutTestSegFormIDs;

%macro tranwrdMac(macvar, fromtxt, totxt);
	data _null_;
		length _strng_ $ 128;
		_strng_ =  tranwrd("&&&macvar.", "&fromtxt.", "&totxt.");
		call symput("&macvar.", trim(_strng_));
	run;
%mend tranwrdMac;

/*	Designed to adjust value of macro variable.  Common use: testID / segmentId changes for
		specific values as directed by Mark V. in email received Friday, May 10, 2019 5:01 PM MDT		*/
%macro MacCondAdj(macVarName, fromVal, toVal);
	data _null_ ;
		length _MacVar_ $ 128;
		format _MacVar_ $128.;
		_MacVar_ = "&&&macVarName..";
		if _MacVar_ = "&fromVal." then _MacVar_ = "&toVal.";
		call symput("&macVarName.", trim(_MacVar_));
	run;
%mend MacCondAdj;

%macro SetFylName(SubTyp, Subj, Grd, IABShortTitle, _AcadYear_, _vrsn_);
	%if &IABShortTitleSAS.=ListenInterpet %then %let IABShortTitle=ListenInterpret;
	%if &TSubTyp.=ica %then %do;
		%let _FylName_=SBAC-%upcase(&TSubTyp.)-COMBINED-%upcase(&Subj.)-&Grd.-&_AcadYear_._v&_vrsn_..xlsx;
	%end;
	%else %if &TSubTyp.=iab %then %do;
		%let _FylName_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&IABShortTitle.-&Grd.-&_AcadYear_._v&_vrsn_..xlsx;
	%end;
	%else %if &TSubTyp.=fiab %then %do;
		%let _FylName_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&IABShortTitle.-&Grd.-&_AcadYear_._v&_vrsn_..xlsx;
	%end;
	%else %if &TSubTyp.=Practice %then %do;
		%let _FylName_=SBAC-Practice-&Subj.-&IABShortTitle.-&Grd.-&_AcadYear_._v&_vrsn_..xlsx;
	%end;
	%else %if &TSubTyp.=Training %then %do;
		%let _FylName_=SBAC-TRN-&Subj.-&Grd.-&_AcadYear_._v&_vrsn_..xlsx;
	%end;
%mend SetFylName;

/*	Subset the config-sheet level data from the TDF	*/
%macro SubsetTDF(TSubTyp, TDFVrs, Subj, Grd, IABShortTitle, _AcadYear_);
	proc sql;
		create table TDF_Data as
		%if %upcase(&TSubTyp.) = FIAB %then %do;
			select * from WrkData.TDF_2022_23_IAB_v&TDFVrs.			/*	HERE!! <<<-----===##<<<	*/
		%end;
		%else %do;
			select * from WrkData.TDF_2022_23_&TSubTyp._v&TDFVrs.			/*	HERE!! <<<-----===##<<<	*/
		%end;
		where Subject="&Subj." and student_grade=&Grd. and role = "&TSubTyp."
		%if %upcase(&TSubTyp.)=IAB or %upcase(&TSubTyp.)=FIAB or &TSubTyp.=Practice %then %do;
			and Short_Title="&IABShortTitle."
		%end;
		%if &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			order by Seg_Position, Item_Position;
		%end;
		%else %do;
			%if %upcase(&Subj.)=ELA %then %do;
				order by Short_Title, Seq;
			%end;
			%else %if %upcase(&Subj.)=MATH %then %do;
				order by Seq;
			%end;
		%end;
	quit;
	data TDF_Data;
		set TDF_Data;
		if Short_Title = 'ListenInterpet' then Short_Title='ListenInterpret';
	run;
/*%GetSnow;
	Title "DS: TDF_Data [&now.]";
	proc print data=TDF_Data;
	run;*/
%mend SubsetTDF;

/*	This setting is to support exceptional tests.  PackageID, TestID, and SegmentID are effected	*/
%macro SetExceptionalTests;
	%let ExceptionalTestList=%str("FIAB-MATH-TFG-7-2022-2023", "FIAB-MATH-TIG-8-2022-2023",
			"FIAB-MATH-TGCEDLinExp-11-2022-2023", "FIAB-MATH-TGCEDQuad-11-2022-2023");
	%let NumExcepTests=4;
	%let ExcepTest1=IAB-MATH-TFG-7;
	%let ExcepTest2=IAB-MATH-TIG-8;
	%let ExcepTest3=IAB-MATH-TGCEDLinExp-11;
	%let ExcepTest4=IAB-MATH-TGCEDQuad-11;
%mend SetExceptionalTests;

%macro Cre8TstSegNames(TSubTyp, tdfvrsn, Subj, Grd, IABShortTitle, _AcadYear_, ReptResults);
	%BlankOutTestSegFormIDs;
	%let IABShortTitleSAS=%substr(&IABShortTitle, 1, 25);
	%tranwrdMac(IABShortTitleSAS, -, _);
	%SubsetTDF(&TSubTyp., &tdfvrsn., &Subj., &Grd., &IABShortTitle., &_AcadYear_.);
	%if &IABShortTitleSAS.=ListenInterpet %then %let IABShortTitle=ListenInterpret;
	proc sql;
		create table SFTSgData as
		select distinct Short_Title, Full_Title, Seg_Description
		from TDF_Data
		order by Short_Title, Full_Title, Seg_Description
		%if %upcase(&Subj.)=MATH %then %do;
			descending
		%end;
		;
		create table SFTData as
		select distinct Short_Title, Full_Title
		from TDF_Data
		order by Short_Title;
	quit;
	%TotalRec(inDS=SFTSgData);
	%let NumTtlSegs=&NumObs.;
	%TransMac(DSName=SFTSgData, VarName=Short_Title, Prefx=STSg);
	%TransMac(DSName=SFTSgData, VarName=Full_Title, Prefx=FTSg);
	%TransMac(DSName=SFTSgData, VarName=Seg_Description, Prefx=TSeg);
	%if &NumTtlSegs=1 %then %do;
		%let _TestId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&IABShortTitle.-&Grd.;
		%let _TestLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
		%if &TSubTyp.=Practice %then %do;
			%tranwrdMac(_TestLabel_, (Practice), );
		%end;
		%if &TSubTyp.=Training %then %do;
			%tranwrdMac(_TestLabel_, (Training), );
		%end;
		%if &Grd.=11 %then %do;
			%tranwrdMac(_TestLabel_, Grade 11, High School);
		%end;
		%let _SegmentId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&IABShortTitle.-&Grd.;
		%let _SegmentLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
		%if &TSubTyp.=Practice %then %do;
			%tranwrdMac(_SegmentLabel_, (Practice), );
		%end;
		%if &TSubTyp.=Training %then %do;
			%tranwrdMac(_SegmentLabel_, (Training), );
		%end;
		%if &Grd.=11 %then %do;
			%tranwrdMac(_SegmentLabel_, Grade 11, High School);
		%end;
		%let _SegmentFormId_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
		%if &TSubTyp.=Practice %then %do;
			%tranwrdMac(_SegmentFormId_, (Practice), );
		%end;
		%if &TSubTyp.=Training %then %do;
			%tranwrdMac(_SegmentFormId_, (Training), );
		%end;
		%if &Grd.=11 %then %do;
			%tranwrdMac(_SegmentFormId_, Grade 11, High School);
		%end;
	%end;
	%if &NumTtlSegs=2 %then %do;	/* These are IABs with one test name and two segments	*/
		%if %upcase(&TSubTyp.)=IAB or %upcase(&TSubTyp.)=FIAB or &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			%let _TestId_=SBAC-IAB-%upcase(&Subj.)-&IABShortTitle.-&Grd.;
			%let _TestLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
			%if &TSubTyp.=Practice %then %do;
				%tranwrdMac(_TestLabel_, (Practice), );
			%end;
			%if &TSubTyp.=Training %then %do;
				%tranwrdMac(_TestLabel_, (Training), );
			%end;
			%if &Grd.=11 %then %do;
				%tranwrdMac(_TestLabel_, Grade 11, High School);
			%end;
			%let _SegmentId_=SBAC-IAB-%upcase(&Subj.)-&IABShortTitle.-&Grd.-SEG1-&TSeg1.;
			%let _SegmentLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg1. (%upcase(&TSubTyp.));
			%if &TSubTyp.=Practice %then %do;
				%tranwrdMac(_SegmentLabel_, (Practice), );
			%end;
			%if &TSubTyp.=Training %then %do;
				%tranwrdMac(_SegmentLabel_, (Training), );
			%end;
			%if &Grd.=11 %then %do;
				%tranwrdMac(_SegmentLabel_, Grade 11, High School);
			%end;
			%let _SegmentFormId_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg1. (%upcase(&TSubTyp.));
			%if &TSubTyp.=Practice %then %do;
				%tranwrdMac(_SegmentFormId_, (Practice), );
			%end;
			%if &TSubTyp.=Training %then %do;
				%tranwrdMac(_SegmentFormId_, (Training), );
			%end;
			%if &Grd.=11 %then %do;
				%tranwrdMac(_SegmentFormId_, Grade 11, High School);
			%end;
			%let _SegmentIdB_=SBAC-IAB-%upcase(&Subj.)-&IABShortTitle.-&Grd.-SEG2-&TSeg2.;
			%let _SegmentLabelB_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg2. (%upcase(&TSubTyp.));
			%if &TSubTyp.=Practice %then %do;
				%tranwrdMac(_SegmentLabelB_, (Practice), );
			%end;
			%if &TSubTyp.=Training %then %do;
				%tranwrdMac(_SegmentLabelB_, (Training), );
			%end;
			%if &Grd.=11 %then %do;
				%tranwrdMac(_SegmentLabelB_, Grade 11, High School);
			%end;
	/*	%if &TSubTyp.=Practice %then %do;
				%tranwrdMac(_SegmentFormIdB_, (Practice), );
			%end;
			%if &TSubTyp.=Training %then %do;
				%tranwrdMac(_SegmentFormIdB_, (Training), );
			%end;	*/
			%let _SegmentFormIdB_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg2. (%upcase(&TSubTyp.));
			%if &TSubTyp.=Practice %then %do;
				%tranwrdMac(_SegmentFormIdB_, (Practice), );
			%end;
			%if &TSubTyp.=Training %then %do;
				%tranwrdMac(_SegmentFormIdB_, (Training), );
			%end;
			%if &Grd.=11 %then %do;
				%tranwrdMac(_SegmentFormIdB_, Grade 11, High School);
			%end;
		%end;
		%else %if &TSubTyp.=ica %then %do;
			%let _TestId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.;
			%let _TestLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
			%let _TestId2_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg2.-&Grd.;
			%let _TestLabel2_=Grade &Grd. %upcase(&Subj.) - &FTSg2. (%upcase(&TSubTyp.));
			%if &Subj.=math and %eval(&Grd. < 6) %then %do;
				%let _SegmentId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.;
				%let _SegmentLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
				%let _SegmentFormId_=Grade &Grd. %upcase(&Subj.) - &FTSg1 (%upcase(&TSubTyp.));
				%let _SegmentId2_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg2.-&Grd.;
				%let _SegmentLabel2_=Grade &Grd. %upcase(&Subj.) - &FTSg2. (%upcase(&TSubTyp.));
				%let _SegmentFormId2_=Grade &Grd. %upcase(&Subj.) - &FTSg2. (%upcase(&TSubTyp.));
			%end;
			%else %do;
				%let _SegmentId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.-SEG1-&TSeg1.;
				%let _SegmentLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg1. (%upcase(&TSubTyp.));
				%let _SegmentFormId_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg1. (%upcase(&TSubTyp.));
				%let _SegmentIdB_=SBAC-&TSubTyp.-%upcase(&Subj.)-&STSg2.-&Grd.-SEG2-&TSeg2.;
				%let _SegmentLabelB_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg2. (%upcase(&TSubTyp.));
				%let _SegmentFormIdB_=Grade &Grd. %upcase(&Subj.) - &FTSg1. &TSeg2. (%upcase(&TSubTyp.));
			%end;
		%end;
	%end;
	%if &NumTtlSegs=3 %then %do;
		%if "&STSg2."="&STSg1." %then %do;	/* This is like a math ICA - like grade 8	*/
			%let _TestId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.;
			%let _TestLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
			%let _SegmentId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.-SEG1-&TSeg1.;
			%let _SegmentLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. - &TSeg1. (%upcase(&TSubTyp.));
			%let _SegmentFormId_=Grade &Grd. %upcase(&Subj.) - &FTSg1. - &TSeg1. (%upcase(&TSubTyp.));
			%let _SegmentIdB_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg2.-&Grd.-SEG2-&TSeg2.;
			%let _SegmentLabelB_=Grade &Grd. %upcase(&Subj.) - &FTSg2. - &TSeg2. (%upcase(&TSubTyp.));
			%let _SegmentFormIdB_=Grade &Grd. %upcase(&Subj.) - &FTSg2. - &TSeg2. (%upcase(&TSubTyp.));
			%let _TestId2_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg3.-&Grd.;
			%let _TestLabel2_=Grade &Grd. %upcase(&Subj.) - &FTSg3. (%upcase(&TSubTyp.));
			%let _SegmentId2_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&StSg3.-&Grd.;
			%let _SegmentLabel2_=Grade &Grd. %upcase(&Subj.) - &FTSg3. (%upcase(&TSubTyp.));
			%let _SegmentFormId2_=Grade &Grd. %upcase(&Subj.) - &FTSg3. (%upcase(&TSubTyp.));
		%end;
		%if "&STSg3."="&STSg2." %then %do;	/*	This is like an ELA ICA - like grade 11	*/
			%let _TestId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.;
			%let _TestLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
			%let _SegmentId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg1.-&Grd.;
			%let _SegmentLabel_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
			%let _SegmentFormId_=Grade &Grd. %upcase(&Subj.) - &FTSg1. (%upcase(&TSubTyp.));
			%let _TestId2_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg2.-&Grd.;
			%let _TestLabel2_=Grade &Grd. %upcase(&Subj.) - &FTSg2. (%upcase(&TSubTyp.));
			%let _SegmentId2_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&STSg2.-&Grd.-SEG1-&TSeg2.;
			%let _SegmentLabel2_=Grade &Grd. %upcase(&Subj.) - &FTSg2. - &TSeg2. (%upcase(&TSubTyp.));
			%let _SegmentFormId2_=Grade &Grd. %upcase(&Subj.) - &FTSg2. - &TSeg2. (%upcase(&TSubTyp.));
			%let _SegmentId2B_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&StSg3.-&Grd.-SEG2-&TSeg3.;
			%let _SegmentLabel2B_=Grade &Grd. %upcase(&Subj.) - &FTSg3. - &TSeg3. (%upcase(&TSubTyp.));
			%let _SegmentFormId2B_=Grade &Grd. %upcase(&Subj.) - &FTSg3. - &TSeg3. (%upcase(&TSubTyp.));
		%end;
	%end;
	%TotalRec(inDS=SFTData);
	%let NumShrtTitles=&NumObs.;
	%SetFylName(&TSubTyp., &Subj., &Grd., &IABShortTitle., &_AcadYear_., &vrsn.);
	%if &TSubTyp.=ica %then %do;
		%let _PackageId_=SBAC-%upcase(&TSubTyp.)-COMBINED-%upcase(&Subj.)-&Grd.;
	%end;
	%else %if %upcase(&TSubTyp.)=IAB or &TSubTyp.=FIAB or &TSubTyp.=Practice %then %do;
		%let _PackageId_=SBAC-%upcase(&TSubTyp.)-%upcase(&Subj.)-&IABShortTitle.-&Grd.;
	%end;
	%else %if &TSubTyp.=Training %then %do;
		%let _PackageId_=SBAC-TRN-&Subj.-&Grd.;
	%end;
	%tranwrdMac(_PackageId_, FIAB, IAB);
	%tranwrdMac(_TestId_, FIAB, IAB);
	%tranwrdMac(_TestId2_, FIAB, IAB);
%*	%tranwrdMac(_TestLabel_, FIAB, IAB);
%*	%tranwrdMac(_TestLabel2_, FIAB, IAB);
	%tranwrdMac(_SegmentId_, FIAB, IAB);
%*	%tranwrdMac(_SegmentLabel_, FIAB, IAB);
%*	%tranwrdMac(_SegmentLabel2_, FIAB, IAB);
	%tranwrdMac(_SegmentLabelB_, FIAB, IAB);
	%tranwrdMac(_SegmentLabel2B_, FIAB, IAB);
	%tranwrdMac(_SegmentId2_, FIAB, IAB);
	%tranwrdMac(_SegmentIdB_, FIAB, IAB);
%*	%tranwrdMac(_SegmentFormId_, FIAB, IAB);
%*	%tranwrdMac(_SegmentFormId2_, FIAB, IAB);
%*	%tranwrdMac(_SegmentFormIdB_, FIAB, IAB);
%*	%tranwrdMac(_SegmentFormId2B_, FIAB, IAB);
	/*	Put conditional ID and Label adjustment logic here		*/
	%SetExceptionalTests;
	%do ClcOnly=1 %to &NumExcepTests;
		%MacCondAdj(_TestId_, SBAC-&&ExcepTest&ClcOnly.., SBAC-&&ExcepTest&ClcOnly..-Calc);
		%MacCondAdj(_PackageId_, SBAC-&&ExcepTest&ClcOnly.., SBAC-&&ExcepTest&ClcOnly..-Calc);
		%MacCondAdj(_SegmentId_, SBAC-&&ExcepTest&ClcOnly.., SBAC-&&ExcepTest&ClcOnly..-Calc);
	%end;
	%put _PackageId_ &_PackageId_.;
	%put _TestId_ &_TestId_.;
	%put _SegmentId_ &_SegmentId_.;
	%if &ReptResults.=1 %then %do;
		FileName outRept "&WrkHere.\OutFiles.\&_FylName_..txt";
		data _null_;
			format OutLyn $84.;
			file outRept ;
			OutLyn = 'Test SubType: '||"&TSubTyp."||' - Subject: '||"&Subj."||' - Grade: '||"&Grd.";
			put OutLyn;
			OutLyn = ' ';
			put OutLyn;
			OutLyn = 'PackageId: '||"&_PackageId_.";				put OutLyn;
			OutLyn = 'TestId: '||"&_TestId_.";					put OutLyn;
			OutLyn = 'TestLabel: '||"&_TestLabel_.";				put OutLyn;
			OutLyn = 'SegmentId: '||"&_SegmentId_.";				put OutLyn;
			OutLyn = 'SegmentLabel: '||"&_SegmentLabel_.";		put OutLyn;
			OutLyn = 'SegmentFormId: '||"&_SegmentFormId_.";		put OutLyn;
			OutLyn = 'SegmentIdB: '||"&_SegmentIdB_.";		put OutLyn;
			OutLyn = 'SegmentLabelB: '||"&_SegmentLabelB_.";		put OutLyn;
			OutLyn = 'SegmentFormIdB: '||"&_SegmentFormIdB_.";		put OutLyn;
			OutLyn = 'TestId2: '||"&_TestId2_.";					put OutLyn;
			OutLyn = 'TestLabel2: '||"&_TestLabel2_.";				put OutLyn;
			OutLyn = 'SegmentId2: '||"&_SegmentId2_.";				put OutLyn;
			OutLyn = 'SegmentLabel2: '||"&_SegmentLabel2_.";		put OutLyn;
			OutLyn = 'SegmentFormId2: '||"&_SegmentFormId2_.";		put OutLyn;
			OutLyn = 'SegmentId2B: '||"&_SegmentId2B_.";				put OutLyn;
			OutLyn = 'SegmentLabel2B: '||"&_SegmentLabel2B_.";		put OutLyn;
			OutLyn = 'SegmentFormId2B: '||"&_SegmentFormId2B_.";		put OutLyn;
		run;
	%end;
	%if &ReptResults.=2 %then %do;
		data &Subj.&Grd.&IABShortTitleSAS.;
			format TestId $48. TestLabel $84. SegmentId $74. SegmentLabel $128. SegmentFormId $128.;
			%if &NumTtlSegs.=1 %then %do;
				TestId = "&_TestId_.";
				TestLabel = "&_TestLabel_.";
				SegmentId = "&_SegmentId_.";
				SegmentLabel = "&_SegmentLabel_.";
				SegmentFormId = "&_SegmentFormId_.";
				output;
			%end;
			%else %if &NumTtlSegs.=2 %then %do;
				TestId = "&_TestId_.";
				TestLabel = "&_TestLabel_.";
				SegmentId = "&_SegmentId_.";
				SegmentLabel = "&_SegmentLabel_.";
				SegmentFormId = "&_SegmentFormId_.";
				output;
				TestId = "&_TestId_.";
				TestLabel = "&_TestLabel_.";
				SegmentId = "&_SegmentIdB_.";
				SegmentLabel = "&_SegmentLabelB_.";
				SegmentFormId = "&_SegmentFormIdB_.";
				output;
			%end;
			%else %if &NumTtlSegs.=3 %then %do;
				%if &STSg2.=&STSg1. %then %do;	/* This is like a math ICA - like grade 8	*/
					TestId = "&_TestId_.";
					TestLabel = "&_TestLabel_.";
					SegmentId = "&_SegmentId_.";
					SegmentLabel = "&_SegmentLabel_.";
					SegmentFormId = "&_SegmentFormId_.";
					output;
					TestId = "&_TestId_.";
					TestLabel = "&_TestLabel_.";
					SegmentId = "&_SegmentIdB_.";
					SegmentLabel = "&_SegmentLabelB_.";
					SegmentFormId = "&_SegmentFormIdB_.";
					output;
					TestId = "&_TestId2_.";
					TestLabel = "&_TestLabel2_.";
					SegmentId = "&_SegmentId2_.";
					SegmentLabel = "&_SegmentLabel2_.";
					SegmentFormId = "&_SegmentFormId2_.";
					output;
				%end;
				%if &STSg3.=&STSg2. %then %do;	/*	This is like an ELA ICA - like grade 11	*/
					TestId = "&_TestId_.";
					TestLabel = "&_TestLabel_.";
					SegmentId = "&_SegmentId_.";
					SegmentLabel = "&_SegmentLabel_.";
					SegmentFormId = "&_SegmentFormId_.";
					output;
					TestId = "&_TestId2_.";
					TestLabel = "&_TestLabel2_.";
					SegmentId = "&_SegmentId2_.";
					SegmentLabel = "&_SegmentLabel2_.";
					SegmentFormId = "&_SegmentFormId2_.";
					output;
					TestId = "&_TestId2_.";
					TestLabel = "&_TestLabel2_.";
					SegmentId = "&_SegmentId2B_.";
					SegmentLabel = "&_SegmentLabel2B_.";
					SegmentFormId = "&_SegmentFormId2B_.";
					output;
				%end;
			%end;
		run;
		%if &Subj.=ELA and &Grd.=3 and &IABShortTitleSAS.=BriefWrites %then %do;
			data WrkData.&TSubTyp._v&vrsn._IDs_and_Labels;
				set ELA3BriefWrites;
			run;
			%GetSnow;
			Title "DS: &Subj.&Grd.&IABShortTitleSAS. [&now.]";
			proc print data=&Subj.&Grd.&IABShortTitleSAS.;
			run;
		%end;
		%else %do;
			proc append base=WrkData.&TSubTyp._v&vrsn._IDs_and_Labels data=&Subj.&Grd.&IABShortTitleSAS.;
			run;
		%end;
		%if &Subj.=MATH and &Grd.=11 and &IABShortTitleSAS.=SSE %then %do;
			libname XLNMSOOT XLSX "&WrkHere.\&TSubTyp._v&vrsn._IDs_and_Labels.xlsx";
			data XLNMSOOT.IDs_and_Labels;
				set WrkData.&TSubTyp._v&vrsn._IDs_and_Labels;
			run;
		%end;
	%end;
%mend Cre8TstSegNames;

%macro ConditionallyRemoveOriginalFiles(_FylName_);
	data _null_;
		file "&WrkHere.\DelOrigFiles.bat";
		format OutLyn $184.;
		OutLyn = 'echo ##### Removing original files #####';		put OutLyn;
		OutLyn = 'del "'||"&WrkHere.\&_FylName_."||'"';		put OutLyn;
	/*	OutLyn = 'del "'||"&WrkHere.\&_FylName_..bak"||'"';		put OutLyn;	*/
	run;
	X "DelOrigFiles" ;
%mend ConditionallyRemoveOriginalFiles;

%macro ZeroOne2TRUEFALSE(_VAR_);
	if &_VAR_ = '0' then &_VAR_ = 'FALSE';
	else if &_VAR_ = '1' then &_VAR_ = 'TRUE';
%mend;

%macro SetIRTModel(PntsVar, ModelVar);
	if &PntsVar. = 1 then &ModelVar. = 'IRT3PLn';
	else if &PntsVar. = . then &ModelVar. = '';
	else if &PntsVar. > 1 then &ModelVar. = 'IRTGPC';
%mend SetIRTModel;

%macro Cre8OutXL(TSubTyp, tdfvrsn, _vrsn_, Subj, Grd, IABShortTitle, _AcadYear_, _RR_);
	%SetFylName(&TSubTyp., &Subj., &Grd., &IABShortTitle., &_AcadYear_., &vrsn.);
	%if &IABShortTitleSAS.=ListenInterpet %then %let IABShortTitle=ListenInterpret;
	/*
	%if &TSubTyp.=ICA %then %do;
		%let _PackageId_=&TSubTyp.-COMBINED-&Subj.-&Grd.;
	%end;
	%else %if &TSubTyp.=IAB or &TSubTyp.=FIAB %then %do;
		%let _PackageId_=&TSubTyp.-&Subj.-&IABShortTitle.-&Grd.;
	%end;
	*/
	%if &_RR_.=yes %then %do;
		%ConditionallyRemoveOriginalFiles(&_FylName_.);
	%end;
	libname SrcData "&WrkHere.\SrcData";
	libname XLOut XLSX "&WrkHere.\OutFiles\&_FylName_.";
	/*** === Package === ***/
	proc sql noprint;
		select ScaledLo, ScaledPart1, ScaledPart2, ScaledPart3, ScaledHi
			into :_SL_, :_SP1_, :_SP2_, :_SP3_, :_SH_
		from SrcData.testscores
		where upcase(Subject) = %upcase("&Subj.") and grade = &Grd.;
	quit;
	data PackageData;
		set SrcData.PackageTemplate;
		length InputParam $42;
		format InputParam $42.;
		if InputParam='_PackageId_' then InputParam="&_PackageId_.";
		if InputParam='_AcadYear_' then InputParam="&_AcadYear_.";
		if InputParam='_vrsn_' then InputParam="&_vrsn_.";
		if InputParam='_Subj_' then InputParam=%upcase("&Subj.");
		if InputParam='_Grd_' then InputParam="&Grd.";
		%if &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			if InputParam='interim' then InputParam='summative';
		%end;
		%if &TSubTyp.=FIAB %then %do;
			if InputParam='_TSubType_' then InputParam='IAB';
		%end;
		%else %if &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			if InputParam='_TSubType_' then InputParam='';
		%end;
		%else %do;
			if InputParam='_TSubType_' then InputParam=%upcase("&TSubTyp.");
		%end;
		if InputParam='_ScaledLo_' then InputParam=compress("&_SL_.");
		if InputParam='_ScaledPart1_' then InputParam="&_SP1_.";
		if InputParam='_ScaledPart2_' then InputParam="&_SP2_.";
		if InputParam='_ScaledPart3_' then InputParam="&_SP3_.";
		if InputParam='_ScaledHi_' then InputParam=compress("&_SH_.");
		put '***>>> ' InputParam=  ;
	run;
	data XLOut.Package;
		set PackageData;
	run;
	/*** === Scoring === ***/
	data ScoringTemp;
		set SrcData.ScoringTemplate;
		format RowOrder 3.0 ;
		RowOrder = _n_;
	run;
	/*	For Practice and Training config sheets the scoring page must bear these changes:
				TestId should be some dummy value (this causes no scoring config in the built XML)
				item missing item parameters need to bear some real-type dummy values (a=0.6000, b=0.2000)	*/
	%if %upcase(&TSubTyp.)=IAB or %upcase(&TSubTyp.)=FIAB %then %let _lastCol_=5;
	%else %if %upcase(&TSubTyp.)=ICA %then %do;
		%if %upcase(&Subj.)=ELA %then %let _lastCol_=32;
		%else %if %upcase(&Subj.)=MATH %then %let _lastCol_=26;
	%end;
	%if &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
		data ScoringData;
			set SrcData.ScoringTemplate;
			if InputVarDesc='Input Data Values and Descriptions' then InputParam = 'One Rule Per Column';
			if InputVar = 'Input Variable' then InputParam = 'Input Parameter';
			if InputVar = 'BlueprintElementId' then InputParam = 'DUMMY';
			if InputVar = 'BlueprintElementType' then InputParam = 'test';
			if InputVar = 'ComputationOrder' then InputParam = '10';
			if InputVar = 'Name' then InputParam = 'SBACIABAttemptedness';
			if InputVar = 'measure' then InputParam = 'Attempted';
		run;
	%end;
	%else %do;
		proc sql;
			create table SrcScoringSubData as
			select * from SrcData.ScoringData
			%if &TSubTyp.=fiab %then %do;
				where upcase(TSubType) = 'IAB'
			%end;
			%else %do;
				where upcase(TSubType) = %upcase("&TSubTyp.")
			%end;
			%if %upcase(&TSubTyp.)=ICA %then %do;
				and upcase(Subject) = %upcase("&Subj.")
			%end;
			;
			create table ScoringData as
			select temp.XMLRef, temp.Usage, temp.InputVarDesc, temp.InputVar,
				dat.InputVar, 
				%do cn = 1 %to %eval(&_lastCol_. - 1);
					dat.Col&cn.,
				%end;
				dat.Col&_lastCol_.
			from ScoringTemp as temp
			left join SrcScoringSubData as dat
			on temp.InputVar = dat.InputVar
			order by temp.RowOrder;
		quit;
		proc sql noprint;
			select LOT, HOT
				into :_LOT_, :_HOT_
			from SrcData.testscores
			where upcase(Subject) = %upcase("&Subj.") and grade = &Grd.;
		quit;
		data ScoringData;
			set ScoringData;
			if InputVarDesc='Input Data Values and Descriptions' then Col1 = 'One Rule Per Column';
			%do i=1 %to &_lastCol_.;
				if col&i. = '_BPElemID_' then col&i.="&_PackageId_.";
				if col&i. = '_LOT_' then col&i.="&_LOT_.";
				if col&i. = '_HOT_' then col&i.="&_HOT_.";
				if col&i. = '_TestPart1_' then col&i.="&_SegmentId_.";
				if col&i. = '_TestPart1A_' then col&i.="&_SegmentId_.";
				if col&i. = '_TestPart1B_' then col&i.="&_SegmentIdB_.";
				if col&i. = '_TestPart2_' then col&i.="&_SegmentId2_.";
				if col&i. = '_TestPart2A_' then col&i.="&_SegmentId2_.";
				if col&i. = '_TestPart2B_' then col&i.="&_SegmentId2B_.";
			%end;
		run;
	%end;
	data XLOut.Scoring;
		set ScoringData;
	run;
	/*** === Tests === ***/
	data TestsData;
		set SrcData.TestsTemplate;
		if InputParam='_TestId_' then InputParam="&_TestId_.";
		if InputParam='_TestLabel_' then InputParam="&_TestLabel_.";
		%if &NumShrtTitles.=2 %then %do;
			format InputParam2 $84.;
			if InputVar='Input Variable' then InputParam2='Input Parameter';
			if InputVar='TestId' then InputParam2="&_TestId2_.";
			if InputVar='TestLabel' then InputParam2="&_TestLabel2_.";
		%end;
	run;
	data XLOut.Tests;
		set TestsData;
	run;
	/*** === Segments === ***/
	%if &Subj.=MATH %then %let _CntSpanPresTF_=TRUE;
	%else %if &Subj.=ELA %then %let _CntSpanPresTF_=FALSE;
	proc sql noprint;
		select slope, intercept
		into :_slope_, :_intercept_
		from SrcData.scaling
		where upcase(Subject)="%upcase(&Subj.)";
	quit;
	data SegmentsData;
		set SrcData.segmentsTemplate;
		length InputParam $ 88;
		format InputParam $88.;
		if InputParam='_SegmentId_' then InputParam="&_SegmentId_.";
		if InputParam='_TestId_' then InputParam = "&_TestId_.";
		if InputParam = '_SegmentLabel_' then InputParam = "&_SegmentLabel_.";
		if InputVar = 'SegmentEntryApproval' then %ZeroOne2TRUEFALSE(InputParam);
		if InputVar = 'SegmentExitAppoval' then %ZeroOne2TRUEFALSE(InputParam);						/* Appoval?	*/
		if InputVar = 'SegmentEnglishPresentation' then %ZeroOne2TRUEFALSE(InputParam);
		if InputVar = 'SegmentBraillePresentation' then %ZeroOne2TRUEFALSE(InputParam);
		if InputVar = 'SegmentSpanishPresentation' then InputParam = "&_CntSpanPresTF_.";
		if InputParam = '_slope_' then InputParam = "&_slope_.";
		if InputParam = '_intercept_' then InputParam = "&_intercept_.";
		%if %upcase(&TSubTyp.)=ICA %then %do;
			%if %upcase(&Subj.)=ELA %then %do;		/*	1 2A 2B	*/
				%if &NumTtlSegs.=3 %then %do;
					format InputParam2 $88. InputParam3 $88.;
					if InputVar = 'Input Variable' then do;
						InputParam2 = 'Input Parameter';
						InputParam3 = 'Input Parameter';
					end;
					if InputVarDesc='Input Data Values and Descriptions' then do;
						InputParam2 = "1 Or More SegmentId's Allowed Per TestId";
						InputParam3 = '';
					end;
					if InputVar = 'SegmentId' then do;
						InputParam2 = "&_SegmentId2_.";
						InputParam3 = "&_SegmentId2B_.";
					end;
					if InputVar = 'TestId' then do;
						InputParam2 = "&_TestId2_.";
						InputParam3 = "&_TestId2_.";
					end;
					if InputVar = 'SegmentPosition' then do;
						InputParam2 = '1';
						InputParam3 = '2';
					end;
					if InputVar = 'SegmentLabel' then do;
						InputParam2 = "&_SegmentLabel2_.";
						InputParam3 = "&_SegmentLabel2B_.";
					end;
					if InputVar = 'SegmentEntryApproval' then InputParam2 = InputParam;
					if InputVar = 'SegmentExitAppoval' then InputParam2 = InputParam;
					if InputVar = 'SegmentEnglishPresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentBraillePresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentSpanishPresentation' then InputParam2 = "&_CntSpanPresTF_.";
					if InputVar = 'SegmentSlope' then InputParam2 = InputParam;
					if InputVar = 'SegmentIntercept' then InputParam2 = InputParam;
					if InputVar = 'SegmentEntryApproval' then InputParam3 = InputParam;
					if InputVar = 'SegmentExitAppoval' then InputParam3 = InputParam;
					if InputVar = 'SegmentEnglishPresentation' then InputParam3 = InputParam;
					if InputVar = 'SegmentBraillePresentation' then InputParam3 = InputParam;
					if InputVar = 'SegmentSpanishPresentation' then InputParam3 = "&_CntSpanPresTF_.";
					if InputVar = 'SegmentSlope' then InputParam3 = InputParam;
					if InputVar = 'SegmentIntercept' then InputParam3 = InputParam;
				%end;
			%end;
			%else %if %upcase(&Subj.)=MATH %then %do;
				%if &NumTtlSegs.=2 %then %do;		/*	1 2		*/
					format InputParam2 $88.;
					if InputVar = 'Input Variable' then do;
						InputParam2 = 'Input Parameter';
					end;
					if InputVarDesc='Input Data Values and Descriptions' then do;
						InputParam2 = "1 Or More SegmentId's Allowed Per TestId";
					end;
					if InputVar = 'SegmentId' then do;
						InputParam2 = "&_SegmentId2_.";
					end;
					if InputVar = 'TestId' then do;
						InputParam2 = "&_TestId2_.";
					end;
					if InputVar = 'SegmentPosition' then do;
						InputParam2 = '1';
					end;
					if InputVar = 'SegmentLabel' then do;
						InputParam2 = "&_SegmentLabel2_.";
					end;
					if InputVar = 'SegmentEntryApproval' then InputParam2 = InputParam;
					if InputVar = 'SegmentExitAppoval' then InputParam2 = InputParam;
					if InputVar = 'SegmentEnglishPresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentBraillePresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentSpanishPresentation' then InputParam2 = "&_CntSpanPresTF_.";
					if InputVar = 'SegmentSlope' then InputParam2 = InputParam;
					if InputVar = 'SegmentIntercept' then InputParam2 = InputParam;
				%end;
				%else %if &NumTtlSegs.=3 %then %do;		/*	1A 1B 2		*/
					format InputParam2 $88. InputParam3 $88.;
					if InputVar = 'Input Variable' then do;
						InputParam2 = 'Input Parameter';
						InputParam3 = 'Input Parameter';
					end;
					if InputVarDesc='Input Data Values and Descriptions' then do;
						InputParam2 = '';
						InputParam3 = "1 Or More SegmentId's Allowed Per TestId";
					end;
					if InputVar = 'SegmentId' then do;
						InputParam2 = "&_SegmentIdB_.";
						InputParam3 = "&_SegmentId2_.";
					end;
					if InputVar = 'TestId' then do;
						InputParam2 = "&_TestId_.";
						InputParam3 = "&_TestId2_.";
					end;
					if InputVar = 'SegmentPosition' then do;
						InputParam2 = '2';
						InputParam3 = '1';
					end;
					if InputVar = 'SegmentLabel' then do;
						InputParam2 = "&_SegmentLabelB_.";
						InputParam3 = "&_SegmentLabel2_.";
					end;
					if InputVar = 'SegmentEntryApproval' then InputParam2 = InputParam;
					if InputVar = 'SegmentExitAppoval' then InputParam2 = InputParam;
					if InputVar = 'SegmentEnglishPresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentBraillePresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentSpanishPresentation' then InputParam2 = "&_CntSpanPresTF_.";
					if InputVar = 'SegmentSlope' then InputParam2 = InputParam;
					if InputVar = 'SegmentIntercept' then InputParam2 = InputParam;
					if InputVar = 'SegmentEntryApproval' then InputParam3 = InputParam;
					if InputVar = 'SegmentExitAppoval' then InputParam3 = InputParam;
					if InputVar = 'SegmentEnglishPresentation' then InputParam3 = InputParam;
					if InputVar = 'SegmentBraillePresentation' then InputParam3 = InputParam;
					if InputVar = 'SegmentSpanishPresentation' then InputParam3 = "&_CntSpanPresTF_.";
					if InputVar = 'SegmentSlope' then InputParam3 = InputParam;
					if InputVar = 'SegmentIntercept' then InputParam3 = InputParam;
				%end;
			%end;
		%end;
		%else %if %upcase(&TSubTyp.)=IAB or %upcase(&TSubTyp.)=FIAB or &TSubTyp=Practice or &TSubTyp=Training %then %do;
			%if &NumTtlSegs.=2 %then %do;
				format InputParam2 $88.;
				if InputVar = 'Input Variable' then InputParam2 = 'Input Parameter';
				if InputVar = 'SegmentId' then InputParam2 = "&_SegmentIdB_.";
				if InputVar = 'TestId' then InputParam2 = "&_TestId_.";
				if InputVar = 'SegmentPosition' then InputParam2 = '2';
				if InputVar = 'SegmentLabel' then InputParam2 = "&_SegmentLabelB_.";
				if InputVar = 'SegmentEntryApproval' then InputParam2 = InputParam;
					if InputVar = 'SegmentExitAppoval' then InputParam2 = InputParam;
					if InputVar = 'SegmentEnglishPresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentBraillePresentation' then InputParam2 = InputParam;
					if InputVar = 'SegmentSpanishPresentation' then InputParam2 = "&_CntSpanPresTF_.";
					if InputVar = 'SegmentSlope' then InputParam2 = InputParam;
					if InputVar = 'SegmentIntercept' then InputParam2 = InputParam;
			%end;
		%end;
	run;
	data XLOut.Segments;
		set SegmentsData;
	run;
	/*** === SegmentForms === ***/
	/*	Pre-Process the data from the TDF	*/
	%TotalRec(inDS=TDF_Data);
	%let NumItems=&NumObs.;
	%SetExceptionalTests;
	data TDF_DataSF;
		set TDF_Data;
		format IRTModel1 $8. IRTModel2 $8. MaxRubStrd1 $1. MaxRubStrd2 $1. Scr1Dim $1. Scr2Dim $1. weight1 $1. weight2 $1.
					aparm1Str $8. aparm2Str $8. bparm1Str $8. bparm2Str $8.
					irtb0_d1 9.5 irtb1_d1 9.5 irtb2_d1 9.5 irtb3_d1 9.5 
					irtb0_d2 9.5 irtb1_d2 9.5 irtb2_d2 9.5 irtb3_d2 9.5
					b0Parm1Str $8. b0Parm2Str $8. b1Parm1Str $8. b1Parm2Str $8. b2Parm1Str $8. b2Parm2Str $8.
					b3Parm1Str $8. b3Parm2Str $8. cParm1Str $1. cParm2Str $1.	 
					V2InputParam $88. SegId $88. SegFrmId $88.;
		%if %upcase(&TSubTyp.)=IAB or %upcase(&TSubTyp.)=FIAB or &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			if Item_Position = 1 then V2InputParam = 'Multiple ItemIds Allowed Per Segment';
			else V2InputParam = '';
			/*	These are exceptional tests	*/
			if (("&TSubTyp.-&Subj.-&IABShortTitle.-&Grd.-&_AcadYear_." in (&ExceptionalTestList.))
						and (Seg_Position = 2)) then Seg_Position = 1 ;
		/*	put 'SegmentPosition: ' SegmentPosition;	*/
			if Seg_Position = 1 then do;
				SegId = "&_SegmentId_.";
				SegFrmId = "&_SegmentFormId_.";
			end;
			else if Seg_Position = 2 then do;
				SegId = "&_SegmentIdB_.";
				SegFrmId = "&_SegmentFormIdB_.";
			end;
		%end;		/*	TSubTyp is either IAB or FIAB	or Practice or Training	*/
		%else %if %upcase(&TSubTyp.)=ICA %then %do;
			%if %upcase(&Subj.)=ELA %then %do;
				if Short_Title = 'FIXED' then do;
					SegId = "&_SegmentId_.";
					SegFrmId = "&_SegmentFormId_.";
					if seg_Position = 1 and Item_Position = 1 then V2InputParam = 'Multiple ItemIds Allowed Per Segment';
					else V2InputParam = '';
				end;
				else if Short_Title = 'PT' then do;
					V2InputParam = 'Multiple ItemIds Allowed Per Segment';
					if Seg_Description = 'PT1' then do;
						SegId = "&_SegmentId2_.";
						SegFrmId = "&_SegmentFormId2_.";
					end;
					else if Seg_Description = 'PT2' then do;
						SegId = "&_SegmentId2B_.";
						SegFrmId = "&_SegmentFormId2B_.";
					end;
				end;
			%end;
			%else %if %upcase(&Subj.)=MATH %then %do;
				if Short_Title = 'FIXED' then do;
					if Item_Position = 1 then V2InputParam = 'Multiple ItemIds Allowed Per Segment';
					else V2InputParam = '';
					if Seg_Position = 1 then do;
						SegId = "&_SegmentId_.";
						SegFrmId = "&_SegmentFormId_.";
					end;
					else if Seg_Position = 2 then do;
						SegId = "&_SegmentIdB_.";
						SegFrmId = "&_SegmentFormIdB_.";
					end;
				end;
				else if Short_Title = 'PT' then do;
					if Item_Position = 1 then V2InputParam = 'Multiple ItemIds Allowed Per Segment';
					else V2InputParam = '';
					SegId = "&_SegmentId2_.";
					SegFrmId = "&_SegmentFormId2_.";
				end;
			%end;
		%end;	/* TSubType is ICA	*/
		%if &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			if max_rubric_d1 =. then max_rubric_d1 = 1;
		%end;
		if compress(Recoding_d1) = '' and max_rubric_d1 = . then max_rubric_d1 = max_score_d1;
		if compress(Recoding_d2) = '' and max_rubric_d2 = . then max_rubric_d2 = Max_score_d2;
		%SetIRTModel(max_rubric_d1, IRTModel1);
		%SetIRTModel(max_rubric_d2, IRTModel2);
		if max_rubric_d1 = . then MaxRubStrd1 = '';		else MaxRubStrd1 = compress(max_rubric_d1);
		if max_rubric_d2 = . then MaxRubStrd2 = '';		else MaxRubStrd2 = compress(max_rubric_d2);
		if ItemType='wer' then do;
			Scr1Dim = 'C';		Scr2Dim = 'D';
		end;
		else do;
			Scr1Dim = '';			Scr2Dim = '';
		end;
		%if &TSubTyp.=Practice or &TSubTyp.=Training %then %do;
			if irt_a_d1 =. then irt_a_d1 = 1;
			if irt_b_d1 =. then irt_b_d1 = 1;
			aparm1Str = compress(irt_a_d1);
		%end;
		%else %do;
			if irt_a_d1 =. then aparm1Str = '';	else aparm1Str = compress(irt_a_d1);
			if irt_a_d2 =. then aparm2Str = '';	else aparm2Str = compress(irt_a_d2);
		%end;
		if IRTModel1='IRT3PLn' then do;
			bparm1Str=compress(irt_b_d1);					cParm1Str='0';
		end;
		else do;
			bparm1Str='';					cParm1Str='';
			if irt_step_2_d1 =. then irtb0_d1=.;			else irtb0_d1 = irt_b_d1 - irt_step_2_d1;
			if irt_step_3_d1 =. then irtb1_d1=.;			else irtb1_d1 = irt_b_d1 - irt_step_3_d1;
			if irt_step_4_d1 =. then irtb2_d1=.;			else irtb2_d1 = irt_b_d1 - irt_step_4_d1;
			if irt_step_5_d1 =. then irtb3_d1=.;			else irtb3_d1 = irt_b_d1 - irt_step_5_d1;
			if irtb0_d1 =. then b0Parm1Str='';	else b0Parm1Str = compress(irtb0_d1);
			if irtb1_d1 =. then b1Parm1Str='';	else b1Parm1Str = compress(irtb1_d1);
			if irtb2_d1 =. then b2Parm1Str='';	else b2Parm1Str = compress(irtb2_d1);
			if irtb3_d1 =. then b3Parm1Str='';	else b3Parm1Str = compress(irtb3_d1);
		end;
		if IRTModel2='IRT3PLn' then do;
			bparm2Str=compress(irtb_d2);					cParm2Str='0';
		end;
		else do;
			bparm2Str='';					cParm2Str='';
			if irt_step_2_d2 =. then irtb0_d2=.;			else irtb0_d2 = irt_b_d2 - irt_step_2_d2;
			if irt_step_3_d2 =. then irtb1_d2=.;			else irtb1_d2 = irt_b_d2 - irt_step_3_d2;
			if irt_step_4_d2 =. then irtb2_d2=.;			else irtb2_d2 = irt_b_d2 - irt_step_4_d2;
			if irt_step_5_d2 =. then irtb3_d2=.;			else irtb3_d2 = irt_b_d2 - irt_step_5_d2;
			if irtb0_d2 =. then b0Parm2Str='';	else b0Parm2Str = compress(irtb0_d2);
			if irtb1_d2 =. then b1Parm2Str='';	else b1Parm2Str = compress(irtb1_d2);
			if irtb2_d2 =. then b2Parm2Str='';	else b2Parm2Str = compress(irtb2_d2);
			if irtb3_d2 =. then b3Parm2Str='';	else b3Parm2Str = compress(irtb3_d2);
		end;
		weight1 = '1';
		if max_rubric_d2 =. then weight2 = '';	else weight2 = '1';
	/*U	put 'SegmentPosition: ' SegmentPosition;	*/
	run;
	%TransMac(DSName=TDF_DataSF, VarName=V2InputParam, Prefx=V2InPrm);
	%TransMac(DSName=TDF_DataSF, VarName=SegId, Prefx=sgid);
	%TransMac(DSName=TDF_DataSF, VarName=SegFrmId, Prefx=sgfid);
	%TransMac(DSName=TDF_Data, VarName=Item_Id, Prefx=itid);
	%TransMac(DSName=TDF_DataSF, VarName=Seg_Position, Prefx=sgpo);
/*	%do jitm=1 %to &NumItems.;
		%put segpos&jitm. = &&sgpo&jitm..;
	%end;	*/
	%TransMac(DSName=TDF_Data, VarName=item_position, Prefx=itpo);
	%TransMac(DSName=TDF_DataSF, VarName=IRTModel1, Prefx=irt1mod);
	%TransMac(DSName=TDF_DataSF, VarName=IRTModel2, Prefx=irt2mod);
	%TransMac(DSName=TDF_DataSF, VarName=MaxRubStrd1, Prefx=max1pnt);
	%TransMac(DSName=TDF_DataSF, VarName=MaxRubStrd2, Prefx=max2pnt);
	%TransMac(DSName=TDF_DataSF, VarName=Scr1Dim, Prefx=scr1dm);
	%TransMac(DSName=TDF_DataSF, VarName=Scr2Dim, Prefx=scr2dm);
	%TransMac(DSName=TDF_DataSF, VarName=weight1, Prefx=wg1t);
	%TransMac(DSName=TDF_DataSF, VarName=weight2, Prefx=wg2t);
	%TransMac(DSName=TDF_DataSF, VarName=aparm1Str, Prefx=a1st);
	%TransMac(DSName=TDF_DataSF, VarName=aparm2Str, Prefx=a2st);
	%TransMac(DSName=TDF_DataSF, VarName=bparm1Str, Prefx=b1st);
	%TransMac(DSName=TDF_DataSF, VarName=bparm2Str, Prefx=b2st);
	%TransMac(DSName=TDF_DataSF, VarName=b0parm1Str, Prefx=b01st);
	%TransMac(DSName=TDF_DataSF, VarName=b0parm2Str, Prefx=b02st);
	%TransMac(DSName=TDF_DataSF, VarName=b1parm1Str, Prefx=b11st);
	%TransMac(DSName=TDF_DataSF, VarName=b1parm2Str, Prefx=b12st);
	%TransMac(DSName=TDF_DataSF, VarName=b2parm1Str, Prefx=b21st);
	%TransMac(DSName=TDF_DataSF, VarName=b2parm2Str, Prefx=b22st);
	%TransMac(DSName=TDF_DataSF, VarName=b3parm1Str, Prefx=b31st);
	%TransMac(DSName=TDF_DataSF, VarName=b3parm2Str, Prefx=b32st);
	%TransMac(DSName=TDF_DataSF, VarName=cparm1Str, Prefx=c1st);
	%TransMac(DSName=TDF_DataSF, VarName=cparm2Str, Prefx=c2st);
	data SegmentFormsData;
		set SrcData.segmentFormsTemplate;
		length InputParam $ 88;
		format InputParam $88.;
/*	if InputVar = 'SegmentId' then InputParam = "&_SegmentId_.";
		if InputVar = 'SegmentFormId' then InputParam = "&_SegmentFormId_.";	*/
		if InputVar = 'SegmentId' then InputParam = "&sgid1.";
		if InputVar = 'SegmentFormId' then InputParam = "&sgfid1.";
		if InputVar = 'SegmentFormCohort' then InputParam = 'Default';
		if InputVar = 'SegmentFormPosition' then InputParam = "&sgpo1.";
		if InputVar = 'ItemPosition' then InputParam = "&itpo1.";
		if InputVar = 'ItemId' then InputParam = "&itid1.";
		if InputVar = 'ItemEnglishPresentation' then InputParam = 'TRUE';
		if InputVar = 'ItemBraillePresentation' then InputParam = 'TRUE';
		if InputVar = 'ItemSpanishPresentation' then InputParam = "&_CntSpanPresTF_.";
		%do srs=1 %to 2;
			if InputVar = "MeasurementModel_&srs." then InputParam = "&&&irt&srs.mod1.";
			if InputVar = "ScorePoints_&srs." then InputParam = "&&&max&srs.pnt1.";
			if InputVar = "Dimension_&srs." then InputParam = "&&&scr&srs.dm1.";
			if InputVar = "Weight_&srs." then InputParam = "&&&wg&srs.t1.";
			if InputVar = "a_&srs." then InputParam = "&&&a&srs.st1.";
			if InputVar = "b_&srs." then InputParam = "&&&b&srs.st1.";
			if InputVar = "b0_&srs." then InputParam = "&&&b0&srs.st1.";
			if InputVar = "b1_&srs." then InputParam = "&&&b1&srs.st1.";
			if InputVar = "b2_&srs." then InputParam = "&&&b2&srs.st1.";
			if InputVar = "b3_&srs." then InputParam = "&&&b3&srs.st1.";
			if InputVar = "c_&srs." then InputParam = "&&&c&srs.st1.";
		%end;
		%do Itms=2 %to &NumItems.;
			format InputParam&Itms. $88.;
			if InputVarDesc = 'Input Data Values and Descriptions' then InputParam&Itms. = "&&V2InPrm&Itms..";			/*	Conditionally set this to the top header value	*/
			if InputVar = 'Input Variable' then InputParam&Itms. = 'Input Parameter';
			if InputVar = 'SegmentId' then InputParam&Itms. = "&&sgid&Itms..";			/*	Conditionally set this to the other Segment IDs	*/
			if InputVar = 'SegmentFormId' then InputParam&Itms. = "&&sgfid&Itms..";		/*	Conditionally set this to the other Segment Form IDs	*/
			if InputVar = 'SegmentFormCohort' then InputParam&Itms. = 'Default';
			if InputVar = 'SegmentFormPosition' then InputParam&Itms. = "&&sgpo&Itms..";
			if InputVar = 'ItemPosition' then InputParam&Itms. = "&&itpo&Itms..";
			if InputVar = 'ItemId' then InputParam&Itms. = "&&itid&Itms..";
			if InputVar = 'ItemEnglishPresentation' then InputParam&Itms. = 'TRUE';
			if InputVar = 'ItemBraillePresentation' then InputParam&Itms. = 'TRUE';
			if InputVar = 'ItemSpanishPresentation' then InputParam&Itms. = "&_CntSpanPresTF_.";
			%do srs=1 %to 2;
				if InputVar = "MeasurementModel_&srs." then InputParam&Itms. = "&&&irt&srs.mod&Itms..";
				if InputVar = "ScorePoints_&srs." then InputParam&Itms. = "&&&max&srs.pnt&Itms..";
				if InputVar = "Dimension_&srs." then InputParam&Itms. = "&&&scr&srs.dm&Itms..";
				if InputVar = "Weight_&srs." then InputParam&Itms. = "&&&wg&srs.t&Itms..";
				if InputVar = "a_&srs." then InputParam&Itms. = "&&&a&srs.st&Itms..";
				if InputVar = "b_&srs." then InputParam&Itms. = "&&&b&srs.st&Itms..";
				if InputVar = "b0_&srs." then InputParam&Itms. = "&&&b0&srs.st&Itms..";
				if InputVar = "b1_&srs." then InputParam&Itms. = "&&&b1&srs.st&Itms..";
				if InputVar = "b2_&srs." then InputParam&Itms. = "&&&b2&srs.st&Itms..";
				if InputVar = "b3_&srs." then InputParam&Itms. = "&&&b3&srs.st&Itms..";
				if InputVar = "c_&srs." then InputParam&Itms. = "&&&c&srs.st&Itms..";
			%end;
		%end;
	run;
	data XLOut.SegmentForms;
		set SegmentFormsData;
	run;
	/*** === Tools === ***/
	proc sql;
		create table ToolsData as
		select * from SrcData.ToolsTemplate
		%if &Subj. = MATH %then %do;
			where InputVar not like 'ToolOption%_1_5'
		%end;
		;
	quit;
	data ToolsData;
		set ToolsData;
		if InputVar not in ('', 'Input Variable') then InputParam = '';	/*	This blanks out the existing tool content after the top two rows	*/
	run;
	data XLOut.Tools;
		set ToolsData;
	run;
%mend Cre8OutXL;

%macro PS1FnctnHead;
	OutLyn = '$objExcel = new-object -comobject excel.application';		put OutLyn;
	OutLyn = '$objExcel.DisplayAlerts = $false';		put OutLyn;
	OutLyn = '$file = "'||"&WrkHere.\OutFiles\"||"&_FylName_."||'"';		put OutLyn;
%mend PS1FnctnHead;
%macro PS1FnctnTail;
	OutLyn = '$worksheet1 = $workbook.worksheets.item(1)';		put OutLyn;
	OutLyn = '$worksheet1.Activate()';		put OutLyn;
	OutLyn = '$workbook.save()';		put OutLyn;
	OutLyn = '$workbook.close()';		put OutLyn;
%mend PS1FnctnTail;
%macro WrytPSLFylsAndBAT(TSubTyp, tdfvrsn, Subj, Grd, IABShortTitle, _FylName_);
	%global ExecSegMrg;
	/*	This is used for the SegementForms header merge logic	*/
	data SerHdrAddr;
		format srl 3.0 HdrAd $3.;
		srl=1; HdrAd='E'; output;		srl=2; HdrAd='F'; output;		srl=3; HdrAd='G'; output;		srl=4; HdrAd='H'; output;
		srl=5; HdrAd='I'; output;		srl=6; HdrAd='J'; output;		srl=7; HdrAd='K'; output;		srl=8; HdrAd='L'; output;
		srl=9; HdrAd='M'; output;		srl=10; HdrAd='N'; output;		srl=11; HdrAd='O'; output;		srl=12; HdrAd='P'; output;
		srl=13; HdrAd='Q'; output;		srl=14; HdrAd='R'; output;		srl=15; HdrAd='S'; output;		srl=16; HdrAd='T'; output;
		srl=17; HdrAd='U'; output;		srl=18; HdrAd='V'; output;		srl=19; HdrAd='W'; output;		srl=20; HdrAd='X'; output;
		srl=21; HdrAd='Y'; output;		srl=22; HdrAd='Z'; output;		srl=23; HdrAd='AA'; output;		srl=24; HdrAd='AB'; output;
		srl=25; HdrAd='AC'; output;		srl=26; HdrAd='AD'; output;		srl=27; HdrAd='AE'; output;		srl=28; HdrAd='AF'; output;
		srl=29; HdrAd='AG'; output;		srl=30; HdrAd='AH'; output;		srl=31; HdrAd='AI'; output;		srl=32; HdrAd='AJ'; output;
		srl=33; HdrAd='AK'; output;		srl=34; HdrAd='AL'; output;		srl=35; HdrAd='AM'; output;		srl=36; HdrAd='AN'; output;
		srl=37; HdrAd='AO'; output;		srl=38; HdrAd='AP'; output;		srl=39; HdrAd='AQ'; output;		srl=40; HdrAd='AR'; output;
		srl=41; HdrAd='AS'; output;		srl=42; HdrAd='AT'; output;		srl=43; HdrAd='AU'; output;		srl=44; HdrAd='AV'; output;
		srl=45; HdrAd='AW'; output;		srl=46; HdrAd='AX'; output;		srl=47; HdrAd='AY'; output;		srl=48; HdrAd='AZ'; output;
	run;
	%TransMac(DSName=SerHdrAddr, VarName=HdrAd, Prefx=hda);
	/*	Write first, main ps1 file and execute it 	*/
	data _null_;
		file "&WrkHere.\FixUpXLfromSAS.ps1" ;
		format OutLyn $184.;
		%PS1FnctnHead;
		OutLyn = '$workbook = $objExcel.workbooks.open($file)';		put OutLyn;
		OutLyn = 'For ($i=1; $i -le 6; $i++) {';		put OutLyn;
		OutLyn = '	$worksheet = $workbook.worksheets.item($i)';		put OutLyn;
		OutLyn = '	$worksheet.Rows(1).Delete() | Out-Null';		put OutLyn;
		OutLyn = '	$worksheet.UsedRange.Columns.Autofit() | Out-Null';		put OutLyn;
		OutLyn = '	$worksheet.Activate()';		put OutLyn;
		OutLyn = '	$MergeCells = $worksheet.Range("A1:B1")';		put OutLyn;
		OutLyn = '	$MergeCells.Select() | Out-Null';		put OutLyn;
		OutLyn = '	$MergeCells.MergeCells = $true';		put OutLyn;
		OutLyn = '	$MergeCells = $worksheet.Range("C1:D1")';		put OutLyn;
		OutLyn = '	$MergeCells.Select() | Out-Null';		put OutLyn;
		OutLyn = '	$MergeCells.MergeCells = $true';		put OutLyn;
		OutLyn = '	$HomeCells = $worksheet.Range("A1")';		put OutLyn;
		OutLyn = '	$HomeCells.Select() | Out-Null';		put OutLyn;
		OutLyn = '	$HomeCells.Activate()';		put OutLyn;
		OutLyn = '}';		put OutLyn;
		%PS1FnctnTail;
		OutLyn = '$objExcel.quit()';		put OutLyn;
	run;
	/* Write script that merges scoring page header */
	%if %upcase(&TSubTyp.)=IAB or %upcase(&TSubTyp.)=FIAB or &TSubTyp.=Practice or &TSubTyp.=Training %then %let FldRng=E1:I1;
	%else %if %upcase(&TSubTyp.)=ICA %then %do;
		%if %upcase(&Subj.)=ELA %then %let FldRng=E1:AJ1;
		%else %if %upcase(&Subj.)=MATH %then %let FldRng=E1:AD1;
	%end;
	data _null_;
		file "&WrkHere.\MergeScoringHdr.ps1" ;
		format OutLyn $184.;
		%PS1FnctnHead;
		OutLyn = '$workbook = $objExcel.workbooks.open($file)';		put OutLyn;
		OutLyn = '$worksheet = $workbook.worksheets.item(2)';		put OutLyn;
		OutLyn = '$worksheet.Activate()';		put OutLyn;
		OutLyn = '$MergeCells = $worksheet.Range("'||"&FldRng."||'")';		put OutLyn;
		OutLyn = '$MergeCells.Select() | Out-Null';		put OutLyn;
		OutLyn = '$MergeCells.MergeCells = $true';		put OutLyn;
		OutLyn = '$HomeCells = $worksheet.Range("A1")';		put OutLyn;
		OutLyn = '$HomeCells.Select() | Out-Null';		put OutLyn;
		OutLyn = '$HomeCells.Activate()';		put OutLyn;
		%PS1FnctnTail;
		OutLyn = '$objExcel.quit()';		put OutLyn;
	run;
	/* Conditionally Write script that merges E1:F1 on Tests page	*/
	%if &NumShrtTitles=2 %then %do;
		data _null_;
			file "&WrkHere.\MergeTestsHdr.ps1";
			format OutLyn $184.;
			%PS1FnctnHead;
			OutLyn = '$workbook = $objExcel.workbooks.open($file)';		put OutLyn;
			OutLyn = '$worksheet = $workbook.worksheets.item(3)';		put OutLyn;
			OutLyn = '$worksheet.Activate()';		put OutLyn;
			OutLyn = '$MergeCells = $worksheet.Range("E1:F1")';		put OutLyn;
			OutLyn = '$MergeCells.Select() | Out-Null';		put OutLyn;
			OutLyn = '$MergeCells.MergeCells = $true';		put OutLyn;
			OutLyn = '$HomeCells = $worksheet.Range("A1")';		put OutLyn;
			OutLyn = '$HomeCells.Select() | Out-Null';		put OutLyn;
			OutLyn = '$HomeCells.Activate()';		put OutLyn;
			%PS1FnctnTail;
			OutLyn = '$objExcel.quit()';		put OutLyn;
		run;
	%end;
	/* Conditionally write script that merges Segements page header	*/
	%macro SegmentsPage(SScrRng);
		data _null_;
			file "&WrkHere.\MergeSegments.ps1";
			format OutLyn $184.;
			%PS1FnctnHead;
			OutLyn = '$workbook = $objExcel.workbooks.open($file)';		put OutLyn;
			OutLyn = '$worksheet = $workbook.worksheets.item(4)';		put OutLyn;
			OutLyn = '$worksheet.Activate()';		put OutLyn;
			OutLyn = '$MergeCells = $worksheet.Range("'||"&SScrRng."||'")';		put OutLyn;
			OutLyn = '$MergeCells.Select() | Out-Null';		put OutLyn;
			OutLyn = '$MergeCells.MergeCells = $true';		put OutLyn;
			OutLyn = '$HomeCells = $worksheet.Range("A1")';		put OutLyn;
			OutLyn = '$HomeCells.Select() | Out-Null';		put OutLyn;
			OutLyn = '$HomeCells.Activate()';		put OutLyn;
			%PS1FnctnTail;
			OutLyn = '$objExcel.quit()';		put OutLyn;
		run;
	%mend SegmentsPage;
	%macro ExecSP;
		%if %upcase(&Subj.) = MATH and %eval(&Grd. > 5) %then %do;
			%SegmentsPage(E1:F1);
			%let ExecSegMrg = yes;
		%end;
		%else %if %upcase(&Subj.) = ELA and %upcase(&TSubTyp.) = ICA %then %do;
			%SegmentsPage(F1:G1);
			%let ExecSegMrg = yes;
		%end;
		%else %if %upcase(&Subj.) = ELA and %upcase(&TSubTyp.) = IAB and %eval(&Grd. > 5) %then %do;
			%SegmentsPage(E1:F1);
			%let ExecSegMrg = yes;
		%end;
		%else %if &TSubTyp.=Practice and %upcase(&Subj.)=ELA and "&IABShortTitle."="PRAC-Perf" %then %do;
			%SegmentsPage(E1:F1);
			%let ExecSegMrg = yes;
		%end;
		%else %if &TSubTyp.=Training and %upcase(&Subj.)=MATH and %eval(&Grd. > 5) %then %do;
			%SegmentsPage(E1:F1);
			%let ExecSegMrg = yes;
		%end;
		%else %do;
			%let ExecSegMrg = no;
		%end;
	%mend ExecSP;
		%ExecSP;
	/*	Write script that measures number of items in segments and how many Segments	*/
	%macro MergeSFP(HdrRng);
		OutLyn = '$MergeCells = $worksheet.Range("'||"&HdrRng."||'")';		put OutLyn;
		OutLyn = '$MergeCells.Select() | Out-Null';		put OutLyn;
		OutLyn = '$MergeCells.MergeCells = $true';		put OutLyn;
	%mend MergeSFP;
	%macro MSegFrmsPage;
		proc sql;
			create table StFtSdData as
			select distinct Short_Title, Full_Title, Seg_Description
			from TDF_Data
			order by Short_Title, Full_Title, Seg_Description
			%if %upcase(&Subj.)=MATH %then %do;
				descending
			%end;
			;
			create table StFtData as
			select distinct Short_Title, Full_Title
			from TDF_Data
			order by Short_Title;
		quit;
		%TotalRec(inDS=StFtSdData);
		%let NumItmGrps=&NumObs.;
		%if &NumItmGrps=1 %then %do;
			%TotalRec(inDS=TDF_Data);
			%let NumItms=&NumObs.;
		%end;
		%else %if &NumItmGrps=2 %then %do;
			%TransMac(DSName=StFtSdData, Varname=Short_Title, Prefx=st);
			%TransMac(DSName=StFtSdData, Varname=Seg_Description, Prefx=sd);
			%do dsn=1 %to 2;
				data ItmGrp&dsn.;
					set TDF_Data;
					if Short_Title="&&st&dsn.." and Seg_Description="&&sd&dsn..";
				run;
				%TotalRec(inDS=ItmGrp&dsn.);
				%let Ni_Ig_&dsn. = &NumObs.;
			%end;
			%let ig1s=1;																		%let ig1e=&NI_Ig_1.;
			%let ig2s=%eval(&NI_Ig_1. + 1);									%let ig2e=%eval(&NI_Ig_1. + &NI_Ig_2.);
		%end;
		%else %if &NumItmGrps=3 %then %do;
			%TransMac(DSName=StFtSdData, Varname=Short_Title, Prefx=st);
			%TransMac(DSName=StFtSdData, Varname=Seg_Description, Prefx=sd);
			%do dsn=1 %to 3;
				data ItmGrp&dsn.;
					set TDF_Data;
					if Short_Title="&&st&dsn.." and Seg_Description="&&sd&dsn..";
				run;
				%TotalRec(inDS=ItmGrp&dsn.);
				%let Ni_Ig_&dsn. = &NumObs.;
			%end;
			%let ig1s=1;																		%let ig1e=&NI_Ig_1.;
			%let ig2s=%eval(&NI_Ig_1. + 1);									%let ig2e=%eval(&NI_Ig_1. + &NI_Ig_2.);
			%let ig3s=%eval(&NI_Ig_1. + &NI_Ig_2. + 1);			%let ig3e=%eval(&NI_Ig_1. + &NI_Ig_2. + &NI_Ig_3.);
		%end;
		data _null_;
			file "&WrkHere.\MergeSegmentForms.ps1";
			format OutLyn $184.;
			%PS1FnctnHead;
			OutLyn = '$workbook = $objExcel.workbooks.open($file)';		put OutLyn;
			OutLyn = '$worksheet = $workbook.worksheets.item(5)';		put OutLyn;
			OutLyn = '$worksheet.Activate()';		put OutLyn;
			%if &NumItmGrps=1 %then %do;
				%MergeSFP(E1:&&hda&NumItms..1);
			%end;
			%else %if &NumItmGrps=2 %then %do;
				%MergeSFP(&&hda&ig1s..1:&&hda&ig1e..1);
				%MergeSFP(&&hda&ig2s..1:&&hda&ig2e..1);
			%end;
			%else %if &NumItmGrps=3 %then %do;
				%MergeSFP(&&hda&ig1s..1:&&hda&ig1e..1);
				%MergeSFP(&&hda&ig2s..1:&&hda&ig2e..1);
				%MergeSFP(&&hda&ig3s..1:&&hda&ig3e..1);
			%end;
			OutLyn = '$HomeCells = $worksheet.Range("A1")';		put OutLyn;
			OutLyn = '$HomeCells.Select() | Out-Null';		put OutLyn;
			OutLyn = '$HomeCells.Activate()';		put OutLyn;
			%PS1FnctnTail;
			OutLyn = '$objExcel.quit()';		put OutLyn;
		run;
	%mend MSegFrmsPage;
		%MSegFrmsPage;
	/* Write BAT file that executes the ps1 file(s) 	*/
	data _null_;
		file "&WrkHere.\AdjustXLFmt.bat" ;
		format OutLyn $184.;
		OutLyn = 'cls';		put OutLyn;
		OutLyn = 'echo off';		put OutLyn;
		OutLyn = 'echo ########## Subject: '||"&Subj."||' - Grade: '||"&Grd."||' - Short Title: '||"&IABShortTitle."||' ##########';		put OutLyn;
		OutLyn = 'echo ########## Batch File: AdjustXLFmt.bat ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ########## powershell job executing (FixUpXLfromSAS.ps1) ##########';		put OutLyn;
		OutLyn = 'powershell -File "'||"&WrkHere.\FixUpXLfromSAS.ps1"||'"';		put OutLyn;
		OutLyn = 'echo ########## powershell job completed (FixUpXLfromSAS.ps1) ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ########## powershell job executing (MergeScoringHdr.ps1) ##########';		put OutLyn;
		OutLyn = 'powershell -File "'||"&WrkHere.\MergeScoringHdr.ps1"||'"';		put OutLyn;
		OutLyn = 'echo ########## powershell job completed (MergeScoringHdr.ps1) ##########';		put OutLyn;
		%if &NumShrtTitles=2 %then %do;
			OutLyn = 'echo ##########';		put OutLyn;
			OutLyn = 'echo ##########';		put OutLyn;
			OutLyn = 'echo ########## powershell job executing (MergeTestsHdr.ps1) ##########';		put OutLyn;
			OutLyn = 'powershell -File "'||"&WrkHere.\MergeTestsHdr.ps1"||'"';		put OutLyn;
			OutLyn = 'echo ########## powershell job completed (MergeTestsHdr.ps1) ##########';		put OutLyn;
		%end;
		%if &ExecSegMrg. = yes %then %do;
			OutLyn = 'echo ##########';		put OutLyn;
			OutLyn = 'echo ##########';		put OutLyn;
			OutLyn = 'echo ########## powershell job executing (MergeSegments.ps1) ##########';		put OutLyn;
			OutLyn = 'powershell -File "'||"&WrkHere.\MergeSegments.ps1"||'"';		put OutLyn;
			OutLyn = 'echo ########## powershell job completed (MergeSegments.ps1) ##########';		put OutLyn;
		%end;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ########## powershell job executing (MergeSegmentForms.ps1) ##########';		put OutLyn;
		OutLyn = 'powershell -File "'||"&WrkHere.\MergeSegmentForms.ps1"||'"';		put OutLyn;
		OutLyn = 'echo ########## powershell job completed (MergeSegmentForms.ps1) ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
		OutLyn = 'echo ##########';		put OutLyn;
	run;
	X 'AdjustXLFmt' ;
	
	data _null_;
		file "&WrkHere.\DelBAKFiles.bat";
		format OutLyn $184.;
		OutLyn = "echo ##### Removing BAK (orphan) files #####";		put OutLyn;
		OutLyn = 'del "'||"&WrkHere.\OutFiles\&_FylName_..bak"||'"';		put OutLyn;
	run;
	X "DelBAKFiles" ;
	
%mend WrytPSLFylsAndBAT;

%macro RunFullProc(TSubTyp, tdfvrsn, vrsn, Subj, Grd, IABShortTitle, _AcadYear_);
	%Cre8TstSegNames(&TSubTyp., &tdfvrsn., &Subj., &Grd., &IABShortTitle., &_AcadYear_., 0);
	%Cre8OutXL(&TSubTyp., &tdfvrsn., &vrsn., &Subj., &Grd., &IABShortTitle, &_AcadYear_., yes);
	/* ods excel close;	*/
	%WrytPSLFylsAndBAT(&TSubTyp., &tdfvrsn., &Subj., &Grd., &IABShortTitle., &_FylName_.);
%mend RunFullProc;

%macro RunFullICAProc;
	%RunFullProc(ica, 89, 1, ela, 3, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 4, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 5, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 6, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 7, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 8, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 9, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 10, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, ela, 11, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 3, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 4, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 5, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 6, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 7, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 8, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 9, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 10, FIXED, 2022-2023);
	%RunFullProc(ica, 89, 1, math, 11, FIXED, 2022-2023);
%mend RunFullICAProc;
%*	%RunFullICAProc;

%macro RunFullIABProc;
	%RunFullProc(iab, 91, 1, ela, 3, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 3, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 3, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 3, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 3, Revision, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 4, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 4, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 4, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 4, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 4, Revision, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 5, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 5, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 5, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 5, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 5, Revision, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 6, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 6, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 6, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 6, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 6, Revision, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 7, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 7, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 7, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 7, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 7, Revision, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 8, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 8, EditRevise, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 8, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 8, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 8, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 11, BriefWrites, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 11, ReadInfo, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 11, ReadLit, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 11, Research, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 11, Revision, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 3, MD, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 3, OA, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 4, MD, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 4, NBT, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 4, NF, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 4, OA, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 5, MD, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 5, NBT, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 5, NF, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 5, OA, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 6, EE, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 6, NS, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 7, EE, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 7, G, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 8, EE, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 8, G, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 11, AlgLin, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 11, AlgQuad, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 11, GCO, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 11, GMD, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 3, Perf-Opinion-Beetles, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 4, Perf-Opinion-Reptiles, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 5, Perf-Informational-Recycling, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 6, Perf-Argument-Multivitamins, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 7, Perf-Explanatory-MobileEdTech, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 8, Perf-Argument-MapsandTechnology, 2022-2023);
	%RunFullProc(iab, 91, 1, ela, 11, Perf-Explanatory-Marshmallow, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 3, Perf-OrderForm, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 4, Perf-AnimalJumping, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 5, Perf-TurtleHabitat, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 6, Perf-CellPhonePlan, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 6, Perf-FeedingTheGiraffe, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 7, Perf-CampingTasks, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 8, Perf-BaseballTickets, 2022-2023);
	%RunFullProc(iab, 91, 1, math, 11, Perf-TeenDrivingRest, 2022-2023);
%mend RunFullIABProc;
%*	%RunFullIABProc;

%macro RunFullFIABProc;
%*	%RunFullProc(fiab, 91, 1, ela, 3, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, WriteInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 3, WriteOpinion, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, WriteInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 4, WriteOpinion, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, WriteInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 5, WriteOpinion, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, WriteArgue, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, WriteExplanatory, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 6, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, WriteArgue, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, WriteExplanatory, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 7, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, WriteArgue, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, WriteExplanatory, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 8, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, Editing, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, LangVocab, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, ListenInterpret, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, ResearchAnalyzeInfo, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, ResearchEvidence, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, ResearchInterpInteg, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, WriteArgue, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, WriteExplanatory, 2022-2023);
	%RunFullProc(fiab, 91, 1, ela, 11, WriteNarrative, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, G, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, NBT, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, NF, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, TAOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, TBOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, TCOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, TDOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, TGMD, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 3, TIJMD, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, G, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TAOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TBOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TCOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TDNBT, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TENBT, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TFNF, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, TGNF, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 4, THNF, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, G, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, TAOA, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, TCNBT, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, TDNBT, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, TENF, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, TGMD, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 5, TIMD, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, G, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, RP, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, SP, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, TBNS, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, TCNS, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, TDNSRat, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, TEEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, TFEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 6, TGEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, NS, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, RP, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, SP, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, TCEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, TDEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, TEG, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 7, TFG, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, EE2, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, F, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, NS, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, TCEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, TDEE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, TGG, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 8, TIG, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, GeoRightTriRatios, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, IF, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, NQ, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, SP, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, SSE, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, TGCEDLinExp, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, TGCEDQuad, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, THREI, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, TIREILinExp, 2022-2023);
	%RunFullProc(fiab, 91, 1, math, 11, TIREIQuad, 2022-2023);
%mend RunFullFIABProc;
%*	%RunFullFIABProc;