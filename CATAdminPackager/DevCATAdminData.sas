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
 *==================================================================================================*/

%let OneDrvStub = C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC;
%let wrkHere = &OneDrvStub.\CATAdminPackage;
 
*** source data library for 18-19 *** ;
/*	libname TDFLib "&OneDrvStub.\SBTemp\FFConfig\2020-21";	*/

libname imrtLib "&OneDrvStub.\IMRT";
libname libHere "&wrkHere.";

%macro InteractionData;
	%SetDSLabel;
	data libHere.InterAction (label = "&DSLabel.");
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
	Title "Contents of libHere.InterAction [&now.]";
	proc contents data=libHere.InterAction order=varnum;
	run;
	proc print data=libHere.InterAction;
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

%macro SubjGrd(Subj, Grd, tipp, ppfd, stim, bpelem);
	%let trgt_TDF = libHere.tdf_2019_20_summative_v27;
	%let bpref1_stub = (SBAC)SBAC-GEN-SUM-UD-ELA-CAT-;
	%let bp_season = Spring;
	%let bp_year_range = 2019-2020;
	%let yr2Yr = 1920;
	%let ELA_version = 19055;		/*	<<<===---*<<<		These values are made up			<<<===---*<<<		*/
	%let MATH_version = 19062;	/*	<<<===---*<<<		These values are made up			<<<===---*<<<		*/
	/*	testitem poolproperty - top	*/
	%if &tipp. = 1 %then %do;	 /* refresh tipp datasets - top	*/
		proc sql;
			create table ti_pp_&Subj._&Grd. as
			select tdf.itemId, upcase(tdf.ItemType) as ItemType, tdf.ASLPool, tdf.BraillePool,
				tdf.SpanishPool, tdf.TranslatedGlossaryPool, tdf.DetailedELAClaim2Target,
				tdf.claim, tdf.SRC, tdf.target, tdf.dok, /*	imrt.p_ccss,	*/
			  tdf.DOK, tdf.StudentGrade as Grade, tdf.ItemGrade, tdf.StimId as passageref, 
			  tdf.PassageLength, imrt.answerKey as IATanswerKey, tdf.AllowCalculator, 
			  case 
			  	when tdf.PassageLength = 'S' then 'Short'
			  	when tdf.PassageLength = 'L' then 'Long'
			  	else ''
			  end as Passage_Length, intrad.interaction,
				tdf.ScoringEngine, tdf.MaxScr_d1 as scorePoints, tdf.IRTa_d1, tdf.IRTb_d1,
				tdf.GPCd2_d1, tdf.GPCd3_d1, tdf.GPCd4_d1, tdf.GPCd5_d1, tdf.FullTitle
			from &trgt_TDF. as tdf
			left join imrtLib.imrt_etypes_keys_20201206 as imrt 
				on tdf.itemId = imrt.itemId
			left join libHere.interaction as intrad
				on compress(upcase(tdf.ItemType)) = compress(intrad.itemType)
			where compress(tdf.Subject) = "&Subj." and tdf.StudentGrade = &Grd.;
		quit;
		data libHere.testitem_pp_&Subj._&Grd._&yr2Yr. (drop=FullTitle rename=(Passage_Length = PassageLength));
			set ti_pp_&Subj._&Grd. (drop=PassageLength);
			format version 6.0 TDSPoolFilter $16. Answer_Key $3. Test_Pool $12.
					bpref1 $56. bpref2 $32. bpref3 $32. bpref4 $32. bpref5 $32. bpref6 $32. bpref7 $12. bpref8 $16.;
			version = &&&Subj._version.;
			if ItemGrade < Grade then TDSPoolFilter = 'OFFGRADE BELOW';
			else if ItemGrade > Grade then TDSPoolFilter = 'OFFGRADE ABOVE';
			else TDSPoolFilter = '';
			if scorePoints=1 then do;
				measModel = 'IRT3PLn';
				IRTc_d1 = 0;
			end;
			else do;
				measModel = 'IRTGPC';
				if scorePoints = 2 then do;
					IRTb0_d1 = IRTb_d1 - GPCd2_d1;
					IRTb1_d1 = IRTb_d1 - GPCd3_d1;
				end;
				else if scorePoints = 3 then do;
					IRTb0_d1 = IRTb_d1 - GPCd2_d1;
					IRTb1_d1 = IRTb_d1 - GPCd3_d1;
					IRTb2_d1 = IRTb_d1 - GPCd4_d1;
				end;
				else if scorePoints = 4 then do;
					IRTb0_d1 = IRTb_d1 - GPCd2_d1;
					IRTb1_d1 = IRTb_d1 - GPCd3_d1;
					IRTb2_d1 = IRTb_d1 - GPCd4_d1;
					IRTb3_d1 = IRTb_d1 - GPCd5_d1;
				end;
			end;
			bpref1 = compress("&bpref1_stub."||"&Grd."||'-'||"&bp_season."||'-'||"&bp_year_range.");
			/*	bpref2	*/
			bpref2 = '';
			if ShortTitle = 'BriefWrite' then do;			/*	Must still solve how to determine which items are BriefWrite items	*/
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
			/*	bpref3	*/
			bpref3 = '';
			if Claim = 2 and Target in ('1', '3', '6') and DetailedELAClaim2Target in ('bE', 'bO') then do;
				if DetailedELAClaim2Target = 'bE' then bpref3 = compress('ELAG'||"&Grd."||'_Test3_S1_Claim2_EE_T136');
				else if DetailedELAClaim2Target = 'bO' then bpref3 = compress('ELAG'||"&Grd."||'_Test3_S1_Claim2_OP_T136');
			end;
			/*	bpref4	*/
			bpref4 = '';
			/*	bpref5	*/
			bpref5 = '';
			/*	bpref6	*/
			if Claim in (1, 2) and dok = 2 then bpref6 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Claim'||Claim||'_DOK2');
			else if Claim in (1, 2) and dok in (3, 4) then bpref6 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Claim'||Claim||'_DOK3+');
			else if Claim = 3 and dok in (2, 3, 4) then bpref6 = compress('ELAG'||"&Grd."||'_Test3_Seg1_Claim'||Claim||'_DOK2+');
			else bpref6 = '';
			/*	bpref7	*/
			bpref7 = compress('SBAC-'||Claim||'-'||SRC);
			/*	bpref8	*/
			bpref8 = compress(bpref7||'|'||Target||'-'||"&Grd.");
			Test_Pool = 'Summative' ;
			Answer_Key = 'IAT' ;
			/*	The testItem PP records do not show IAT Answer Key rows for items with item type = EBSR		*/
			if ItemType = 'EBSR' then do;
				/*	interaction for EBSR items depends on whether the item is of type MC|MC or MC|MS		*/
				if length(compress(IATanswerKey)) = 3 then interaction = 'multipleChoice';
			end;
			if index(FullTitle, 'CAT') > 0;
		run;
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
						from libHere.testitem_pp_&Subj._&Grd._1920
						where itemType in ('MC', 'MS')
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
			set libHere.testitem_pp_&Subj._&Grd._&yr2Yr.;
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
		%BuildFDs(ForPPFDs, ASL, ASLPool, 1);		/*	This is not perfectly correct.  There are no blank values	*/
		%BuildFDs(ForPPFDs, Depth of Knowledge, Dok, 1);
		%BuildFDs(FD4IATanswerKey, IAT Answer Key, IATanswerKey, 1);
		%BuildFDs(ForPPFDs, Interaction, interaction, 1);		
		%BuildFDs(ForPPFDs, Grade, ItemGrade, 1);
		%if &Subj = ELA %then %do;
			%BuildFDs(ForPPFDs, Passage Length, PassageLength, 1);
		%end;
		%BuildFDs(ForPPFDs, Language, LangENU, 1);
		%BuildFDs(ForPPFDs, Language, LangBrl, 1);
		%if &Subj. = MATH %then %do;
			%BuildFDs(ForPPFDs, Language, LangESN, 1);
			%BuildFDs(ForPPFDs, Calculator, AllowCalculator, 1);
		%end;
		%BuildFDs(ForPPFDs, Scoring Engine, ScoreEngine, 1);
		%BuildFDs(ForPPFDs, TDSPoolFilter, TDSPoolFilter, 1);
		%BuildFDs(ForPPFDs, Test Pool, Test_Pool, 1);
		data libhere.testbp_pp_&subj._&grd._&yr2Yr.;
			set FD4CapItemType FD4ASLPool FD4Dok FD4IATanswerKey FD4ItemGrade
				FD4Interaction FD4LangENU FD4LangBrl
			%if &Subj. = ELA %then %do;
				FD4PassageLength
			%end;
			%if &Subj. = MATH %then %do;
				FD4LangESN FD4AllowCalculator
			%end;
			FD4ScoreEngine FD4TDSPoolFilter FD4Test_Pool;
		run;
	%end;		/*	Recompute ppfd counts - bottom	*/
	/*	poolproperty counts - bottom	*/
	/*	itemPool passage dataset	*/
	%if &Subj. = ELA %then %do;
		%if &stim. = 1 %then %do;
			proc sql;
				create table libHere.itempool_stim_&Subj._&Grd._&yr2Yr. as 
				select distinct StimId, &&Subj._version. as version
				from &trgt_TDF. as tdf
				where StimId ne . and compress(tdf.Subject) = "&Subj."
					and tdf.StudentGrade = &Grd.
				order by StimId;
			quit;
		%end;
	%end;		/*	bottom of itemPool passage dataset	*/
	%if &bpelem. = 1 %then %do;		/*	Top of bpelement block		*/
		%if &Subj = MATH %then %let Sbj = MA;
		%else %let Sbj = &Subj.;
		%SetDSLabel;
		DATA libHere.tbp_bpelm_&Subj._&grd._&yr2Yr. (label="&DSLabel.");
			LENGTH
				subject	$ 3		grade	8		SchoolYear	$ 5		elementType	$ 16		minOpItems	8
				maxOpItems	8		minFtItems	8		maxFtItems	8		opItemCount	8		ftItemCount	8
				id_uniqueId	$ 56		id_name	$ 36		version	8 ;
			FORMAT %bpelemVarFmtLst;
			INFORMAT %bpelemVarFmtLst;
			INFILE "&wrkHere.\&Sbj.-&Grd._19-20_ts_adm_bpelem.csv"
				LRECL=32767		FIRSTOBS=2		ENCODING="WLATIN1"		DLM='2c'x
				MISSOVER		DSD ;
			INPUT
				subject	: $CHAR3.		grade	: ?? BEST2.		SchoolYear	: $CHAR5.		elementType	: $CHAR16.
				minOpItems	: ?? BEST2.		maxOpItems	: ?? BEST2.		minFtItems	: ?? BEST2.
				maxFtItems	: ?? BEST2.		opItemCount	: ?? BEST3.		ftItemCount	: ?? BEST2.
				id_uniqueId	: $CHAR56.		id_name	: $CHAR36. ;
			version = &&&Subj._version. ;
		RUN;
	%end;		/*	Top of bpelement block		*/
%mend SubjGrd;
	%SubjGrd(ELA, 6, 0, 0, 0, 1);
	%SubjGrd(ELA, 7, 0, 0, 0, 1);
	%SubjGrd(MATH, 4, 0, 0, 0, 1);
	%SubjGrd(MATH, 8, 0, 0, 0, 1);