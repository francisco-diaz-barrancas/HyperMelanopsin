clear, close all

place='Sete_Fontes_Rock';

fsize_ipRGC = 2.4; % 2.4 deg Dendritic field in parafovea 3-4mm of ecc (Dacey et al, 2005, Grunert and Martin, 2020)     
fsize_parasol = 1; % 1deg Size used by Mante et al(2005)   

d0name = ['scenes_2015\'];
s = dir(d0name);
%s = s([s.isdir]);
s=s(~ismember({s.name},{'.','..'}));
smat=s(contains({s.name},'.mat'));
spdf=s(contains({s.name},'.pdf'));

% From Nascimento, Amano & Foster 2016 (*4)
evar.mSize_deg = [5.3 6.9]*4;        

LocalContrast=nan(4,size(smat,1));
LocalExcitation=nan(4,size(smat,1));
LocalContrastLum=nan(4,size(smat,1));
LocalLuminance=nan(4,size(smat,1));
LocalipOut=nan(4,size(smat,1));
sections={'Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10','Q11','Q12','Q13','Q14','Q15','Q16'};

for j=1:size(smat,1)
    stscene=open([smat(1).folder '\' smat(j).name]);
    try
        scene=stscene.hsi;
    catch ME
        scene=stscene.absolute;
    end

    % From each scene
    evar.mSize_px = size(scene(:,:,1));
    
    
    for i = 1:16
        switch sections{i}
            case 'Q1'
                evar.section=scene(1:ceil(end/4), 1:ceil(end/4),:);
            case 'Q2'
                evar.section=scene(1:ceil(end/4), ceil(end/4)+1:ceil(end/2),:);
            case 'Q3'
                evar.section=scene(1:ceil(end/4), ceil(end/2)+1:(ceil(end/4)*3),:);
            case 'Q4'
                evar.section=scene(1:ceil(end/4), (ceil(end/4)*3)+1:end,:);
            case 'Q5'
                evar.section=scene(ceil(end/4)+1:ceil(end/2), 1:ceil(end/4),:);
            case 'Q6'
                evar.section=scene(ceil(end/4)+1:ceil(end/2), ceil(end/4)+1:ceil(end/2),:);
            case 'Q7'
                evar.section=scene(ceil(end/4)+1:ceil(end/2), ceil(end/2)+1:(ceil(end/4)*3),:);
            case 'Q8'
                evar.section=scene(ceil(end/4)+1:ceil(end/2), (ceil(end/4)*3)+1:end,:);
            case 'Q9'
                evar.section=scene(ceil(end/2)+1:(ceil(end/4)*3), 1:ceil(end/4),:);
            case 'Q10'
                evar.section=scene(ceil(end/2)+1:(ceil(end/4)*3), ceil(end/4)+1:ceil(end/2),:);
            case 'Q11'
                evar.section=scene(ceil(end/2)+1:(ceil(end/4)*3), ceil(end/2)+1:(ceil(end/4)*3),:);
            case 'Q12'
                evar.section=scene(ceil(end/2)+1:(ceil(end/4)*3), (ceil(end/4)*3)+1:end,:);
            case 'Q13'
                evar.section=scene((ceil(end/4)*3)+1:end,  1:ceil(end/4),:);
            case 'Q14'
                evar.section=scene((ceil(end/4)*3)+1:end,  ceil(end/4)+1:ceil(end/2),:);
            case 'Q15'
                evar.section=scene((ceil(end/4)*3)+1:end, ceil(end/2)+1:(ceil(end/4)*3),:);
            case 'Q16'
                evar.section=scene((ceil(end/4)*3)+1:end, (ceil(end/4)*3)+1:end,:);
        end

        evar.dfdiam_deg = fsize_ipRGC;
        evar.dfdiam_px=evar.dfdiam_deg/evar.mSize_deg(1)*evar.mSize_px(1);         
        % Mel Receptive field computation
        excit=computeExcitations(evar.section);
        evar.sectionMel=excit.SMLRG(:,:,5);
        evar.sectionPhot=evar.sectionMel;      
        evar=computeFieldVariables(evar);
        LocalContrast(i,j)=evar.localContrast;
        LocalExcitation(i,j)=evar.localExc;
        
        % ipRGC output (L+M+Mel)/S
        evar.sectionPhot=0.33*excit.SMLRG(:,:,2)+0.66*excit.SMLRG(:,:,3)+0.69*excit.SMLRG(:,:,5);
        evar=computeFieldVariables(evar);
        LMmelOut=evar.localExc;
        evar.sectionPhot=excit.SMLRG(:,:,1);
        evar=computeFieldVariables(evar);
        SOut=evar.localExc;
        %new configuration
        LocalipOut(i,j)=LMmelOut-0.12*SOut;
      
         % Lum Receptive field computation
        evar.sectionLum=excit.Lum10;
        evar.sectionPhot=evar.sectionLum;       
        evar.dfdiam_deg = fsize_parasol; 
        evar.dfdiam_px=evar.dfdiam_deg/evar.mSize_deg(1)*evar.mSize_px(1); 
        evar=computeFieldVariables(evar);
        LocalContrastLum(i,j)=evar.localContrast;
        LocalLuminance(i,j)=evar.localExc;
    
    end
end

mExTi=repmat(mean(LocalExcitation')',1,size(LocalExcitation,2));
CsTiMel = sqrt(((LocalExcitation-mExTi)./mExTi).^2);%sqrt(mean(((LEs-mLEs)/mLEs).^2));
mCtMel=mean(CsTiMel);
sCtMel=std(CsTiMel);

mExSc=repmat(mean(LocalExcitation),size(sections,2),1);
CsScMel = sqrt(((LocalExcitation-mExSc)./mExSc).^2);
mCsMel=mean(CsScMel);
sCsMel=std(CsScMel);

mExScip=repmat(mean(LocalipOut),size(sections,2),1);
CsScip = sqrt(((LocalipOut-mExScip)./mExScip).^2);
mCsip=mean(CsScip);
sCsip=std(CsScip);

mExSclum=repmat(mean(LocalLuminance),size(sections,2),1);
CsSclum = sqrt(((LocalLuminance-mExSclum)./mExSclum).^2);
mCslum=mean(CsSclum);
sCslum=std(CsSclum);

save(['results\scenes_2015_16portion_newIPRGC\enviroment\Results_' place],'CsScMel','CsSclum','CsScip','LocalExcitation',"LocalContrast",'LocalLuminance',"LocalContrastLum","LocalipOut")

%evar = make_figures(evar,place,mCtMel,sCtMel,mCsMel,sCsMel,LocalExcitation, LocalContrast,scene,sections);
szv=size(CsSclum,1)*size(CsSclum,2);

figure,
subplot(2,2,1)
plot(reshape(CsSclum,size(CsSclum,1)*size(CsSclum,2),1),reshape(CsScMel,size(CsScMel,1)*size(CsScMel,2),1),'ro')
refline(1,0)
title('Contrasts Mel vs Lum')
subplot(2,2,2)
plot(reshape(CsSclum,size(CsSclum,1)*size(CsSclum,2),1),reshape(CsScip,size(CsScMel,1)*size(CsScMel,2),1),'bo')
title('Contrasts ipRGC vs Lum')
refline(1,0)

subplot(2,2,3)
plot(reshape(LocalLuminance,size(CsSclum,1)*size(CsSclum,2),1),reshape(LocalExcitation,size(CsScMel,1)*size(CsScMel,2),1),'ro')
title('Absolute Mel vs Lum')


subplot(2,2,4)
plot(reshape(LocalLuminance,size(CsSclum,1)*size(CsSclum,2),1),reshape(LocalipOut,size(CsScMel,1)*size(CsScMel,2),1),'bo')
title('Absolute ipRGC vs Lum')

savefig(['results\scenes_2015_16portion_newIPRGC\enviroment\correlations_' place])
