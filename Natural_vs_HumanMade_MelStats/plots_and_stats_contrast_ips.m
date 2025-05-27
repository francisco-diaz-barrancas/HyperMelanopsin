function  out = plots_and_stats_contrast_ips(vars)
% Ploting data and compute statistics for contrast

load(['Results/Results_' vars.data_group '.mat'],'outdata');

out.scenesGroup = vars.data_group;
out.variable = 'Contrast';

sx = size(outdata.MelCteSce,1);
sy = size(outdata.MelCteSce,2);

yip10 = reshape(outdata.ip1CteSce,sx*sy,1);
yip20 = reshape(outdata.ip2CteSce,sx*sy,1);

% Removing outliers
yip1 = rmoutliers(yip10);
yip2 = rmoutliers(yip20);

% Transformations to achieve normality
yip1 = sqrt(yip1);
yip2 = sqrt(yip2);

% Data preparation
yip1(isnan(yip1))=[];
yip2(isnan(yip2))=[];

yzip1 = zscore(yip1);
yzip2 = zscore(yip2);

% Normality tests: null hypothesis is that the distribution is normal
out.hnorm(3)= kstest(yzip1);
out.hnorm(4)= kstest(yzip2);

% Data preparation for statistics and plotting
yip1n = [yip1; nan(sx*sy - length(yip1),1)];
yip2n = [yip2; nan(sx*sy - length(yip2),1)];

% Plots and stats
figure('Position', [20 320 400 300],Name = ['ip1-ip2 ' vars.data_group]),
x2 = [ones(sx*sy,1) 2*ones(sx*sy,1)];
y2 = [yip1n, yip2n];
names2 = {' ipRGC 1  ',' ipRGC 2  '};

swarmchart(x2,y2,'filled');
hold on
errorbar(mean(y2,'omitnan'),std(y2,'omitnan'),'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
xticks(1:2)
xticklabels(names2)
yvals = 0:0.2:1.4;
yticks(yvals)
yticklabels(yvals.^2)
title('Contrast')

out.reultsMeans_ips = mean(y2,'omitnan').^2;
out.resultsStds_ips =std(y2,'omitnan').^2;
yip = rmoutliers([yip10 yip20]);
out.reultsMedians_ips = median(yip);
yips =yip.^(1/2);

% Pairwise t-tests
[out.th_ips,out.tp_ips,out.tci_ips,out.tstats_ips] = ttest(yips(:,1),yips(:,2));

figure('Position', [420 50 400 300], Name = ['ipRGCs contrast comparison ' vars.data_group]),
plot(yips(:,1), yips(:,2),'.','MarkerSize',15);
hold on
[out.ci_ips, out.m_ips, out.h_ips] = plotMean(yips(:,1), yips(:,2), 'k');
line([0 1.4],[0 1.4],'LineStyle',':','LineWidth',2,'Color','k')
xyvals = 0:0.2:1.4;
xticks(xyvals)
yticks(xyvals)
xticklabels(xyvals.^2)
yticklabels(xyvals.^2)
xlabel('Contrast (ipRGC 1)')
ylabel('Contrast (ipRGC 2)')
title(['Environment: ' vars.data_group],'FontSize',12)
fips = gcf;

figure('Position', [720 50 105 80], Name = ['inset' vars.data_group]),
plot(yips(:,1), yips(:,2),'.','MarkerSize',15);
hold on
[out.ci_ips, out.m_ips, out.h_ips] = plotMean2(yips(:,1), yips(:,2), 'k');
line([0 1.4],[0 1.4],'LineStyle',':','LineWidth',2,'Color','k')
switch vars.data_group
    case 'natural'
        xlim([0.575 0.62])
        ylim([0.575 0.625])
    case 'human-made'
        xlim([0.615 0.635])
        ylim([0.61 0.64])
end
xticks([])
yticks([])
fips_inset = gcf;

% save figures
exportgraphics(fips,['figs/contrast_ipRGCs_' vars.data_group '.png'],'Resolution',300)
exportgraphics(fips_inset,['figs/contrast_ipRGCs_' vars.data_group '_inset.png'],'Resolution',150)

% adding transformed data
out.yip1t = yip1;
out.yip2t = yip2;

% recovering original data
out.yip1 = yip1.^2;
out.yip2 = yip2.^2;

% original data with outliers
out.yip10 = yip10;
out.yip20 = yip20;

out.sx = sx;
out.sy = sy;