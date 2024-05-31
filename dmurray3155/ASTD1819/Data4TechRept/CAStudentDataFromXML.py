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
#	2020-02-17 - Edited from this version: D:\SBAC\16-17\ETS_CA\XML\CAStudentFlagsFromXMLz2.py
# --------------------------------------------------------------------------------------------------

#
# import tool(s) from my toolbox
#
from sys import path
path.append("C:/Users/Donald Murray/Documents/GitHub/PythonCode")
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
locFldr = "E:/SBAC/AnnualStudTest/1819/ETS/CA"
stateabbrev = 'CA'
SchlYr = '18-19'
SYEnd = 19
Subj = "ELA"
Grd = "06"
SbjGd = "EL6"
print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)

#
# These lines set up to export the results to a SQL file
#
psvExport = locFldr + "/tab_" + Subj + Grd + "_" + SchlYr +"_StdData.psv"	# This is the target file to write the data to
psv = open(psvExport, "w") # "w" indicates that it is opened for writing
psvHeader = 'stateabbreviation|syend|subject|gradelevelwhenassessed|studentId|sex|ethnicityvalue|educationsubgroupvalue|' \
		+ 'languagecode|englishlanguageproficiencylevel|firstentrydateintousschool|limitedenglishproficiencyentrydate|' \
		+ 'districtId|districtName|schoolId|schoolName|studentGroupName|oppId|oppKey|' \
		+ 'oppStartDate|oppStatus|oppValidity|oppCompleteness|testId|testMode|' \
		+ 'assessmentLevelforWhichDesigned|accomSpanTrans|accomASL|accomBraille|accomTransGloss|' \
		+ 'accomNEA|accomNEDS|overallScaleScore|overallScaleScoreSE|overallPerformanceLevel|' \
		+ 'overallThetaScore|claim1ScaleScore|claim1ScaleScoreSE|claim1PerformanceLevel|claim2ScaleScore|claim2ScaleScoreSE|' \
		+ 'claim2PerformanceLevel|claim3ScaleScore|claim3ScaleScoreSE|claim3PerformanceLevel|claim4ScaleScore|claim4ScaleScoreSE|' \
		+ 'claim4PerformanceLevel\n'
psv.write(psvHeader)

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

	tdsr_test = TDSR.getElementsByTagName("Test")[0]
	testId = tdsr_test.getAttribute('testId')
	testMode = tdsr_test.getAttribute('mode')
	AssessmentLevelForWhichDesigned = tdsr_test.getAttribute('grade')
	subject = tdsr_test.getAttribute('subject')

	Stud = TDSR.getElementsByTagName("Examinee")[0]
	NumEATags = Stud.getElementsByTagName("ExamineeAttribute").length
	ea_attr = 0
	while ea_attr < NumEATags:
		#	Initialize fields
		if ea_attr == 0:
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
		ExamAttr = Stud.getElementsByTagName("ExamineeAttribute")[ea_attr]
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
			AlternateSSID = 'CA_' + str(EAValue)
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
		ea_attr += 1

	NumERTags = Stud.getElementsByTagName("ExamineeRelationship").length
	er_attr = 0
	while er_attr < NumERTags:
		ExamRel = Stud.getElementsByTagName("ExamineeRelationship")[er_attr]
		ERName = ExamRel.getAttribute('name')
		ERValue = ExamRel.getAttribute('value')
		if ERName == "DistrictID":
			districtId = ERValue
		elif ERName == "DistrictName":
			districtName = ERValue
		elif ERName == "SchoolID":
			schoolId = ERValue
		elif ERName == "SchoolName":
			schoolName = ERValue
		elif ERName == "StudentGroupName":
			studentGroupName = ERValue
		er_attr += 1

	Opptunty = TDSR.getElementsByTagName("Opportunity")[0]
	oppId = Opptunty.getAttribute('oppId')
	oppKey = Opptunty.getAttribute('key')
	oppStartDate = Opptunty.getAttribute('startDate')
	oppStatus = Opptunty.getAttribute('status')
	oppValidity = Opptunty.getAttribute('validity')
	oppCompleteness = Opptunty.getAttribute('completeness')
	#	Get overall scale score
	
	NumAccomTags = Opptunty.getElementsByTagName("Accommodation").length
	accms = 0
	while accms < NumAccomTags:
		if (accms == 0):
			accomSpanTrans = ''
			accomASL = ''
			accomBraille = ''
			accomTransGloss = ''
		accmAttr = Opptunty.getElementsByTagName("Accommodation")[accms]
		accmType = accmAttr.getAttribute("type")
		accmValue = accmAttr.getAttribute("value")
		accmCode = accmAttr.getAttribute("code")
		if (accmType == 'Language'):
			accomSpanTrans = accmCode
		if (accmType == 'American Sign Language'):
			accomASL = accmCode
		if (accmType == 'Braille Type'):
			accomBraille = accmCode
		if (accmType == 'Word List'):
			accomTransGloss = accmCode
		if (accmType == 'Non-Embedded Accommodations'):
			accomNEA = accmCode
		if (accmType == 'Non-Embedded Designated Supports'):
			accomNEDS	 = accmCode
		accms += 1

	NumScrTags = Opptunty.getElementsByTagName("Score").length
	scrs = 0
	while scrs < NumScrTags:
		#	Initialize overall scale score
		if (scrs == 0):
			overallScaleScore = ''
			overallScaleScoreSE = ''
			overallPerformanceLevel = ''
			overallThetaScore = ''
			claim1ScaleScore = ''
			claim1ScaleScoreSE = ''
			claim1PerformanceLevel = ''
			claim2ScaleScore = ''
			claim2ScaleScoreSE = ''
			claim2PerformanceLevel = ''
			claim3ScaleScore = ''
			claim3ScaleScoreSE = ''
			claim3PerformanceLevel = ''
			claim4ScaleScore = ''
			claim4ScaleScoreSE = ''
			claim4PerformanceLevel = ''
		scrAttr = Opptunty.getElementsByTagName("Score")[scrs]
		scrMeasOf = scrAttr.getAttribute("measureOf")
		scrMeasLabel = scrAttr.getAttribute("measurelabel")
		scrVal = scrAttr.getAttribute("value")
		scrValSE = scrAttr.getAttribute("standardError")
		if (scrMeasOf == 'Overall'):
			if (scrMeasLabel == 'ScaleScore'):
				overallScaleScore = scrVal
				overallScaleScoreSE = scrValSE
			elif (scrMeasLabel == 'PerformanceLevel'):
				overallPerformanceLevel = scrVal
			elif (scrMeasLabel == 'Pre-LOSS/HOSS theta'):
				overallThetaScore = scrVal
		elif (scrMeasOf == 'Claim1'):
			if (scrMeasLabel == 'ScaleScore'):
				claim1ScaleScore = scrVal
				claim1ScaleScoreSE = scrValSE
			elif (scrMeasLabel == 'PerformanceLevel'):
				claim1PerformanceLevel = scrVal
		elif (scrMeasOf == 'Claim2'):
			if (scrMeasLabel == 'ScaleScore'):
				claim2ScaleScore = scrVal
				claim2ScaleScoreSE = scrValSE
			elif (scrMeasLabel == 'PerformanceLevel'):
				claim2PerformanceLevel = scrVal
		elif (scrMeasOf == 'Claim3'):
			if (scrMeasLabel == 'ScaleScore'):
				claim3ScaleScore = scrVal
				claim3ScaleScoreSE = scrValSE
			elif (scrMeasLabel == 'PerformanceLevel'):
				claim3PerformanceLevel = scrVal
		elif (scrMeasOf == 'Claim4'):
			if (scrMeasLabel == 'ScaleScore'):
				claim4ScaleScore = scrVal
				claim4ScaleScoreSE = scrValSE
			elif (scrMeasLabel == 'PerformanceLevel'):
				claim4PerformanceLevel = scrVal
		scrs += 1

	psvRow = stateabbrev + '|' + str(SYEnd) + '|' + subject + '|' + GradeLevelWhenAssessed + '|' + AlternateSSID + '|' + Sex + '|' + str(ethnicityValue) + '|' \
			+ str(educationSubgroupValue) + '|' + LanguageCode + '|' + EnglishLanguageProficiencyLevel + '|' + FirstEntryDateIntoUSSchool + '|' \
			+ LimitedEnglishProficiencyEntryDate + '|' + districtId + '|' + districtName + '|' + schoolId + '|' + schoolName + '|' \
			+ studentGroupName + '|' + oppId + '|' + oppKey + '|' + oppStartDate + '|' + oppStatus + '|' + oppValidity + '|' + oppCompleteness + '|' + testId + '|' + testMode + '|' \
			+ AssessmentLevelForWhichDesigned + '|' + accomSpanTrans + '|' + accomASL + '|' + accomBraille + '|' + accomTransGloss + '|' \
			+ accomNEA + '|' + accomNEDS + '|' + str(overallScaleScore) + '|' + str(overallScaleScoreSE) + '|' \
			+ str(overallPerformanceLevel) + '|' + str(overallThetaScore) + '|' + str(claim1ScaleScore) + '|' + str(claim1ScaleScoreSE) + '|' + str(claim1PerformanceLevel) + '|' \
			+ str(claim2ScaleScore) + '|' + str(claim2ScaleScoreSE) + '|' + str(claim2PerformanceLevel) + '|' + str(claim3ScaleScore) + '|' + str(claim3ScaleScoreSE) + '|' \
			+ str(claim3PerformanceLevel) + '|' + str(claim4ScaleScore) + '|' + str(claim4ScaleScoreSE) + '|' + str(claim4PerformanceLevel) + '\n'
	psv.write(psvRow)
	if filerownum%10000 == 0:
		# helps me keep track of progress and predict end time
		thisNow = time.time()
		midVal = datetime.datetime.fromtimestamp(thisNow)
		estEndVal = thisNow + (((len(z.namelist()) - filerownum) / 10000) * (thisNow - lastNow))
		estEndValRept = datetime.datetime.fromtimestamp(estEndVal)
		print("File row number: " + str(format(filerownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S') \
				+ " - Est. Completion: " + estEndValRept.strftime('%Y-%m-%d %H:%M:%S'))
		lastNow = thisNow
	filerownum += 1

#
# wrap up time reporting
ended = time.time()
endTimeVal = datetime.datetime.fromtimestamp(ended)
print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)
print("Ended: " + endTimeVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py