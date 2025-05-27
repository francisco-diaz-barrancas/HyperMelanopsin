% Code to compare statististcs of natural versus human-made scenes

clear, close all

groups = {'natural', 'human-made'}; 
outdataC = cell(1,length(groups));
outdataI = cell(1,length(groups));
for i = 1:length(groups)
    vars.data_group = groups{i};
    outC = plots_and_stats_contrast(vars);
    outdataC{i} = outC;
    outI = plots_and_stats_intensity(vars);
    outdataI{i} = outI;
end

[mel.c_h,mel.c_p,mel.c_ci,mel.c_stats] = ttest2(outdataC{1}.yMelt,outdataC{2}.yMelt);
[lum.c_h,lum.c_p,lum.c_ci,lum.c_stats] = ttest2(outdataC{1}.yLumt,outdataC{2}.yLumt);
[ip1.c_h,ip1.c_p,ip1.c_ci,ip1.c_stats] = ttest2(outdataC{1}.yip1t,outdataC{2}.yip1t);

[mel.vc_h,mel.vc_p,mel.vc_ci,mel.vc_stats] = vartest2(outdataC{1}.yMelt,outdataC{2}.yMelt);
[lum.vc_h,lum.vc_p,lum.vc_ci,lum.vc_stats] = vartest2(outdataC{1}.yLumt,outdataC{2}.yLumt);
[ip1.vc_h,ip1.vc_p,ip1.vc_ci,ip1.vc_stats] = vartest2(outdataC{1}.yip1t,outdataC{2}.yip1t);

[mel.i_h,mel.i_p,mel.i_ci,mel.i_stats] = ttest2(outdataI{1}.yMelt,outdataI{2}.yMelt);
[lum.i_h,lum.i_p,lum.i_ci,lum.i_stats] = ttest2(outdataI{1}.yLumt,outdataI{2}.yLumt);
[ip1.i_h,ip1.i_p,ip1.i_ci,ip1.i_stats] = ttest2(outdataI{1}.yip1t,outdataI{2}.yip1t);

[mel.vi_h,mel.vi_p,mel.vi_ci,mel.vi_stats] = vartest2(outdataI{1}.yMelt,outdataI{2}.yMelt);
[lum.vi_h,lum.vi_p,lum.vi_ci,lum.vi_stats] = vartest2(outdataI{1}.yLumt,outdataI{2}.yLumt);
[ip1.vi_h,ip1.vi_p,ip1.vi_ci,ip1.vi_stats] = vartest2(outdataI{1}.yip1t,outdataI{2}.yip1t);

save('Results_comparison_NatvsHM.mat','outdataC','outdataI','mel','lum','ip1');



% Data preparation for statistics and plotting

% Melanopsin
yMelnat = [outdataI{1}.yMelt; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{1}.yMelt),1)];
yMelhm = [outdataI{2}.yMelt; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{2}.yMelt),1)];
ym = [yMelnat, yMelhm];
xm = [ones(outdataI{1}.sx*outdataI{1}.sy,1) 2*ones(outdataI{1}.sx*outdataI{1}.sy,1)];
mean_ymt = mean(ym,'omitnan');
std_ymt = std(ym,'omitnan');
ci_ymt = ci(ym);
median_ymt = median(ym,'omitnan');
median_ym = [median(outdataI{1}.yMel,'omitnan') median(outdataI{2}.yMel,'omitnan')];
fortable.ym = [median(outdataI{1}.yMel,'omitnan') iqr(outdataI{1}.yMel); median(outdataI{2}.yMel,'omitnan') iqr(outdataI{2}.yMel)];
fortable.cm = [median(outdataC{1}.yMel,'omitnan') iqr(outdataC{1}.yMel); median(outdataC{2}.yMel,'omitnan') iqr(outdataC{2}.yMel)];


% Luminance
yLumnat = [outdataI{1}.yLumt; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{1}.yLumt),1)];
yLumhm = [outdataI{2}.yLumt; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{2}.yLumt),1)];
yl = [yLumnat, yLumhm];
xl = [ones(outdataI{1}.sx*outdataI{1}.sy,1) 2*ones(outdataI{1}.sx*outdataI{1}.sy,1)];
mean_ylt = mean(yl,'omitnan');
std_ylt = std(yl,'omitnan');
ci_ylt = ci(yl);
median_ylt = median(yl,'omitnan');
median_yl = [median(outdataI{1}.yLum,'omitnan') median(outdataI{2}.yLum,'omitnan')];
fortable.yl = [median(outdataI{1}.yLum,'omitnan') iqr(outdataI{1}.yLum); median(outdataI{2}.yLum,'omitnan') iqr(outdataI{2}.yLum)];
fortable.cl = [median(outdataC{1}.yLum,'omitnan') iqr(outdataC{1}.yLum); median(outdataC{2}.yLum,'omitnan') iqr(outdataC{2}.yLum)];

% ipRGC 1
yip1nat = [outdataI{1}.yip1t; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{1}.yip1t),1)];
yip1hm = [outdataI{2}.yip1t; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{2}.yip1t),1)];
y1 = [yip1nat, yip1hm];
x1 = [ones(outdataI{1}.sx*outdataI{1}.sy,1) 2*ones(outdataI{1}.sx*outdataI{1}.sy,1)];
mean_y1t = mean(y1,'omitnan');
std_y1t = std(y1,'omitnan');
ci_y1t = ci(y1);
median_y1t = median(y1,'omitnan');
median_y1 = [median(outdataI{1}.yip1,'omitnan') median(outdataI{2}.yip1,'omitnan')];
fortable.yip1 = [median(outdataI{1}.yip1,'omitnan') iqr(outdataI{1}.yip1); median(outdataI{2}.yip1,'omitnan') iqr(outdataI{2}.yip1)];
fortable.cip1 = [median(outdataC{1}.yip1,'omitnan') iqr(outdataC{1}.yip1); median(outdataC{2}.yip1,'omitnan') iqr(outdataC{2}.yip1)];


% Plotting data of Figure 1 
figure('Position', [10 700 1000 400],Name = 'Comparing absolute values'), 
subplot(1,3,1)
set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',14);
swarmchart(xm,ym,'filled');
hold on
errorbar(mean_ymt,std_ymt,'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
title('Melanopsin','FontSize',16)
xticks(1:4)
xticklabels(groups)
yvals = [0 0.4641588833613 1 1.5182944859378 2];
ytickformat('%d')
yticks(yvals)
yticklabels(yvals.^3)
ylabel('Excitation','FontSize',14)

subplot(1,3,3)
set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',14);
swarmchart(xl,yl,'filled');
hold on
errorbar(mean_ylt,std_ylt,'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
title('Luminance','FontSize',16)
xticks(1:4)
xticklabels(groups)
yvals = [0 4.641588833613 10 15.182944859378 20];
ytickformat('%d')
yticks(yvals)
yticklabels(yvals.^3)
ylabel('Absolute value','FontSize',14)

subplot(1,3,2)
set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',14);
swarmchart(x1,y1,'filled');
hold on
errorbar(mean_y1t,std_y1t,'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
title('ipRGCs','FontSize',16)
xticks(1:4)
xticklabels(groups)
yvals = [0 0.4641588833613 1 1.5182944859378 2];
ytickformat('%d')
yticks(yvals)
yticklabels(yvals.^3)
ylabel('Excitation','FontSize',14)

%% Melanopsin vs Luminance Contrast

% Natural scenes
cMelAlln = outdataC{1,1}.yMel0;
cLumAlln = outdataC{1,1}.yLum0;

X0 = [cLumAlln, cMelAlln];
X0(any((X0>1), 2), :) = [];

cMelAll =X0(:,2);
cLumAll = X0(:,1);

ratio_upncontrast(1) = sum(cLumAll<cMelAll)/length(cLumAll);

figure('Position', [1500 800 400 300],Name = 'Natural Mel vs Lum contrasts'),
coefficients_nat = polyfit(cLumAll,cMelAll, 1);
xFit = linspace(min(cLumAll), max(cLumAll), 1000);
yFit = polyval(coefficients_nat , xFit);
plot(cLumAll,cMelAll, '.', 'MarkerSize', 18,'Color',[0.2 0.8 0.2]); 
hold on; 
plot(xFit, yFit, '-', 'LineWidth', 3,'Color',[0.5 0.8 0.5]); 
grid on;
line('LineStyle','--','Color',[0.5 0.5 0.5], 'LineWidth', 2)
xlabel('Luminance contrast','FontSize',15)
ylabel('Melanopsin contrast','FontSize',15)
title('Natural scenes','FontSize',15)
[nrho, npval] = corr(cLumAll,cMelAll);


% Human-made scenes
cMelAllh = outdataC{1,2}.yMel0;
cLumAllh = outdataC{1,2}.yLum0;

X0 = [cLumAllh, cMelAllh];
X0(any((X0>1), 2), :) = [];

cMelAll =X0(:,2);
cLumAll = X0(:,1);
ratio_upncontrast(2) = sum(cLumAll<cMelAll)/length(cLumAll);

figure('Position', [1400 700 400 300],Name = 'Human-made Mel vs Lum contrasts'),
coefficients_hm = polyfit(cLumAll,cMelAll, 1);
xFit = linspace(min(cLumAll), max(cLumAll), 1000);
yFit = polyval(coefficients_hm , xFit);
plot(cLumAll,cMelAll, 'b.', 'MarkerSize', 18); 
hold on; 
plot(xFit, yFit, '-', 'LineWidth', 3,'Color',[0.5 0.5 1]); 
grid on;
line('LineStyle','--','Color',[0.5 0.5 0.5], 'LineWidth', 2)
xlabel('Luminance contrast','FontSize',15)
ylabel('Melanopsin contrast','FontSize',15)
title('Human-made scenes','FontSize',15)
[hrho, hpval] = corr(cLumAll,cMelAll);


%% Independence

% Natural

logMel=log10(outdataI{1,1}.yMel0);
lcMel=log10(outdataC{1,1}.yMel0);
figure('Position', [1200 50 400 300],Name = 'Natural independence'),
[values, centers]= hist3([logMel lcMel],'CdataMode','auto','Nbins',[10 10]);
hold on
[c,h]=contourf(centers{:}, values.',5);
set(h, 'edgecolor','none');
xlabel('Melanopsin excitation (log)','FontSize',15)
ylabel('Melanopsin contrast (log)','FontSize',15)
title('Natural scenes','FontSize',15)
xlim([-1.1 1]);
ylim([-1.5 0.2]);
colorbar
hold off
grid on
[inrho, inpval] = corr(logMel,lcMel);
coefficients_ind = polyfit(logMel,lcMel, 1);

logLum=log10(outdataI{1,1}.yLum0);
lcLum=log10(outdataC{1,1}.yLum0);
[inrhoL, inpvalL] = corr(logLum,lcLum);

% Human-made
logMel=log10(outdataI{1,2}.yMel0);
lcMel=log10(outdataC{1,2}.yMel0);
figure('Position', [1300 100 400 300],Name = 'Human-made independence'),
[values, centers]= hist3([logMel lcMel],'CdataMode','auto','Nbins',[10 10]);
hold on
[c,h]=contourf(centers{:}, values.',5);
set(h, 'edgecolor','none');
xlabel('Melanopsin excitation (log)','FontSize',15)
ylabel('Melanopsin contrast (log)','FontSize',15)
title('Human-made scenes','FontSize',15)
xlim([-1.7 2]);
ylim([-1.5 0.18]);
colorbar
hold off
grid on
[ihrho, ihpval] = corr(logMel,lcMel);

logLum=log10(outdataI{1,2}.yLum0);
lcLum=log10(outdataC{1,2}.yLum0);
[ihrhoL, ihpvalL] = corr(logLum,lcLum);


