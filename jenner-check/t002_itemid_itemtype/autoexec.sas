/* cap input rows for the captured run */
options obs=100;

/* %GetNow and %TotalRec from toolbox.sas (repo root) -- unmodified, referenced by
   read_itid_ittyp.sas */
%macro GetNow;
    %global now;
    %let time=%sysfunc(time(),timeampm11.);
    %let date=%sysfunc(date(),worddate12.);
    %let now=on &date. at &time;
%mend GetNow;

%macro TotalRec(inDS=);
    %global NumObs;
    %local TotObs;
    data _null_ ;
       set &inDS. end=LastOne ;
       if LastOne then call symput('TotObs', _n_);
    run;
    %let NumObs=&TotObs;
%mend TotalRec;
