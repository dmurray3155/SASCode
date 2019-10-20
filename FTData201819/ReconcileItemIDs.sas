%let workhere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819;
%include "&workhere.\SetSessionEnv.sas";
%let CntGrd=ela03;

/*	Begin by building a subset of ETS data that will be merged to AIR data	*/
proc sql;
	create table &CntGrd._CACasesinAIR as 
	select studentId, oppKey, oppID, componval2Num, catBool, itemOper,
		itemFormat, scan(ItemId, 2, '-') as ItemId
	from libhere.&CntGrd._ETSSrc
	where oppKey in (select tdsopportunityguid from libhere.&CntGrd._AIRSrc2);
quit;
proc freq data=&CntGrd._CACasesinAIR; /* noprint;	*/
	tables itemFormat * itemOper * ItemID / list missing out=ETSItemIDs;
run;
data ETSItemIDs;
	set ETSItemIDs;
	format ETSItemID $12.;
	if itemOper = 1 then itmidPfx = 'O_';
	else if itemOper = 0 then itmidPfx = 'F_';
	if itemFormat = 'WER' then do;
		ETSItemID = compress(itmidPfx||ItemId||'_A');	output;
		ETSItemID = compress(itmidPfx||ItemId||'_B');	output;
		ETSItemID = compress(itmidPfx||ItemId||'_C');	output;
		ETSItemID = compress(itmidPfx||ItemId||'_D');	output;
	end;
	else do;
		ETSItemID = compress(itmidPfx||ItemId);	output;
	end;
run;
/*
%GetNow;
Title "ETSItemIDs [&now.]";
proc print data=ETSItemIDs;
run;
*/
proc contents data=libhere.&CntGrd._AIRSrc noprint out=AIRVars (rename=(name=AIRItemId));
run;
data AIRItemIDs;
	set AIRVars;
	where (((AIRItemId like 'O_%') or (AIRItemId like 'F_%')) and (AIRItemId not like '%_RV_%'));
run;
%getNow;
proc sql;
	Title "&CntGrd. ItemID values in ETS but not in AIR [&now.]";
	select ETSItemID from ETSItemIDs
	where ETSItemID not in (select AIRItemId from AIRItemIDs);
	Title "&CntGrd. ItemID values in AIR but not in ETS [&now.]";
	select AIRItemID from AIRItemIDs
	where AIRItemID not in (select ETSItemID from ETSItemIDs);
quit;
	
	
	
