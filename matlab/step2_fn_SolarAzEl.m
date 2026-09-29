function [Az,El] = step2_fn_SolarAzEl(UTC,Lat,Lon,Alt)
% Written by Darin C. Koblick (MATLAB File Exchange), last updated Apr 16, 2013
% Solar azimuth and elevation (deg) for a UTC time and site location.

if ischar(UTC)
    jd = juliandate(UTC,'yyyy/mm/dd HH:MM:SS');
else
    [y,mo,d,h,mi,s] = datevec(UTC);
    jd = juliandate(datestr([y,mo,d,h,mi,s],'yyyy/mm/dd HH:MM:SS'),'yyyy/mm/dd HH:MM:SS');
end
d = jd-2451543.5;

w = 282.9404+4.70935e-5*d;
e = 0.016709-1.151e-9.*d;
M = mod(356.0470+0.9856002585.*d,360);
L = w + M;
oblecl = 23.4393-3.563e-7.*d;

E = M+(180/pi).*e.*sin(M.*(pi/180)).*(1+e.*cos(M.*(pi/180)));

x = cos(E.*(pi/180))-e;
y = sin(E.*(pi/180)).*sqrt(1-e.^2);

r = sqrt(x.^2 + y.^2);
v = atan2(y,x).*(180/pi);

lon = v + w;

xeclip = r.*cos(lon.*(pi/180));
yeclip = r.*sin(lon.*(pi/180));
zeclip = 0.0;

xequat = xeclip;
yequat = yeclip.*cos(oblecl.*(pi/180))+zeclip*sin(oblecl.*(pi/180));
zequat = yeclip.*sin(23.4406.*(pi/180))+zeclip*cos(oblecl.*(pi/180));

r = sqrt(xequat.^2 + yequat.^2 + zequat.^2)-(Alt./149598000);
RA = atan2(yequat,xequat).*(180/pi);
delta = asin(zequat./r).*(180/pi);

hourvec = datevec(UTC);
UTH = hourvec(:,4) + hourvec(:,5)/60 + hourvec(:,6)/3600;

GMST0 = mod(L+180,360)./15;
SIDTIME = GMST0 + UTH + Lon./15;

HA = (SIDTIME.*15 - RA);

x = cos(HA.*(pi/180)).*cos(delta.*(pi/180));
y = sin(HA.*(pi/180)).*cos(delta.*(pi/180));
z = sin(delta.*(pi/180));

xhor = x.*cos((90-Lat).*(pi/180))-z.*sin((90-Lat).*(pi/180));
yhor = y;
zhor = x.*sin((90-Lat).*(pi/180))+z.*cos((90-Lat).*(pi/180));

Az = atan2(yhor,xhor).*(180/pi) + 180;
El = asin(zhor).*(180/pi);
end

function jd = juliandate(varargin)
[year,month,day,hour,min,sec] = datevec(datenum(varargin{:}));
idx = month <= 2;
year(idx) = year(idx)-1;
month(idx) = month(idx)+12;
jd = floor(365.25*(year + 4716.0)) + floor(30.6001*(month + 1.0)) + 2.0 - ...
    floor(year/100.0) + floor(floor(year/100.0)/4.0) + day - 1524.5 + ...
    (hour + min/60 + sec/3600)/24;
end
