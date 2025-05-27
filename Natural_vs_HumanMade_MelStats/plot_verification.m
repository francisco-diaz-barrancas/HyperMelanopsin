% Plot verification results
clear, close all

load('Results/Results_verification.mat');
smat = evar.sceneNames;
scNames = {'Luminance','Melanopsin','EES','mel5p'};

mCsMel=median(outdata.MelCteSce,'omitnan');
sCsMel= iqr(outdata.MelCteSce); %std(outdata.MelCteSce,'omitnan');
mCsMel(isnan(mCsMel)) = 0;

mCslum=median(outdata.LumCteSce,'omitnan');
sCslum=iqr(outdata.LumCteSce); %std(outdata.LumCteSce,'omitnan');
mCslum(isnan(mCslum)) = 0;

mCsip1=median(outdata.ip1CteSce,'omitnan');
sCsip1=iqr(outdata.ip1CteSce); %std(outdata.ip1CteSce,'omitnan');
mCsip1(isnan(mCsip1)) = 0;

mCsip2=median(outdata.ip2CteSce,'omitnan');
sCsip2=iqr(outdata.ip2CteSce); %std(outdata.ip2CteSce,'omitnan');
mCsip2(isnan(mCsip2)) = 0;

figure,
subplot(4,1,1)
errorbar(mCsMel,sCsMel,'.--','MarkerSize',16)
title('Melanopic contrast', 'Interpreter', 'none')
xticks(1:size(smat,1))
subplot(4,1,2)
errorbar(mCslum,sCslum,'.--','MarkerSize',16)
title('Luminance contrast', 'Interpreter', 'none')
xticks(1:size(smat,1))
subplot(4,1,3)
errorbar(mCsip1,sCsip1,'.--','MarkerSize',16)
title('ipRGC1 contrast', 'Interpreter', 'none')
xticks(1:size(smat,1))
subplot(4,1,4)
errorbar(mCsip2,sCsip2,'.--','MarkerSize',16)
title('ipRGC2 contrast', 'Interpreter', 'none')
xlabel('Artificial scene')
xticks(1:size(smat,1))
xticklabels(scNames)

fverif = gcf;
% save figures
exportgraphics(fverif,'figs/verification.png','Resolution',300)