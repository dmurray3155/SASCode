# ------------------------------------------------------------------------------
# FileName: nv_prod_stud_tbl_mysql_2_rs.py
# Purpose: Get the NV prod student data out of my local MySQL and prepare bulk 
#          inserts that will be run against the AWS redshift instance.
# Author: Donald Murray
# Date: 2018-01-03 (yeah, Vacation day ... sigh)
# Notes:
#   logic for connecting to MySQL is borrowed from here:
#      http://gowrishankarnath.com/
#      http://gowrishankarnath.com/mysql-programming-python-using-mysql-python-connector/
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
locFldr = "F:/SBAC/16-17/DRC/Nevada"

#
# Set up to export the results to a SQL file
#
sqlExport = locFldr + "/blkInsrt2ProdRS_NV_1617.sql"	# This is the target file to write the data to
sql = open(sqlExport, "w") # "w" indicates that it is opened for writing
sqlHeader = "INSERT INTO students (stateabbreviation, schoolId, externalSSID, sex, ethnicityValue, edSubgrpValue) VALUES\n"
sql.write(sqlHeader)

#
# Enable read from local MySQL
#
import mysql.connector
from mysql.connector import errorcode

config = {
'user': 'root',
'password': '@sbac3155',
'host': 'localhost',
'database': 'nv1617',
'raise_on_warnings': True,
}

try:
	cnx = mysql.connector.connect(**config)
	cursor = cnx.cursor()
	# Read data from source table in MySQL
	readProdStudData = "SELECT 'NV' AS stateabbreviation, sc.schl_num as schoolId, st.state_unique_id AS ExternalSSId, CASE WHEN gender = 'M' THEN 'Male' WHEN gender = 'F' THEN 'Female' END AS sex, CASE WHEN ethnicity = 'H' THEN 128 WHEN ethnicity = 'I' THEN 64 WHEN ethnicity = 'A' THEN 32 WHEN ethnicity = 'B' THEN 16 WHEN ethnicity = 'C' THEN 8 WHEN ethnicity = 'P' THEN 4 WHEN ethnicity = 'M' THEN 2 ELSE 0 END AS ethnicityValue, CONV(CONCAT('0', lep, iep, '0', frl, IF(immigrant + migrant > 0, 1, 0), homeschool), 2, 10) AS EdSubgrpValue FROM students AS st, schools AS sc WHERE st.schl_row_num = sc.row_num ORDER BY st.row_num"
	cursor.execute(readProdStudData)
	#specify the attributes that you want to display
	filerownum = 1
	for (stateabbreviation, schoolId, ExternalSSId, sex, ethnicityValue, EdSubgrpValue ) in cursor:
		if filerownum%5000 == 0:
			sqlrow = "('" + stateabbreviation + "', '" + str(schoolId) + "', '" + str(ExternalSSId) + "', '" + sex + "', " + str(ethnicityValue) + ", " + str(EdSubgrpValue) + ");\n"
			sql.write(sqlrow)
			sql.write(sqlHeader)
			# helps me keep track of progress and predict end time
			thisNow = time.time()
			midVal = datetime.datetime.fromtimestamp(thisNow)
			print("File row number: " + str(format(filerownum, ',d')) + " at: " + midVal.strftime('%Y-%m-%d %H:%M:%S'))
		else:
			sqlrow = "('" + stateabbreviation + "', '" + str(schoolId) + "', '" + str(ExternalSSId) + "', '" + sex + "', " + str(ethnicityValue) + ", " + str(EdSubgrpValue) + "),\n"
			sql.write(sqlrow)
		filerownum += 1
	cnx.commit()
except mysql.connector.Error as err:
	if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
		print("Something is wrong with your user name or password")
	elif err.errno == errorcode.ER_BAD_DB_ERROR:
		print("Database does not exist")
	else:
		print(err)
else:
	cursor.close()
	cnx.close()

#
# wrap up time reporting
ended = time.time()
endTimeVal = datetime.datetime.fromtimestamp(ended)
print("Ended: " + endTimeVal.strftime('%Y-%m-%d %H:%M:%S'))
elapsedSeconds = ended - started
prntSec2HMS(elapsedSeconds)		# This is from my toolbox.py