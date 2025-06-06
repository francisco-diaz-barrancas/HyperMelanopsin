% Code to compute the excitations and contrasts from natural and human-made
% environments. Project: Melanopsin Statistics.


clear, close all

evar.group = 'verification';

evar.fsize_ipRGC = 1.37; % 1.37 deg Dendritic field in parafovea from Nasir-Ahmad et al., 2019, size: 2.4 in the periphery
evar.fsize_parasol = 0.36; % 0.36 deg dendritic field from Dacey and Petersen, 1992 % 1deg Receptive field size used by Mante et al(2005)   

d0name = ['data_' evar.group]; 
s = dir(d0name);
s=s(~ismember({s.name},{'.','..'}));
smat=s(contains({s.name},'.mat'));
spdf=s(contains({s.name},'.pdf'));
evar.sceneNames = cell(size(smat,1),1);

% From Nascimento, Amano & Foster 2016 (*2). In this way, four x four ipRGCs fit in 
evar.mSize_deg = [5.3 6.9]*2;        

LocalContrast_Mel=nan(4,size(smat,1));
LocalMelExc=nan(4,size(smat,1));
LocalContrastLum=nan(4,size(smat,1));
LocalLuminance=nan(4,size(smat,1));
LocalipOut=nan(4,size(smat,1));
sections={'Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10','Q11','Q12','Q13','Q14','Q15','Q16'};

for j=1:size(smat,1)
    evar.sceneNames{j}=smat(j).name;
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

        evar.dfdiam_deg = evar.fsize_ipRGC;
        evar.dfdiam_px=evar.dfdiam_deg/evar.mSize_deg(1)*evar.mSize_px(1);         
        % Mel Receptive field computation
        excit=computeExcitations(evar.section);
        evar.sectionMel=excit.SMLRG(:,:,5);
        evar.sectionPhot=evar.sectionMel;      
        evar=computeFieldVariables(evar);
        LocalContrast_Mel(i,j)=evar.localContrast;
        LocalMelExc(i,j)=evar.localExc;
        
        % ipRGC output1 (L+M+Mel)/S from Barrionuevo and Cao, 2016
        evar.sectionPhot=0.33*excit.SMLRG(:,:,2)+0.66*excit.SMLRG(:,:,3)+0.69*excit.SMLRG(:,:,5);
        evar=computeFieldVariables(evar);
        LMmelOut=evar.localExc;
        evar.sectionPhot=excit.SMLRG(:,:,1);
        evar=computeFieldVariables(evar);
        SOut=evar.localExc;
        LocalipOut(i,j)=LMmelOut-0.12*SOut;
      
        % ipRGC output2 (L+M+Mel)/S all factors equals to 1
        evar.sectionPhot=excit.SMLRG(:,:,2)+excit.SMLRG(:,:,3)+excit.SMLRG(:,:,5);
        evar=computeFieldVariables(evar);
        LMmelOut2=evar.localExc;
        evar.sectionPhot=excit.SMLRG(:,:,1);
        evar=computeFieldVariables(evar);
        SOut2=evar.localExc;
        LocalipOut2(i,j)=LMmelOut2-SOut2;

        % % Lum based on parasol dendritic field size
        evar.sectionLum=excit.Lum10;
        evar.sectionPhot=evar.sectionLum;       
        evar.dfdiam_deg = evar.fsize_parasol; 
        evar.dfdiam_px=evar.dfdiam_deg/evar.mSize_deg(1)*evar.mSize_px(1); 
        evar=computeFieldVariables(evar);
        LocalContrastLum(i,j)=evar.localContrast;
        LocalLuminance(i,j)=evar.localExc;  


    end
end

mExSc=repmat(mean(LocalMelExc),size(sections,2),1);
CsScMel = sqrt(((LocalMelExc-mExSc)./mExSc).^2);
CsScMel(CsScMel<0.01) = nan;
mCsMel=mean(CsScMel,'omitnan');
sCsMel=std(CsScMel,'omitnan');
mCsMel(isnan(mCsMel)) = 0;

mExScip1=repmat(mean(LocalipOut),size(sections,2),1);
CsScip1 = sqrt(((LocalipOut-mExScip1)./mExScip1).^2);
CsScip1(CsScip1<0.01) = nan;
mCsip1=mean(CsScip1,'omitnan');
sCsip1=std(CsScip1,'omitnan');
mCsip1(isnan(mCsip1)) = 0;

mExScip2=repmat(mean(LocalipOut2),size(sections,2),1);
CsScip2 = sqrt(((LocalipOut2-mExScip2)./mExScip2).^2);
CsScip2(CsScip2<0.01) = nan;
mCsip2=mean(CsScip2,'omitnan');
sCsip2=std(CsScip2,'omitnan');
mCsip2(isnan(mCsip2)) = 0;

mExSclum=repmat(mean(LocalLuminance),size(sections,2),1);
CsSclum = sqrt(((LocalLuminance-mExSclum)./mExSclum).^2);
CsSclum(CsSclum<0.01) = nan;
mCslum=mean(CsSclum,'omitnan');
sCslum=std(CsSclum,'omitnan');
mCslum(isnan(mCslum)) = 0;


outdata.MelExc = LocalMelExc;
outdata.ipOut1 = LocalipOut;
outdata.ipOut2 = LocalipOut2;
outdata.Lum = LocalLuminance;
outdata.LumCteLoc = LocalContrastLum;
outdata.MelCteSce = CsScMel;
outdata.LumCteSce = CsSclum;
outdata.ip1CteSce = CsScip1;
outdata.ip2CteSce = CsScip2;


%% Save and plot contrasts

save(['Results\Results_' evar.group],'outdata','evar')

figure,
subplot(4,1,1)
errorbar(mCsMel,sCsMel,'o-')
title('Melanopic contrast', 'Interpreter', 'none')
xticks(1:size(smat,1))
subplot(4,1,2)
errorbar(mCslum,sCslum,'o-')
title('Luminance contrast', 'Interpreter', 'none')
xticks(1:size(smat,1))
subplot(4,1,3)
errorbar(mCsip1,sCsip1,'o-')
title('ipRGC1 contrast', 'Interpreter', 'none')
xticks(1:size(smat,1))
subplot(4,1,4)
errorbar(mCsip2,sCsip2,'o-')
title('ipRGC2 contrast', 'Interpreter', 'none')
xlabel('Scene')
xticks(1:size(smat,1))
xticklabels(evar.sceneNames)