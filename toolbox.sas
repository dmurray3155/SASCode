/*===========================================================================================================*
 |  Name: ToolBox.sas                                                                                        |
 |  Author: Don Murray                                                                                       |
 |  Purpose: General, often used utilities                                                                   |
 |  Notes:                                                                                                   |
 |  Application: User centered.                                                                              |
 *------- Development History -------------------------------------------------------------------------------*
 |  05 APR 2005  Initial Logic Development.  The tools stored here were adapted from utils.mac.sas.          |
 |  22 JUN 2005  Added DS2HTML below                                                                         |
 *===========================================================================================================*/
*LibName TEMPLTS 'C:\Program Files\SAS\SAS 9.1\Templates';
%macro ClearLog;
    dm 'log; clear;';
%mend ClearLog;
%macro ClearOut;
    dm 'output; clear;';
%mend ClearOut;
%macro ClrBoth;
    dm 'log; clear; output; clear;';
%mend ClrBoth;
%macro ClrAll;
    dm 'log; clear; output; clear; results; delete;';
%mend ClrAll;

/*==========================================================================================================*
 |  Name: SetIMRTPrd																																												|
 |  Author: Don Murray (as Smarter Balanced)																																|
 |  Purpose: General, often used utilities																																	|
 |  Notes: Added under SBAC tenure																																					|
 |  Application: Define SAS library to postGreSQL IMRT production access.																		|
 *------- Development History ------------------------------------------------------------------------------*
 |  2019 08 15		Initial Logic Development.																																|
 *==========================================================================================================*/
%macro SetIMRTPrd;
	/*	Set LibName to access data from IMRT production system	*/
	libname imrtprd postgres server='imrt-prod-bi.c7g9woytu6d2.us-west-2.rds.amazonaws.com'
					port=5432 user=analyst password="{SAS004}16BA0F3B37E8E8015239B6EA6094FB6AE51C247064ACD638"
					database=imrt;
%mend SetIMRTPrd;

/*==========================================================================================================*
 |  Name: SetTCD																																														|
 |  Author: Don Murray (as Smarter Balanced)																																|
 |  Purpose: General, often used utilities																																	|
 |  Notes: Added under SBAC tenure																																					|
 |  Application: Define SAS library to postGreSQL TCD access.																								|
 *------- Development History ------------------------------------------------------------------------------*
 |  2019 08 28		Initial Logic Development.																																|
 *==========================================================================================================*/
%macro ConTCD;
	server="analyticsaurora-cluster.cluster-cimuvo5urx1e.us-west-2.rds.amazonaws.com"
	port=5432 database=test_construction user=dmurray
	password="{SAS004}70C77B5C28AB1C0D08B92DB91E465FE4E886F34B598E14AF"
%mend ConTCD;
%macro SetTCD;
	/*	Set LibName to access data from TCD system	*/
	libname tcd postgres %ConTCD;
%mend SetTCD;

/*==========================================================================================================*
 |  Name: ConRSItm																																													|
 |  Author: Don Murray (as Smarter Balanced)																																|
 |  Purpose: General, often used utilities																																	|
 |  Notes: Added under SBAC tenure																																					|
 |  Application: Define parameters for connect to string.																										|
 *------- Development History ------------------------------------------------------------------------------*
 |  2019 12 13		Initial Logic Development.																																|
 *==========================================================================================================*/
%macro ConRSItm;
	server="analytics.cs909ohc4ovd.us-west-2.redshift.amazonaws.com"
	port=5439 database=items user=ca_analytics
	password="{SAS004}3F84105DD2614973017278F8C138573F06354E17FE2FAD9D"
%mend ConRSItm;

/*==========================================================================================================*
 |  Name: SetRSItm																																													|
 |  Author: Don Murray (as Smarter Balanced)																																|
 |  Purpose: General, often used utilities																																	|
 |  Notes: Added under SBAC tenure.  Uses ConRSItm as a submacro for connection parameters.									|
 |  Application: Define SAS library to postGreSQL TCD access.																								|
 *------- Development History ------------------------------------------------------------------------------*
 |  2019 12 12		Initial Logic Development.																																|
 *==========================================================================================================*/
%macro SetRSItm;
	/*	Set LibName to access data from TCD system	*/
	libname items redshift %ConRSItm;
%mend SetRSItm;

/*-------------------------------------------------------------------*
 | Set preferred system options based on SAS version (03 DEC 2009)   |
 *-------------------------------------------------------------------*/
%macro SetOptions;
   %if &SYSVER=9.1 %then %do;
      options nocenter nodate nonumber mprint mlogic symbolgen spool 
              formchar="|----|+|---+=|-/\<>*";
   %end;
   %if &SYSVER=9.2 %then %do;
      options nocenter nodate nonumber mprint mlogic symbolgen spool fullstimer
              formchar="|----|+|---+=|-/\<>*";
   %end;
   %if &SYSVER=9.3 %then %do;
      options nocenter nodate nonumber mprint mlogic symbolgen spool
              formchar="|----|+|---+=|-/\<>*";
   %end;
   %if &SYSVER=9.4 %then %do;
      options nocenter nodate nonumber mprint mlogic symbolgen spool
              formchar="|----|+|---+=|-/\<>*";
   %end;
%mend SetOptions;

/*-------------------------------------------------------------------*
 | Define informative SAS dataset label content (2011-06-01)         |
 | H.Dodson started this one :)                                      |
 *-------------------------------------------------------------------*/
%macro SetDSLabel;
	 %global DSLabel;
   %let username=%sysget(username);
   %let compname=%sysget(computername);
   /* assign program name -- including path to progname */
   proc sql noprint;
      select compbl(xpath) into :progname
      from sashelp.vextfl where upcase(xpath) like '%.SAS';
   quit;
   %let progname=&progname;
   %let DSLabel=Created by &username. on &compname. using &progname.;
%mend SetDSLabel;

/*-------------------------------------------------------------------*
 | Manage hex replacements that do not act nicely between Windows    |
 | 1252 and UTF-8 encodings.  This is mostly used by the insert XML  |
 | part of the Propagate_Image_Work.sas job.                         |
 | D.Murray: 2013-12-02                                              |
 | 2014-02-24: comment out first three to prevent XML tag structure  |
 |             replacements.                                         |
 *-------------------------------------------------------------------*/
%macro HexReplace(_VarName_);
/* &_VarName_.=tranwrd(&_VarName_., '26'x, '&amp;');
   &_VarName_.=tranwrd(&_VarName_., '3C'x, '&lt;');
   &_VarName_.=tranwrd(&_VarName_., '3E'x, '&gt;'); */
   &_VarName_.=tranwrd(&_VarName_., '91'x, '&lsquo;');
   &_VarName_.=tranwrd(&_VarName_., '92'x, '&rsquo;');
   &_VarName_.=tranwrd(&_VarName_., '93'x, '&ldquo;');
   &_VarName_.=tranwrd(&_VarName_., '94'x, '&rdquo;');
   &_VarName_.=tranwrd(&_VarName_., '95'x, '&bull;');
   &_VarName_.=tranwrd(&_VarName_., '96'x, '&ndash;');
   &_VarName_.=tranwrd(&_VarName_., '97'x, '&mdash;');
   &_VarName_.=tranwrd(&_VarName_., 'A1'x, '&iexcl;');
   &_VarName_.=tranwrd(&_VarName_., 'A2'x, '&cent;');
   &_VarName_.=tranwrd(&_VarName_., 'A3'x, '&pound;');
   &_VarName_.=tranwrd(&_VarName_., 'A9'x, '&copy;');
   &_VarName_.=tranwrd(&_VarName_., 'B0'x, '&deg;');
   &_VarName_.=tranwrd(&_VarName_., 'BF'x, '&iquest;');
   &_VarName_.=tranwrd(&_VarName_., 'D7'x, '&times;');
   &_VarName_.=tranwrd(&_VarName_., 'E7'x, '&ccedil;');
   &_VarName_.=tranwrd(&_VarName_., 'F1'x, '&ntilde;');
   &_VarName_.=tranwrd(&_VarName_., 'F7'x, '&divide;');
%mend HexReplace;

/*-----------------------------------------------------------------------------*
 |  Compute age in years given birthdate (birth) and currentdate (curdate)     |
 |  Added on 05APR2010 from sasCommunity Tip of the Day from 04APR2010         |
 *-----------------------------------------------------------------------------*/
%macro ComputeAge(birth=, curdate=);
	 %global age;
   data _null_;
      age = floor((intck('month', &birth., &curdate.) - (day(somedate) < day(birth))) / 12);    
      call symput('age', age);
   run;
   %let age=&age.;
%mend;

%macro GetNow;
    %global now;
    %let time=%sysfunc(time(),timeampm11.);
    %let date=%sysfunc(date(),worddate12.);
    %let now=on &date. at &time;
%mend GetNow;

%macro GetSNow;
    %global now;
    %let time=%sysfunc(time(),time5.);
    %let date=%sysfunc(date(),date9.);
    %let now=&date. &time;
%mend GetSNow;

%macro now(fmt=datetime22.2);
  %sysfunc( datetime(), &fmt )
%mend now;

%global PersInfo;
%let PersInfo=%str(D.Murray, (970) 617-3155);

%macro DSExists(DsName=);
   %global DSExists;
   %let DSExists=%sysfunc(exist(&DsName));
%mend DSExists;

%macro VarExists(DsName, VarName);
   %global VarExists;
   %let dsid=%sysfunc(open(&DsName, i));
   %let VarExists=%sysfunc(varnum(&dsid, &VarName));
   %let dsid=%sysfunc(close(&dsid));
%mend VarExists;

%macro Clear_Titles;
    options nomprint;
    %do i=1 %to 9;
        Title&i.;
        Footnote&i.;
    %end;
    options mprint;
%mend Clear_Titles;

/*-------------------------------------------------------------------*
 | Redirect Print Output to PC flat file.                            |
 *-------------------------------------------------------------------*/
 %macro printto_PC(out=);
    filename out_to &out ;
    options nocenter ; * pagesize=15000;    /* 80 */
    proc printto print=out_to new;
    run;
 %mend printto_PC;

/*-------------------------------------------------------------------*
 | Route output back to default.                                     |
 *-------------------------------------------------------------------*/
 %macro printto_off;
    proc printto;
    run;
 %mend printto_off;

 /* How Many Items in Dataset - 06 APR 2005 */
 %macro TotalRec(inDS=);
    %global NumObs;
    %local TotObs;
    data _null_ ;
       set &inDS. end=LastOne ;
       if LastOne then call symput('TotObs', _n_);
    run;
    %let NumObs=&TotObs;
 %mend TotalRec;

/*-------------------------------------------------------------------*
 | Return SAS date value from string pieces 19 APR 2007              |
 *-------------------------------------------------------------------*/
 %macro Date_MDY(MM, DD, YYYY);
    if &MM in ("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12")
       and &DD in ("01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12",
                   "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24",
                   "25", "26", "27", "28", "29", "30", "31")
       and &YYYY in ("1958", "1959", "1960", "1961", "1962", "1963", "1964", "1965", "1966",
                     "1967", "1968", "1969", "1970", "1971", "1972", "1973", "1974", "1975",
                     "1976", "1977", "1978", "1979", "1980", "1981", "1982", "1983", "1984",
                     "1985", "1986", "1987", "1988", "1989", "1990", "1991", "1992", "1993",
                     "1994", "1995", "1996", "1997", "1998", "1999", "2000", "2001", "2002",
                     "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010", "2011",
                     "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020",
					 "2021", "2022", "2023", "2024", "2025")
            then Date_Val = MDY(&MM, &DD, &YYYY);
    else Date_Val = .;
 %mend Date_MDY;
 
 /*-------------------------------------------------------------------*
 | Return SAS date value from string pieces 19 SEP 2011              |
 *-------------------------------------------------------------------*/
 %macro Time_HMS(HH, MM, SS);
    if &HH in ("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11",
    						"12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23")
       and &MM in ("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11",
       						 "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23",
       						 "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35",
       						 "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47",
       						 "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59")
       and &SS in ("00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11",
       						 "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23",
       						 "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35",
       						 "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47",
       						 "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59")
            then Time_Val = HMS(&HH, &MM, &SS);
    else Time_Val = .;
 %mend Time_HMS;
 
/*-------------------------------------------------------------------*
 | Return date value of YYYYMMDD for the current date (20101213)     |
 *-------------------------------------------------------------------*/
 %macro SetYYYYMMDD;
 	 %global YYYYMMDD;
   data _null_;
    	 format mont dayt $2.;
       if length(compress(day(today())))=1 then dayt = compress('0'||day(today()));
   	   else dayt = compress(day(today()));
   	   if length(compress(month(today())))=1 then mont = compress('0'||month(today()));
   	   else mont = compress(month(today()));
       call symput('YYYYMMDD',  compress(year(today())||mont||dayt));
    run;
 %mend SetYYYYMMDD;

/*-------------------------------------------------------------------*
 | Replace difficult hex characters in web-bound content with their  |
 | web-friendly codes according to this reference:                   |
 | http://www.techdictionary.com/ascii.html           (2013-07-11)   |
 | better reference: http://www.w3schools.com/tags/ref_symbols.asp   |
 *-------------------------------------------------------------------*/
 %macro HexFixUp(varName);
    &varName=tranwrd(&varName, '91'x, "&lsquo;");  /* left single quotation mark */
    &varName=tranwrd(&varName, '92'x, "&rsquo;");  /* right single quotation mark */
    &varName=tranwrd(&varName, '93'x, "&ldquo;");  /* left double quotation mark */
    &varName=tranwrd(&varName, '94'x, "&rdquo;");  /* right double quotation mark */
    &varName=tranwrd(&varName, '96'x, "&ndash;");  /* en dash */
    &varName=tranwrd(&varName, '97'x, "&mdash;");  /* em dash */
    &varName=tranwrd(&varName, 'A1'x, "&iexcl;");  /* inverted exclamation mark */
 %mend HexFixUp;

/*-------------------------------------------------------------------*
 | Return time value of HHMMSS for the current time  (20110316)      |
 *-------------------------------------------------------------------*/
 %macro SetHHMMSS;
 	 %global HHMMSS;
   data _null_;
      format _tmptime_ $8. trnwrdtt $6. HHMMSS $6.;
      _tmptime_="%sysfunc(time(),time8.2)";
      trnwrdtt=compress(tranwrd(_tmptime_, ':', ''));
      if length(trnwrdtt)=5 then HHMMSS=compress('0'||trnwrdtt);
      else HHMMSS=compress(trnwrdtt);
      call symput('HHMMSS', HHMMSS);
    run;
 %mend SetHHMMSS;

/*-------------------------------------------------------------------*
 | Examine SAS LOG files for ERROR occurrances  (20110428)           |
 *-------------------------------------------------------------------*/
%macro StudyLogs(INDX, inFyl);
	 %global _indx_ inLog _EREX_;
   FileName LOGFile "&inFyl";
   %let inLog=&inFyl;
   %let _indx_=&INDX.;
   data _null_;
      retain ERROREXISTS 0 ;
      infile LOGFile ;
      input ; 
      if ((index(_infile_, 'ERROR') > 0) and (index(_infile_, '_ERROR_') = 0)) then ERROREXISTS = 1;
      call symput('_EREX_', ERROREXISTS);
   run;
   %let _EREX_=&_EREX_.;
%mend StudyLogs;

/*-------------------------------------------------------------------*
 | Set Logs Status (utility for StudyLogs) (20110428)                |
 *-------------------------------------------------------------------*/
%macro SetLogsStatus;
   %if &_EREX_=1 %then %do;
      _Status_ = '*** Has Errors Reported ***';
   %end;
   %else %do;
      _Status_ = '... Has No Errors ...';
   %end;
%mend SetLogsStatus;

/*-------------------------------------------------------------------*
 | Initialize Logs Report (utility for StudyLogs) (20110428)         |
 *-------------------------------------------------------------------*/
%macro InitLogsRept;
   data LogsReport;
      format INDX 3.0 _LogName_ $48. _Status_ $32.;
      length _LogName_ $64 _Status_ $32;
      _LogName_ = "&inLog.";
      INDX = &_indx_;
      %SetLogsStatus;
      output;
   run;
%mend InitLogsRept;

/*-------------------------------------------------------------------*
 | Subsequent Logs Report (utility for StudyLogs) (20110428)         |
 *-------------------------------------------------------------------*/
%macro SubseqLogRept;
   data LogsReport;
      set LogsReport;
      output;
      _LogName_ = "&inLog.";
      INDX = &_indx_;
      %SetLogsStatus;
      output;
   run;
%mend SubseqLogRept;

/*-------------------------------------------------------------------*
 | Deliver Logs Report (utility for StudyLogs) (20110428)            |
 *-------------------------------------------------------------------*/
%macro DelvrLogRept;
   proc sort data=LogsReport noduprec;
      by INDX;
   run;
   options ls=95;
   %GetSnow;
   Title "Report of SAS LOG files and their ERROR status (&now.)";
   proc print data=LogsReport noobs;
   run;
%mend DelvrLogRept;

/*---------------------------------------------------------------------------------------*
 | Perform standard SAS merge of two SAS datasets on a common variable.  The returned    |
 | dataset is in the original sort order of the first dataset.  The by variable(s) can   |
 | be a space delimited list of common variables.               11 SEP 2009              |
 *---------------------------------------------------------------------------------------*/
 %macro SAS_Merge(DS1, DS2, ComVar, OutDS);
 	  data DS1;
 	     set &DS1.;
 	     format original_sort_order 3.0;
 	     original_sort_order = _n_;
 	  run;
    proc sort data=DS1 out=DS1;
       by &ComVar.;
    run;
    proc sort data=&DS2. out=DS2;
       by &ComVar.;
    run;
    data Out_DS;
       merge DS1 DS2;
       by &ComVar.;
    run;
    proc sort data=Out_DS;
       by original_sort_order;
    run;
    data &OutDS.;
       set Out_DS (drop=original_sort_order);
    run;
 %mend SAS_Merge;

/*-------------------------------------------------------------------*
 | Distill an input variable in an input dataset to distinct values. |
 | The output dataset contains only the variable and only unique     |
 | values (16 MARCH 2011)                                            |
 *-------------------------------------------------------------------*/
 %macro DstlDS(inDS=, inVar=, outDS=);
    data TmpDS;
       set &inDS.;
       keep &inVar.;
    run;
    proc sort data=TmpDS noduprec out=&outDS.;
       by &inVar.;
    run;
 %mend DstlDS;

/*-------------------------------------------------------------------*
 | Used for FTP of flat files from local HD to FTP accessible server.|
 | Added 03 MAY 2010 to support FTP of score file to EOC Rept Server |
 *-------------------------------------------------------------------*/
 %macro FTP2Rept(LocFile=, SvrFile=, lrecl=256);
   filename  ScrFile  FTP  "&SvrFile" debug binary
             host='eocreporting.pacificmetrics.com'
             user='pacific'
             pass=metrics22
             port=21;
   data _null_;
      infile "&LocFile.";
      input;
      file ScrFile;
      put _infile_ ;
   run;
 %mend FTP2Rept;

/*======================================================================================================*
 | Macro Name : ReptMulti                                                                               |
 | Stored As  : \\Pacmet-svr\users\Don\toolbox.SAS                                                      |
 | Author     : Don Murray                                                                              |
 | Purpose    : Report whether a field has multiple occurrances of the same value in a given dataset.   |
 | SubMacros  : TotalRec (see above)                                                                    |
 | Notes      : This is especially useful while sequencing response vectors in elaborate ways.          |
 | Usage      : %ReptMulti(DSName=ItemCalibMap, VarName=ItemID) would report whether ItemID has         |
 |              duplicate values or not.                                                                |
 |------------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                          |
 | ....name........  ....description................................................................... |
 |  DSName            Name of input dataset containing field of interest.  Can be two-level DS name.    |
 |  VarName           Name of field of interest from input dataset.  This can be one or more fields.    |
 |------------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                                  |
 | ..date.....  ....description........................................................................ |
 | 20 MAY 2005  Initial Logic Development.  I had implemented this often enough in mid-project code     |
 |              that I decided it was time to design it properly.                                       |
 | 10 JUN 2005  Added logic to report that there were no cases of multiple values.                      |
 | 13 NOV 2009  Added Date / Time to second title in results output.                                    |
 *======================================================================================================*/
/*-------------------------------------------------------------------*
 | Report mutiple occurances of values in a particular variable      |
 *-------------------------------------------------------------------*/
 %macro ReptMulti(DSName=, VarName=);
    %let NumVars = 0;
    %do %until(%quote(&test) = );
       %let NumVars = %eval(&NumVars. + 1);
       %let test = %scan(&VarName, &NumVars.);
    %end;
    %let NumVars = %eval(&NumVars. - 1);
    %do i=1 %to &NumVars. ;
       %let VarNum&i = %scan(&VarName., &i.);
    %end;

    %do i=1 %to &NumVars. ;
       proc freq data=&DSName. ;
          tables &&VarNum&i.. / noprint out=ReptDS;
       run;
       data ReptDS;
          set ReptDS;
          if count > 1;
       run;
       %TotalRec(inDS=ReptDS);
       %GetNow;
       %if &NumObs= %then %do;
          data ReptNone;
             format Report_None $64. ;
             Report_None = "No multiple occurrances of &&VarNum&i...";
             output ;
          run;
          proc print data=ReptNone noobs;
             var Report_None ;
             Title1 "Macro ReptMulti results reported &now.";
             Title2 "Variable &&VarNum&i.. does not occur multiple times in &DSName.";
          run;
       %end;
       %else %do;
          proc print data=ReptDS;
             var &&VarNum&i.. Count ;
             Title1 "Macro ReptMulti results reported &now.";
             Title2 "Variable &&VarNum&i.. occurs multiple times in &DSName.";
          run;
       %end;
       Title ;
    %end;
    proc datasets Lib=work nolist;
       delete ReptDS ReptNone ;
    run;
    quit;
 %mend ReptMulti;

/*======================================================================================================*
 | Macro Name : TransMac                                                                                |
 | Stored As  : \\Pacmet-svr\users\Don\toolbox.SAS                                                      |
 | Author     : Don Murray                                                                              |
 | Purpose    : convert a column of data to a macro array; That is a series of macro variables all      |
 |              with the same stem with an index tacked on the right side.                              |
 | SubMacros  : TotalRec (see above)                                                                    |
 | Notes      : This is especially useful while sequencing response vectors in elaborate ways.          |
 | Usage      : %TransMac(DSName=ItemCalibMap, VarName=ItemID, Prefx=I_ID) would assign the contents    |
 |              of ItemID in dataset ItemCalibMap to macro variables I_ID1 .. I_IDn where n is the      |
 |              number of observations in ItemCalibMap.                                                 |
 |------------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                          |
 | ....name........  ....description................................................................... |
 |  DSName            Name of input dataset containing field of interest.  Can be two-level DS name.    |
 |  VarName           Name of field of interest from input dataset.  This can be only a single field.   |
 |                    Call the macro again for successive applications to additional fields.            |
 |  Prefx             Stem of series of macro variables.                                                |
 |  NumObs            Output macro variable that holds the number of observations in the input dataset. |
 |                    This is not specified in the macro parameter list.  It is a result of the         |
 |                    application of TotalRec.                                                          |
 |------------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                                  |
 | ..date.....  ....description........................................................................ |
 | 18 MAY 2005  Initial Logic Development.  I had implemented this often enough in mid-project code     |
 |              that I decided it was time to design it properly.                                       |
 *======================================================================================================*/
 %macro TransMac(DSName=, VarName=, Prefx=);
    data _SupDS;
       set &DSName (keep=&VarName) ;
    run;
    %TotalRec(inDS=_SupDS);
    %do i=1 %to &NumObs;
       %global &Prefx&i ;
    %end;    
    proc transpose data=_SupDS out=_outTrns prefix=pfx ;
       var &VarName ;
    run;
    data _null_;
       set _outTrns ;
       array pfx(&NumObs) pfx1-pfx&NumObs ;
       %do i=1 %to &NumObs;
          call symput("&Prefx&i", pfx(&i));
       %end;
    run;
    %do i=1 %to &NumObs;
       %let &Prefx&i=&&&Prefx&i ;
    %end;
 %mend TransMac ;

/*=================================================================================================*
 | Macro Name : CumFD                                                                              |
 | Stored As  : U:\Don\toolbox.sas                                                                 |
 | Author     : Don Murray                                                                         |
 | Purpose    : Compute cumulative frequency and percent columns and incorporate them into an      |
 |              otherwise standard SAS FD dataset.                                                 |
 | SubMacros  : DSExists and VarExists stored under u:\Don\toolbox.sas                             |
 | Notes      : This macro will return an FD dataset that its three original columns plus two      |
 |              additional columns: 1) CumFrq - a cumulative expression of count.                  |
 |              2) CumPct - a cumulative expression of percent.                                    |
 |              This logic is developed separately to facilitate re-use of code and encourage      |
 |              an object oriented approach to SAS code development.                               |
 | Usage      : This logic was developed as part of the equipercentile equating macro used in      |
 |              the North Carolina vertical scaling project.                                       | 
 |-------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                     |
 | ....name........  ....description.............................................................. |
 |  inFD              Name of input FD dataset                                                     |
 |  outCumFD          Name of output FD dataset which will include two new cumulative columns.     |
 |-------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                             |
 | ..date.....  ....description....................................................................|
 | 15 SEP 2006  Initial Logic Development.                                                         |
 *=================================================================================================*/
 %macro CumFD(inFD, outCumFD);
    %DSExists(DsName=&inFD.);
    %let inFDExists=&DSExists.;
    %if &inFDExists %then %do;
       %VarExists(&inFD., count);
       %let CountExists=&VarExists.;
       %VarExists(&inFD., percent);
       %let PercentExists=&VarExists.;
       %if &CountExists and &PercentExists %then %do;
          data &outCumFD.;
             set &inFD. ;
             format CumFrq 6.0 CumPct 10.3;
             retain CumFrq 0 CumPct 0;
             label CumFrq='Cumulative Frequency' CumPct='Cumulative Percent';
             CumFrq = CumFrq + count;
             CumPct = CumPct + percent;
          run;
       %end;
       %else %if not &CountExists. %then %do;
          put "*** ERROR: CumFD macro message => No field named 'count' exists on dataset &inFD.";
       %end;
       %else %if not &PercentExists. %then %do;
          put "*** ERROR: CumFD macro message => No field named 'percent' exists on dataset &inFD.";
       %end;
    %end;
    %else %do;
       put "*** ERROR: CumFD macro message => No dataset exists named &inFD.";
    %end;
 %mend CumFD;

/*=================================================================================================*
 | Macro Name : CSList.sas                                                                         |
 | Stored As  : D:\Server\U\Don\CSList.sas                                                         |
 | Author     : Don Murray                                                                         |
 | Purpose    : From a variable in a SAS dataset create a text file containing a comma separated   |
 |              list.                                                                              |
 | SubMacros  : SetYYYYMMDD, SetHHMMSS (both from toolbox.sas)                                     |
 | Notes      : A strong motivation for developing this is the need for comma separated lists of   |
 |              tf_ids and tfs_ids while developing score file code for EOC administrations.       |
 | Usage      : %CSList(C:\User, ZL, IDList, ThisID); will write the output comma separated list   |
 |                 as a text file to C:\User\ZL_ThisID_YYYYMMDDHHMMSS.txt.  The content of the     |
 |                 list comes from ThisID from the SAS dataset named IDList.                       |
 |-------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                     |
 | ....name........  ....description.............................................................. |
 |  TargFldr          Target folder to which the output text file will be written.                 |
 |  Cnt               This is a set of characters to begin the output text file name with          |
 |                       (typically a two to four letter content area code).                       |
 |  inDS              Name of input SAS dataset (can be two level).                                |
 |  Dstl              This is a boolean (0 or 1) that instructs the logic to reduce the input      |
 |                       dataset and variable to one instance per value.                           |
 |  inVar             variable that will provide content for the comma separated list.             |
 |  Encls             This is a boolean (0 or 1) that instructs the logic to enclose each element  |
 |                    in the list in single quotes.                                                |
 |-------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                             |
 | ..date.....  ....description....................................................................|
 | 16 MAR 2011  Initial Logic Development.                                                         |
 | 2014 03 27   I had to debug the functionality dependent on Encls=1.                             |
 *=================================================================================================*/
 %macro CSList(TargFldr, Cnt, inDS, Dstl, inVar, Encls);
    %SetYYYYMMDD;
    %SetHHMMSS;
    FileName OutLst "&TargFldr.\&Cnt._&inVar._&YYYYMMDD&HHMMSS..txt";
    %if &Dstl=1 %then %do;
       %DstlDS(inDS=&inDS., inVar=&inVar., outDS=TmpDS);
    %end;
    %else %do;
       data TmpDS;
          set &inDS.;
       run;
    %end;
    data _null_;
       set TmpDS end=lastone;
       file OutLst;
       format OutLine $112.;
       length OutLine $112;
       retain OutLine LineLen;
       if _n_ = 1 then do;
          OutLine = repeat(' ', 111);
          %if &Encls=1 %then %do;
             LineLen = length(compress(&inVar.)) + 6;
             substr(OutLine, 1, LineLen) = compress("('"||&inVar.||"',");
          %end;
          %else %do;
             LineLen = length(compress(&inVar.)) + 4;
             substr(OutLine, 1, LineLen) = compress('('||&inVar.||',');
          %end;
       end;
       else do;
          if LineLen > 100 then do;
             put OutLine;
             LineLen = 0;
             OutLine = repeat(' ', 124);
             if lastone then do;
                %if &Encls=1 %then %do;
                   LineLen = length(compress(&inVar.)) + 3;
                   substr(OutLine, 2, LineLen) = compress("'"||&inVar.||"')");
                %end;
                %else %do;
                   LineLen = length(compress(&inVar.)) + 1;
                   substr(OutLine, 2, LineLen) = compress(&inVar.||')');
                %end;
                put OutLine;
             end;
             else do;
             	 %if &Encls=1 %then %do;
             	    LineLen + length(compress(&inVar.)) + 6;
                  substr(OutLine, 2, LineLen) = compress("'"||&inVar.||"',");
               %end;
               %else %do;
                  LineLen + length(compress(&inVar.)) + 4;
                  substr(OutLine, 2, LineLen) = compress(&inVar.||',');
               %end;
             end;
          end;
          else do;
             if lastone then do;
                %if &Encls=1 %then %do;
                   ThisPiece = length(compress(&inVar.)) + 3;
                   substr(OutLine, LineLen, ThisPiece) = compress("'"||&inVar.||"')");
                %end;
                %else %do;
                   ThisPiece = length(compress(&inVar.)) + 1;
                   substr(OutLine, LineLen, ThisPiece) = compress(&inVar.||')');
                %end;
                put OutLine;
             end;
             else do;
             	%if &Encls=1 %then %do;
             	   ThisPiece = length(compress(&inVar.)) + 4;
                 substr(OutLine, LineLen, ThisPiece) = compress("'"||&inVar.||"',");
              %end;
              %else %do;
                 ThisPiece = length(compress(&inVar.)) + 2;
                 substr(OutLine, LineLen, ThisPiece) = compress(&inVar.||',');
              %end;
             	LineLen + ThisPiece;
             end;
          end;
       end;
    run;
 %mend CSList;
 

/*======================================================================================================*
 | Macro Name : DS2HTML                                                                                 |
 | Stored As  : \\Pacmet-svr\users\Don\toolbox.sas                                                      |
 | Author     : Don Murray                                                                              |
 | Purpose    : Write html representation of SAS dataset                                                |
 | SubMacros  : TransMac, TotalRec                                                                      |
 | Notes      : This was motivated by the logic and results of Read_Analyse_PASS_CR.sas stored under    |
 |              \\Pacmet-svr\Projects\Louisiana\PASS\2005 Research Study\Programs                       |
 | Usage      : %DS2HTML(DSName=MyLib.MyData, TblHead=Contents of MyLib.MyData,                         |
 |                       TargetFN=C:\Documents and Settings\MyData.html);                               |
 |------------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                          |
 | ....name........  ....description................................................................... |
 |  DSName             Name of input dataset                                                            |
 |  TblHead            Text to put in top row of table (default of blank suppresses top row above       |
 |                        variable names)                                                               |
 |  TargetFN           File reference for target html output file (user to include file extension).     |
 |------------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                                  |
 | ..date.....  ....description........................................................................ |
 | 22 JUN 2005  Initial Logic Development.                                                              |
 *======================================================================================================*/
 %macro DS2HTML(DSName=, TblHead=, TargetFN=);
    data DSName_ ;
       set &DSName ;
    run;
    %let DS_Name=&DSName;
    FileName Out_html "&TargetFN";
   /* Determine how many variables and their names */
    proc contents data=DSName_ noprint out=VarListDS;
    run;
    proc sort data=VarListDS (keep=name type length varnum) ;
       by VarNum ;
    run;
   /* The two macros below (TotalRec and TransMac are both stored under \\Pacmet-svr\users\Don\toolbox.sas) */
    %TotalRec(inDS=VarListDS) ;
    %TransMac(DSName=VarListDS, VarName=Name, Prefx=VrNm);
    %TransMac(DSName=VarListDS, VarName=type, Prefx=typ);
    %TransMac(DSName=VarListDS, VarName=length, Prefx=len);
    data _null_;
       set DSName_ end=LastOne ;
       file Out_html lrecl=512 ;
       if _n_=1 then do;
          put '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"';
          put '    "http://www.w3.org/TR/html4/loose.dtd">';
          put "<html><head><title>&DS_Name.</title>" ;
          put '  <META NAME="author" CONTENT="Don Murray">';
          put '  <META NAME="date" CONTENT="'  %str("%sysfunc(date(),yymmdd10.)") '">';
          put '  <META NAME="description" CONTENT="This HTML page was generated by SAS using custom SAS code.">';
          put '</head>';
          put '<body><table '
              'summary="HTML page generated by SAS" '
              'border=1 cellspacing=2 cellpadding=4>';
          %if "&TblHead" ne "" %then %do;
             put "<tr><td colspan=&NumObs. bgcolor=#ffffbb><font face=arial size=3><b>&TblHead.</b></font></td></tr>";
          %end;
          put '  <tr>';
          %do i=1 %to &NumObs;
             %if &&typ&i=2 %then %do;
                   %if &&len&i < 12 %then %let AlnFld=center;
                   %else %let AlnFld=left;
                %end;
             %else %let AlnFld=right ;
             put "    <td align=&AlnFld. bgcolor=#ffffbb><font face=arial size=3><b>&&VrNm&i..</b></font></td>";
          %end;
          put '  </tr>';
       end;
       put "  <tr>";
       %do i=1 %to &NumObs;
       %if &&typ&i=2 %then %do;
          %if &&len&i < 12 %then %let AlnFld=center;
                %else %let AlnFld=left;
             %end;
          %else %let AlnFld=right ;
          put "    <td align=&AlnFld.><font face=courier size=3>" &&VrNm&i.. "</font></td>" ;
       %end;
       put "  </tr>";
       if LastOne then do;
          put '</table>' ;
          put '</body>' ;
          put '</html>' ;
       end;
    run;
 %mend DS2HTML;

/*=================================================================================================*
 | Macro Name : Read_PMF                                                                           |
 | Stored As  : E:\Server\U\Don\Parscale\Read_PMF.sas                                              |
 | Author     : Don Murray                                                                         |
 | Purpose    : Read parameter files in PMF form (output from transcale)                           |
 | SubMacros  : none                                                                               |
 | Notes      : Need to verify transformation variable locations in PMF file.                      |
 | Usage      : %let TrgLib=C:\Projects\Louisiana\IMS\12OC2005_2004Data;                           |
 |              libname OutSDS "&TrgLib.";                                                         |
 |              %Read_PMF(in_pmf=&TrgLib.\10-Math_2004_Eq_Cal-2_D2.pmf,                            |
 |                        out_sds=OutSDS.Pmf_Data);                                                |
 |              The above three statements would read the referenced pmf file and write out a      |
 |              SAS dataset named Pmf_Data.                                                        |
 |-------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                     |
 | ....name........  ....description.............................................................. |
 |  in_pmf            path and file name of input parameter file in pmf form                       |
 |  out_sds           name of output sas dataset (can be two level name).  Default = PMF_Data      |
 |-------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                             |
 | ..date.....  ....description....................................................................|
 | 12 OCT 2005  Initial Logic Development.  Logic is based on PAR2SAS in toolbox.sas               |
 | 21 FEB 2006  Added logic to determine from the file both firstobs and maxlevl.  I also had to   |
 |              make items sequence string to account for ELA items 1A, 1B, and 1C.                |
 | 20 JUN 2006  implemented logic for MC only tests since the MaxLvl sort of bombs for these.      |
 | 13 NOV 2006  Changed Item_Seq in/format to $5. from $4.  I also removed that "@" column wise    |
 |              read specification (lines 91 and 93).  These changes were necessitated by          |
 |              P:\Louisiana\2004 Fall Restest\Calib\10-Math\10-Math_2004_Fall_EQ_.pmf             |
 | 14 MAR 2007  Increased ItmSq and Item_Seq format from $6. to $8. to accommodate item_IDs.       |
 | 30 OCT 2007  Changed format / informat on Item_Status from 2.0 to $2. to avoid downstream       |
 |              type conflicts.  DRC often sets Item_Status to letters O or A to mark OP vs. Anch. |
 | 14 AUG 2009  Changed the names of guessing and location to guess and locate to match IMS data   |
 |              handling code.                                                                     |
 *=================================================================================================*/
%macro Read_PMF(in_pmf=, out_sds=PMF_Data);
   FileName PMF_File "&in_pmf";
   data FrstDLine;
      retain FstObs 0 ;
      infile PMF_File ;
      input ; 
      select ;
         when(index(_infile_, '...End of Comments...')>0) FstObs=_n_ + 2;
         otherwise ;
      end;
      call symput('First_Obs', FstObs);
   run;
   %let First_Obs=&First_Obs;
   data MxLvl;
      format ItmSq $8. Lvl 3.0 ;
      infile PMF_File firstobs=&First_Obs.;
      input ItmSq $ Lvl;
   run;
   proc means data=MxLvl max noprint;
      var Lvl ;
      output out=OutMax max=MaxLvl;
   run;
   data _null_;
      set OutMax;
      call symput('MaxLevl', MaxLvl);
   run;
   %let MaxLevl=&MaxLevl;
   %if &MaxLevl=1 %then %do; /* Test of only MC items */
      data &out_sds. ;
           %let _EFIERR_ = 0; /* set the ERROR detection */
           format   Item_Seq $8.  Item_level 3.0
                    slope 7.5  locate 9.5  guess 7.5 
                    Item_Status $2.  m1 7.4  m2 9.4  v1  7.4  v2  9.4;
           informat Item_Seq $8.  Item_level 3.0
                    slope 7.5  locate 9.5  guess 7.5 
                    Item_Status $2.  m1 7.4  m2 9.4  v1  7.4  v2  9.4;
           infile PMF_File firstobs=&First_Obs.;   /* Verify this before using */
           input Item_Seq $ Item_level slope locate guess item_status m1 m2 v1 v2 ;
           if _ERROR_ then call symput('_EFIERR_',1);  /* set det. */
      run;
   %end;
   %else %do; /* Test has some CR items in it */
      data &out_sds. ;
           %let _EFIERR_ = 0; /* set the ERROR detection */
           format   Item_Seq $8.  Item_level 3.0
                    slope 7.5  locate 9.5  guess 7.5 
                    %do i=1 %to %eval(&MaxLevl - 2);
                        step_&i
                    %end;
                    9.5
                    Item_Status $2.  m1 7.4  m2 9.4  v1  7.4  v2  9.4;
           informat Item_Seq $8.  Item_level 3.0
                    slope 7.5  locate 9.5  guess 7.5 
                    %do i=1 %to %eval(&MaxLevl - 2);
                        step_&i
                    %end;
                    9.5
                    Item_Status $2.  m1 7.4  m2 9.4  v1  7.4  v2  9.4;
           infile PMF_File firstobs=&First_Obs.;   /* Verify this before using */
           input Item_Seq $ Item_level @;
           select (Item_level);
               when (1) input slope locate guess item_status m1 m2 v1 v2 ;
               %do j=3 %to &MaxLevl;
                   when (&j) input slope locate
                   %do k=1 %to %eval(&j-2);
                       step_&k
                   %end;
                   Item_Status $ m1 m2 v1 v2 ;
               %end;
           end;    /* select (itm_levls) */
           if _ERROR_ then call symput('_EFIERR_',1);  /* set det. */
      run;
   %end;
%mend Read_PMF;


/*============================================================================*
 | Macro Name : PAR2SAS                                                       |
 | Stored As  : U:\SAS_Work\PAR2SAS.SAS                                       |
 | Author     : Don Murray                                                    |
 | Purpose    : Read Parameter file output from pardux, create a SAS dataset  |
 |              with the same name as the input file on the work library.     |
 | SubMacros  : none                                                          |
 | Notes      : The file extension of ".PAR" is added by the macro.           |
 | Usage      : %let PCPath=M:\Projects\Missouri\2003_Spg;                    |
 |              %PAR2SAS(PathRef=&PCPath.\EFTCal\CA\Grd03,                    |
 |                       FileRef=CA03, Prt=N);                                |
 |----------------------------------------------------------------------------|
 | PARAMETERS:                                                                |
 | ....name........  ....description......................................... |
 |  PathRef           Path to location of *.PAR file                          |
 |  FileRef           Name of PAR file (without extentsion -- see Note above) |
 |  Prt               Y for "yes, print PAR data" or N for "No prints thanks" |
 |----------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                        |
 | ..date.....  ....description...............................................|
 | 04 APR 2002  Initial Logic Development.                                    |
 | 22 SEP 2003  Added Item Level of zero for turned off items and added this  |
 |              macro header block.                                           |
 | 04 FEB 2005  Renamed variables a little more descriptively.  These names   |
 |              match the Missouri Item database column names.                |
 *============================================================================*/
%macro PAR2SAS(PathRef=,FileRef=,Prt=N);
    FileName PAR_File "&PathRef.\&FileRef..PAR";
    data WORK.&FileRef.;
        %let MaxLevl=9;
        %let _EFIERR_ = 0; /* set the ERROR detection */
        infile PAR_File lrecl=250 firstobs=2;
        format  RWO_Seq 3.0  Item_level 1.0
                irt_a 7.5  irt_b 9.4  irt_c 6.4
                irt_alpha 7.5
                %do i=1 %to %eval(&MaxLevl - 1);
                    irt_gamma&i
                %end;
                7.4
                Item_Status 2.0  m1 7.4  m2 9.4;
        informat  RWO_Seq 3.0  Item_level 1.0
                irt_a 7.5  irt_b 9.4  irt_c 6.4
                irt_alpha 7.5
                %do i=1 %to %eval(&MaxLevl - 1);
                    irt_gamma&i
                %end;
                7.4
                Item_Status 2.0  m1 7.4  m2 9.4;
        input @ 1 RWO_Seq
              @ 6 Item_level @;
        select (Item_level);
            when (0) input @ 8 irt_a Item_Status m1 m2;
            when (1) input @ 8 irt_a irt_b irt_c Item_Status m1 m2;
            %do j=2 %to &MaxLevl;
                when (&j) input @8 irt_alpha
                %do k=1 %to %eval(&j-1);
                    irt_gamma&k
                %end;
                Item_Status m1 m2;
            %end;
        end;    /* select (itm_levls) */
        if _ERROR_ then call symput('_EFIERR_',1);  /* set det. */
    run;
    %if &Prt=Y %then %do;
        proc print data=WORK.&FileRef.;
            Title1 "Contents of SAS DS: WORK.&FileRef..";
        run;
        Title1;
    %end;
%mend PAR2SAS;

%macro Common_Fmts;
    proc format;
       /*--------------------------------------------------------*
        | Format to convert 1, 0 to Yes, No.                     |
        *--------------------------------------------------------*/
        value fmt_YN
            0='N'
            1='Y'
         other =' '
        ;
        value fmt_YNE
            1='Y'
         other ='N'
        ;
        value $fmt_YN
            '0'='N'
            '1'='Y'
         other =' '
        ;
       /*--------------------------------------------------------*
        | Formats for responses (rsp) and scores (rwo)           |
        | Designed for Clarity export for TABE CRT-GED Linking.  |
        *--------------------------------------------------------*/
        value $rsp
            '1'='1'   '2'='2'   '3'='3'   '4'='4'   '5'='5'   '*'=' '
            'A'='1'   'B'='2'   'C'='3'   'D'='4'   'E'='5'
            'F'='1'   'G'='2'   'H'='3'   'J'='4'   ' '=' '
            'a'='1'   'b'='2'   'c'='3'   'd'='4'   'e'='5'   other=' '
            ;
        value $rwo
            '1'-'5'=0   '*'=0   ' '=0
            'A'-'E'=1   'a'-'e'=1  other=0
            ;
       /*--------------------------------------------------------*
        | Format for responses (rsp) and scores (rwo) designed   |
        | for Winscore export for TABE CRT-GED Linking.          |
        *--------------------------------------------------------*/
        value $WinScr
            '0'=0   '1'=1   '2'=2   '3'=3   '4'=4   '5'=5
            '6'=6   '7'=7   '8'=8   '9'=9   '*'=.   '-'=.
            ' '=.   other=.
            ;
       /*--------------------------------------------------------*
        | Formats to relate month to number & vice-versa.        |
        *--------------------------------------------------------*/
        value $Num2Mon
            '01'='Jan'
            '02'='Feb'
            '03'='Mar'
            '04'='Apr'
            '05'='May'
            '06'='Jun'
            '07'='Jul'
            '08'='Aug'
            '09'='Sep'
            '10'='Oct'
            '11'='Nov'
            '12'='Dec'
          other ='Err'
        ;
        value $Mon2Num
            'Jan'='01'
            'Feb'='02'
            'Mar'='03'
            'Apr'='04'
            'May'='05'
            'Jun'='06'
            'Jul'='07'
            'Aug'='08'
            'Sep'='09'
            'Oct'='10'
            'Nov'='11'
            'Dec'='12'
           other ='Er'
        ;
    run;
%mend Common_Fmts;

 /*==================================================================*
  | Macro Name : TrimCharVars                                        |
  | Stored in  : toolbox.sas                                         |
  | Author     : Don Murray                                          |
  | Purpose    : Trim Character Variable formats and informats to    |
  |              their observed maximum instance within a given      |
  |              dataset.                                            |
  | SubMacros  : none                                                |
  | Notes      : This is most useful when used on certain PEID data  |
  |              extractions.                                        |
  | Usage      : %TrimCharVars(inDS=SASLBR.edt_file,outDS=edt_out);  |
  |              would determine the ideal informat / format lenghts |
  |              of all character variables in SASLBR.edt_file to    |
  |              apply so that a minumum of white space is committed |
  |              when edt_out is stored.                             |
  |------------------------------------------------------------------|
  | PARAMETERS:                                                      |
  | ..name.....  ..description...................................... |
  |   inDS       Input dataset to be "storage space optimized".      |
  |  outDS       Output dataset created with optimum informats and   |
  |              formats based on the contents of each character     |
  |              variable in inDS.                                   |
  |------------------------------------------------------------------|
  | PRODUCTION HISTORY:                                              |
  | ..date.....  ..description...................................... |
  | 18 APR 2003  Initial Logic Development.                          |
  | 13 SEP 2004  I added the proc datasets statement at the end to   |
  |              clean up work datasets that are not used after      |
  |              this macro executes.  This was motivated by the     |
  |              fact that SAS Enterprise Guide shows all work       |
  |              datasets in the Process Flow pane.                  |
  | 06 APR 2005  Copied intact from utils.mac.sas to toolbox.sas     |
  |              (i.e. ctb2pacmet)                                   |
  | 25 SEP 2006  Changed macro variables to positional structure.    |
  | 11 NOV 2009  Added length statement to character var re-         |
  |              characterization step in addition to the informat   |
  |              and format statements.                              |
  *==================================================================*/
  %macro TrimCharVars(inDS, outDS);
     options nomprint nomlogic nosymbolgen;
     %local NumVars ;
     *                                                          ;
     *  Begin by committing all variable names as well as the   ;
     *  number of variables to macro variables.                 ;
     *                                                          ;
     proc contents data=&inDS noprint out=edtCnt;
     run;
     data _null_;
        set edtCnt end=LastOne;
        call symput('Var'||left(_n_),trim(name));
        if LastOne then call symput('NumVars',_n_);
     run;
     %let NumVars=&NumVars;

     *                                                          ;
     *  Determine the max. occurring length of each variable.   ;
     *                                                          ;
     data edtFile;
        set &inDS;
        %do i=1 %to &NumVars;
           VL&i = length(&&Var&i);
        %end;
     run;
     proc means data=edtFile Max noprint;
        var %do i=1 %to &NumVars;
              VL&i
           %end;
           ;
        output out=MaxVarLn  max=
           %do i=1 %to &NumVars;
              MaxVL&i
           %end;
        ;
     run;
     data varsum;
        set edtCnt;
        if _n_ = 1 then set MaxVarLn;
        %do i=1 %to &NumVars;
           if _n_=&i then MaxVLn = MaxVL&i ;
        %end;
     run;
     data _null_;
        set varsum;
        call symput('CVFLn'||left(_n_),trim(left(MaxVLn)));
        call symput('VType'||left(_n_),trim(left(type)));
     run;

     *                                                          ;
     *  Apply determined maximum variable lengths to format     ;
     *  and informat of character vairables in &outDS.          ;
     *                                                          ;
     data &outDS;
     	  length
     	  %do i=1 %to &NumVars;
           %if &&VType&i=2 %then %do;
               &&Var&i $ &&CVFLn&i..
           %end;
        %end;
        ;
        informat
        %do i=1 %to &NumVars;
           %if &&VType&i=2 %then %do;
               &&Var&i $&&CVFLn&i...
           %end;
        %end;
        ;
        format
        %do i=1 %to &NumVars;
           %if &&VType&i=2 %then %do;
               &&Var&i $&&CVFLn&i...
           %end;
        %end;
        ;
        set &inDS;
     run;
     proc datasets Lib=work nolist;
        delete
           EDTCnt EDTFile MaxVarLn VarSum
         ;
      run;
      quit;
     options mprint;
  %mend TrimCharVars;

/* This macro assumes that the input dataset contains iu_item_id (as IMS_ID) and iu_publication_id */
/* This was added to the toolbox.sas from the EOC IMS data extract code on 2012-02-16 */
%macro KeepMostRecent(inDS=, outDS=);
   data TempDS;
      set &inDS.;
      format _year_ 4.0 YrPrt SsnPrt $2. _season_ 3.0;
      YrPrt = substr(iu_publication_id, 4, 2);
      SsnPrt = substr(iu_publication_id, 7, 2);
      select(YrPrt);
         when('97') _year_ = 1997;
         when('98') _year_ = 1998;
         when('99') _year_ = 1999;
         when('00') _year_ = 2000;
         when('01') _year_ = 2001;
         when('02') _year_ = 2002;
         when('03') _year_ = 2003;
         when('04') _year_ = 2004;
         when('05') _year_ = 2005;
         when('06') _year_ = 2006;
         when('07') _year_ = 2007;
         when('08') _year_ = 2008;
         when('09') _year_ = 2009;
         when('10') _year_ = 2010;
         when('11') _year_ = 2011;
         when('12') _year_ = 2012;
         when('13') _year_ = 2013;
         when('14') _year_ = 2014;
         when('15') _year_ = 2015;
         otherwise ;
      end;
      select(SsnPrt);
         when('WI') _season_ = 1;
         when('SP') _season_ = 2;
         when('SU') _season_ = 3;
         when('FA') _season_ = 4;
      end;
   run;
   proc sort data=TempDS;
      by IMS_ID _year_ _season_;
   run;
   data &OutDS.;
      set TempDS;
      by IMS_ID;
      if last.IMS_ID;
      drop _year_ YrPrt SsnPrt _season_ ;
   run;
%mend KeepMostRecent;

/*-------------------------------------------------------------------*
 | Define IMS libname references through SAS/ACCESS for MySQL        |
 | On 2013.04.05 I adjusted DefLDEE after changes to details for it  |
 |             last fall after the breech.                           |
 *-------------------------------------------------------------------*/
%macro DefStg(dbmt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname IMS_stg mysql user=pacific password=metrics22 database=IMS_m
           server='192.168.10.41' dbmax_text=&dbmt. port=3306;
%mend DefStg;
%macro DefLDEE(dbmt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname IMS_LDEE mysql user=ldedssa password='ssdalde,12212012' database=IMS_ENC
           server='192.168.10.55' dbmax_text=&dbmt. port=3306;
%mend DefLDEE;

/*--------------------------------------------------------------------------------*
 | Define bizwald libname references through SAS/ACCESS for MySQL (2011-06-03)    |
 *--------------------------------------------------------------------------------*/
%macro DefBiz(dbmt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname BizLib mysql user=bizwald password=Blondie database=bizwald_DBM
           server='bizwald.com' dbmax_text=&dbmt. port=3306;
%mend DefBiz;

/*------------------------------------------------------------------------------*
 | Define OMAP libname references through SAS/ACCESS for MySQL (2012-02-20      |
 *------------------------------------------------------------------------------*/
%macro DefOMAP(dbmt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname OMAPLib mysql user=pacific password=metrics22 database=eag_db 
           server='eagmath.pacificmetrics.com' dbmax_text=&dbmt. port=3306;
%mend DefOMAP;

/* This is for the Automated Scoring database */
/* the details were provided by Mitch F. via e-mail at Wed 11/14/2007 10:45 AM */
/* Later details: 
    www.louisianaeoc.org (216.171.219.241)
    as.pacificmetrics.com (216.171.219.252) 
    from e-mail from Sue L.: sent Mon 12/3/2007 3:28 PM
    
    or this:
    mysqlas.pacificmetrics.com
    216.171.219.246
 */
%macro DefAS;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname AS_DB mysql user=pacific password=metrics22 database=auto_scoring_db
           server='mysqlas.pacificmetrics.com' dbmax_text=19000 port=3306;
%mend DefAS;
%macro DefEOC_QA(dbmaxtxt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_QA mysql user=pacific password=metrics22 /* database=EOC_QA */ database=EOC_SPRING_2013
           server='192.168.10.96' /* server='eocqa.pacificmetrics.com' */ dbmax_text=&dbmaxtxt. port=3306;
   /* server changed on 2012-10-26 */
%mend DefEOC_QA;
/* modified on 2014-05-07 to allow for macro driven DB targets */
%macro DefEOCHist(dbYrTrgt=2013, dbAdmnTrgt=SPRING, dbmaxtxt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname Hist mysql user=pacific password=metrics22  database=EOC_&dbAdmnTrgt._&dbYrTrgt.
           server='192.168.10.96' dbmax_text=&dbmaxtxt. port=3306;
%mend DefEOCHist;
%macro DefEOC_DEV;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_DEV mysql user=pacific password=metrics22 database=EOC_DB
           server='216.171.219.149' dbmax_text=19000 port=3306;
%mend DefEOC_DEV;
%macro DefEOC_MM;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_MM mysql user=pacific password=metrics22 database=EOC_COPY_DB
           server='216.171.219.149' port=3306;
%mend DefEOC_MM;
%macro DefEOC_BIG;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_BIG mysql user=pacific password=metrics22 database=EOC_DB_4_29
           server='216.171.219.149' port=3306;
%mend DefEOC_BIG;

/* Updated after IM convo with Dave V. at 15:50 MDT, 15 MARCH 2011 */
/* Connection to BC Networks VPN must be active */
%macro DefEOC_PRD(dbmaxtxt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_PRD mysql user=pacific password=metrics22 database=EOC_PRODUCTION
           server='192.168.10.110' dbmax_text=&dbmaxtxt. port=3306;
%mend DefEOC_PRD;

%macro DefEOC_PRDS(dbmaxtxt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_PRDS mysql user=pacific password=metrics22 database=EOC_DB
           server='mysql2.louisianaeoc.org' dbmax_text=&dbmaxtxt. port=3306;
%mend DefEOC_PRDS;

%macro DefEOC_RPT(dbmaxtxt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_RPT mysql user=pacific password=metrics22 database=EOC_DB_LOCAL
           server='eocreporting.pacificmetrics.com' dbmax_text=&dbmaxtxt. port=3306;
%mend DefEOC_RPT;

/* Added on 23 FEB 2012 to back-fill Dec.2011 admin work */
%macro DefEOC_DB1(dbmaxtxt=2000);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_DB1 mysql user=pacific password=metrics22 database=EOC_PRODUCTION_FL11
           server='eocdb1.pacificmetrics.com' dbmax_text=&dbmaxtxt. port=3306;
%mend DefEOC_DB1;

%macro DefEOC_RSCH;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_RSCH mysql user=pacific password=metrics22 database=EOC_RESEARCH
           server='mysql.louisianaeoc.org' dbmax_text=2000 port=3306;
%mend DefEOC_RSCH;

%macro DefEAGLE;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EAGLELB mysql user=pacific password=metrics22 database=DON_M_05_18_10
           server='eaglestaging.pacificmetrics.com' port=3306;
%mend DefEAGLE;

%macro DefEOCV;
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname EOC_v mysql user=eocuser password=metrics21 database=EOC_v
           server='research.pacificmetrics.com'  port=3306;
%mend DefEOCV;

%macro DefLoc (WhchDB);
	 %if &SYSVER=9.1 %then %do;
      options set=SASMYL MYWIN417;
   %end;
   libname locmysql mysql user=root database=&WhchDB.
           server='localhost' dbmax_text=2000 port=3309;
%mend DefLoc;

/* Added on 2014 04 24 */
%macro DefReptProto(dbmaxtxt=2048);
   libname Proto mysql user=dmurray password=b33rF0rMyH0rses database=EOC_DB_LOCAL
   server='eocreportingproto.pacificmetrics.com' port=3306 dbmax_text=&dbmaxtxt.;
%mend DefReptProto;

/* Added on 2014 05 13 - to experiment with temp schema operations */
%macro DefReptProTemp(dbmaxtxt=2048);
   libname ProTemp mysql user=dmurray password=b33rF0rMyH0rses database=temp
   server='eocreportingproto.pacificmetrics.com' port=3306 dbmax_text=&dbmaxtxt.;
%mend DefReptProTemp;

/* Added on 2014 05 07 */
%macro DefEOCSlave;
   libname Slave mysql user=dmurray password=c0ldb33r database=EOC_PRODUCTION server='db9.pacificmetrics.com' port=13306;
%mend DefEOCSlave;


/*=================================================================================================*
 | Macro Name : Random_Sample                                                                      |
 | Stored As  : F:\Server\U\Don\Random_Sample.sas                                                  |
 | Author     : Don Murray (This technique is from page 23 of the course notes from                |
 |                 SAS Programming III: Advanced Techniques                                        |
 | Purpose    : Obtain a random sample without replacement of a known size from an existing dataset|
 | SubMacros  : TotalRec (from the toolbox.sas of d.murray)                                        |
 | Notes      : Using the seed value of zero on the ranuni function causes the function to use the |
 |              computer clock to initialize the seed.  This results in the non-replicability of   |
 |              the random number stream.  Consequently, running this macro again in the same      |
 |              manner will result in different random samples.                                    |
 | Usage      : %Random_Sample(inDS=BigOne, outDS=Sampleof200, samp=200                            |
 |              The above would randomly sample 200 cases from the dataset named BigOne and write  |
 |              them to the dataset named Sampleof200                                              |
 |-------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                     |
 | ....name........  ....description.............................................................. |
 |  inDS             Name of the dataset from which to draw the sample                             |
 |  outDS            Name of the dataset to which the sample will be written                       |
 |  samp             The number of cases to draw                                                   |
 |-------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                             |
 | ..date.....  ....description....................................................................|
 | 11 MAY 2010  Initial Logic Development of the macro.  I have used this technique outside of a   |
 |              macro several times before.                                                        |
 *=================================================================================================*/
%macro Random_Sample(inDS=, outDS=, samp=);
   %TotalRec(inDS=&inDS.);
   data &outDS.;
      SampSize=&samp.;
      ObsLeft=&NumObs.;
      do while(SampSize > 0);
         PickIt + 1;
         If ranuni(0) < SampSize / ObsLeft then do;
            set &inDS. point=PickIt  nobs=TotObs;
            output;
            SampSize=SampSize - 1;
         end;
         ObsLeft=ObsLeft - 1;
      end;
      stop;
   run;
%mend Random_Sample;

/*=================================================================================================*
 | Macro Name : ApplyENG2ExclLogic                                                                 |
 | Stored As  : toolbox.sas                                                                        |
 | Author     : Don Murray                                                                         |
 | Purpose    : Keep an item record for an EOC ENG2 item only from a form value as designated      |
 |              by Matt Schulz.                                                                    |
 | SubMacros  : None                                                                               |
 | Notes      :                                                                                    |
 | Usage      : Simply invoke %ApplyENG2ExclLogic for an ENG2 loop.
 |-------------------------------------------------------------------------------------------------|
 | PARAMETERS:                                                                                     |
 | ....name........  ....description.............................................................. |
 |-------------------------------------------------------------------------------------------------|
 | PRODUCTION HISTORY:                                                                             |
 | ..date.....  ....description....................................................................|
 | 28 AUG 2012  Initial Logic Development.  See D:\Server\Z\EOC\Data_Pulls\20120828\               |
 |              IMS Upload Specs w logic.xls                                                       |
 *=================================================================================================*/
%macro ApplyENG2ExclLogic;
   if iu_item_id='300450.1' then do; if iu_form='A'; end;
   if iu_item_id='300450.2' then do; if iu_form='A'; end;
   if iu_item_id='300660' then do; if iu_form='A'; end;
   if iu_item_id='300661' then do; if iu_form='A'; end;
   if iu_item_id='300663' then do; if iu_form='A'; end;
   if iu_item_id='300664' then do; if iu_form='A'; end;
   if iu_item_id='300665' then do; if iu_form='A'; end;
   if iu_item_id='300667' then do; if iu_form='A'; end;
   if iu_item_id='300669' then do; if iu_form='A'; end;
   if iu_item_id='300670' then do; if iu_form='A'; end;
   if iu_item_id='300744' then do; if iu_form='A'; end;
   if iu_item_id='300647' then do; if iu_form='A'; end;
   if iu_item_id='300486' then do; if iu_form='A'; end;
   if iu_item_id='300489' then do; if iu_form='A'; end;
   if iu_item_id='300685' then do; if iu_form='A'; end;
   if iu_item_id='300589' then do; if iu_form='A'; end;
   if iu_item_id='300644' then do; if iu_form='A'; end;
   if iu_item_id='300642' then do; if iu_form='A'; end;
   if iu_item_id='300671' then do; if iu_form='A'; end;
   if iu_item_id='300674' then do; if iu_form='A'; end;
   if iu_item_id='300676' then do; if iu_form='A'; end;
   if iu_item_id='300677' then do; if iu_form='A'; end;
   if iu_item_id='300678' then do; if iu_form='A'; end;
   if iu_item_id='300679' then do; if iu_form='A'; end;
   if iu_item_id='300680' then do; if iu_form='A'; end;
   if iu_item_id='300681' then do; if iu_form='A'; end;
   if iu_item_id='300593' then do; if iu_form='A'; end;
   if iu_item_id='300635' then do; if iu_form='A'; end;
   if iu_item_id='300591' then do; if iu_form='A'; end;
   if iu_item_id='300737' then do; if iu_form='A'; end;
   if iu_item_id='300538' then do; if iu_form='A'; end;
   if iu_item_id='300738' then do; if iu_form='A'; end;
   if iu_item_id='300636' then do; if iu_form='A'; end;
   if iu_item_id='300539' then do; if iu_form='A'; end;
   if iu_item_id='300699.1' then do; if iu_form='B'; end;
   if iu_item_id='300699.2' then do; if iu_form='B'; end;
   if iu_item_id='300573' then do; if iu_form='B'; end;
   if iu_item_id='300574' then do; if iu_form='B'; end;
   if iu_item_id='300576' then do; if iu_form='B'; end;
   if iu_item_id='300577' then do; if iu_form='B'; end;
   if iu_item_id='300578' then do; if iu_form='B'; end;
   if iu_item_id='300579' then do; if iu_form='B'; end;
   if iu_item_id='300581' then do; if iu_form='B'; end;
   if iu_item_id='300582' then do; if iu_form='B'; end;
   if iu_item_id='300599.1' then do; if iu_form='C'; end;
   if iu_item_id='300599.2' then do; if iu_form='C'; end;
   if iu_item_id='300521' then do; if iu_form='C'; end;
   if iu_item_id='300523' then do; if iu_form='C'; end;
   if iu_item_id='300525' then do; if iu_form='C'; end;
   if iu_item_id='300528' then do; if iu_form='C'; end;
   if iu_item_id='300532' then do; if iu_form='C'; end;
   if iu_item_id='300527' then do; if iu_form='C'; end;
   if iu_item_id='300530' then do; if iu_form='C'; end;
   if iu_item_id='300531' then do; if iu_form='C'; end;
   if iu_item_id='300511' then do; if iu_form='C'; end;
   if iu_item_id='300512' then do; if iu_form='C'; end;
   if iu_item_id='300510' then do; if iu_form='C'; end;
   if iu_item_id='300515' then do; if iu_form='C'; end;
   if iu_item_id='300516' then do; if iu_form='C'; end;
   if iu_item_id='300517' then do; if iu_form='C'; end;
   if iu_item_id='300518' then do; if iu_form='C'; end;
   if iu_item_id='300519' then do; if iu_form='C'; end;
   if iu_item_id='300745' then do; if iu_form='C'; end;
   if iu_item_id='300583' then do; if iu_form='C'; end;
   if iu_item_id='300585' then do; if iu_form='C'; end;
   if iu_item_id='300488' then do; if iu_form='C'; end;
   if iu_item_id='300586' then do; if iu_form='C'; end;
   if iu_item_id='300684' then do; if iu_form='C'; end;
   if iu_item_id='300687' then do; if iu_form='C'; end;
   if iu_item_id='300688' then do; if iu_form='C'; end;
   if iu_item_id='300463' then do; if iu_form='C'; end;
   if iu_item_id='300502' then do; if iu_form='C'; end;
   if iu_item_id='300465' then do; if iu_form='C'; end;
   if iu_item_id='300466' then do; if iu_form='C'; end;
   if iu_item_id='300504' then do; if iu_form='C'; end;
   if iu_item_id='300468' then do; if iu_form='C'; end;
   if iu_item_id='300469' then do; if iu_form='C'; end;
   if iu_item_id='300470' then do; if iu_form='C'; end;
   if iu_item_id='300735' then do; if iu_form='C'; end;
   if iu_item_id='300692' then do; if iu_form='C'; end;
   if iu_item_id='300637' then do; if iu_form='C'; end;
   if iu_item_id='300736' then do; if iu_form='C'; end;
   if iu_item_id='300598' then do; if iu_form='C'; end;
   if iu_item_id='300696' then do; if iu_form='C'; end;
   if iu_item_id='300597' then do; if iu_form='C'; end;
   if iu_item_id='300594' then do; if iu_form='C'; end;
   if iu_item_id='300700.1' then do; if iu_form='E'; end;
   if iu_item_id='300700.2' then do; if iu_form='E'; end;
   if iu_item_id='300601' then do; if iu_form='E'; end;
   if iu_item_id='300602' then do; if iu_form='E'; end;
   if iu_item_id='300604' then do; if iu_form='E'; end;
   if iu_item_id='300606' then do; if iu_form='E'; end;
   if iu_item_id='300607' then do; if iu_form='E'; end;
   if iu_item_id='300608' then do; if iu_form='E'; end;
   if iu_item_id='300611' then do; if iu_form='E'; end;
   if iu_item_id='300612' then do; if iu_form='E'; end;
   if iu_item_id='300721' then do; if iu_form='E'; end;
   if iu_item_id='300722' then do; if iu_form='E'; end;
   if iu_item_id='300723' then do; if iu_form='E'; end;
   if iu_item_id='300724' then do; if iu_form='E'; end;
   if iu_item_id='300725' then do; if iu_form='E'; end;
   if iu_item_id='300726' then do; if iu_form='E'; end;
   if iu_item_id='300727' then do; if iu_form='E'; end;
   if iu_item_id='300731' then do; if iu_form='E'; end;
   if iu_item_id='300485' then do; if iu_form='E'; end;
   if iu_item_id='300542' then do; if iu_form='E'; end;
   if iu_item_id='300748' then do; if iu_form='E'; end;
   if iu_item_id='300484' then do; if iu_form='E'; end;
   if iu_item_id='300746' then do; if iu_form='E'; end;
   if iu_item_id='300544' then do; if iu_form='E'; end;
   if iu_item_id='300541' then do; if iu_form='E'; end;
   if iu_item_id='300546' then do; if iu_form='E'; end;
   if iu_item_id='300709' then do; if iu_form='E'; end;
   if iu_item_id='300710' then do; if iu_form='E'; end;
   if iu_item_id='300712' then do; if iu_form='E'; end;
   if iu_item_id='300713' then do; if iu_form='E'; end;
   if iu_item_id='300716' then do; if iu_form='E'; end;
   if iu_item_id='300717' then do; if iu_form='E'; end;
   if iu_item_id='300718' then do; if iu_form='E'; end;
   if iu_item_id='300719' then do; if iu_form='E'; end;
   if iu_item_id='300492' then do; if iu_form='E'; end;
   if iu_item_id='300535' then do; if iu_form='E'; end;
   if iu_item_id='300491' then do; if iu_form='E'; end;
   if iu_item_id='300633' then do; if iu_form='E'; end;
   if iu_item_id='300695' then do; if iu_form='E'; end;
   if iu_item_id='300698' then do; if iu_form='E'; end;
   if iu_item_id='300639' then do; if iu_form='E'; end;
   if iu_item_id='300536' then do; if iu_form='E'; end;
   if iu_item_id='300650.1' then do; if iu_form='F'; end;
   if iu_item_id='300650.2' then do; if iu_form='F'; end;
   if iu_item_id='300550.1' then do; if iu_form='H'; end;
   if iu_item_id='300550.2' then do; if iu_form='H'; end;
   if iu_item_id='300522' then do; if iu_form='H'; end;
   if iu_item_id='300524' then do; if iu_form='H'; end;
   if iu_item_id='300529' then do; if iu_form='H'; end;
   if iu_item_id='300509' then do; if iu_form='H'; end;
   if iu_item_id='300513' then do; if iu_form='H'; end;
   if iu_item_id='300514' then do; if iu_form='H'; end;
   if iu_item_id='300464' then do; if iu_form='H'; end;
   if iu_item_id='300505' then do; if iu_form='H'; end;
   if iu_item_id='300467' then do; if iu_form='H'; end;
%mend ApplyENG2ExclLogic;

/* EthnReptFromVec added on 2014-05-22 to streamline creation of reported ethnicity flags and value
   from st_ethnicity_vector */
%macro EthnReptFromVec;
	 format st_ethn_Hisp st_ethn_AmerInd st_ethn_Asian st_ethn_Black st_ethn_Hawai st_ethn_White Ethn_Rept $1.;
   st_ethn_Hisp=put(substr(compress(put(st_ethnicity_vector, binary6.)), 6, 1), fmt_YN.);
   st_ethn_AmerInd=put(substr(compress(put(st_ethnicity_vector, binary6.)), 5, 1), fmt_YN.);
   st_ethn_Asian=put(substr(compress(put(st_ethnicity_vector, binary6.)), 4, 1), fmt_YN.);
   st_ethn_Black=put(substr(compress(put(st_ethnicity_vector, binary6.)), 3, 1), fmt_YN.);
   st_ethn_Hawai=put(substr(compress(put(st_ethnicity_vector, binary6.)), 2, 1), fmt_YN.);
   st_ethn_White=put(substr(compress(put(st_ethnicity_vector, binary6.)), 1, 1), fmt_YN.);
   if compress(put(st_ethnicity_vector, binary6.))='000000' then Ethn_Rept='0';
   else if st_ethn_Hisp='Y' then Ethn_Rept = '1';
   else if st_ethnicity_vector=2 then Ethn_Rept='2';
   else if st_ethnicity_vector=4 then Ethn_Rept='3';
   else if st_ethnicity_vector=8 then Ethn_Rept='4';
   else if st_ethnicity_vector=16 then Ethn_Rept='5';
   else if st_ethnicity_vector=32 then Ethn_Rept='6';
   else Ethn_Rept='7';
%mend EthnReptFromVec;

/* LogTimer Macro originally found here:
   http://www.sascommunity.org/mwiki/images/a/a1/VIEWS_News_Issue48.pdf  */
%MACRO LogTimer(StartOrEnd);
   %LET StartOrEnd = %UPCASE(&StartOrEnd.);
   %GLOBAL LogTimerWasStarted;
   %GLOBAL SaveStartDateTime;
   %GLOBAL SaveStartCPUtime;
   options nomprint nomlogic nosymbolgen;
   DATA _NULL_;
      DateTime = DATETIME();
      CALL SYMPUT('LogTimerDate',
      TRIM(LEFT(PUT(DATEPART(DateTime), DATE9.))));
      CALL SYMPUT('LogTimerTime',
      TRIM(LEFT(PUT(TIMEPART(DateTime), TIME8.))));
      IF "&StartorEnd" = 'START' THEN
         CALL SYMPUT('SaveStartDateTime',
         PUT(DateTime, 22.10));
         /* maximum precision for saved Start datetime
         to avoid possible negative elapsed time */
      ELSE DO;
         ElapsedSeconds =
         DateTime -
         INPUT(SYMGET('SaveStartDateTime'), 22.10);
         CALL SYMPUT('LogTimerElapsedTime',
         TRIM(LEFT(PUT(ElapsedSeconds, TIME.))));
      END;
   RUN;
   %LET TaskListCommand = %STR('tasklist /v');
   FILENAME TaskList PIPE &TaskListCommand.;
   DATA _NULL_;
      INFILE TaskList LRECL = 224 PAD END = LastOne;
      /* LRECL varies by Windows version.
      224 is appropriate for Windows XP.
      229 is for Windows 2003 Advanced Server. */
      INPUT @1 CommandResponse $CHAR224.;
      IF _N_ GE 4;
      IF INDEX(CommandResponse, "&sysjobID.") NE 0;
      Cumulative_CPUtime =
      TRIM(LEFT(SUBSTR(CommandResponse,
      140, 12)));
      /* offset of Cumulative_CPU_time
      varies by Windows version.
      140 is appropriate for Windows XP.
      145 is for Windows 2003 Advanced Server. */
      Cumulative_CPU_seconds =
      INPUT(Cumulative_CPUtime, HHMMSS12.);
      IF "&StartorEnd." = 'START' THEN
         CALL SYMPUT('SaveStartCPUtime',
         TRIM(LEFT(Cumulative_CPU_seconds)));
      ELSE DO;
         CPU_seconds =
         Cumulative_CPU_seconds -
         INPUT(SYMGET('SaveStartCPUtime'), 8.);
         CALL SYMPUT('LogTimerCPUtime',
         TRIM(LEFT(PUT(CPU_seconds, TIME.))));
      END;
   RUN;
   %PUT *****************************************;
   %IF &StartOrEnd. = START %THEN %DO;
      %PUT Started at &LogTimerTime. on
      &LogTimerDate.;
      %LET LogTimerWasStarted = YES;
   %END;
   %ELSE %IF &StartOrEnd. = END %THEN %DO;
      %IF &LogTimerWasStarted. EQ YES %THEN %DO;
         %PUT Ended at &LogTimerTime. on
         &LogTimerDate.;
         %PUT Elapsed Time (hours:minutes:seconds) =
         &LogTimerElapsedTime.;
         %PUT CPU Time (hours:minutes:seconds) =
         &LogTimerCPUtime.;
      %END;
      %ELSE %DO;
         %PUT LogTimer Macro User ERROR: Invocation
         Value was &StartOrEnd.;
         %PUT But there was no prior invocation with
         Start;
      %END;
   %END;
   %ELSE %DO;
      %PUT LogTimer Macro User ERROR: Invocation
      Value was &StartOrEnd.;
      %PUT Must be Start or End;
   %END;
   %PUT *****************************************;
   options mprint mlogic symbolgen;
%MEND LogTimer;

/* The below three can be found here: http://www.minequest.com/downloads.html */
%macro Fact(_inFact,_outfact);
/**************************************************************************************/
/* _inFact = is a whole number that is the number of elements from which the */
/* factorial is computed. (REQUIRED) */
/* _outFact = the returned Factorial value. */
/* */
/* Name: Fact.SAS */
/* Data: Sourced from MineQuest, LLC. Auth: Phil Rack */
/* Date: 5/15/2007 Revd: */
/* */
/* Copyright (C) 2007 by MineQuest, LLC. All Rights Reserved. */
/**************************************************************************************/
   if (&_infact le 0) or (&_infact eq .) then do; 
      &_outfact = .;
   end;
   else do;
      _counter = &_infact;
      _Fact = 1;
      Do while (_counter > 0);
         _fact = _fact * _counter;
         _counter + -1;
      End;
      &_outfact = _fact;
      drop _counter _fact;
   End;
   /********************************************************************************************/
   /* FACT is copyright (c) 2007 by MineQuest, LLC. All Rights Reserved. */
   /* MineQuest, LLC, 1939 Queensbridge Dr., Columbus, OH USA. */
   /* This Macro Program is proprietary software and is licensed property of MineQuest, LLC. */
   /********************************************************************************************/
%mend Fact;

%Macro Comb(_totelemComb, _sampElemComb, _Comb);
/**************************************************************************************/ 
/* _totelemComb = is a whole number that is the number of elements from which the */ 
/* sample is chosen. (REQUIRED) */ 
/* _samElemComb = the whole number that is the number of chosen elements. (REQUIRED) */ 
/* _Comb = the returned Combination value. */ 
/* */ 
/* Name: Comb.SAS */ 
/* Data: Sourced from MineQuest, LLC. Auth: Phil Rack */ 
/* Date: 5/15/2007 Revd: */ 
/* */ 
/* Copyright (C) 2007 by MineQuest, LLC. All Rights Reserved. */ 
/**************************************************************************************/ 
   if (&_totelemcomb le 0) or (&_totelemcomb = .) or (&_sampelemcomb le 0) or (&_sampelemcomb = .) or (&_totelemcomb lt &_sampElemcomb) then Do;
      &_comb = .;
   End;
   Else Do;
      %fact(&_totelemcomb,_nfact );
      %fact(&_sampElemcomb,_rfact);
      _diff = &_totElemcomb - &_sampElemcomb;
      %fact(_diff,_rfact2);
      &_comb = _nfact / (_rfact * _rfact2);
      drop _nfact _rfact _rfact2 _diff;
   End;
   /********************************************************************************************/
   /* COMB is copyright (c) 2007 by MineQuest, LLC. All Rights Reserved. */ 
   /* MineQuest, LLC, 1939 Queensbridge Dr., Columbus, OH USA. */
   /* This Macro Program is proprietary software and is licensed property of MineQuest, LLC. */
   /********************************************************************************************/
%mend Comb;

%macro Perm(_totelemPerm, _sampElemPerm, _perm);
/**************************************************************************************/ 
/* _totelemPerm = is a whole number that is the number of elements from which the */
/* sample is chosen. (REQUIRED) */
/* _samElemPerm = the whole number that is the number of chosen elements. (REQUIRED) */
/* _Perm = the returned Permutation value. */
/* */
/* Name: PERM.SAS */
/* Data: Sourced from MineQuest, LLC. Auth: Phil Rack */
/* Date: 5/15/2007 Revd: */
/* */
/* Copyright (C) 2007 by MineQuest, LLC. All Rights Reserved. */
/**************************************************************************************/
   if (&_totelemperm le 0) or (&_totelemperm = .) or (&_sampelemperm le 0) or (&_sampelemperm = .) or (&_totelemperm lt &_sampElemperm) then Do;
      &_perm = .;
   End;
   Else Do;
      %fact(&_totelemPerm, _nperm );
      _diffperm = &_totElemPerm - &_sampElemPerm;
      %fact(_diffperm, _rperm);
      &_perm = _nperm / _rPerm;
      Drop _nperm _rperm _diffperm;
   End;
   /********************************************************************************************/
   /* PERM is copyright (c) 2007 by MineQuest, LLC. All Rights Reserved. */
   /* MineQuest, LLC, 1939 Queensbridge Dr., Columbus, OH USA. */
   /* This Macro Program is proprietary software and is licensed property of MineQuest, LLC. */
   /********************************************************************************************/
%mend Perm;

/*-------------------------------------------------------------------*
 | Copied from the January 10, 2006 SAS enews newsletter             |
 *-------------------------------------------------------------------*/
%macro drive(dir,ext);                                                                                                                  
                                                                                                                                        
 /** creates a fileref **/                                                                                                              
                                                                                                                                        
 %let filrf=mydir;                                                                                                                      
                                                                                                                                        
 /** Assigns the fileref of mydir to the directory you passed in **/                                                                    
                                                                                                                                        
 %let rc=%sysfunc(filename(filrf,&dir));                                                                                                
                                                                                                                                        
 /** Opens the directory to be read **/                                                                                                 
                                                                                                                                        
 %let did=%sysfunc(dopen(&filrf));                                                                                                      
                                                                                                                                        
 /** Returns the number of members in the directory you passed in **/                                                                   
                                                                                                                                        
 %let memcnt=%sysfunc(dnum(&did));                                                                                                      
                                                                                                                                        
 /** Loop through entire directory **/                                                                                                  
                                                                                                                                        
  %do i = 1 %to &memcnt;                                                                                                                
                                                                                                                                        
 /** Retrieves the extension of each file in the directory as we go **/                                                                 
 /**  through the loop.  The file is reversed so that the extension **/                                                                 
 /**  is listed first, just in case the filename contains periods.  **/                                                                 
                                                                                                                                        
   %let name=%qsysfunc(reverse(%qscan(%qsysfunc(reverse(%qsysfunc(dread(&did,&i)))),1,.)));                                             
                                                                                                                                        
 /** Check to see if the extension matches the parameter value **/                                                                      
 /** If condition is true print the full name to the log       **/                                                                      
                                                                                                                                        
    %if (%superq(ext) ne and %qupcase(&name) = %qupcase(&ext)) or                                                                       
        (%superq(ext) = and %superq(name) ne) %then                                                                                     
        %put %qsysfunc(dread(&did,&i));                                                                                                 
                                                                                                                                        
  %end;                                                                                                                                 
                                                                                                                                        
 /** Close the directory **/                                                                                                            
                                                                                                                                        
 %let rc=%sysfunc(dclose(&did));                                                                                                        
                                                                                                                                        
%mend drive;                                                                                                                            
                                                                                                                                        
/** First parameter is the directory of where your files are stored. **/                                                                
/** Second parameter is the extension you are looking for.           **/                                                                
/** Leave 2nd paramater blank if you want a list of all the files.   **/                                                                
                                                                                                                                        
/* %drive(c:\,sas) */

