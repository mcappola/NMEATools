# NMEATools v1.1
Functions for extracting data from NMEA formatted files in MATLAB and Julia.

Notes:
Currently assumes RVDAS format for timestamp. Functions have been tested on multiple UNOLS vessles, but timestamp formats can change from ship to ship. 

- This has been fixed for gpgga2mat.m abd gpgga2txt.m. Date is now pulled from the GPZDA line, so these will now work for any GPS output.

___________________________________________________________________________________________________

gpgga2mat.m -- Extracts datetime, latitude, and longitude, from GPS data formatted in NMEA GPGGA lines and saves in the MATLAB environment.

gpgga2txt.m -- Extracts datetime, latitude, and longitude, from GPS data formatted in NMEA GPGGA lines and saves to a text file.

gpgga2txt.jl -- Extracts datetime, latitude, and longitude, from GPS data formatted in NMEA GPGGA lines and saves to a text file. Fast! Use for larger files.

hehdt2mat.m -- Extracts datetime, and heading, from gyroscope data formatted in NMEA HEHDT lines and saves in the MATLAB environment.

hehdt2txt.m -- Extracts datetime, and heading, from gyroscope data formatted in NMEA HEHDT lines and saves to a text file.

hehdt2txt.jl -- Extracts datetime and heading true from gyroscope data formatted in NMEA HEHDT lines and saves to a text file. Fast! Use for larger files.

psxn2mat.m -- Extracts datetime, heading, pitch, roll, and heave, from Kongsberg SeaPath accelerometer data formatted in NMEA PSXN lines and saves in the MATLAB environment.

psxn2txt.m -- Extracts datetime, heading, pitch, roll, and heave, from Kongsberg SeaPath accelerometer data formatted in NMEA PSXN lines and saves to a text file.

psxn2txt.jl -- Extracts datetime, heading, pitch, roll, and heave, from Kongsberg SeaPath accelerometer data formatted in NMEA PSXN lines and saves to a text file. Fast! Use for larger files.
