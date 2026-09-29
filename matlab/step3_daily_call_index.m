% step3_daily_call_index.m
% Adapted from gen_fig2.m (W. Oestreich); last updated Sept 29, 2026
% Computes daily blue whale call index from the daily mean spectrum and writes one csv per deployment.

clear all; close all;

[CIfile,CIdir] = uigetfile('*.mat','Select *bySolarElevation.mat file');
load(fullfile(CIdir,CIfile));
outputPrefix = erase(CIfile,'_SpectrumLevel_Daily-1min_bySolarElevation.mat');

mincount = 1400;

sm = sum(D.sm,3);
ct = sum(D.ct,3);
xcl = find(ct(1,:) < mincount);
ct(:,xcl) = NaN;

L.time = D.time;
L.freq = D.freq;
L.ltsa = sm./ct;
c = step3_fn_call_index(L);

dv = datevec(D.time);
Date = datetime(D.time,'ConvertFrom','datenum');
CI = c.blue(:);
Month = dv(:,2);

writetable(table(Date,CI,Month), [outputPrefix '_daily_CI.csv']);
