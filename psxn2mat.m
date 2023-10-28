function out = psxn2mat(file,varargin)

% Extracts date, heading, pitch, roll, and heave, from NMEA formatted 
% Kongsberg SeaPath text files (Text files with a NMEA PSXN line). Saves 
% output to a matfile and writes the output to a structure in the current 
% workspace.

% Notes
% - Accurate datetime extraction assumes the ship is using RVDAS for
% writing the timestamp. This code has been tested on several UNOLS ships
% successfully. 

% - PSXN lines are a proprietary Kongsberg format, not a standard NMEA
% format. Check your data files before using. This has been tested with the
% SeaPath 330 and the SeaPath 380 successfully.

% Required Argument     : Filepath

% Optional Arguments    : OutputFilename -(No ext) Default is psxn.mat
%                       : Truncate - Number of skipped data lines.
%                       Decreases data output density. Default is 1 which 
%                       keeps every scan. 10 would save every 10th scan.

% Output                : DateTime (UTC)
%                       : Heading True (Degrees)
%                       : Roll (Degrees) (Positive is port side up)
%                       : Pitch (Degrees) (Positive is bow up)
%                       : Heave (Meters) (Positive is down)

% Written by: Michael Cappola (mcappola@udel.edu)
% Created on: 03/27/2022
% Last edit: 10/28/2023
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

p = inputParser;
addRequired(p,'file');
addParameter(p,'OutputFilename','psxn');         
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
    if contains(tline,'PSXN,23')
        n = n+1;
    end
    tline = fgetl(fid);
end
fclose(fid);

% Format of text line.
fmt = '%f+%f:%f:%f:%f %c%c%c%c%c,%f,%f,%f,%f,%f*%f';

dat = nan(n,6);
rol = nan(n,1);
pit = nan(n,1);
hdt = nan(n,1);
hve = nan(n,1);
rolcheck = nan(n,1);
pitcheck = nan(n,1);
hdtcheck = nan(n,1);
hvecheck = nan(n,1);

% Pulls out datetime and gyroheading.
fid = fopen(file);
tline = fgetl(fid);
k = 0;
h = 0;
while ischar(tline)
    if contains(tline,'PSXN,20')
        k=k+1;
        b = textscan(tline,fmt);    % Builds char of selected line w/ fmt.
        rolcheck(k) = b{12};
        pitcheck(k) = b{13};
        hdtcheck(k) = b{14};
        hvecheck(k) = b{15};
    end
    if contains(tline,'PSXN,23')
        h=h+1;
        a = textscan(tline,fmt);    % Builds char of selected line w/ fmt.
        
        %Date
        yr = a{1} + 2000;           % Convert RVDAS Year fmt to year
        dt = datevec(datenum(yr, ones(size(yr)), a{2}));    %ddd -> mmdd
        mm = dt(:,2);               % Mon
        dd = dt(:,3);               % Day
        dt(4) = a{3};               % Hr
        dt(5) = a{4};               % Min
        dt(6) = a{5};               % Sec
        dat(h,:) = dt;
        
        rol(h) = a{12};
        pit(h) = a{13};
        hdt(h) = a{14};
        hve(h) = a{15};
    end
    tline = fgetl(fid);
end
fclose(fid);

dat = datetime(dat);

% Filter data. A value of 2 is internally flagged as bad.
hdt(hdtcheck==2) = nan;
hve(hvecheck==2) = nan;
rol(rolcheck==2) = nan;
pit(pitcheck==2) = nan;

% Sort by date, just in case.
[dat,idx] = sort(dat);
hdt = hdt(idx);
hve = hve(idx);
rol = rol(idx);
pit = pit(idx);

% Index for truncated data. 1 (default) does nothing.
idx = 1:truncate:length(dat);            

% Truncate the vectors. 1 (default) does nothing.
dat = dat(idx);                            
hdt = hdt(idx);
hve = hve(idx);
rol = rol(idx);
pit = pit(idx);

save([filename '.mat'],'dat','hdt','hve','rol','pit')

out.dat = dat;
out.hdt = hdt;
out.hve = hve;
out.rol = rol;
out.pit = pit;
