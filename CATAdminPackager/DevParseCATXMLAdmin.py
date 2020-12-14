# --------------------------------------------------------------------------------------------------
# FileName:	DevParseCATXMLAdmin.py
# Purpose:	Read through an XML file and write out a data object that SAS will ingest. This is a
#						companion process to DevCATAdminData.sas and will first extract subject / grade wise
#						content for the testSpecification - administration - bpelement - identifier nodes.
# Author:		Donald Murray
# Date:			2020-12-11
# Notes:		This is necessary because Matt's process collects all grades in a subject together.
#	YYYY-MM-DD - Note to illuminate editorial milestones
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
# Subj = "MA" or "ELA"
# Grd = "3", "4", "5", "6", "7", "8", "11"
locFldr = "C:/Users/Donald Murray/OneDrive - Smarter Balanced UCSC/CATAdminPackage"

SchlYr = '19-20'
SchoolYear = '2019-2020'
SchoolYr = '2019-20'
Subj = "MA"
Grd = "8"

Get_ts_adm_bpelem = 0
Get_isp_prop = 1

if Subj == "ELA":
	subTrgt = SchoolYr + '_' + Subj + '_CAT_SBAC_Test_Packages.10.03.19/TDS/Administration'
else:
	subTrgt = SchoolYr + '_' + Subj + '_CAT_SBAC_Test_Packages/TDS/Administration'

fylName = '(SBAC)SBAC-GEN-SUM-UD-' + Subj + '-CAT-' + Grd + '-Spring-' + SchoolYear + '.xml'

print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)

#
# These lines set up to export the results of testspecification - admin - bpelement to a CSV file
#		/testspecification/administration/testblueprint/bpelement
#
if Get_ts_adm_bpelem == 1:
	csvExport = locFldr + "/" + Subj + "-" + Grd + "_" + SchlYr +"_ts_adm_bpelem.csv"	# This is the target file to write the data to
	csv = open(csvExport, "w") # "w" indicates that it is opened for writing
	csvHeader = 'subject,grade,SchoolYear,elementType,minOpItems,maxOpItems,minFtItems,maxFtItems,opItemCount,ftItemCount,' \
			+ 'id_uniqueId,id_name\n'
	csv.write(csvHeader)

#
# These lines set up to export the results of itemselectionparameter - property to a CSV file
#		/testspecification/administration/adminsegment/itemselector/itemselectionparameter
#
if Get_isp_prop == 1:
	csvispExp = locFldr + "/" + Subj + "-" + Grd + "_" + SchlYr +"_isp_prop.csv"	# This is the target file to write the data to
	csvisp = open(csvispExp, "w")
	csvispHeader = 'isp_bpelemId,isp_prop_count,isp_prop_name,isp_prop_value,isp_prop_label\n'
	csvisp.write(csvispHeader)

trgtPathFile = locFldr + '/' + subTrgt + '/' + fylName

#
# Now set up to parse the content of the XML file
from xml.dom import minidom

ThisXML = minidom.parse(open(trgtPathFile))
testSpec = ThisXML.getElementsByTagName("testspecification")[0]

admin = testSpec.getElementsByTagName("administration")[0]

#	/testspecification/administration/testblueprint/bpelement

if Get_ts_adm_bpelem == 1:
	testbp = admin.getElementsByTagName('testblueprint')[0]
	bpelem_total = testbp.getElementsByTagName("bpelement").length

	bpelem_count = 0
	while bpelem_count < bpelem_total:

		bpelem = testbp.getElementsByTagName("bpelement")[bpelem_count]
		bpe_elementtype = bpelem.getAttribute("elementtype")
		bpe_minopitems = bpelem.getAttribute("minopitems")
		bpe_maxopitems = bpelem.getAttribute("maxopitems")
		bpe_minftitems = bpelem.getAttribute("minftitems")
		bpe_maxftitems = bpelem.getAttribute("maxftitems")
		bpe_opitemcount = bpelem.getAttribute("opitemcount")
		bpe_ftitemcount = bpelem.getAttribute("ftitemcount")
	
		bpe_id = bpelem.getElementsByTagName("identifier")[0]
		bpe_id_uniqueid = bpe_id.getAttribute("uniqueid")
		bpe_id_name = bpe_id.getAttribute("name")

		csvRow = Subj + ',' + Grd + ',' + SchlYr + ',' + bpe_elementtype + ',' + bpe_minopitems + ',' + bpe_maxopitems + ',' \
				+ bpe_minftitems + ',' + bpe_maxftitems + ',' + bpe_opitemcount + ',' + bpe_ftitemcount + ',' \
				+ bpe_id_uniqueid + ',' + bpe_id_name + '\n'
		csv.write(csvRow)

		bpelem_count += 1

#	/testspecification/administration/adminsegment/itemselector/itemselectionparameter

if Get_isp_prop == 1:
	admseg = admin.getElementsByTagName('adminsegment')[0]
	itmsel = admseg.getElementsByTagName('itemselector')[0]
	isp_total = itmsel.getElementsByTagName('itemselectionparameter').length

	isp_count = 0
	while isp_count < isp_total:
	
		isp = itmsel.getElementsByTagName("itemselectionparameter")[isp_count]
		isp_bpelemId = isp.getAttribute("bpelementid")
	
		isp_prop_total = isp.getElementsByTagName("property").length
	
		isp_prop_count = 0
		while isp_prop_count < isp_prop_total:
			isp_prop = isp.getElementsByTagName("property")[isp_prop_count]
			isp_prop_name = isp_prop.getAttribute("name")
			isp_prop_value = isp_prop.getAttribute("value")
			isp_prop_label = isp_prop.getAttribute("label")

			csvispRow = isp_bpelemId + ',' + str(isp_prop_total) + ',' + isp_prop_name + ',' + isp_prop_value + ',' + isp_prop_label + '\n'
			csvisp.write(csvispRow)

			isp_prop_count += 1
		
		isp_count += 1

#
# wrap up time reporting
ended = time.time()
endTimeVal = datetime.datetime.fromtimestamp(ended)
print("School Year: " + SchlYr + " - Subject: " + Subj + " - Grade: " + Grd)
print("Ended: " + endTimeVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py