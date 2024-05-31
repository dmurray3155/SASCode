# ------------------------------------------------------------------------------
# FileName: ReadFromRS.py
# Purpose: Test Connection to Redshift
# Author: Don Murray
# Date: 2018-01-06 (yeah, Saturday ... sigh)
# Notes:
#		This test is an attempt to help break our dependence on CSV files.  Logic
#		borrowed from this site:
#		https://www.blendo.co/blog/access-your-data-in-amazon-redshift-and-postgresql-with-python-and-r/
# ------------------------------------------------------------------------------

import psycopg2
conn=psycopg2.connect(dbname='analytics', host='analytics.cs909ohc4ovd.us-west-2.redshift.amazonaws.com', port='5439', user='ca_analytics', password='ohs6ahTh')
cur=conn.cursor()
qry1 = 'select distinct syend, subject, grade, count(*) as frequency '
qry2 = 'from ca_opp_timing '
qry3 = 'group by syend, subject, grade '
qry4 = 'order by syend, subject, grade;'
# cur.execute("select distinct syend, subject, grade, count(*) as frequency from ca_opp_timing group by syend, subject, grade order by syend, subject, grade;")
cur.execute(qry1 + qry2 + qry3 + qry4)
# cur.fetchall()

for (syend, subject, grade, frequency) in cur:
	print("School Year End: " + str(syend) + " Subject: " + subject + " Grade: " + grade + " Freq: " + str(format(frequency, "7,d")))

cur.close()
conn.close()