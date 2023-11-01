function gpgga2txt(file,varargin)

% Extracts date, latitude, and longitude, from NMEA formatted GPS text
% files (Text files with a NMEA GPGGA line). Saves output to a text file.

% Notes
% - Accurate datetime extraction assumes the ship is using RVDAS for
% writing the timestamp. This code has been tested on several UNOLS ships
% successfully. 

% Required Argument     : Filepath

% Optional Arguments    : OutputFilename - Default is gppga.txt
%                       : Truncate - Number of skipped data lines.
%                       Decreases data output density. Default is 1 which 
%                       keeps every scan. 10 would save every 10th scan.

% Output                : DateTime (UTC)
%                       : Longitude (Decimal)
%                       : Latitude (Decimal)

% Written by: Michael Cappola (mcappola@udel.edu)
% Created on: 03/27/2022
% Last edit: 10/28/2023
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

p = inputParser;
addRequired(p,'file');
addParameter(p,'OutputFilename','gpgga.txt');         
addParameter(p,'Truncate',1);  
parse(p,file,varargin{:});

filename = p.Results.OutputFilename;
truncate = p.Results.Truncate;

% Counts the number of lines containing "GPGGA" for preallocating arrays.
% Saves time for big files.
fid = fopen(file);
tline = fgetl(fid);
n = 0;
while ischar(tline)
    if contains(tline,'GPGGA')      
        n=n+1;     
    end
    tline = fgetl(fid);
end
fclose(fid);

% Format of "GPGGA" Line.
fmt = '%f+%f:%f:%f:%f %c%c%c%c%c%c,%f,%f,%c,%f,%c,%f,%f,%f,%f,%c,%f,%c,%s';

% Preallocation.
dat = nan(floor(n/truncate),6);
lat = nan(floor(n/truncate),1);           
lon = nan(floor(n/truncate),1);

% Pulls out GPS Data.
fid = fopen(file);
tline = fgetl(fid);
n = 0;
k = 0;
while ischar(tline)
    if contains(tline,'GPGGA')
        n=n+1;
        if rem(n,truncate)==0
            k = k+1;
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
            
            if ~isempty(a{13}|a{15})            % Checks if GPS is running.
                %Latitude
                deg = floor(a{13}/100);         % Pull Degree out
                min = (a{13}/100 - deg)*100;    % Pull Minute out
                dec = min/60;                   % Convert Minute to Dec
                com = deg + dec;                % Combine
                if a{14} == 'N'                 % N = +, S = -.
                    lat(k,:) = com;
                else
                    lat(k,:) = com*-1;
                end
                
                %Longitude
                deg = floor(a{15}/100);         % Pull Degree out
                min = (a{15}/100 - deg)*100;    % Pull Minute out
                dec = min/60;                   % Convert Minute to Dec
                com = deg + dec;                % Combine
                if a{16} == 'E'                 % E = +, W = -.
                    lon(k,:) = com;
                else
                    lon(k,:) = com*-1;
                end
            else
                lat(k,:) = nan;                 % Records nan if GPS is off.
                lon(k,:) = nan;
            end            
        end
    end
    tline = fgetl(fid);
end
fclose(fid);

dat = datetime(dat);

% Sort by date, just incase the files we appended out of order.
[dat,idx] = sort(dat);
lat = lat(idx);
lon = lon(idx);

% Clean up variables and filenames for text file.
dat = datevec(dat);
Year = dat(:,1);
Month = dat(:,2);
Day = dat(:,3);
Hour = dat(:,4);
Minute = dat(:,5);
Second = dat(:,6);

Latitude = round(lat,4);
Longitude = round(lon,4);

% Makes and saves table for text file.
t = table(Year,Month,Day,Hour,Minute,Second,Latitude,Longitude);
writetable(t,filename);

