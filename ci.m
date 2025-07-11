function outCI = ci(x)

x(isnan(x)) = [];
SEM = std(x)/sqrt(length(x));               % Standard Error
ts = tinv([0.025  0.975],length(x)-1);      % T-Score
outCI = mean(x) + ts*SEM;                      % Confidence Intervals