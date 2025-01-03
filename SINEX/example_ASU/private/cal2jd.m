function jd=cal2jd(yr, mn, dy)
% CAL2JD  Converts calendar date to Julian date using algorithm
%   from "Practical Ephemeris Calculations" by Oliver Montenbruck
%   (Springer-Verlag, 1989). Uses astronomical year for B.C. dates
%   (2 BC = -1 yr). Non-vectorized version. See also DOY2JD, GPS2JD,
%   JD2CAL, JD2DOW, JD2DOY, JD2GPS, JD2YR, YR2JD.
% Usage:   jd=cal2jd(yr,mn,dy)
% Input:   yr - calendar year
%          mn - calendar month
%          dy - calendar day (including factional day)
% Output:  jd - jJulian date

% Version: 24 Apr 99
if nargin ~= 3
  warning('Incorrect number of arguments');
  return;
end

if mn > 2
  y = yr;
  m = mn;
else
  y = yr - 1;
  m = mn + 12;
end
date1=4+31*(10+12*1582);   % Last day of Julian calendar (1582.10.04)
date2=15+31*(10+12*1582);  % First day of Gregorian calendar (1582.10.15)
date=dy+31*(mn+12*yr);
if date <= date1
  b = -2;
elseif date >= date2
  b = fix(y/400) - fix(y/100);
else
  warning('Dates between October 5 & 15, 1582 do not exist');
  return;
end
if y > 0
  jd = fix(365.25*y) + fix(30.6001*(m+1)) + b + 1720996.5 + dy;
else
  jd = fix(365.25*y-0.75) + fix(30.6001*(m+1)) + b + 1720996.5 + dy;
end
