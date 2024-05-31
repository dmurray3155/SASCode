# --------------------------------------------------------------------------------------------------
# FileName:	CAStudentFlagsFromXML.py
# Purpose:	Read through the XML files and collect all available student demographic and
#						education-group and other student flags that are available for CA 16-17 and compose
#						race and education-group binary vector decimals.
# Author:		Donald Murray
# Date:			2018-01-29
# Notes:		The first parts of the content loaded to redshift (district and school details for CA 
#						students) were collected as part of the CA Dist Schl LEP gathering from XML as requested
#						by Parash less than a week ago.  Those will be distilled from MySQL db ca1617	stored to 
#						the localhost on analytics.smarterbalanced.org (table name: ca_dist_schl_lep) and
#						written to redshift after that distillation.
#						The ExamineeAttribute collection and attribution logic was roughed out in python code
#						file: ProtoExamAttrLogic.py
# --------------------------------------------------------------------------------------------------

#
# import tool(s) from my toolbox
#
from sys import path
path.append("F:/Python/tools")
from toolbox import prntSec2HMS
from toolbox import YN2Bool

#
# Initialize start time for process
#
import time
import datetime
started = time.time()
lastNow = started
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
stateabbrev = 'CA'
SchlYr = '16-17'
SYEnd = 17
Subj = "MATH"
Grd = "03"
SbjGd = "MA3"
print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)

#
# These lines set up to export the results to a SQL file
#
sqlExport = locFldr + "/blkInsrt_" + Subj + Grd + "_" + SchlYr +"_StudFlags.sql"	# This is the target file to write the data to
sql = open(sqlExport, "w") # "w" indicates that it is opened for writing
sqlHeader = 'INSERT INTO ca_stud_flags (stateabbreviation, syend, subject, grade, studentId, sex, ethnicityvalue, educationsubgroupvalue' \
		+ ', languagecode, englishlanguageproficiencylevel, firstentrydateintousschool, limitedenglishproficiencyentrydate) VALUES\n'
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
print("Number of XML files in ZIPFile: " + str(format(len(z.namelist()), ',d')))
#
# Now set up to parse the studentId from the XML files in mypath
from xml.dom import minidom
filerownum = 1
for filename in z.namelist():
	ThisKidTest = minidom.parse(z.open(filename))
	TDSR = ThisKidTest.getElementsByTagName("TDSReport")[0]
	Stud = TDSR.getElementsByTagName("Examinee")[0]
	NumEATags = Stud.getElementsByTagName("ExamineeAttribute").length
	attr = 0
	while attr < NumEATags:
		#	Initialize fields
		if attr == 0:
			IDEAIndicator = "No"
			EconomicDisadvantageStatus = "No"
			LanguageCode = ""
			MigrantStatus = "No"
			AlternateSSID = ""
			GradeLevelWhenAssessed = ""
			Sex = ""
			HispanicOrLatinoEthnicity = "No"
			AmericanIndianOrAlaskaNative = "No"
			Asian = "No"
			BlackOrAfricanAmerican = "No"
			White = "No"
			NativeHawaiianOrOtherPacificIslander = "No"
			DemographicRaceTwoOrMoreRaces = "No"
			Filipino = "No"
			LEPStatus = "No"
			Section504Status = "No"
			IEPStatus = "No"
			HomeschoolStatus = "No"
			FirstEntryDateIntoUSSchool = ""
			LimitedEnglishProficiencyEntryDate = ""
			EnglishLanguageProficiencyLevel = ""
		ExamAttr = Stud.getElementsByTagName("ExamineeAttribute")[attr]
		EAName = ExamAttr.getAttribute('name')
		EAValue = ExamAttr.getAttribute('value')
		if EAName == "IDEAIndicator":
			IDEAIndicator = EAValue
		elif EAName == "EconomicDisadvantageStatus":
			EconomicDisadvantageStatus = EAValue
		elif EAName == "LanguageCode":
			LanguageCode = EAValue
		elif EAName == "MigrantStatus":
			MigrantStatus = EAValue
		elif EAName == "AlternateSSID":
			AlternateSSID = EAValue
		elif EAName == "GradeLevelWhenAssessed":
			GradeLevelWhenAssessed = EAValue
		elif EAName == "Sex":
			Sex = EAValue
		elif EAName == "HispanicOrLatinoEthnicity":
			HispanicOrLatinoEthnicity = EAValue
		elif EAName == "AmericanIndianOrAlaskaNative":
			AmericanIndianOrAlaskaNative = EAValue
		elif EAName == "Asian":
			Asian = EAValue
		elif EAName == "BlackOrAfricanAmerican":
			BlackOrAfricanAmerican = EAValue
		elif EAName == "White":
			White = EAValue
		elif EAName == "NativeHawaiianOrOtherPacificIslander":
			NativeHawaiianOrOtherPacificIslander = EAValue
		elif EAName == "DemographicRaceTwoOrMoreRaces":
			DemographicRaceTwoOrMoreRaces = EAValue
		elif EAName == "Filipino":
			Filipino = EAValue
		elif EAName == "LEPStatus":
			LEPStatus = EAValue
		elif EAName == "Section504Status":
			Section504Status = EAValue
		elif EAName == "IEPStatus":
			IEPStatus = EAValue
		elif EAName == "HomeschoolStatus":
			HomeschoolStatus = EAValue
		elif EAName == "FirstEntryDateIntoUSSchool":
			FirstEntryDateIntoUSSchool = EAValue
		elif EAName == "LimitedEnglishProficiencyEntryDate":
			LimitedEnglishProficiencyEntryDate = EAValue
		elif EAName == "EnglishLanguageProficiencyLevel":
			EnglishLanguageProficiencyLevel = EAValue
		#	Distill Race Flags into ethnicityValue
		binaryRaceVector = YN2Bool(HispanicOrLatinoEthnicity) + YN2Bool(AmericanIndianOrAlaskaNative) + YN2Bool(Asian) \
				+ YN2Bool(BlackOrAfricanAmerican) + YN2Bool(White) + YN2Bool(NativeHawaiianOrOtherPacificIslander) \
				+ YN2Bool(DemographicRaceTwoOrMoreRaces) + YN2Bool(Filipino)
		ethnicityValue = int(binaryRaceVector, 2)
		#	Distill education subgroup flags into educationSubgroupValue
		binaryEGVector = YN2Bool(IDEAIndicator) + YN2Bool(LEPStatus) + YN2Bool(IEPStatus) + YN2Bool(Section504Status) \
				+ YN2Bool(EconomicDisadvantageStatus) + YN2Bool(MigrantStatus) + YN2Bool(HomeschoolStatus)
		educationSubgroupValue = int(binaryEGVector, 2)
		#	print("Attribute Number: " + str(attr) + " - ExamineeAttribute Name: " + EAName + " - Value: " + EAValue)
		attr += 1

	if filerownum == len(z.namelist()):
		sqlRow = "('" + stateabbrev + "', " + str(SYEnd) + ", '" + Subj +"', '" + Grd + "', '" + str(AlternateSSID) + "', '" + Sex + "', " + str(ethnicityValue) + ", " \
				+ str(educationSubgroupValue) + ", '" + LanguageCode + "', '" + EnglishLanguageProficiencyLevel + "', '" + FirstEntryDateIntoUSSchool + "', '"  \
				+ LimitedEnglishProficiencyEntryDate + "');"
		sql.write(sqlRow)
	else:
		if filerownum%5000 == 0:
			sqlRow = "('" + stateabbrev + "', " + str(SYEnd) + ", '" + Subj +"', '" + Grd + "', '" + str(AlternateSSID) + "', '" + Sex + "', " + str(ethnicityValue) + ", " \
					+ str(educationSubgroupValue) + ", '" + LanguageCode + "', '" + EnglishLanguageProficiencyLevel + "', '" + FirstEntryDateIntoUSSchool + "', '"  \
					+ LimitedEnglishProficiencyEntryDate + "');\n"
			sql.write(sqlRow)
			# helps me keep track of progress and predict end time
			thisNow = time.time()
			midVal = datetime.datetime.fromtimestamp(thisNow)
			estEndVal = thisNow + (((len(z.namelist()) - filerownum) / 5000) * (thisNow - lastNow))
			estEndValRept = datetime.datetime.fromtimestamp(estEndVal)
			print("File row number: " + str(format(filerownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S') \
					+ " - Est. Completion: " + estEndValRept.strftime('%Y-%m-%d %H:%M:%S'))
			lastNow = thisNow
			sql.write(sqlHeader)
		else:
			sqlRow = "('" + stateabbrev + "', " + str(SYEnd) + ", '" + Subj +"', '" + Grd + "', '" + str(AlternateSSID) + "', '" + Sex + "', " + str(ethnicityValue) + ", " \
					+ str(educationSubgroupValue) + ", '" + LanguageCode + "', '" + EnglishLanguageProficiencyLevel + "', '" + FirstEntryDateIntoUSSchool + "', '"  \
					+ LimitedEnglishProficiencyEntryDate + "'),\n"
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