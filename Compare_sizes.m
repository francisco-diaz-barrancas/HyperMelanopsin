clear, close all

sizes = {'1.37', '2.4'};

for i = 1:2
    switch sizes{i}
        case '1.37'
            load('Results_comparison_NatvsHM.mat')
        case '2.4'
            load('Results_comparison_NatvsHM_2p4.mat')
    end
    % natural
    nIMel0(:,i) = outdataI{1,1}.yMel0; 
    nCMel0(:,i) = outdataC{1,1}.yMel0; 
    
    % human-made
    hIMel0(:,i) = outdataI{1,2}.yMel0; 
    hCMel0(:,i) = outdataC{1,2}.yMel0; 
    
end

% Removing outliers
nCMel = rmoutliers(nCMel0);
hCMel = rmoutliers(hCMel0);
nIMel = rmoutliers(nIMel0);
hIMel = rmoutliers(hIMel0);

% Transformations to achieve normality
nCMel = sqrt(nCMel);
hCMel = sqrt(hCMel);
nIMel = nIMel.^(1/3);
hIMel = hIMel.^(1/3);

zsnCMel = zscore(nCMel(:,1));
zshCMel = zscore(hCMel(:,1));
zsnIMel = zscore(nIMel(:,1));
zshIMel = zscore(hIMel(:,1));

nCM = nCMel(~isnan(nCMel(:,2)),2);
hCM = hCMel(~isnan(hCMel(:,2)),2);
nIM = nIMel(~isnan(nIMel(:,2)),2);
hIM = hIMel(~isnan(hIMel(:,2)),2);
zbnCMel = zscore(nCM);
zbhCMel = zscore(hCM);
zbnIMel = zscore(nIM);
zbhIMel = zscore(hIM);

% Normality tests: null hypothesis is that the distribution is normal
melst.hnorm(1)= kstest(zsnCMel);
melst.hnorm(2)= kstest(zshCMel);
melst.hnorm(3)= kstest(zsnIMel);
melst.hnorm(4)= kstest(zshIMel);
melst.hnorm(5)= kstest(zbnCMel);
melst.hnorm(6)= kstest(zbhCMel);
melst.hnorm(7)= kstest(zbnIMel);
melst.hnorm(8)= kstest(zbhIMel);

% Pairwise t-tests
[melst.ni_th,melst.ni_tp,melst.ni_tci,melst.ni_tstats] = ttest(nIMel(:,1),nIMel(:,2));
[melst.nc_th,melst.nc_tp,melst.nc_tci,melst.nc_tstats] = ttest(nCMel(:,1),nCMel(:,2));
[melst.hi_th,melst.hi_tp,melst.hi_tci,melst.hi_tstats] = ttest(hIMel(:,1),hIMel(:,2));
[melst.hc_th,melst.hc_tp,melst.hc_tci,melst.hc_tstats] = ttest(hCMel(:,1),hCMel(:,2));


% plots
figure('Position', [100 100 900 600], Name = 'Melanopsin without outliers'),

% Intensity
subplot(2,2,1)
plot(nIMel(:,1), nIMel(:,2),'.','MarkerSize',15);
hold on
%plotMean(nIMel(:,1), nIMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 2],[0 2],'LineStyle',':','LineWidth',2,'Color','k')
xyvals = 0:2;
xticks(xyvals)
yticks(xyvals)
xticklabels(xyvals.^3)
yticklabels(xyvals.^3)
title('Natural','FontSize',14)
xlabel('Melanopsin excitation (1.37°)')
ylabel('Melanopsin excitation  (2.4°)')

subplot(2,2,2)
plot(hIMel(:,1), hIMel(:,2),'.','MarkerSize',15);
hold on
%plotMean(hIMel(:,1), hIMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 2],[0 2],'LineStyle',':','LineWidth',2,'Color','k')
xticks(xyvals)
yticks(xyvals)
xticklabels(xyvals.^3)
yticklabels(xyvals.^3)
title('Human-made','FontSize',14)
xlabel('Melanopsin excitation (1.37°)')
ylabel('Melanopsin excitation (2.4°)')

% Contrast
subplot(2,2,3)
plot(nCMel(:,1), nCMel(:,2),'.','MarkerSize',15);
hold on
%plotMean(nCMel(:,1), nCMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 1.5],[0 1.5],'LineStyle',':','LineWidth',2,'Color','k')
xyvals = [0 1 1.414213562];
xticks(xyvals)
yticks(xyvals)
xticklabels(xyvals.^2)
yticklabels(xyvals.^2)
title('Natural','FontSize',14)
xlabel('Melanopsin contrast (1.37°)')
ylabel('Melanopsin Contrast (2.4°)')

subplot(2,2,4)
plot(hCMel(:,1), hCMel(:,2),'.','MarkerSize',15);
hold on
%plotMean(hCMel(:,1), hCMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 1.5],[0 1.5],'LineStyle',':','LineWidth',2,'Color','k')
xticks(xyvals)
yticks(xyvals)
xticklabels(xyvals.^2)
yticklabels(xyvals.^2)
title('Human-made','FontSize',14)
xlabel('Melanopsin contrast (1.37°)')
ylabel('Melanopsin Contrast (2.4°)')
fmain = gcf;


figure('Position', [20 50 100 80], Name = 'Melanopsin natural excitation'),
plot(nIMel(:,1), nIMel(:,2),'.','MarkerSize',15);
hold on
%[melst.ci_ne, melst.m_ne, melst.h_ne] = plotMean(nIMel(:,1), nIMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 2],[0 2],'LineStyle',':','LineWidth',2,'Color','k')
xlim([0.745 0.84])
ylim([0.76 0.85])
xyvals = [];
xticks(xyvals)
yticks(xyvals)
fne = gcf;

figure('Position', [220 50 100 80], Name = 'Melanopsin human-made excitation'),
plot(hIMel(:,1), hIMel(:,2),'.','MarkerSize',15);
hold on
%[melst.ci_he, melst.m_he, melst.h_he] = plotMean(hIMel(:,1), hIMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 2],[0 2],'LineStyle',':','LineWidth',2,'Color','k')
xlim([0.93 1.09])
ylim([0.95 1.1])
xyvals = [];
xticks(xyvals)
yticks(xyvals)
fhe = gcf;

figure('Position', [420 50 100 80], Name = 'Melanopsin natural contrast'),
plot(nCMel(:,1), nCMel(:,2),'.','MarkerSize',15);
hold on
%[melst.ci_nc, melst.m_nc, melst.h_nc] = plotMean(nCMel(:,1), nCMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 1.5],[0 1.5],'LineStyle',':','LineWidth',2,'Color','k')
xlim([0.55 0.63])
ylim([0.52 0.61])
xyvals = [];
xticks(xyvals)
yticks(xyvals)
fnc = gcf;

figure('Position', [620 50 100 80], Name = 'Melanopsin human-made contrast'),
plot(hCMel(:,1), hCMel(:,2),'.','MarkerSize',15);
hold on
%[melst.ci_hc, melst.m_hc, melst.h_hc] = plotMean(hCMel(:,1), hCMel(:,2), 'k'); % plotMean obtained from https://osf.io/2r4ux/
line([0 1.5],[0 1.5],'LineStyle',':','LineWidth',2,'Color','k')
xlim([0.56 0.66])
ylim([0.57 0.65])
xyvals = [];
xticks(xyvals)
yticks(xyvals)
fhc = gcf;

% save figures
exportgraphics(fmain,'figs/size_comparison_main.png','Resolution',300)
exportgraphics(fne,'figs/size_comparison_inset_ne.png','Resolution',150)
exportgraphics(fhe,'figs/size_comparison_inset_he.png','Resolution',150)
exportgraphics(fnc,'figs/size_comparison_inset_nc.png','Resolution',150)
exportgraphics(fhc,'figs/size_comparison_inset_hc.png','Resolution',150)