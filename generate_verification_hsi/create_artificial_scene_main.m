clear, close all


phot_name = 'mel';

load('gamut_5p.mat')

rads = 30*gvars.RadforA;

Ap = (gvars.norm_fundamentals'*rads)';

switch phot_name
    case 'mel'
        smlri0 = mel.gamut(mel.maxlocation,1:5);
        smlrip = mel.gamut(mel.maxlocation,17:21);
        smlrin = mel.gamut(mel.maxlocation,27:31);
        fig_name = 'Melanopsin';
    case 'lum'
        smlri0 = lm.gamut(lm.maxlocation,1:5);
        smlrip = lm.gamut(lm.maxlocation,17:21);
        smlrin = lm.gamut(lm.maxlocation,27:31);
        fig_name = 'Luminance';
end

bcgar = smlri0/Ap;
bcgarp = smlrip/Ap;
bcgarn = smlrin/Ap;


bl = bcgar;
rad_bl = rads.*repmat(bl,301,1);
spectra.bl = sum(rad_bl,2);
vbl = spectra.bl'*gvars.norm_fundamentals;

% Photoreception code
phot_pos = bcgarp; 
phot_neg = bcgarn; 

rad_phot_pos = rads.*repmat(phot_pos,301,1);
rad_phot_neg = rads.*repmat(phot_neg,301,1);

spectra.pos = sum(rad_phot_pos,2);
spectra.neg = sum(rad_phot_neg,2);

figure, plot([spectra.bl spectra.pos spectra.neg])
legend({'bl',[phot_name ' pos'],[phot_name ' neg']})
title(fig_name)

vpos = spectra.pos'*gvars.norm_fundamentals;
vneg = spectra.neg'*gvars.norm_fundamentals;

wctr(1,:) = (vpos-vbl)./vbl*100;
wctr(2,:) = (vneg-vbl)./vbl*100;
wctr(3,:) = (vpos-vneg)./vneg*100;

%% artificial scenes

hsi = im_gen(spectra);
save(['Artificial_' phot_name],'hsi');

    