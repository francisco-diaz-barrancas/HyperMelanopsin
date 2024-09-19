function evar = computeExcitations(scene)
% code to obtain photreceptors excitations (L:L-cone, M:M-cone, S:S-cone,
% R:rod, G (or I):melanopsin) from a hyperspectral natural image. Natural images were obtained
% from Sergio Nascimento's database:https://sites.google.com/view/sergionascimento/home
%PAB(2023).



CHROMAT=true; %true to compute L/(L+M), S/(L+M), R/(L+M) and G/(L+M)

deltanm=5;
wlnm=400:deltanm:700;
[Ylength, Xlength, Slices]=size(scene);
wl10nm=(400:10:Slices*10+400-10);

%Interpolation
scene5nm=nan(Ylength,Xlength,length(wlnm));
for j=1:Ylength
    for i=1:Xlength
        scene5nm(j,i,:)=interp1(wl10nm,squeeze(scene(j,i,:)),wlnm);
    end
end
[Ylength, Xlength, Slices5nm]=size(scene5nm);

vRad=reshape(scene5nm,Ylength*Xlength,Slices5nm); %reshape the matrix image in a vector

%Radiance stats for each slice
evar.statsRad=[mean(vRad); std(vRad); skewness(vRad); kurtosis(vRad)]';



%S M L R G
evar.SMLRG=nan(Ylength,Xlength,5);
load smlrg_CIE.mat smlrg_CIE;
[r,c]=find(smlrg_CIE(:,1)==wlnm);
smlrg_bar5nm=smlrg_CIE(r,2:end);
A = readmatrix('xyz10e_5.csv');
[rl,c]=find(A(:,1)==wlnm);
vlambda=A(rl,3);
Km=683;

for j=1:Ylength
    for i=1:Xlength
            pixel=squeeze(scene5nm(j,i,:));
            evar.SMLRG(j,i,:)=(smlrg_bar5nm'*pixel)*deltanm;% in alfa-opic cd/m2
            evar.Lum10(j,i,:)=Km*(vlambda'*pixel)*deltanm;% in 10deg cd/m2
    end
end
vSMLRG=reshape(evar.SMLRG,Ylength*Xlength,5);
evar.statsS=[mean(vSMLRG(:,1)) std(vSMLRG(:,1)) skewness(vSMLRG(:,1)) kurtosis(vSMLRG(:,1))];
evar.statsM=[mean(vSMLRG(:,2)) std(vSMLRG(:,2)) skewness(vSMLRG(:,2)) kurtosis(vSMLRG(:,2))];
evar.statsL=[mean(vSMLRG(:,3)) std(vSMLRG(:,3)) skewness(vSMLRG(:,3)) kurtosis(vSMLRG(:,3))];
evar.statsR=[mean(vSMLRG(:,4)) std(vSMLRG(:,4)) skewness(vSMLRG(:,4)) kurtosis(vSMLRG(:,4))];
evar.statsMel=[mean(vSMLRG(:,5)) std(vSMLRG(:,5)) skewness(vSMLRG(:,5)) kurtosis(vSMLRG(:,5))];
vLum=reshape(evar.Lum10,Ylength*Xlength,1);
evar.statsLum10=[mean(vLum) std(vLum) skewness(vLum) kurtosis(vLum)];


% Chromaticities
if CHROMAT
    for j=1:Ylength
        for i=1:Xlength
            evar.lsrg(j,i,1)=evar.SMLRG(j,i,3)/(evar.SMLRG(j,i,3)+evar.SMLRG(j,i,2));%L/(L+M)
            evar.lsrg(j,i,2)=evar.SMLRG(j,i,1)/(evar.SMLRG(j,i,3)+evar.SMLRG(j,i,2));%S/(L+M)
            evar.lsrg(j,i,3)=evar.SMLRG(j,i,4)/(evar.SMLRG(j,i,3)+evar.SMLRG(j,i,2));%R/(L+M)
            evar.lsrg(j,i,4)=evar.SMLRG(j,i,5)/(evar.SMLRG(j,i,3)+evar.SMLRG(j,i,2));%G/(L+M)          
        end
    end
end



end