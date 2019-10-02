/*==================================================================================================*
 | Program	:	SetSessionEnv.sas																																			|
 | Author		:	Don Murray (for Smarter Balanced)																											|
 | Purpose	:	Set scaling and LOT HOT LOSS HOSS macro variables for downstream application					|
 | Macros		: ScaleThetaScore (Defined in this code file).																					|
 | Notes		:	This code file also defines a library to a SAS library on the system SSD.							|
 | Usage		:	Applicable to Measurement Inc IA And calibration data preparation work.  This code		|
 |						is used while processing and scoring student data.																		|
 |--------------------------------------------------------------------------------------------------|
 | AMENDMENT HISTORY:																																								|
 |	..date..... 	....description.................................................................. |
 |	2019 10 01		Copied from 2017-18 project location (D:\SBAC\17-18\Calib) to 2018-19 project			|
 |								location (C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819)	|
 |								and modified for current application for 2018-19.																	|
 *==================================================================================================*/
libname libhere 'C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819';
libname fastwrk 'C:\Users\Donald Murray\Documents\My SAS Files\9.4\FastWork';

/*	ELA:	Slope: 85.8		Int: 2508.2
	Math:	Slope: 79.3		Int: 2514.9
Table 3. Vertical Scaling Constants on the Reporting Metric
Subject Grade Slope (a) Intercept (b)
ELA 3-8, HS 85.8 2508.2
Math 3-8, HS 79.3 2514.9

Table 4. 2014 – 2015 Lowest and Highest Obtainable Scores
Subject Grade
Theta Metric Scale Score Metric
LOT HOT LOSS HOSS
ELA 3 -4.5941 1.3374 2114 2623
ELA 4 -4.3962 1.8014 2131 2663
ELA 5 -3.5763 2.2498 2201 2701
ELA 6 -3.4785 2.5140 2210 2724
ELA 7 -2.9114 2.7547 2258 2745
ELA 8 -2.5677 3.0430 2288 2769
ELA HS -2.4375 3.3392 2299 2795
Math 3 -4.1132 1.3335 2189 2621
Math 4 -3.9204 1.8191 2204 2659
Math 5 -3.7276 2.3290 2219 2700
Math 6 -3.5348 2.9455 2235 2748
Math 7 -3.3420 3.3238 2250 2778
Math 8 -3.1492 3.6254 2265 2802
Math HS -2.9564 4.3804 2280 2862		*/
%macro ScaleThetaScore(CG, thetaScore, scaleScore);
	%let ela_SLOPE=85.8;	%let ela_INTERCEPT=2508.2;
	%let mat_SLOPE=79.3;	%let mat_INTERCEPT=2514.9;
	%let ela03LOSS=2114;	%let ela03HOSS=2623;
	%let ela04LOSS=2131;	%let ela04HOSS=2663;
	%let ela05LOSS=2201;	%let ela05HOSS=2701;
	%let ela06LOSS=2210;	%let ela06HOSS=2724;
	%let ela07LOSS=2258;	%let ela07HOSS=2745;
	%let ela08LOSS=2288;	%let ela08HOSS=2769;
	%let ela11LOSS=2299;	%let ela11HOSS=2795;
	%let math03LOSS=2189;	%let math03HOSS=2621;
	%let math04LOSS=2204;	%let math04HOSS=2659;
	%let math05LOSS=2219;	%let math05HOSS=2700;
	%let math06LOSS=2235;	%let math06HOSS=2748;
	%let math07LOSS=2250;	%let math07HOSS=2778;
	%let math08LOSS=2265;	%let math08HOSS=2802;
	%let math11LOSS=2280;	%let math11HOSS=2862;
	%let Cnt=%substr(&CG., 1, 3);
	&scaleScore. = round(&thetaScore. * &&&Cnt._SLOPE. + &&&Cnt._INTERCEPT., 1);
	if &scaleScore. < &&&CG.LOSS. then &scaleScore. = &&&CG.LOSS.;
	if &scaleScore. > &&&CG.HOSS. then &scaleScore. = &&&CG.HOSS.;
%mend ScaleThetaScore;