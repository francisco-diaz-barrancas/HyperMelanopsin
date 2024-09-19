function svar = computeFieldVariables(svar)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
scene0=svar.sectionPhot;

matrixSize = size(scene0);
pdiam =  svar.dfdiam_px;
patchRadius = pdiam / 2;



[X, Y] = meshgrid(1:matrixSize(2), 1:matrixSize(1));

centerX = matrixSize(2) / 2;
centerY = matrixSize(1) / 2;

% Calculate the distance of each grid point from the center
distances = sqrt((X - centerX).^2 + (Y - centerY).^2);


% Find the indices of the elements within the circular patch
patchIndices = find(distances <= patchRadius);

wMask = zeros(matrixSize);

a=cos(pi/patchRadius*distances)+1;
sum_a=sum(a(patchIndices));
w=a/sum_a; % used by Mate et al, 2005

wMask(patchIndices)=w(patchIndices);
lMask=wMask.*scene0;
svar.localExc = sum(lMask,'all');
cMask = wMask.*((scene0-svar.localExc)/svar.localExc).^2;
svar.localContrast = sqrt(sum(cMask,'all'));
svar.patchxy=patchIndices;
end