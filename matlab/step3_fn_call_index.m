function ci = step3_fn_call_index(L)
% Written by John Ryan (MBARI), last updated May 18, 2020
% Blue whale B call index: mean level at 43-44 Hz over mean level at 37 and 50 Hz.

cif.blue = [37 43 44 50];
[q,ia,ib] = intersect(cif.blue,L.freq);
ci.blue = mean(L.ltsa(ib([2 3]),:),'omitnan') ./ mean(L.ltsa(ib([1 4]),:),'omitnan');
ci.blueband = mean(L.ltsa(ib([2 3]),:),'omitnan');
ci.noiseband = mean(L.ltsa(ib([1 4]),:),'omitnan');
end
