/*==================================================================================================*
 | Program	:	DevCATAdminData.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	From TDF (or pull list), develop data that will be written to XML for CAT Admin				|
 |						package.																																							|
 | Macros		: ... as well as small, often used tools from my toolbox.																|
 | Notes		:	Input datasets may vary based on time-frame.  From 18-19 onward test definition       |
 |						files represented the draft item pool.  Prior to that it was called the pull list.		|
 |						The IMRT data joined to TDF data for testitem poolproperty was gathered from IMRT			|
 |						by IMRT_Extract_keys_eItemTypes.sql and imrt_2_sasds.sas under the <<OneDrive>>\IMRT 	|
 |						folder.																																								|
 | Usage		:	Applicable to test packaging > summative > admin package(s)														|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2020 08 16		Initial development. 																															|
 |	2020 12 11		bpelem content is read from the CAT XML files by DevParseCATXMLAdmin.py						|
 |	2021 03 16		Split outputs between CAT and PT (and eventually SRC).  Also added tspc data.			|
 *==================================================================================================*/

%let OneDrvStub = C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC;
%let wrkHere = &OneDrvStub.\CATAdminPackage;
 
*** source data library for 18-19 *** ;
/*	libname TDFLib "&OneDrvStub.\SBTemp\FFConfig\2020-21";	*/

libname imrtLib "&OneDrvStub.\IMRT";

%* %let fldrYr = 2019_20;
%let fldrYr = 2022_23;

libname libHere "&wrkHere.";
libname lbHrCAT "&wrkHere.\CAT\&fldrYr.";
libname lbHrPT "&wrkHere.\PT\&fldrYr.";
* libname lbHrSRC "&wrkHere.\SRC";

%macro PubDateTime;
    %global pbt;
    %let time=%sysfunc(time(),timeampm9.);
    %let date=%sysfunc(date(),worddate12.);
    %let pbt=&date. at &time;
%mend PubDateTime;

%macro InteractionData;
	%SetDSLabel;
	data lbHrCAT.InterAction (label = "&DSLabel.");
		format itemType $6. subject $4. interaction $30. sbirt $40. ;
		itemType = 'MC';	subject = 'BOTH';		interaction = 'multipleChoice' ;
		sbirt = 'SR single response' ;	output;
		itemType = 'MS';	subject = 'BOTH';		interaction = 'multipleSelect' ;
		sbirt = 'SR multiple correct responses' ;	output;
		itemType = 'HTQO';	subject = 'ELA';		interaction = 'hotTextReorder' ;
		sbirt = 'Hot Text' ;	output;
		itemType = 'HTQS';	subject = 'ELA';		interaction = 'hotTextSelectable' ;
		sbirt = 'Hot Text' ;	output;
		/*	Note that the item type in the XML file has only item type of 'HTQ'	*/
		itemType = 'SA';	subject = 'BOTH';		interaction = 'textEntrySimple' ;
		sbirt = 'Short text' ;	output;
		itemType = 'MI';	subject = 'BOTH';		interaction = 'tableMatch' ;
		sbirt = 'Matching Tables variation T-F or Y-N' ;	output;
		itemType = 'EBSR';	subject = 'ELA';		interaction = 'multipleChoice multipleSelect' ;
		sbirt = 'EBSR' ;	output;
		itemType = 'GI';	subject = 'MATH';		interaction = 'grid' ;
		sbirt = '' ;	output;
		itemType = 'EQ';	subject = 'MATH';		interaction = 'equation' ;
		sbirt = '' ;	output;
		itemType = 'TI';	subject = 'MATH';		interaction = 'tableInput' ;
		sbirt = '' ;	output;
		label sbirt = 'Smarter Balanced Item Response Types';
	run;
	%GetSnow;
	Title "Contents of lbHrCAT.InterAction [&now.]";
	proc contents data=lbHrCAT.InterAction order=varnum;
	run;
	proc print data=lbHrCAT.InterAction;
	run;
%mend InteractionData;
%*	%InteractionData;

%macro bpelemVarFmtLst;
	subject $CHAR3.
	grade BEST2.
	SchoolYear $CHAR6.
	elementType $CHAR16.
	minOpItems BEST2.
	maxOpItems BEST2.
	minFtItems BEST1.
	maxFtItems BEST1.
	opItemCount BEST3.
	ftItemCount BEST1.
	id_uniqueId $CHAR56.
	id_name $CHAR36.
	version	BEST6.
%mend bpelemVarFmtLst;

%macro ISPPropVarFmtLst;
	segment 3.0
	subject $CHAR3.
	grade BEST2.
	SchoolYear $CHAR6.
	isp_bpElemId $CHAR56.
	isp_prop_count BEST2.
	isp_prop_name $CHAR31.
	isp_prop_value $CHAR16.
	isp_prop_label $CHAR184.
%mend ISPPropVarFmtLst;

%* %SubjGrd(MATH, 4, PT, 1, 1, 1, 1, 1, 1, 1);

%macro SubjGrd(Subj, Grd, CtPt, tspc, tipp, ppfd, stim, bpelem, ispPrp, itmGrp);
	%let trgt_TDF = libHere.tdf_2022_23_summative_v15;
	%let bpref1_stub = (SBAC)SBAC-GEN-SUM-UD-;
	%let bp_season = Spring;
	%let bp_year_range = 2022-2023;
	%let yr2Yr = 2223;
	%let ELA_version = 19045;		/*	<<<===---*<<<		These values are made up			<<<===---*<<<		*/
	%let MATH_version = 19616;	/*	<<<===---*<<<		These values are made up			<<<===---*<<<		*/
	%put Subj &Subj.;
	%put &Subj._Version &&&Subj._version.;
	%PubDateTime;
	%if &CtPt = PT %then %let UniqueIDScope = Perf;
	%else %let UniqueIDScope = &CtPt.;	/*	this resolves to CAT	*/
	%if &Subj. = MATH %then %let Subject = Mathematics;
	%else %let Subject = &Subj.;
	/*	testspecification identifier and properties	*/
	%if &tspc = 1 %then %do;	/*	refresh tspc datasets - top	*/
		data lbHr&CtPt..testspec_&CtPt._&Subj._&Grd._&yr2Yr.;
			format purpose $16. publisher $4. publishdate $24. pubversion $3.
					uniqueId $56. idName $48. idLabel $32. version 6.0 
					name $12. value $12. label $12. ;
			retain purpose publisher publishdate pubversion uniqueId idName idLabel version;
			purpose = 'administration';
			publisher = 'SBAC';
			publishdate = "&pbt.";
			pubversion = '1.0';
			uniqueId = compress("&bpref1_stub."||"&Subj."||'-'||"&UniqueIDScope."||'-'||"&Grd."||'-'||"&bp_season."||'-'||"&bp_year_range.");
			idName = compress(substr("&bpref1_stub.", 7)||"&Subj."||'-'||"&UniqueIDScope."||'-'||"&Grd.");
			%if &CtPt. = CAT %then %do;
				idLabel = ('SUMMATIVE: G'||compress("&Grd."||'-'||compress("&Subj.")||'-CAT'));
			%end;
			%else %do;
				idLabel = 'Grade '||compress("&Grd.")||" &Subject.";
			%end;
			version = &&&Subj._version.;
			name = 'subject';
			value = "&Subject.";
			label = "&Subject.";
			output;
			name = 'grade';
			value = "&Grd.";
			label = "grade &Grd.";
			output;
			name = 'type';
			value = 'summative';
			label = 'summative';
			output;
		run;
	%end;		/*	refresh tspc datasets - bottom	*/
	/*	testitem poolproperty - top	*/
	%if &tipp. = 1 %then %do;	 /* refresh tipp datasets - top	*/
		proc sql;
			/*	Begin by retrieving and setting TDSPoolFilter values 
					per item based on studentGrade and itemGrade		*/
			create table TDSPF as 
			select a.subject, a.item_Id, a.student_Grade, a.item_Grade,
				'OFFGRADE BELOW' format $16. as TDSPoolFilter_below ,
				'' format $16. as TDSPoolFilter_above 
			from &trgt_TDF. as a
			where upcase(a.subject) = "&Subj." and a.student_Grade = &Grd.
			/* Here is where I would branch for PT vs. CAT */
				and short_title = 'CAT' and a.item_Grade < a.student_Grade
			union
			select b.subject, b.item_Id, b.student_Grade, b.item_Grade,
				'' format $16. as TDSPoolFilter_below ,
				'OFFGRADE ABOVE' format $16. as TDSPoolFilter_above 
			from &trgt_TDF. as b
			where upcase(b.subject) = "&Subj." and b.student_Grade = &Grd.
				and short_title = 'CAT' and b.item_Grade > b.student_Grade;
			/*	Now add the above results to the rest of the testitem block data	*/
			create table ti_pp_&Subj._&Grd. as
			select tdf.item_Id, upcase(tdf.Item_Type) as Item_Type, tdf.ASL_Pool, tdf.Braille_Pool,
				tdf.Spanish_Pool, tdf.Translated_Glossary_Pool, tdf.claim2_detail,
				tdf.claim, tdf.SRC, tdf.target, tdf.dok, /*	imrt.p_ccss,	*/
			  tdf.DOK, tdf.Student_Grade, tdf.Item_Grade as Grade, tdf.Stim_Id as passageref, 
			  tdf.Passage_Length, imrt.answerKey as IATanswerKey, tdf.Allow_Calc, 
				intrad.interaction, tdspf.TDSPoolFilter_above,  tdspf.TDSPoolFilter_below,
				tdf.Scoring_Engine, tdf.Max_Score_d1 as scorePoints, tdf.IRT_a_d1, tdf.IRT_b_d1,
				tdf.irt_step_2_d1, tdf.irt_step_3_d1, tdf.irt_step_4_d1, tdf.irt_step_5_d1, tdf.Full_Title
			from &trgt_TDF. as tdf
			left join imrtLib.imrt_etypes_keys_20201206 as imrt 
				on tdf.item_Id = imrt.itemId
			left join lbHrCAT.interaction as intrad
				on compress(upcase(tdf.Item_Type)) = compress(intrad.itemType)
			left join TDSPF as tdspf  
			  on tdf.item_Id = tdspf.item_Id
			where compress(upcase(tdf.Subject)) = "&Subj." and tdf.Student_Grade = &Grd.;
		quit;
		Title "TDSPF";
		proc print data=TDSPF;
		run;
		proc sql;
			create table ti_pp_&Subj._&Grd._2 as
			select a.*, b.segment, 
				%do bpr = 1 %to 8;
					b.bpref_&bpr.,
				%end;
				b.bpref_9
			from ti_pp_&Subj._&Grd. as a
			left join libHere.itemBPRefs_&Subj._&Grd._&yr2Yr._&CtPt. as b
				on a.item_Id = b.itemId;
		quit;
		data testitem_pp_&Subj._&Grd._&yr2Yr. ;
			set ti_pp_&Subj._&Grd._2 ;
			format version 6.0 Answer_Key $3. Test_Pool $12. ; /* bpref1 $56. bpref2 $32. bpref3 $32.
						bpref4 $32. bpref5 $32. bpref6 $32. bpref7 $12. bpref8 $16.; */
			version = &&&Subj._version.;
			if scorePoints=1 then do;
				measModel = 'IRT3PLn';
				IRTc_d1 = 0;
			end;
			else do;
				measModel = 'IRTGPC';
				if scorePoints = 2 then do;
					IRTb0_d1 = IRT_b_d1 - irt_step_2_d1;
					IRTb1_d1 = IRT_b_d1 - irt_step_3_d1;
				end;
				else if scorePoints = 3 then do;
					IRTb0_d1 = IRT_b_d1 - irt_step_2_d1;
					IRTb1_d1 = IRT_b_d1 - irt_step_3_d1;
					IRTb2_d1 = IRT_b_d1 - irt_step_4_d1;
				end;
				else if scorePoints = 4 then do;
					IRTb0_d1 = IRT_b_d1 - irt_step_2_d1;
					IRTb1_d1 = IRT_b_d1 - irt_step_3_d1;
					IRTb2_d1 = IRT_b_d1 - irt_step_4_d1;
					IRTb3_d1 = IRT_b_d1 - irt_step_5_d1;
				end;
			end;
/**		bpref1 = compress("&bpref1_stub."||"&Grd."||'-'||"&bp_season."||'-'||"&bp_year_range.");
			**	bpref2	** ;
			bpref2 = '';
			if ShortTitle = 'BriefWrite' then do;			**	Must still solve how to determine which items are BriefWrite items	** ;
				%if &Grd. = 11 %then %do;
					bpref2 = 'ELAG11_Test3_S1_BriefWrite';
				%end;
				%else %if &Grd. = 4 or &Grd. = 5 %then %do;
					bpref2 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Brief Write');
				%end;
				%else %do;
					bpref2 = compress('ELAG'||"&Grd."||'_Test3_S1_Brief Write');
				%end;
			end;
			**	bpref3	** ;
			bpref3 = '';
			if Claim = 2 and Target in ('1', '3', '6') and DetailedELAClaim2Target in ('bE', 'bO') then do;
				if DetailedELAClaim2Target = 'bE' then bpref3 = compress('ELAG'||"&Grd."||'_Test3_S1_Claim2_EE_T136');
				else if DetailedELAClaim2Target = 'bO' then bpref3 = compress('ELAG'||"&Grd."||'_Test3_S1_Claim2_OP_T136');
			end;
			**	bpref4	** ;
			bpref4 = '';
			**	bpref5	** ;
			bpref5 = '';
			**	bpref6	** ;
			if Claim in (1, 2) and dok = 2 then bpref6 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Claim'||Claim||'_DOK2');
			else if Claim in (1, 2) and dok in (3, 4) then bpref6 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Claim'||Claim||'_DOK3+');
			else if Claim = 3 and dok in (2, 3, 4) then bpref6 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Claim'||Claim||'_DOK2+');
			else bpref6 = '';
			**	bpref7	** ;
			bpref7 = compress('SBAC-'||Claim||'-'||SRC);
			**	bpref8	** ;
			bpref8 = compress(bpref7||'|'||Target||'-'||"&Grd.");		*/
			Test_Pool = 'Summative' ;
			Answer_Key = 'IAT' ;
			/*	The testItem PP records do not show IAT Answer Key rows for items with item type = EBSR		*/
			if Item_Type = 'EBSR' then do;
				/*	interaction for EBSR items depends on whether the item is of type MC|MC or MC|MS		*/
				if length(compress(IATanswerKey)) = 3 then interaction = 'multipleChoice';
			end;
			if index(Full_Title, 'CAT') > 0;
		run;
		%SetDSLabel;
		proc sql;
			create table lbHr&CtPt..testitem_pp_&CtPt._&Subj._&Grd._&yr2Yr. (label = "&DSLabel.") as
			select distinct * from testitem_pp_&Subj._&Grd._&yr2Yr.;
		quit;
	%end; /* refresh tipp datasets - bottom	*/
	/*	testitem poolproperty - bottom	*/
	/*	poolproperty counts - top	*/
	%if &ppfd. = 1 %then %do;	/*	Recompute ppfd counts - top	*/
		%macro BuildFDs(inDS, prop, fld, PrntIt);
			%if &fld. = IATanswerKey %then %do;
				%macro AnsKeyValCount(keyVal);
					proc sql;
						create table akeykv&keyVal.DS as
						select 'IAT Answer Key' as property format $42.,
						"&keyVal." as IATanswerKey format $42.,
						count(*) as itemCount format 5.0
						from lbHr&CtPt..testitem_pp_&CtPt._&Subj._&Grd._&yr2Yr.
						where item_Type in ('MC', 'MS')
							and index(IATanswerKey, "&keyVal.") > 0;
					quit;
				%mend AnsKeyValCount;
				%AnsKeyValCount(A);
				%AnsKeyValCount(B);
				%AnsKeyValCount(C);
				%AnsKeyValCount(D);
				%AnsKeyValCount(E);
				%AnsKeyValCount(F);
				%AnsKeyValCount(G);
				%AnsKeyValCount(H);
				data FD4IATanswerKey;
					set akeykvADS akeykvBDS akeykvCDS akeykvDDS
							akeykvEDS akeykvFDS akeykvGDS akeykvHDS;
					if itemCount > 0;
				run;
				%if &PrntIt. = 1 %then %do;
					%GetSnow;
					Title "Check FD4IATanswerKey for &Subj.-&Grd. [&now.]";
					proc print data=FD4IATanswerKey;
					run;
				%end;
			%end;	/*	Process Answer Keys - bottom	*/
			%else %do;
				proc freq data=&inDS. noprint;
					tables &fld. / out=outDS_&fld.;
				run;
				data FD4&fld. (keep=property value itemCount);
					format property $42. value $42. itemCount 5.0;
					set outDS_&fld.;
					property = "&prop.";
					value = left(trim(&fld.));
					itemCount = count;
					%if %eval(&fld. = PasLen or &fld. = LangBrl or &fld. = LangESN) %then %do;
						where &fld. ne '';
					%end;
				run;
				%if &PrntIt. = 1 %then %do;
					%GetSnow;
					Title "Check FD4&fld. for &Subj.-&Grd. [&now.]";
					proc print data=FD4&fld.;
					run;
				%end;
			%end;
		%mend BuildFDs;
		data ForPPFDs;
			set lbHrCAT.testitem_pp_&CtPt._&Subj._&Grd._&yr2Yr.;
			format CapItemType $4. PasLen $5. LangENU $3. LangESN $3. LangBrl $11. ScoreEngine $32.;
			if ItemType in ('HTQO', 'HTQS') then CapItemType = 'HTQ';
			else CapItemType = ItemType;
			if length(DetailedELAClaim2Target) > 0 then Claim2_Category = substr(DetailedELAClaim2Target, 2, 1);
			else Claim2_Category = '';
			LangENU = 'ENU';
			if compress(BraillePool) = 'Y' then LangBrl = 'ENU-Braille';
			if compress(SpanishPool) = 'Y' then LangESN = 'ESN';
			select (ScoringEngine);
				when ('AutomaticWithKey') ScoreEngine = 'Automatic With key';
				when ('AutomaticWithKeys') ScoreEngine = 'Automatic with Key(s)';
				when ('AutomaticWithRubric') ScoreEngine = 'Automatic with Machine Rubric';
				when ('HandScored') ScoreEngine = 'HandScored';
			end;
		run;
		%BuildFDs(ForPPFDs, --ITEMTYPE--, CapItemType, 1);
		%BuildFDs(ForPPFDs, ASL, ASL_Pool, 1);		/*	This is not perfectly correct.  There are no blank values	*/
		%BuildFDs(ForPPFDs, Depth of Knowledge, Dok, 1);
		%BuildFDs(FD4IATanswerKey, IAT Answer Key, IATanswerKey, 1);
		%BuildFDs(ForPPFDs, Interaction, interaction, 1);		
		%BuildFDs(ForPPFDs, Grade, Grade, 1);
		%if &Subj = ELA %then %do;
			%BuildFDs(ForPPFDs, Passage Length, Passage_Length, 1);
		%end;
		%BuildFDs(ForPPFDs, Language, LangENU, 1);
		%BuildFDs(ForPPFDs, Language, LangBrl, 1);
		%if &Subj. = MATH %then %do;
			%BuildFDs(ForPPFDs, Language, LangESN, 1);
			%BuildFDs(ForPPFDs, Calculator, Allow_Calc, 1);
		%end;
		%BuildFDs(ForPPFDs, Scoring Engine, Scoring_Engine, 1);
		%BuildFDs(ForPPFDs, TDSPoolFilter_below, TDSPoolFilter_below, 1);
		%BuildFDs(ForPPFDs, TDSPoolFilter_above, TDSPoolFilter_above, 1);
		%BuildFDs(ForPPFDs, Test Pool, Test_Pool, 1);
		data lbHr&CtPt..testbp_pp_&CtPt._&subj._&grd._&yr2Yr.;
			set FD4CapItemType FD4ASL_Pool FD4Dok FD4IATanswerKey FD4Grade
				FD4Interaction FD4LangENU FD4LangBrl
			%if &Subj. = ELA %then %do;
				FD4Passage_Length
			%end;
			%if &Subj. = MATH %then %do;
				FD4LangESN FD4AllowCalculator
			%end;
			FD4Scoring_Engine FD4TDSPoolFilter_below FD4TDSPoolFilter_above FD4Test_Pool;
			if property in ('TDSPoolFilter_below', 'TDSPoolFilter_above') and value = '' then delete;
		run;
	%end;		/*	Recompute ppfd counts - bottom	*/
	/*	poolproperty counts - bottom	*/
	/*	itemPool passage dataset	*/
	%if &Subj. = ELA %then %do;
		%if &stim. = 1 %then %do;
			proc sql;
				create table lbHr&CtPt..itempool_stim_&CtPt._&Subj._&Grd._&yr2Yr. as 
				select distinct stim_id, &&&Subj._version. as version
				from &trgt_TDF. as tdf
				where stim_id ne . and compress(upcase(tdf.Subject)) = "&Subj."
					and tdf.student_Grade = &Grd.
				order by stim_id;
			quit;
		%end;
	%end;		/*	bottom of itemPool passage dataset	*/
	%if &bpelem. = 1 %then %do;		/*	Top of bpelement block		*/
		%if &Subj = MATH %then %let Sbj = MA;
		%else %let Sbj = &Subj.;
		%SetDSLabel;
		DATA lbHr&CtPt..tbp_bpelm_&CtPt._&Subj._&grd._&yr2Yr. (label="&DSLabel.");
			LENGTH
				subject	$ 3		grade	8		SchoolYear	$ 5		elementType	$ 16		minOpItems	8
				maxOpItems	8		minFtItems	8		maxFtItems	8		opItemCount	8		ftItemCount	8
				id_uniqueId	$ 56		id_name	$ 36		version	8 ;
			FORMAT %bpelemVarFmtLst;
			INFORMAT %bpelemVarFmtLst;
			INFILE "&wrkHere.\&Sbj.-&Grd._19-20_CAT_ts_adm_bpelem.csv"
				LRECL=32767		FIRSTOBS=2		ENCODING="WLATIN1"		DLM='2c'x
				MISSOVER		DSD ;
			INPUT
				subject	: $CHAR3.		grade	: ?? BEST2.		SchoolYear	: $CHAR5.		elementType	: $CHAR16.
				minOpItems	: ?? BEST2.		maxOpItems	: ?? BEST2.		minFtItems	: ?? BEST2.
				maxFtItems	: ?? BEST2.		opItemCount	: ?? BEST3.		ftItemCount	: ?? BEST2.
				id_uniqueId	: $CHAR56.		id_name	: $CHAR36. ;
			SchoolYear = '22-23';
			id_uniqueId = tranwrd(id_uniqueId, 'Spring-2019-2020', '2022-2023');
			version = &&&Subj._version. ;
		RUN;
	%end;		/*	bottom of bpelem block		*/
	%if &ispPrp. = 1 %then %do;		/*	Top of ISP Prop block		*/
		%if &Subj = MATH %then %let Sbj = MA;
		%else %let Sbj = &Subj.;
		%SetDSLabel;
		data lbHr&CtPt..isp_prop_&CtPt._&Subj._&grd._&yr2Yr. (label="&DSLabel.");
			length segment 3.0 subject $ 3 	grade 8 SchoolYear $ 5 	isp_bpElemId $ 56		isp_prop_count 8 
					isp_prop_name $ 31		isp_prop_value $ 16		isp_prop_label $ 184 ;
			format %ISPPropVarFmtLst;
			informat %ISPPropVarFmtLst;
			subject = "&Sbj.";
			grade = &Grd.;
			SchoolYear = "&yr2Yr.";
			infile "&wrkHere.\&Sbj.-&Grd._19-20_CAT_isp_prop.csv"
				lrecl=32767		firstObs=2		encoding="WLATIN1"		DLM='2c'x
				missover 	dsd ;
			input segment isp_bpElemId $	isp_prop_count	$		isp_prop_name	$		isp_prop_value	$		isp_prop_label	$ ;
		run;
	%end;		/*	Bottom of ISP Prop block		*/
	%if &itmGrp. = 1 %then %do;		/*	Top of itemGroup block	*/
		/*	Start by discovering stimulus / item associations	*/
		proc sql;
			create table Count_and_mi_by_Stim as 
			select distinct stim_Id, count(*) as grpItem_rowCount, 
				case
					when count(*) ge 4 then '4'
					when count(*) ge 2 and count(*) lt 4 then '2'
				end as maxitems format $3.,
				1 as groupSortOrder
			from &trgt_TDF.
			where stim_Id ne . and subject = "&Subj." and student_Grade = &Grd.
			group by stim_Id;
		quit;
		proc sql;
			create table stims_and_items as 
			select tdf.item_id as itemid_orig, cnt.*
			from &trgt_TDF. as tdf
			left join Count_and_mi_by_Stim as cnt
			on tdf.stim_id = cnt.stim_id
			where upcase(compress(tdf.Subject)) = "&Subj." and tdf.student_Grade = &Grd. 
				and short_title = 'CAT' ;
		*	order by tdf.stim_id, tdf.item_Id;
		quit;
		proc sql;
			create table bpr1_stm_itm as
			select bpr.segment, bpr.bpref_1, sandi.*
			from stims_and_items as sandi
			left join libHere.itemBPRefs_&Subj._&Grd._&yr2Yr._&CtPt. as bpr
			on sandi.itemId_orig = bpr.itemId
			order by bpr.segment, sandi.stim_id, sandi.itemid_orig;
		quit;
		%GetSnow;
		Title "bpr1_stm_itm for &Subj.-&Grd. [&now.]";
		proc print data=bpr1_stm_itm;
		run;
		data itmGrp_&Subj._&grd._&yr2Yr.;
			format maxitems $3. maxresponses $3. uniqueid $18. name $18. version 8.0
							passageref $12. itemid $12. groupposition 3.0 adminrequired $6. responserequired $6. 
							isfieldtest $6. isactive $6. blockid $1. ;
			set bpr1_stm_itm;
			by segment stim_id ;
			retain groupposition;
			if stim_id = . then do;
				maxitems = 'ALL';
				uniqueid = compress('I-200-'||itemId_orig);		/*	Careful!!  The bank key may be either 200 or 10200	*/
				passageref = '';
				groupposition = 1;
				adminrequired = 'true';
				responserequired = 'true';
				groupSortOrder = 2;
				grpItem_rowCount = 1;
			end;
			else do;
				if first.stim_id then groupposition = 1;
				else groupposition = groupposition + 1;
				passageref = compress('200-'||stim_id);
				uniqueid = compress('G-'||passageref||'-0');		/*	Careful!!  The bank key may be either 200 or 10200	*/
				if maxitems = . then maxitems = 'ALL';
				adminrequired = 'false';
				responserequired = 'false';
				groupSortOrder = 1;
			end;
			itemid = compress('200-'||itemid_orig);
			name = uniqueid;
			maxresponses = 'ALL';
			version = &&&Subj._version. ;
			isfieldtest = 'false';
			isactive = 'true';
			blockid = 'A';
		run;
		%SetDSLabel;
		proc sort data=itmGrp_&Subj._&grd._&yr2Yr.
				out=lbHr&CtPt..itmGrp_&CtPt._&Subj._&grd._&yr2Yr. (label="&DSLabel." drop=itemid_orig stim_id groupSortOrder);
			by segment groupSortOrder stim_id itemId;
		run;
	%end;		/*	Bottom of itemGroup block	*/
%mend SubjGrd;

%*	%SubjGrd(ELA, 3, CAT, 0, 0, 0, 0, 0, 0, 1);
	%SubjGrd(ELA, 4, CAT, 1, 1, 1, 1, 1, 0, 1);
%*	%SubjGrd(ELA, 5, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(ELA, 6, CAT, 0, 0, 0, 0, 0, 0, 1);
	%SubjGrd(ELA, 7, CAT, 1, 1, 1, 1, 1, 0, 1);
%*	%SubjGrd(ELA, 8, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(ELA, 11, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 3, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 4, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 5, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 6, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 7, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 8, CAT, 0, 0, 0, 0, 0, 0, 1);
%*	%SubjGrd(MATH, 11, CAT, 0, 0, 0, 0, 0, 0, 1);



/*
%macro SubjGrd(Subj, Grd, CtPt, tspc, tipp, ppfd, stim, bpelem, ispPrp, itmGrp);
*/