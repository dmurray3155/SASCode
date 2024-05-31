# ------------------------------------------------------------------------------
# FileName: CSV2RDBMS.py
# Purpose: Read the csv file(s) provided by ETS that present score dimension
#						ratings and prepare their contents for ingestion into redshift.
# Author: Donald Murray
# Date: 2018-01-06 (yeah, Saturday ... sigh)
# Notes:
#		https://docs.python.org/3.1/library/csv.html
# ------------------------------------------------------------------------------

#
# import my toolbox
#
from sys import path
path.append("Z:/Python/tools")
from toolbox import prntSec2HMS

#
# Initialize start time and structural variables
#
import time
import datetime
started = time.time()
startVal = datetime.datetime.fromtimestamp(started)
print("Started: " + startVal.strftime('%Y-%m-%d %H:%M:%S'))

#
# Set Target values
#
locFldr = "Z:/CA_Item/ScoreFixes"
SbjGd = "MA4"
TblNm = "m04rf"
print("Subject-Grade: " + SbjGd)

#
# Set up to write out bulk insert SQL file
#
sqlExport = locFldr + "/bulkInsrt2RF_"+SbjGd+".sql"	# This is the target file to write the data to
sql = open(sqlExport, "w") # "w" indicates that it is opened for writing
sqlHeader = "INSERT INTO " + TblNm + " (studentid, ctrid, itemid, score, dim1scr, dim2scr, dim3scr, dim4scr) VALUES\n"
sql.write(sqlHeader)

import csv
csv2db = csv.reader(open('MA4 Ratings.csv'), delimiter=',')
numCSVlines = len(open('MA4 Ratings.csv').readlines())

sqlrownum = 1
for row in csv2db:
	if sqlrownum == numCSVlines:
		sqlrow = "('" + row[0] + "', '" + row[1] + "', '" + row[2] + "', '" + row[3] + "', '" + row[4] + "', '" + row[5] + "', '" + row[6] + "', '" + row[7] + "');"
		sql.write(sqlrow)
	else:
		if sqlrownum%5000 == 0:
			sqlrow = "('" + row[0] + "', '" + row[1] + "', '" + row[2] + "', '" + row[3] + "', '" + row[4] + "', '" + row[5] + "', '" + row[6] + "', '" + row[7] + "');\n"
			sql.write(sqlrow)
			sql.write(sqlHeader)
			# Report progress to console
			thisNow = time.time()
			midVal = datetime.datetime.fromtimestamp(thisNow)
			print("File row number: " + str(format(sqlrownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S'))
		else:
			sqlrow = "('" + row[0] + "', '" + row[1] + "', '" + row[2] + "', '" + row[3] + "', '" + row[4] + "', '" + row[5] + "', '" + row[6] + "', '" + row[7] + "'),\n"
			sql.write(sqlrow)
	sqlrownum += 1

ended = time.time()
endVal = datetime.datetime.fromtimestamp(ended)
print("Ended: " + endVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py