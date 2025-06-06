function hsi = im_gen(spectra)
%Code to generate a virtual hyperspectral image to check correct contrast computation.  

r_t = 1024;
c_t = 1344;
sc_t = 33;
scene = ones(r_t,c_t,sc_t);
sections={'Q1','Q2','Q3','Q4','Q5','Q6','Q7','Q8','Q9','Q10','Q11','Q12','Q13','Q14','Q15','Q16'};
s1 = [spectra.bl spectra.pos spectra.bl spectra.neg];
%s1 = [spec_bl spec_mel_pos spec_bl spec_mel_neg];
s1 = [s1; zeros(20,4)];
wl0 = 400:720;
wl1 = 400:10:720;
s1 = s1(ismember(wl0,wl1),:);

ord1(1,:,:) = [s1 circshift(s1',1)' circshift(s1',2)' circshift(s1',3)']';
 
patches = cell(1,16);

r_s = r_t/4;
c_s = c_t/4;

for i = 1:16
    switch sections{i}
        case 'Q1'
            evar.section = scene(1:ceil(end/4), 1:ceil(end/4),:);
        case 'Q2'
            evar.section = scene(1:ceil(end/4), ceil(end/4)+1:ceil(end/2),:);
        case 'Q3'
            evar.section = scene(1:ceil(end/4), ceil(end/2)+1:(ceil(end/4)*3),:);
        case 'Q4'
            evar.section = scene(1:ceil(end/4), (ceil(end/4)*3)+1:end,:);
        case 'Q5'
            evar.section = scene(ceil(end/4)+1:ceil(end/2), 1:ceil(end/4),:);
        case 'Q6'
            evar.section = scene(ceil(end/4)+1:ceil(end/2), ceil(end/4)+1:ceil(end/2),:);
        case 'Q7'
            evar.section = scene(ceil(end/4)+1:ceil(end/2), ceil(end/2)+1:(ceil(end/4)*3),:);
        case 'Q8'
            evar.section = scene(ceil(end/4)+1:ceil(end/2), (ceil(end/4)*3)+1:end,:);
        case 'Q9'
            evar.section = scene(ceil(end/2)+1:(ceil(end/4)*3), 1:ceil(end/4),:);
        case 'Q10'
            evar.section = scene(ceil(end/2)+1:(ceil(end/4)*3), ceil(end/4)+1:ceil(end/2),:);
        case 'Q11'
            evar.section = scene(ceil(end/2)+1:(ceil(end/4)*3), ceil(end/2)+1:(ceil(end/4)*3),:);
        case 'Q12'
            evar.section = scene(ceil(end/2)+1:(ceil(end/4)*3), (ceil(end/4)*3)+1:end,:);
        case 'Q13'
            evar.section = scene((ceil(end/4)*3)+1:end,  1:ceil(end/4),:);
        case 'Q14'
            evar.section = scene((ceil(end/4)*3)+1:end,  ceil(end/4)+1:ceil(end/2),:);
        case 'Q15'
            evar.section = scene((ceil(end/4)*3)+1:end, ceil(end/2)+1:(ceil(end/4)*3),:);
        case 'Q16'
            evar.section = scene((ceil(end/4)*3)+1:end, (ceil(end/4)*3)+1:end,:);
    end
    
    patches{i} = repmat(ord1(:,i,:),size(evar.section,1),size(evar.section,2)).*evar.section;
    patch(:,:,:,i) = repmat(ord1(:,i,:),size(evar.section,1),size(evar.section,2)).*evar.section;

end

scOut1 = cat(2,patches{1},patches{2},patches{3},patches{4});
scOut2 = cat(2,patches{5},patches{6},patches{7},patches{8});
scOut3 = cat(2,patches{9},patches{10},patches{11},patches{12});
scOut4 = cat(2,patches{13},patches{14},patches{15},patches{16});

hsi = cat(1,scOut1,scOut2,scOut3,scOut4);