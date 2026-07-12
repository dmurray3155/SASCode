/* cap input rows for the captured run */
options obs=100;

/* %GetSnow from toolbox.sas (repo root) -- unmodified, referenced by study_date_times.sas */
%macro GetSNow;
    %global now;
    %let time=%sysfunc(time(),time5.);
    %let date=%sysfunc(date(),date9.);
    %let now=&date. &time;
%mend GetSNow;
