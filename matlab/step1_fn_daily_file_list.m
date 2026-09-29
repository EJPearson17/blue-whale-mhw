function [flist,totsec] = step1_fn_daily_file_list(oneday,nsf,dateinfoloc,ddir,fprefix)
% Written by John Ryan (MBARI), July 2020
% Lists wav files covering one day and corrects file name time errors for full days.

[YY,MM,DD] = datevec(oneday);
if MM < 10; Mx = '0'; else; Mx = ''; end
if DD < 10; Dx = '0'; else; Dx = ''; end
flist1 = dir([ddir fprefix int2str(YY) Mx int2str(MM) Dx int2str(DD) '*.wav']);

[YY,MM,DD] = datevec(oneday-1);
if MM < 10; Mx = '0'; else; Mx = ''; end
if DD < 10; Dx = '0'; else; Dx = ''; end
flist0 = dir([ddir fprefix int2str(YY) Mx int2str(MM) Dx int2str(DD) '*.wav']);

if ~isempty(flist0) | ~isempty(flist1)
    nf = numel(flist0);
    cfn = flist0(nf).name; ldt = datenum(cfn(dateinfoloc),'yyyymmdd_HHMMSS');
    cfn = flist1(1).name; fdt = datenum(cfn(dateinfoloc),'yyyymmdd_HHMMSS');
    dt = (fdt-ldt)*86400;
    if dt < 1.01*nsf
        flist = [flist0(nf); flist1];
    else
        flist = flist1;
    end
    nf = numel(flist);

    totsec = 0;
    for F = 1:nf
        cfn = flist(F).name;
        flist(F).start = datenum(cfn(dateinfoloc),'yyyymmdd_HHMMSS');
        ai = audioinfo([flist(F).folder filesep flist(F).name]);
        flist(F).SampleRate = ai.SampleRate;
        flist(F).TotalSamples = ai.TotalSamples;
        s = ai.TotalSamples/ai.SampleRate;
        flist(F).seconds = s;
        totsec = totsec + s;
    end

    for F = 1:nf
        fstarts(F) = flist(F).start;
        fsecs(F) = flist(F).seconds;
    end
    fpd = 86400/nsf;
    if totsec == (fpd+1)*nsf & all(fsecs == nsf)
        dfstarts = round(86400*diff(fstarts));
        if ~all(dfstarts == nsf)
            fstarts = fstarts(1) + (nsf*(0:nf-1))/86400;
            for F = 1:nf; flist(F).start = fstarts(F); end
        end
    end
end

end
