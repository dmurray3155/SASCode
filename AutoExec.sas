/*==============================================================================*
 |  Name: AutoExec.sas                                                          |
 |  Author: Don Murray                                                          |
 |  Purpose: Specify initial setup conditions at SAS session startup.           |
 |  Notes:                                                                      |
 |  Application:                                                                |
 *------- Development History --------------------------------------------------*
 |  05 APR 2005  Initial Logic Development                                      |
 |  19 APR 2007  Added "spool" to my options list.                              |
 |  09 JUL 2008  Added the formchar setting to the options list.                |
 |  03 DEC 2009  Added fullstimer to options for jobs run under SAS V9.2.       |
 *==============================================================================*/
;
 proc setinit;
 run;
 %include 'C:\Users\Donald Murray\Documents\GitHub\SASCode\toolbox.sas';

 %SetOptions
