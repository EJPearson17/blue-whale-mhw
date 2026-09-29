% step1_make_daily_LTSAs.m
% Written by John Ryan (MBARI), July 2020; modified by Carrie Wall, Oct 2021
% Last updated: Sept 29, 2026
% Makes calibrated daily LTSAs (1 min, 1 Hz) from raw NRS wav files.

clear all; close all;
tic

ddir = uigetdir('D:\', 'Select folder of wav files');
ddir = [ddir filesep];
outdir = uigetdir('D:\', 'Select output folder for daily LTSAs');
outdir = [outdir filesep];

% change for each deployment
fprefix = 'NRS05_2018-2020_';
cal = load('NRS05_cal.csv');
hsens = -192.3;

nsf = 14400;
prefixlen = length(fprefix);
dateinfoloc = prefixlen+1:prefixlen+15;
freqrange = [10 max(cal(:,1))];

DataFiles = dir(fullfile(ddir,'*.wav'));
fulldates = zeros(length(DataFiles),1);
for i = 1:length(DataFiles)
    tmp = DataFiles(i).name;
    fulldates(i) = str2num(tmp(prefixlen+1:prefixlen+8));
end
numdays = unique(fulldates);

for k = 2:numel(numdays)
    tmp = num2str(numdays(k));
    kday = datenum(str2num(tmp(1:4)), str2num(tmp(5:6)), str2num(tmp(7:8)));
    disp(datestr(kday))

    [flist,totsec] = step1_fn_daily_file_list(kday,nsf,dateinfoloc,ddir,fprefix);

    if ~isempty(flist)
        nf = numel(flist);
        refsec = 0:86399;
        filenum = NaN*refsec;
        for F = 1:nf
            csec = round(86400*(flist(F).start - kday)) + (0:flist(F).seconds-1);
            [x,ia,ib] = intersect(refsec,csec);
            filenum(ia) = F;
        end

        P.tave = 60;
        P.fs = flist(1).SampleRate;
        P.dfreq = 1;
        P.nfft = P.fs/P.dfreq;
        P.window = hanning(P.nfft);
        P.sa = P.tave*P.fs;

        clear L
        L.freq = (freqrange(1):freqrange(2))';
        ntbin = 86400/P.tave;
        L.time = kday + (0:ntbin-1)*P.tave/86400 + P.tave/2/86400;
        L.ltsa = NaN(numel(L.freq),numel(L.time));

        for t = 1:numel(L.time)
            cstart = (t-1)*P.tave + 1;
            cend = cstart + P.tave - 1;
            fnum = filenum(cstart:cend);
            rsec = refsec(cstart:cend);
            if all(~isnan(fnum))
                ufnum = unique(fnum);
                X = [];
                for F = 1:numel(ufnum)
                    n = ufnum(F);
                    cfn = [flist(n).folder filesep flist(n).name];
                    csec = round(86400*(flist(n).start - kday)) + (0:flist(n).seconds-1);
                    [x,ia,ib] = intersect(csec,rsec);
                    q = min(ia) - 1;
                    csamp = q*P.fs + [1 length(x)*P.fs];
                    [x,fs] = audioread(cfn,csamp);
                    X = [X; x];
                end
                if length(X) ~= P.sa; disp('Error'); return; end
                [pwr,freq] = pwelch(X,P.window,[],P.nfft,P.fs);
                [x,ia,ib] = intersect(freq,L.freq);
                L.ltsa(:,t) = pwr(ia);
            end
        end

        L.ltsa = 10*log10(L.ltsa) - hsens;
        pag = interp1(cal(:,1),cal(:,2),L.freq,'spline');
        L.ltsa = L.ltsa - repmat(pag,1,numel(L.time));

        date_info = datestr(kday,30);
        save([outdir date_info(1:8) '.mat'],'L');
    end
end

disp(['Time elapsed in min: ' num2str(toc/60)])
