/*==================================================================================================*
 | Program	:	DevCATAdminData.sas																																		|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	From TDF (or pull list), develop data that will be written to XML for CAT Admin				|
 |						package.																																							|
 | Macros		: ... as well as small, often used tools from my toolbox.																|
 | Notes		:	Input datasets may vary based on time-frame.  From 18-19 onward test definition       |
 |						files represented the draft item pool.  Prior to that it was called the pull list.		|
 | Usage		:	Applicable to test packaging > summative > admin package(s)														|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2020 08 16		Initial development. 																															|
 *==================================================================================================*/

%let OneDrvStub = C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC;
%let wrkHere = &OneDrvStub.\CATAdminPackage;
 
*** source data library for 18-19 *** ;
/*	libname TDFLib "&OneDrvStub.\SBTemp\FFConfig\2020-21";	*/

libname imrtLib "&OneDrvStub.\IMRT";
libname libHere "&wrkHere.";

%macro SubjGrd(Subj, Grd, tipp, ppfd);
	/*	testitem poolproperty - top	*/
	%if &tipp. = 1 %then %do;	 /* refresh tipp datasets - top	*/
		proc sql;
			create table ti_pp_&Subj._&Grd. as
			select tdf.itemId, tdf.ItemType, tdf.ASLPool, tdf.BraillePool, tdf.SpanishPool,
				tdf.TranslatedGlossaryPool, tdf.DetailedELAClaim2Target,
			  tdf.DOK, tdf.StudentGrade as Grade, tdf.ItemGrade, tdf.StimId as passageref, 
			  tdf.PassageLength, imrt.answerKey, tdf.AllowCalculator, tdf.ScoringEngine,
				tdf.ScoringEngine, tdf.MaxScr_d1 as scorePoints, tdf.IRTa_d1, tdf.IRTb_d1,
				tdf.GPCd2_d1, tdf.GPCd3_d1, tdf.GPCd4_d1, tdf.GPCd5_d1, tdf.FullTitle
			from libHere.tdf_2019_20_summative_v27 as tdf
			left join imrtLib.imrt_etypes_keys_20200825 as imrt 
			on tdf.itemId = imrt.itemId
			where compress(tdf.Subject) = "&Subj." and tdf.StudentGrade = &Grd.;
		quit;
		data libHere.testitem_pp_&Subj._&Grd._1920 (drop=FullTitle);
			set ti_pp_&Subj._&Grd.;
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
			if index(FullTitle, 'CAT') > 0;
		run;
	%end; /* refresh tipp datasets - bottom	*/
	/*	testitem poolproperty - bottom	*/
	/*	poolproperty counts - top	*/
	%if &ppfd. = 1 %then %do;	/*	Recompute ppfd counts - top	*/
		%macro BuildFDs(inDS, prop, fld, PrntIt);
			%if &fld. = answerKey %then %do;
				%macro AnsKeyValCount(keyVal);
					proc sql;
						create table akeykv&keyVal.DS as
						select 'IAT Answer Key' as property format $42.,
						"&keyVal." as value format $42.,
						count(*) as itemCount format 5.0
						from libHere.testitem_pp_&Subj._&Grd._1920
						where itemType in ('mc', 'ms')
						and index(answerKey, "&keyVal.") > 0;
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
				data FD4answerKey;
					set akeykvADS akeykvBDS akeykvCDS akeykvDDS
							akeykvEDS akeykvFDS akeykvGDS akeykvHDS;
					if itemCount > 0;
				run;
				%if &PrntIt. = 1 %then %do;
					%GetSnow;
					Title "Check FD4answerKey for &Subj.-&Grd. [&now.]";
					proc print data=FD4answerKey;
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
			set libHere.testitem_pp_&Subj._&Grd._1920;
			format CapItemType $4. PasLen $5. LangENU $3. LangESN $3. LangBrl $11. ScoreEngine $32.;
			if ItemType in ('htqo', 'htqs') then CapItemType = 'HTQ';
			else CapItemType = upcase(ItemType);
			if length(DetailedELAClaim2Target) > 0 then Claim2_Category = substr(DetailedELAClaim2Target, 2, 1);
			else Claim2_Category = '';
			if PassageLength = 'L' then PasLen = 'Long';
			else if PassageLength = 'S' then PasLen = 'Short';
			else PasLen = '';
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
		%BuildFDs(ForPPFDs, IAT Answer Key, answerKey, 1);
		%BuildFDs(ForPPFDs, Grade, ItemGrade, 1);
		%if &Subj = ELA %then %do;
			%BuildFDs(ForPPFDs, Passage Length, PasLen, 1);
		%end;
		%BuildFDs(ForPPFDs, Language, LangENU, 1);
		%BuildFDs(ForPPFDs, Language, LangBrl, 1);
		%if &Subj. = MATH %then %do;
			%BuildFDs(ForPPFDs, Language, LangESN, 1);
			%BuildFDs(ForPPFDs, Calculator, AllowCalculator, 1);
		%end;
		%BuildFDs(ForPPFDs, Scoring Engine, ScoreEngine, 1);
		data libhere.testbp_pp_&subj._&grd._1920;
			set FD4CapItemType FD4ASLPool FD4Dok FD4answerKey FD4ItemGrade
				FD4LangENU FD4LangBrl
			%if &Subj. = ELA %then %do;
				FD4PasLen
			%end;
			%if &Subj. = MATH %then %do;
				FD4LangESN FD4AllowCalculator
			%end;
			FD4ScoreEngine;
		run;
	%end;		/*	Recompute ppfd counts - bottom	*/
	/*	poolproperty counts - bottom	*/
%mend SubjGrd;
	%SubjGrd(ELA, 6, 1, 1);
	%SubjGrd(ELA, 7, 1, 1);
	%SubjGrd(MATH, 4, 1, 1);
	%SubjGrd(MATH, 8, 1, 1);