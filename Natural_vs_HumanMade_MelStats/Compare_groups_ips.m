clear, close all

groups = {'natural', 'human-made'}; 
outdataC = cell(1,length(groups));
outdataI = cell(1,length(groups));
for i = 1:length(groups)
    vars.data_group = groups{i};
    outC = plots_and_stats_contrast_ips(vars);
    outdataC{i} = outC;
    outI = plots_and_stats_intensity_ips(vars);
    outdataI{i} = outI;
end

[ip1.c_h,ip1.c_p,ip1.c_ci,ip1.c_stats] = ttest2(outdataC{1}.yip1t,outdataC{2}.yip1t);
[ip2.c_h,ip2.c_p,ip2.c_ci,ip2.c_stats] = ttest2(outdataC{1}.yip2t,outdataC{2}.yip2t);

[ip1.vc_h,ip1.vc_p,ip1.vc_ci,ip1.vc_stats] = vartest2(outdataC{1}.yip1t,outdataC{2}.yip1t);
[ip2.vc_h,ip2.vc_p,ip2.vc_ci,ip2.vc_stats] = vartest2(outdataC{1}.yip2t,outdataC{2}.yip2t);

[ip1.i_h,ip1.i_p,ip1.i_ci,ip1.i_stats] = ttest2(outdataI{1}.yip1t,outdataI{2}.yip1t);
[ip2.i_h,ip2.i_p,ip2.i_ci,ip2.i_stats] = ttest2(outdataI{1}.yip2t,outdataI{2}.yip2t);

[ip1.vi_h,ip1.vi_p,ip1.vi_ci,ip1.vi_stats] = vartest2(outdataI{1}.yip1t,outdataI{2}.yip1t);
[ip2.vi_h,ip2.vi_p,ip2.vi_ci,ip2.vi_stats] = vartest2(outdataI{1}.yip2t,outdataI{2}.yip2t);

save('Results_comparison_NatvsHM_ips','outdataC','outdataI','ip1','ip2');

% Data preparation for statistics and plotting

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

% ipRGC 2
yip2nat = [outdataI{1}.yip2t; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{1}.yip2t),1)];
yip2hm = [outdataI{2}.yip2t; nan(outdataI{1}.sx*outdataI{1}.sy - length(outdataI{2}.yip2t),1)];
y2 = [yip2nat, yip2hm];
x2 = [ones(outdataI{1}.sx*outdataI{1}.sy,1) 2*ones(outdataI{1}.sx*outdataI{1}.sy,1)];
mean_y2t = mean(y2,'omitnan');
std_y2t = std(y2,'omitnan');
ci_y2t = ci(y2);
median_y2t = median(y2,'omitnan');
median_y2 = [median(outdataI{1}.yip2,'omitnan') median(outdataI{2}.yip2,'omitnan')];
fortable.yip2 = [median(outdataI{1}.yip2,'omitnan') iqr(outdataI{1}.yip2); median(outdataI{2}.yip2,'omitnan') iqr(outdataI{2}.yip2)];
fortable.cip2 = [median(outdataC{1}.yip2,'omitnan') iqr(outdataC{1}.yip2); median(outdataC{2}.yip2,'omitnan') iqr(outdataC{2}.yip2)];


figure('Position', [900 410 1000 400],Name = 'Comparing intensity values ipRGCs'), 
subplot(1,2,1)
set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',14);
swarmchart(x1,y1,'filled');
hold on
errorbar(mean_y1t,std_y1t,'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
title('ipRGCs 1','FontSize',16)
xticks(1:2)
xticklabels(groups)
yvals = [0 0.4641588833613 1 1.5182944859378 2 2.466212074 3];
ytickformat('%d')
yticks(yvals)
yticklabels(yvals.^3)
ylabel('Excitation','FontSize',14)
ylim([0 3.2])

subplot(1,2,2)
set(get(gca, 'XAxis'), 'FontWeight', 'bold','FontSize',14);
swarmchart(x2,y2,'filled');
hold on
errorbar(mean_y2t,std_y2t,'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
title('ipRGCs 2','FontSize',16)
xticks(1:2)
xticklabels(groups)
yvals = [0 0.4641588833613 1 1.5182944859378 2 2.466212074 3];
ytickformat('%d')
yticks(yvals)
yticklabels(yvals.^3)
ylabel('Excitation','FontSize',14)
ylim([0 3.2])
fipsexc = gcf;
% save figures
exportgraphics(fipsexc,'figs/excitation_comparison_ipRGCs.png','Resolution',300)


%% ipRGC 1 vs ipRGC 2
yips0(:,1) = [outdataI{1,1}.yip10; outdataI{1,2}.yip10];
yips0(:,2) = [outdataI{1,1}.yip20; outdataI{1,2}.yip20];

yips = rmoutliers(yips0);
yips = yips.^(1/3);

figure('Position', [420 50 400 300], Name = ['ipRGCs excitation comparison ' vars.data_group]),
plot(yips(:,1), yips(:,2),'.','MarkerSize',15,'Color',[0.5 0.5 0.5]);
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
title('All scenes','FontSize',12)
fips = gcf;

figure('Position', [720 50 105 80], Name = ['inset' vars.data_group]),
plot(yips(:,1), yips(:,2),'.','MarkerSize',15,'Color',[0.5 0.5 0.5]);
hold on
%[out.ci_ips, out.m_ips, out.h_ips] = plotMean2(yips(:,1), yips(:,2), 'k'); % plotMean2 obtained from https://osf.io/2r4ux/
line([0 3],[0 3],'LineStyle',':','LineWidth',2,'Color','k')
xlim([1.05 1.25])
ylim([1.15 1.5])
xticks([])
yticks([])
fips_inset = gcf;

% save figures
exportgraphics(fips,'figs/excitation_ipRGCs_all.png','Resolution',300)
exportgraphics(fips_inset,'figs/excitation_ipRGCs_all_inset.png','Resolution',150)