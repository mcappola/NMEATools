# NMEATools v1.1
Tools for extracting data from NMEA formatted files in MATLAB and Julia.

TODO:
- Add R and C languages to the library.
- Separate directory by language.

Notes:
- gpgga2mat.m and gpgga2txt.m are considered general purpose tools. They pull datetime from the GPZDA line, so are written in a way that can be applied to any standard NMEA formatted GPS output. These functions have been tested on UNOLS vessles and BAS vessles. gpgga2txt.jl still assumes RVDAS timetag format, but will be updated in a future version.

- hehdt and psxn files do not have a GPZDA line so these functions rely on the ship's timetag for datetime. All hehdt and psxn functions assume RVDAS timetag format.

___________________________________________________________________________________________________

gpgga2mat.m -- Extracts datetime, latitude, and longitude, from GPS data formatted in NMEA GPGGA lines and saves in the MATLAB environment.

gpgga2txt.m -- Extracts datetime, latitude, and longitude, from GPS data formatted in NMEA GPGGA lines and saves to a text file.

gpgga2txt.jl -- Extracts datetime, latitude, and longitude, from GPS data formatted in NMEA GPGGA lines and saves to a text file. Fast! Use for larger files. Assumes time is RVDAS timetag format.

hehdt2mat.m -- Extracts datetime, and heading, from gyroscope data formatted in NMEA HEHDT lines and saves in the MATLAB environment. Assumes time is RVDAS timetag format.

hehdt2txt.m -- Extracts datetime, and heading, from gyroscope data formatted in NMEA HEHDT lines and saves to a text file. Assumes time is RVDAS timetag format.

hehdt2txt.jl -- Extracts datetime and heading, from gyroscope data formatted in NMEA HEHDT lines and saves to a text file. Fast! Use for larger files. Assumes time is RVDAS timetag format.

psxn2mat.m -- Extracts datetime, heading, pitch, roll, and heave, from Kongsberg SeaPath accelerometer data formatted in NMEA PSXN lines and saves in the MATLAB environment. Assumes time is RVDAS timetag format.

psxn2txt.m -- Extracts datetime, heading, pitch, roll, and heave, from Kongsberg SeaPath accelerometer data formatted in NMEA PSXN lines and saves to a text file. Assumes time is RVDAS timetag format.

psxn2txt.jl -- Extracts datetime, heading, pitch, roll, and heave, from Kongsberg SeaPath accelerometer data formatted in NMEA PSXN lines and saves to a text file. Fast! Use for larger files. Assumes time is RVDAS timetag format.

rvdas2datetime.m -- Parses RVDAS ship timetag into matlab datetime format.

rvdas2datevec.m -- Parses RVDAS ship timetag into matlab date vector format. 
