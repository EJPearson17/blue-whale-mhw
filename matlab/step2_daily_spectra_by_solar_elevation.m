% step2_daily_spectra_by_solar_elevation.m
% Last updated: Sept 29, 2026
% Sums daily LTSA spectrum levels and minute counts by solar elevation (night, dawn/dusk, day).

clear all; close all;

LTSAdir = uigetdir('', 'Select folder of daily LTSAs');
LTSAFiles = dir(fullfile(LTSAdir,'*.mat'));
[~,deployment] = fileparts(LTSAdir);

Lat = 33.897;
Lon = -119.58;

for i = 1:length(LTSAFiles)
    disp(LTSAFiles(i).name)
    load(fullfile(LTSAdir,LTSAFiles(i).name),'L')

    if i == 1
        nfreq = numel(L.freq);
        ndays = length(LTSAFiles);
        days = zeros(ndays,1);
        n = zeros(nfreq,ndays); dd = n; d = n;
        n_ct = n; dd_ct = n; d_ct = n;
    end

    [~,FN] = fileparts(LTSAFiles(i).name);
    days(i) = datenum(str2num(FN(1:4)), str2num(FN(5:6)), str2num(FN(7:end)));

    El = zeros(numel(L.time),1);
    for t = 1:numel(L.time)
        [~,El(t)] = step2_fn_SolarAzEl(L.time(t),Lat,Lon,0);
    end
    idxn = find(El <= -12);
    idxdd = find(El <= 0 & El > -12);
    idxd = find(El > 0);

    n(:,i) = sum(L.ltsa(:,idxn),2);
    dd(:,i) = sum(L.ltsa(:,idxdd),2);
    d(:,i) = sum(L.ltsa(:,idxd),2);

    n_ct(:,i) = numel(idxn);
    dd_ct(:,i) = numel(idxdd);
    d_ct(:,i) = numel(idxd);
end

D.sm = cat(3,n,dd,d);
D.ct = cat(3,n_ct,dd_ct,d_ct);
D.time = days;
D.freq = L.freq;

save([deployment '_SpectrumLevel_Daily-1min_bySolarElevation.mat'],'D');
