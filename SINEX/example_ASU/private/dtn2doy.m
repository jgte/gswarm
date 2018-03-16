function [doy,year]=dtn2doy(dtn)

% [doy,year]=dtn2doy(dtn)
% 
% Convert Matlab-datenum to Day of Year and Year
% 
% Remarks: In case of a vector as input for datenum,
%          Year is just the year of the very first epoch.
%          DoY might be negative or larger than 365 in case 
%          that the year is changing within the dtn vector.

year=str2num(datestr(dtn(1),'yyyy'));
doy =dtn-datenum(year,1,0);
