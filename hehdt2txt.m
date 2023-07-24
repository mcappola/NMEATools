function hehdt2txt(file,varargin)

% Extracts date and heading from NMEA formated gyroscope text files (Text
% files with a NMEA HEHDT line). Saves output to a text file.

% Notes
% - Accurate datetime extraction assumes the ship is using RVDAS for
% writing the timestamp. This code has been tested on several UNOLS ships
% successfully. 

% Required Argument     : Filepath

% Optional Arguments    : OutputFilename -(No ext) Default is hehdt.txt
%                       : Truncate - Number of skipped data lines.
%                       Decreases data output density. Default is 1 which 
%                       keeps every scan. 10 would save every 10th scan.

% Output                : DateTime (UTC)
%                       : Heading True (Degrees)

% Written by: Michael Cappola (mcappola@udel.edu)
% Created on: 03/27/2022
% Last edit: 07/24/2023
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

p = inputParser;
addRequired(p,'file');
addParameter(p,'OutputFilename','hehdt');         
addParameter(p,'Truncate',1);  
parse(p,file,varargin{:});

filename = p.Results.OutputFilename;
truncate = p.Results.Truncate;

% Counts the number of lines for preallocating arrays.
% Saves time for big files.
fid = fopen(file);
tline = fgetl(fid);
n = 0;
while ischar(tline)
    if contains(tline,'$HEHDT')
        n = n+1;
    end
    tline = fgetl(fid);
end
fclose(fid);

% Format of text line.
fmt = '%f+%f:%f:%f:%f %c%c%c%c%c%c,%f,%c*%f';

dat = nan(floor(n/truncate),6);
hdt = nan(floor(n/truncate),1);

% Pulls out datetime and gyroheading.
fid = fopen(file);
tline = fgetl(fid);
n = 0;
k = 0;
while ischar(tline)
    if contains(tline,'$HEHDT')
        n=n+1;
        if rem(n,truncate)==0
            k=k+1;            
            a = textscan(tline,fmt);    % Builds char of selected line w/ fmt.
            
            %Date
            yr = a{1} + 2000;           % Convert RVDAS Year fmt to year
            dt = datevec(datenum(yr, ones(size(yr)), a{2}));    %ddd -> mmdd
            mm = dt(:,2);               % Mon
            dd = dt(:,3);               % Day
            dt(4) = a{3};               % Hr
            dt(5) = a{4};               % Min
            dt(6) = a{5};               % Sec
            dat(k,:) = dt;
            
            hdt(k) = a{12};     % Gyroscope heading            
        end
    end
    tline = fgetl(fid);
end
fclose(fid);

% Convert to MATLAB datetime
dat = datetime(dat);

% Sort by date, just incase the files we appended were out of order.
[dat,idx] = sort(dat);
hdt = hdt(idx);

% Clean up variables and filenames for text file.
DateTime = dat;
HeadingTrue = hdt;

% Makes and saves table for text file.
t = table(DateTime,HeadingTrue);
writetable(t,[filename '.txt']);
