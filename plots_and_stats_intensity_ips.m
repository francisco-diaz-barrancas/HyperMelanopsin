function  out = plots_and_stats_intensity_ips(vars)
% Ploting data and compute statistics for intensity
load(['Results/Results_' vars.data_group '.mat'],'outdata');

out.scenesGroup = vars.data_group;
out.variable = 'Intensity';

sx = size(outdata.MelCteSce,1);
sy = size(outdata.MelCteSce,2);

yip10 = reshape(outdata.ipOut1,sx*sy,1);
yip20 = reshape(outdata.ipOut2,sx*sy,1);

% Removing outliers
yip1 = rmoutliers(yip10);
yip2 = rmoutliers(yip20);

% Transformations to achieve normality
yip1 = (yip1).^(1/3);
yip2 = (yip2).^(1/3);

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
figure(Name = ['ip1-ip2 ' vars.data_group]),
x2 = [ones(sx*sy,1) 2*ones(sx*sy,1)];
y2 = [yip1n, yip2n];
names2 = {' ipRGC 1  ',' ipRGC 2  '};

swarmchart(x2,y2,'filled');
xticks(1:2)
xticklabels(names2)
yvals = 0:27;
yticks(yvals)
yticklabels(yvals.^3)
title('Intensity')
out.reultsMeans_ips = mean(y2,'omitnan').^3;
out.resultsStds_ips =std(y2,'omitnan').^3;
yip = rmoutliers([yip10 yip20]);
out.reultsMedians_ips = median(yip);
yips =yip.^(1/3);
% Pairwise t-tests
[out.th_ips,out.tp_ips,out.tci_ips,out.tstats_ips] = ttest(yips(:,1),yips(:,2));

figure('Position', [420 50 400 300], Name = ['ipRGCs excitation comparison ' vars.data_group]),
plot(yips(:,1), yips(:,2),'.','MarkerSize',15);
hold on
%[out.ci_ips, out.m_ips, out.h_ips] = plotMean(yips(:,1), yips(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 3],[0 3],'LineStyle',':','LineWidth',2,'Color','k')
xyvals = 0:3;
xticks(xyvals)
yticks(xyvals)
xticklabels(xyvals.^3)
yticklabels(xyvals.^3)
xlabel('Excitation (ipRGC 1)')
ylabel('Excitation (ipRGC 2)')
title(['Environment: ' vars.data_group],'FontSize',12)
fips = gcf;

figure('Position', [720 50 105 80], Name = ['inset' vars.data_group]),
plot(yips(:,1), yips(:,2),'.','MarkerSize',15);
hold on
%[out.ci_ips, out.m_ips, out.h_ips] = plotMean2(yips(:,1), yips(:,2), 'k'); % plotMean2 obtained from https://osf.io/2r4ux/
line([0 3],[0 3],'LineStyle',':','LineWidth',2,'Color','k')
switch vars.data_group
    case 'natural'
        xlim([1 1.2])
        ylim([1.1 1.45])
    case 'human-made'
        xlim([1.2 1.5])
        ylim([1.3 1.7])
end
xticks([])
yticks([])
fips_inset = gcf;

% save figures
exportgraphics(fips,['figs/excitation_ipRGCs_' vars.data_group '.png'],'Resolution',300)
exportgraphics(fips_inset,['figs/excitation_ipRGCs_' vars.data_group '_inset.png'],'Resolution',150)

% transformed data
out.yip1t = yip1;
out.yip2t = yip2;

% recovering original data
out.yip1 = yip1.^3;
out.yip2 = yip2.^3;

% original data with outliers
out.yip10 = yip10;
out.yip20 = yip20;
out.sx = sx;
out.sy = sy;

