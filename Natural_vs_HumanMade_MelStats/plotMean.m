function [ ci m h ] = plotMean( dist1, dist2, color )
%PLOTMEAN Summary of this function goes here
%   Detailed explanation goes here

setHoldOff = 0;
if ishold == 0
    setHoldOff = 1;
    hold on;
end

[ci(1) m(1)] = ci_mean(dist1,0.05);
[ci(2) m(2)] = ci_mean(dist1 - dist2,0.05);
[ci(3) m(3)] = ci_mean(dist2,0.05);

ci_intern = ci;
ci_intern(2) = ci_intern(2)./2; 
%Real ci has to be devided by 2, because of comparison to diagonal, which crosses at 0.5;

h(2) = line([m(1)-ci_intern(1) m(1)+ci_intern(1)],[m(3) m(3)],'Color',color);
h(3) = line([m(1) m(1)],[m(3)-ci_intern(3) m(3)+ci_intern(3)],'Color',color);
h(4) = line([m(1)-ci_intern(2) m(1) m(1)+ci_intern(2)],[m(3)+ci_intern(2) m(3) m(3)-ci_intern(2)],'Color',color);
h(1) = plot(m(1),m(3),'Marker','o','Color', color,'MarkerFaceColor',color,'LineStyle','none');

set(h(2:4),'HandleVisibility','off');

if setHoldOff == 1
    hold off;
end