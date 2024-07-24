function out = gpgga2mat(file,varargin)

% Extracts date, latitude, and longitude, from NMEA formatted GPS text
% files (Text files with a NMEA GPGGA line). Saves output to a matfile and 
% writes the output to a structure in the current workspace. Uses the GPGGA
% and GPZDA lines.

% Required Argument     : Filepath

% Optional Arguments    : OutputFilename -(No ext) Default is gppga.mat
%                       : Truncate - Number of skipped data lines.
%                       Decreases data output density. Default is 1 which 
%                       keeps every scan. 10 would save every 10th scan.

% Output                : DateTime (UTC)
%                       : Longitude (Decimal)
%                       : Latitude (Decimal)

% Written by: Michael Cappola (mcappola@udel.edu)
% Created on: 03/27/2022
% Last edit: 07/24/2024
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

p = inputParser;
addRequired(p,'file');
addParameter(p,'OutputFilename','gpgga');         
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

% Format of GPGGA line.
gfmt = '%6c,%f,%f,%c,%f,%c,%f,%f,%f,%f,%c,%f,%c,%s';

% Format for GPZDA line.
dfmt = '%6c,%2f%2f%f,%f,%f,%f';

% Preallocation.
dat = nan(floor(n/truncate),6);
lat = nan(floor(n/truncate),1);           
lon = nan(floor(n/truncate),1);

% Pulls out GPS Data.
fid = fopen(file);
tline = fgetl(fid);
n = 0;
k = 0;
m = 0;
h = 0;
while ischar(tline)
    if contains(tline,'GPZDA')
        n=n+1;
        if rem(n,truncate)==0
            k = k+1;
            
            kill = find(tline=='$');
            tline(1:(kill-1)) = [];
            
            a = textscan(tline,dfmt);
            hh = a{2};
            MM = a{3};
            ss = a{4};
            dd = a{5};
            mm = a{6};
            yy = a{7};
            
            dat(k,:) = [yy,mm,dd,hh,MM,ss];
        end
    end
    
    if contains(tline,'GPGGA')
        m=m+1;
        if rem(m,truncate)==0
            h=h+1;
            
            kill = find(tline=='$');
            tline(1:(kill-1)) = [];
            
            a = textscan(tline,gfmt);    % Builds char of selected line w/ fmt.

            if ~isempty(a{3}|a{5})            % Checks if GPS is running.
                %Latitude
                deg = floor(a{3}/100);         % Pull Degree out
                min = (a{3}/100 - deg)*100;    % Pull Minute out
                dec = min/60;                   % Convert Minute to Dec
                com = deg + dec;                % Combine
                if a{4} == 'N'                 % N = +, S = -.
                    lat(h,:) = com;
                else
                    lat(h,:) = com*-1;
                end
                
                %Longitude
                deg = floor(a{5}/100);         % Pull Degree out
                min = (a{5}/100 - deg)*100;    % Pull Minute out
                dec = min/60;                   % Convert Minute to Dec
                com = deg + dec;                % Combine
                if a{6} == 'E'                 % E = +, W = -.
                    lon(h,:) = com;
                else
                    lon(h,:) = com*-1;
                end
            else
                lat(h,:) = nan;                 % Records nan if GPS is off.
                lon(h,:) = nan;
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

save([filename '.mat'],'dat','lat','lon')

out.dat = dat;
out.lat = lat;
out.lon = lon;

