function [YYYY,MM,DD,hh,mm,ss] = rvdas2datevec(timetag)

% Converts RVDAS timetag into a date vector. 

% INPUT:    RVDAS timetag (char 1x19)
% OUTPUT:   Date vector (doubles)

% Created on: 20240722
% Last edit: 20240722
% Michael Cappola (mcappola@udel.edu)
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

YYYY = 2000 + str2double(timetag(1:2));
aaaa = datevec(datenum(YYYY, ones(size(YYYY)), str2double(timetag(4:6))));
MM = aaaa(2);
DD = aaaa(3);
hh = str2double(timetag(8:9));
mm = str2double(timetag(11:12));
ss = str2double(timetag(14:end));
