function  out = plots_and_stats_intensity(vars)
% Ploting data and compute statistics for intensity
load(['Results/Results_' vars.data_group '.mat'],'outdata');

out.scenesGroup = vars.data_group;
out.variable = 'Absolute values';

sx = size(outdata.MelCteSce,1);
sy = size(outdata.MelCteSce,2);

yMel0 = reshape(outdata.MelExc,sx*sy,1);
yLum0 = reshape(outdata.Lum,sx*sy,1);
yip10 = reshape(outdata.ipOut1,sx*sy,1);

% Removing outliers
yMel = rmoutliers(yMel0);
yLum = rmoutliers(yLum0);
yip1 = rmoutliers(yip10);

% Transformations to achieve normality
yMel = (yMel).^(1/3);
yLum = (yLum).^(1/3);
yip1 = (yip1).^(1/3);

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

% Stats
y = [yMeln, yLumn, yip1n];
out.resultsMeans = mean(y,'omitnan').^3;
out.resultsStds =std(y,'omitnan').^3;
out.resultsMedians = median([yMel0, yLum0, yip10]);

% transformed data
out.yMelt = yMel;
out.yLumt = yLum;
out.yip1t = yip1;

% recovering original data
out.yMel = yMel.^3;
out.yLum = yLum.^3;
out.yip1 = yip1.^3;

% original data with outliers
out.yMel0 = yMel0;
out.yLum0 = yLum0;
out.yip10 = yip10;

out.sx = sx;
out.sy = sy;

