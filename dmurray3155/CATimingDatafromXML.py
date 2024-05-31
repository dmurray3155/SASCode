# ------------------------------------------------------------------------------
# FileName: CATimingDatafromXML.py
# Purpose: Retrieve test timing data from XML files for CA 1617 and 1516.
#						Matt sent email about this at Thu 12/21/2017 5:49 PM MST.
# Author: Donald Murray
# Date: 2017-12-28 (yeah, Vacation day ... sigh)
# Notes:
#   This process improves upon the goal of speeding up the acquisition of 
#				other information that is not included in the CSVs and must be harvested
#				from the XML data.
# ------------------------------------------------------------------------------

#
# import my toolbox
#
from sys import path
path.append("F:/Python/tools")
from toolbox import prntSec2HMS

#
# Initialize start time for process
#
import time
import datetime
started = time.time()
startTimeVal = datetime.datetime.fromtimestamp(started)
print("Started: " + startTimeVal.strftime('%Y-%m-%d %H:%M:%S'))

#
# Set Target values
#
# 1516 locFldr = "F:/SBAC/15-16/ETS"
# 1617 locFldr = "F:/SBAC/16-17/ETS_CA/XML"
# Subj = "MATH" or "ELA"
# Grd = "03", "04", "05", "06", "07", "08", "11"
# SbjGd = "EL3", "EL4", "EL5", "EL6", "EL7", "EL8", "E11",
#         "MA3", "MA4", "MA5", "MA6", "MA7", "MA8", "M11"
locFldr = "F:/SBAC/15-16/ETS"
SchlYr = '15-16'
SYEnd = 16
Subj = "ELA"
Grd = "03"
SbjGd = "EL3"
print("Subject: " + Subj + " - Grade: " + Grd)

#
# These lines set up to export the results to a SQL file
#
sqlExport = locFldr + "/blkInsrt_" + Subj + Grd + "_" + SchlYr +"_timing.sql"	# This is the target file to write the data to
sql = open(sqlExport, "w") # "w" indicates that it is opened for writing
sqlHeader = "INSERT INTO ca_stud_timing (SYEnd, Subject, Grade, studentId, OppID, oppkey, oppstartdate, oppstatus, oppvalidity, oppcompleteness, oppopportunityNum, oppstatusdate, oppcompleteddate) VALUES\n"
sql.write(sqlHeader)

#
# Set up access to the zipped folder that contains the XML files
#
import zipfile
from os import listdir
from os.path import isfile, join
mypath = locFldr + "/"
targetFile = SbjGd + '.zip'
trgtPathFile = mypath + targetFile
z = zipfile.ZipFile(trgtPathFile, "r")
#
# Now set up to parse the studentId from the XML files in mypath
from xml.dom import minidom
filerownum = 1
for filename in z.namelist():
	ThisKidTest = minidom.parse(z.open(xfnamewFldr))
	TDSR = ThisKidTest.getElementsByTagName("TDSReport")[0]
	Stud = TDSR.getElementsByTagName("Examinee")[0]
	# Below conditional handling is required because some XML files have AlternateSSID at row 4 of 
	# ExamineeAttribute block rather than row 5. And 306 cases in the 1516 files had AlternateSSID at row 3
	ExAttr2 = Stud.getElementsByTagName("ExamineeAttribute")[2]
	ExAttr3 = Stud.getElementsByTagName("ExamineeAttribute")[3]
	ExAttr4 = Stud.getElementsByTagName("ExamineeAttribute")[4]
	ChkExAttr2 = ExAttr2.getAttribute('name')
	ChkExAttr3 = ExAttr3.getAttribute('name')
	ChkExAttr4 = ExAttr4.getAttribute('name')
	if ChkExAttr4 == "AlternateSSID":
		StudId = ExAttr4.getAttribute('value')
	elif ChkExAttr3 == "AlternateSSID":
		StudId = ExAttr3.getAttribute('value')
	else:
		StudId = ExAttr2.getAttribute('value')
	Opptunty = TDSR.getElementsByTagName("Opportunity")[0]
	oppId = Opptunty.getAttribute('oppId')
	oppKey = Opptunty.getAttribute('key')
	oppStartDate = Opptunty.getAttribute('startDate')
	oppStatus = Opptunty.getAttribute('status')
	oppValidity = Opptunty.getAttribute('validity')
	oppCompleteness = Opptunty.getAttribute('completeness')
	oppopportunityNum = Opptunty.getAttribute('opportunity')
	oppStatusDate = Opptunty.getAttribute('statusDate')
	oppEndDate = Opptunty.getAttribute('dateCompleted')
	# sqlHeader = "INSERT INTO ca_stud_timing (SYEnd, Subject, Grade, studentId, OppID, oppkey, oppstartdate, oppstatus, oppvalidity, oppcompleteness, oppopportunityNum, oppstatusdate, oppcompleteddate) VALUES\n"
	if filerownum == len(z.namelist()):
		sqlrow = "(" + str(SYEnd) + ",'" + Subj + "', '" + Grd+"','" + StudId + "','" + oppId + "','" + oppKey + "','" + oppStartDate + "','" + oppStatus + "','" + oppValidity + "','" + oppCompleteness + "','" + oppopportunityNum + "','" + oppStatusDate + "','" + oppEndDate + "');"
		sql.write(sqlrow)
	else:
		if filerownum%5000 == 0:
			sqlrow = "(" + str(SYEnd) + ",'" + Subj + "', '" + Grd+"','" + StudId + "','" + oppId + "','" + oppKey + "','" + oppStartDate + "','" + oppStatus + "','" + oppValidity + "','" + oppCompleteness + "','" + oppopportunityNum + "','" + oppStatusDate + "','" + oppEndDate + "');\n"
			sql.write(sqlrow)
			sql.write(sqlHeader)
			# helps me keep track of progress and predict end time
			thisNow = time.time()
			midVal = datetime.datetime.fromtimestamp(thisNow)
			print("File row number: " + str(format(filerownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S'))
		else:
			sqlrow = "(" + str(SYEnd) + ",'" + Subj + "', '" + Grd+"','" + StudId + "','" + oppId + "','" + oppKey + "','" + oppStartDate + "','" + oppStatus + "','" + oppValidity + "','" + oppCompleteness + "','" + oppopportunityNum + "','" + oppStatusDate + "','" + oppEndDate + "'),\n"
			sql.write(sqlrow)
	filerownum += 1

#
# wrap up time reporting
ended = time.time()
endTimeVal = datetime.datetime.fromtimestamp(ended)
print("Ended: " + endTimeVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py