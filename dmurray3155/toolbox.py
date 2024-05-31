# ------------------------------------------------------------------------------
# FileName: toolbox.py
# Purpose: This python code contains user defined functions that are used
#						often enough to devote them to a toolbox that is included with
#						each python work session. Date of each addition is recorded in 
#						the function comment header.
# Author: Donald Murray
# Date: 2017-12-16 (Date of initiation of this python toolbox - yeah Saturday)
# Notes:
#   The structure and usage of this toolbox is much like my long practiced
#				toolbox method in SAS with Pacific Metrics.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Function name: prntSec2HMS(seconds)
# Purpose: display seconds value in HH:MM:SS.ss 
# Author: Donald Murray
# Date Added: 2017-12-16 (yeah, Saturday)
# ------------------------------------------------------------------------------
def prntSec2HMS(seconds):
		elapsedHours = int(seconds / 3600)
		elapsedMinutes = int((seconds - (elapsedHours * 3600)) / 60)
		remainingSeconds = seconds - (elapsedHours * 3600) - (elapsedMinutes *60)
		# print("Elapsed Seconds: " + str(elapsedSeconds))
		print('Elapsed Time (HH:MM:SS.ss): {:02d}:{:02d}:{:00.2f}'.format(elapsedHours, elapsedMinutes, remainingSeconds))

# ------------------------------------------------------------------------------
# Function name: YN2Bool(YNFlag)
# Purpose: Convert "Yes" / "No" to 1 / 0
# Author: Donald Murray
# Date Added: 2018-01-29
# ------------------------------------------------------------------------------
def YN2Bool(YNFlag):
		if YNFlag == "Yes":
			return "1"
		elif YNFlag == "No":
			return "0"
		else:
			return "9"
		
# ------------------------------------------------------------------------------
# Function name: quadratic(a, b, c)
# Purpose: Compute and print any real roots of a quadratic equation
# Author: Donald Murray
# Date Added: 2017-12-16 (yeah, Saturday)
# Note: Include related conditions associated with the discriminant
# ------------------------------------------------------------------------------
def quadratic(a, b, c):
		print("a =",a,",  b =",b,",  c =",c)
		print("Equation: ",a,"* x**2","+",b,"* x", "+",c,"= 0")
		import math
		d = b**2 - 4*a*c		# compute the discriminant
		if d < 0:
			print("This equation has no real roots")
		elif d == 0:
			x = (-b + d)/(2*a)
			print("This equation has one real root: ", x)
		else:
			x1 = (-b + math.sqrt(d))/(2*a)
			x2 = (-b - math.sqrt(d))/(2*a)
			print("This equation has two real roots: ", x1, " and ", x2)
