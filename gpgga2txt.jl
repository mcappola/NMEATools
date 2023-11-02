# gpgga2txt.jl

# Extracts date, latitude, and longitude, from NMEA formatted GPS text files. Saves the output to a
# text file in the local directory.

# Note:
# -Accurate datetime extraction assumes that the ship is using RVDAS for writing the timestamp. This
# code has been tested on several UNOLS ships successfully, but datestamp format has been known to 
# change on non UNOLS research vessels. 

# Input			: Filepath

# Output 		: gpgga.txt with the following fields
#				-Datetime (UTC): yyyy,mm,dd,HH,MM,SS.SS
#				-Longitude (Decimal)
#				-Latitude (Decimal)

# Created on: 10/20/2023
# Last edit: 11/01/2023
# Michael Cappola (mcappola@udel.edu)
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

using Dates

function gpgga2txt(filename)

open("gpgga.txt","w") do file

	# Write Headerline
	println(file,"Year,Month,Day,Hour,Minute,Second,Latitude,Longitude")

	# Loop through data file
	for line in eachline(filename)
		
		# If GPGGA line, extract GPS information
		if occursin("GPGGA",line)

			# Split GPGGA line by comma into the elements array
			elements = split(line,",")
			
			# Checks if GPS was on
			if !isempty(elements[3]) || !isempty(elements[5])

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

				# Extract Latitude and convert to decimal			
				lat = elements[3]
				lat = parse(Float64,lat)
				deg = floor(lat/100)
				min = ((lat/100)-deg)*100
				dec = min/60
				com = deg + dec			
				if elements[4] == "N"
					latitude = com
				else
					latitude = com*-1
				end

				# Extract Longitude and convert to decimal
				lon = elements[5]
				lon = parse(Float64,lon)
				deg = floor(lon/100)
				min = ((lon/100)-deg)*100
				dec = min/60
				com = deg + dec
				if elements[6] == "E"
					longitude = com
				else
					longitude = com*-1
				end
				
				latitude = round(latitude, digits = 4)
				longitude = round(longitude, digits = 4)	

			else
				year = NaN
				month = NaN
				day = NaN
				hour = NaN
				min = NaN
				sec = NaN
				latitude = NaN
				longitude = NaN
			end
			
			# Assemble datastring
			datastring = string(year) * "," * string(month)
			datastring = datastring * "," * string(day)
			datastring = datastring * "," * string(hour)
			datastring = datastring * "," * string(mmm)
			datastring = datastring * "," * string(sec)
			datastring = datastring * "," * string(latitude)
			datastring = datastring * "," * string(longitude)
			
			# Write data to file
			println(file,datastring)				
		end
	end
end

end

for arg in ARGS
	filename = arg
	gpgga2txt(filename)
end
