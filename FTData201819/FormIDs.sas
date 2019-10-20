%let workhere=C:\Users\Donald Murray\OneDrive - Smarter Balanced UCSC\IA_Calib\1819;
data ItemIds;
infile "&workhere.\IDList.txt";
input ItemId;
run;
%CSList(&workhere., ELA03, ItemIds, 1, ItemId, 0);