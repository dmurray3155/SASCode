# ------------------------------------------------------------------------------
# FileName: CSV2RS.py
# Purpose: Read the csv file(s) provided by ETS that present score dimension
#						ratings and prepare their contents for ingestion into redshift.
# Author: Donald Murray
# Date: 2018-01-06 (yeah, Saturday ... sigh)
# Notes:
#		https://docs.python.org/3.1/library/csv.html
#		This version 2 will attempt to use a psycopg2 cursor to insert and then
#			commit the data to redshift.  Because Han still has an R session stalled
#			that is taking up 18,750.4 MB of RAM I can't even load the bulk insert
#			file created by CSV2RDBMS.py.  So much for us acting as good citizens
#			of analytics.smarterbalanced.org.
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
# read the CSV file
#
import csv
csv2db = csv.reader(open('MA4 Ratings.csv'), delimiter=',')
numCSVlines = len(open('MA4 Ratings.csv').readlines())

#
# import into redshift
#
import psycopg2
conn=psycopg2.connect(dbname='analytics', host='analytics.cs909ohc4ovd.us-west-2.redshift.amazonaws.com', port='5439', user='ca_analytics', password='ohs6ahTh')
cur=conn.cursor()

sqlrownum = 1
for row in csv2db:
	qry1 = 'INSERT INTO m04rf (studentid, ctrid, itemid, score, dim1scr, dim2scr, dim3scr, dim4scr) VALUES '
	qry2 = "('" + row[0] + "', '" + row[1] + "', '" + row[2] + "', '" + row[3] + "', '" + row[4] + "', '" + row[5] + "', '" + row[6] + "', '" + row[7] + "');"
	cur.execute(qry1 + qry2)
	conn.commit()
	if sqlrownum%10000 == 0:
		# Report progress to console
		thisNow = time.time()
		midVal = datetime.datetime.fromtimestamp(thisNow)
		print("SQL row number: " + str(format(sqlrownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S'))
	sqlrownum += 1

cur.close()
conn.close()

ended = time.time()
endVal = datetime.datetime.fromtimestamp(ended)
print("Ended: " + endVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py