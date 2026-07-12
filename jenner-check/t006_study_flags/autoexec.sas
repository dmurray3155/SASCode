/* cap input rows for the captured run */
options obs=100;

/* %GetNow from toolbox.sas (repo root) -- unmodified, referenced by ValidateResults.sas */
%macro GetNow;
    %global now;
    %let time=%sysfunc(time(),timeampm11.);
    %let date=%sysfunc(date(),worddate12.);
    %let now=on &date. at &time;
%mend GetNow;
