# psxn2txt.jl

# Extracts date, heading, pitch, roll, and heave, from NMEA formatted Kongsberg SeaPath text files 
# (Text files with a NMEA PSXN line). Saves output to a text file.

# Note:
# -Accurate datetime extraction assumes that the ship is using RVDAS for writing the timestamp. This
# code has been tested on several UNOLS ships successfully, but datestamp format has been known to 
# change on non UNOLS research vessels. 

# - PSXN lines are a proprietary Kongsberg format, not a standard NMEA
# format. Check your data files before using. This has been tested with the
# SeaPath 330 and the SeaPath 380 successfully.

# Input			: Filepath

# Output 		: hehdt.txt with the following fields
#				-Datetime (UTC): yyyy,mm,dd,HH,MM,SS.SS
#                       	-Roll (Degrees) (Positive is port side up)
#                       	-Pitch (Degrees) (Positive is bow up)
#                       	-Heading True (Degrees)
#                       	-Heave (Meters) (Positive is down)

# Created on: 11/05/2023
# Last edit: 11/05/2023
# Michael Cappola (mcappola@udel.edu)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

using Dates

function psxn2txt(filename)

open("psxn.txt","w") do file

	# Write Headerline
	println(file,"Year,Month,Day,Hour,Minute,Second,Roll,Pitch,HeadingTrue,Heave")

	# Loop through data file
	for line in eachline(filename)
		
		# If HEHDT line, extract GPS information
		if occursin("PSXN,23",line)

			# Split PSXN line by comma into the elements array
			elements = split(line,",")
			
			# Checks if system was on
			if !isempty(elements[2])

				# Extract date elements	
				datestring = elements[1]
				datestring = split(datestring," ")
				datestring = datestring[1]
				dateelem = split(datestring,":")
			
				# Make year from yy+ddd			
				yearday = split(dateelem[1],"+")
				year = 2000 + parse(Int16,yearday[1])
			
				# Make month and day from yy+ddd
				t = Dates.value(Date(year,1,1))
				t = t + parse(Int16,yearday[2]) - 1
				month = Dates.month(t)
				day = Dates.day(t)			

				# Extract hour, min, and sec			
				hour = parse(Int16,dateelem[2])
				mmm = parse(Int16,dateelem[3])
				sec = parse(Float16,dateelem[4])
				sec = round(sec, digits = 2)

				# Extract Roll, Pitch, Heading, and Heave
                		rol = elements[3]
				pit = elements[4]
				hdt = elements[5]
				hve = split(elements[6],"*")
				hve = hve[1]			
			else
				year = NaN
				month = NaN
				day = NaN
				hour = NaN
				min = NaN
				sec = NaN
                 		rol = NaN
				pit = NaN
				hdt = NaN
				hve = NaN
			end
			
			# Assemble datastring
			datastring = string(year) * "," * string(month)
			datastring = datastring * "," * string(day)
			datastring = datastring * "," * string(hour)
			datastring = datastring * "," * string(mmm)
			datastring = datastring * "," * string(sec)
			datastring = datastring * "," * string(rol)
			datastring = datastring * "," * string(pit)
			datastring = datastring * "," * string(hdt)
			datastring = datastring * "," * string(hve)
			
			# Write data to file
			println(file,datastring)				
		end
	end
end

end

for arg in ARGS
	filename = arg
	psxn2txt(filename)
end
