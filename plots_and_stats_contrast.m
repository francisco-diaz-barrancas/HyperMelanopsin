function  out = plots_and_stats_contrast(vars)
% Ploting data and compute statistics for contrast
load(['Results/Results_' vars.data_group '.mat'],'outdata');

out.scenesGroup = vars.data_group;
out.variable = 'Contrast';

sx = size(outdata.MelCteSce,1);
sy = size(outdata.MelCteSce,2);

yMel0 = reshape(outdata.MelCteSce,sx*sy,1);
yLum0 = reshape(outdata.LumCteSce,sx*sy,1);
yip10 = reshape(outdata.ip1CteSce,sx*sy,1);

% Removing outliers
yMel = rmoutliers(yMel0);
yLum = rmoutliers(yLum0);
yip1 = rmoutliers(yip10);

% Transformations to achieve normality
yMel = sqrt(yMel);
yLum = sqrt(yLum);
yip1 = sqrt(yip1);

% Data preparation
yMel(isnan(yMel))=[];
yLum(isnan(yLum))=[];
yip1(isnan(yip1))=[];

yzMel = zscore(yMel);
yzLum = zscore(yLum);
yzip1 = zscore(yip1);

% Normality tests: null hypothesis is that the distribution is normal
out.hnorm(1)= kstest(yzMel);
out.hnorm(2)= kstest(yzLum);
out.hnorm(3)= kstest(yzip1);

% Data preparation for statistics and plotting
yMeln = [yMel; nan(sx*sy - length(yMel),1)];
yLumn = [yLum; nan(sx*sy - length(yLum),1)];
yip1n = [yip1; nan(sx*sy - length(yip1),1)];

% Plots and stats
figure('Position', [20 20 400 300],Name = ['mel-lum-ip1 ' vars.data_group]), 
x1 = [ones(sx*sy,1) 2*ones(sx*sy,1) 3*ones(sx*sy,1)];
y = [yMeln, yLumn, yip1n];
yv = reshape(y,size(y,1)*size(y,2),1);
names = {'Melanopsin','Luminance ','  ipRGC   '};
namesv = [repmat(names{1},sy*sx,1); repmat(names{2},sy*sx,1); repmat(names{3},sy*sx,1)];

swarmchart(x1,y,'filled');
hold on
errorbar(mean(y,'omitnan'),std(y,'omitnan'),'o','vertical','LineWidth',3,'CapSize',8,'Color','k')
xticks(1:3)
xticklabels(names)
yvals = 0:0.2:1.4;
yticks(yvals)
yticklabels(yvals.^2)
title('Contrast')

[out.ap, out.at, out.astats] = anova1(yv,namesv);
[out.ac, out.am, ~, out.agnames] = multcompare(out.astats);
out.resultsMeans = mean(y,'omitnan').^2;
out.resultsStds =std(y,'omitnan').^2;
out.resultsMedians = median([yMel0, yLum0, yip10]);

% adding transformed data
out.yMelt = yMel;
out.yLumt = yLum;
out.yip1t = yip1;

% recovering original data
out.yMel = yMel.^2;
out.yLum = yLum.^2;
out.yip1 = yip1.^2;

% original data with outliers
out.yMel0 = yMel0;
out.yLum0 = yLum0;
out.yip10 = yip10;

out.sx = sx;
out.sy = sy;