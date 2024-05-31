# ------------------------------------------------------------------------------
# FileName: CADistSchlLEPfromXML.py
# Purpose: Retrieve district and school details as well as LEP status for each
#						student from the XML files for California 1617.
# Author: Donald Murray
# Date: 2018-01-25
# Notes:
#		This is to help provide LEP data by district (and school) to ETS to help
#			them debug what happened with the discrepancy in LEP flags.
# ------------------------------------------------------------------------------

#
# import tool(s) from my toolbox
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
locFldr = "F:/SBAC/16-17/ETS_CA/XML"
SchlYr = '16-17'
SYEnd = 17
Subj = "MATH"
Grd = "04"
SbjGd = "MA4"
print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)

#
# These lines set up to export the results to a SQL file
#
sqlExport = locFldr + "/blkInsrt_" + Subj + Grd + "_" + SchlYr +"_DstSchl.sql"	# This is the target file to write the data to
sql = open(sqlExport, "w") # "w" indicates that it is opened for writing
sqlHeader = 'INSERT INTO ca_dist_schl_lep (stateabbreviation, syend, subject, grade, districtId, districtName, schoolId, schoolName, studentId, opportunityId, opportunityKey, LEPStatus) VALUES\n'
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
	ThisKidTest = minidom.parse(z.open(filename))
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
	ExAttr12 = Stud.getElementsByTagName("ExamineeAttribute")[12]
	ExAttr13 = Stud.getElementsByTagName("ExamineeAttribute")[13]
	ExAttr14 = Stud.getElementsByTagName("ExamineeAttribute")[14]
	ChkExAttr12 = ExAttr12.getAttribute('name')
	ChkExAttr13 = ExAttr13.getAttribute('name')
	ChkExAttr14 = ExAttr14.getAttribute('name')
	if ChkExAttr14 == "LEPStatus":
		LEPStatus = ExAttr14.getAttribute('value')
	elif ChkExAttr13 == "LEPStatus":
		LEPStatus = ExAttr13.getAttribute('value')
	else:
		LEPStatus = ExAttr12.getAttribute('value')
	ExRel0 = Stud.getElementsByTagName("ExamineeRelationship")[0]
	ExRel1 = Stud.getElementsByTagName("ExamineeRelationship")[1]
	ExRel2 = Stud.getElementsByTagName("ExamineeRelationship")[2]
	ExRel3 = Stud.getElementsByTagName("ExamineeRelationship")[3]
	ExRel4 = Stud.getElementsByTagName("ExamineeRelationship")[4]
	ChkExRel0 = ExRel0.getAttribute('name')
	ChkExRel1 = ExRel1.getAttribute('name')
	ChkExRel2 = ExRel2.getAttribute('name')
	ChkExRel3 = ExRel3.getAttribute('name')
	ChkExRel4 = ExRel4.getAttribute('name')
	if ChkExRel0 == "StateAbbreviation":
		stateabbrev = ExRel0.getAttribute('value')
	else:
		print("ExamineeRelationship inconsistency at [0] (stateAbbreviation) - XML File: " + filename + " - Line Number: " + str(format(filerownum, ',d')))
	if ChkExRel1 == "DistrictID":
		distId = ExRel1.getAttribute('value')
	else:
		print("ExamineeRelationship inconsistency at [1] (districtId) - XML File: " + filename + " - Line Number: " + str(format(filerownum, ',d')))
	if ChkExRel2 == "DistrictName":
		distName = ExRel2.getAttribute('value')
		distName = distName.replace("'", "''")
	else:
		print("ExamineeRelationship inconsistency at [2] (districtName) - XML File: " + filename + " - Line Number: " + str(format(filerownum, ',d')))
	if ChkExRel3 == "SchoolID":
		schlId = ExRel3.getAttribute('value')
	else:
		print("ExamineeRelationship inconsistency at [3] (schoolId) - XML File: " + filename + " - Line Number: " + str(format(filerownum, ',d')))
	if ChkExRel4 == "SchoolName":
		schlName = ExRel4.getAttribute('value')
		schlName = schlName.replace("'", "''")
	else:
		print("ExamineeRelationship inconsistency at [4] (schoolName) - XML File: " + filename + " - Line Number: " + str(format(filerownum, ',d')))
	Opptunty = TDSR.getElementsByTagName("Opportunity")[0]
	oppId = Opptunty.getAttribute('oppId')
	oppKey = Opptunty.getAttribute('key')

	if filerownum == len(z.namelist()):
		sqlRow = "('" + stateabbrev + "', " + str(SYEnd) + ", '" + Subj +"', '" + Grd + "', '" + distId + "', '" + distName + "', '" + schlId + "', '" + schlName + "', '" + StudId + "', '" + oppId + "', '" + oppKey + "', '" + LEPStatus + "');"
		sql.write(sqlRow)
	else:
		if filerownum%5000 == 0:
			sqlRow = "('" + stateabbrev + "', " + str(SYEnd) + ", '" + Subj +"', '" + Grd + "', '" + distId + "', '" + distName + "', '" + schlId + "', '" + schlName + "', '" + StudId + "', '" + oppId + "', '" + oppKey + "', '" + LEPStatus + "');\n"
			sql.write(sqlRow)
			# helps me keep track of progress and predict end time
			thisNow = time.time()
			midVal = datetime.datetime.fromtimestamp(thisNow)
			print("File row number: " + str(format(filerownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S'))
			sql.write(sqlHeader)
		else:
			sqlRow = "('" + stateabbrev + "', " + str(SYEnd) + ", '" + Subj +"', '" + Grd + "', '" + distId + "', '" + distName + "', '" + schlId + "', '" + schlName + "', '" + StudId + "', '" + oppId + "', '" + oppKey + "', '" + LEPStatus + "'),\n"
			sql.write(sqlRow)
	filerownum += 1

#
# wrap up time reporting
ended = time.time()
endTimeVal = datetime.datetime.fromtimestamp(ended)
print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)
print("Ended: " + endTimeVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py