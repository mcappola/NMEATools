# hehdt2txt.jl

# Extracts date and heading from NMEA formatted gyroscope text files. Saves the output to a
# text file in the local directory.

# Note:
# -Accurate datetime extraction assumes that the ship is using RVDAS for writing the timestamp. This
# code has been tested on several UNOLS ships successfully, but datestamp format has been known to 
# change on non UNOLS research vessels. 

# Input			: Filepath

# Output 		: hehdt.txt with the following fields
#				-Datetime (UTC): yyyy,mm,dd,HH,MM,SS.SS
#				-Heading (True, Degrees)

# Created on: 11/01/2023
# Last edit: 11/01/2023
# Michael Cappola (mcappola@udel.edu)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

using Dates

function hehdt2txt(filename)

open("hehdt.txt","w") do file

	# Write Headerline
	println(file,"Year,Month,Day,Hour,Minute,Second,HeadingTrue")

	# Loop through data file
	for line in eachline(filename)
		
		# If HEHDT line, extract GPS information
		if occursin("HEHDT",line)

			# Split HEHDT line by comma into the elements array
			elements = split(line,",")
			
			# Checks if gyroscope was on
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

				# Extract Heading
                		heading = elements[2]

			else
				year = NaN
				month = NaN
				day = NaN
				hour = NaN
				min = NaN
				sec = NaN
				heading = NaN
			end
			
			# Assemble datastring
			datastring = string(year) * "," * string(month)
			datastring = datastring * "," * string(day)
			datastring = datastring * "," * string(hour)
			datastring = datastring * "," * string(mmm)
			datastring = datastring * "," * string(sec)
			datastring = datastring * "," * string(heading)
			
			# Write data to file
			println(file,datastring)				
		end
	end
end

end

for arg in ARGS
	filename = arg
	hehdt2txt(filename)
end
