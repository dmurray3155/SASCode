%let wrkHere=E:\SBAC\AnnualStudTest\1819\DRC\NV;
libname libHere "&wrkHere.";

libname metaLib xlsx "&wrkHere.\2018-19_ItemPoolMetadata_Summative.xlsx";

data libHere.Meta1819;
	set metaLib.'2018-19_SummativeMetadata'n;
run;

/*	18923	*/
	