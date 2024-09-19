function evar = make_figures(evar,place,mC,sC,mCs,sCs,LocalExcitation, LocalContrast,scene,sections)
% make figure
switch place
    case 'levada'
        time= ['14:11'; '15:18'; '16:08'; '17:12'; '18:10'; '18:30'; '18:45'];
        nT=datenum(time);
    case 'gualtar'
        time= ['11:44'; '12:45'; '13:46'; '14:47'; '15:45'; '16:45'; '17:46'; '18:53'; '19:44'];
        nT=datenum(time);
    case 'nogueiro'
        time= ['11:40'; '12:40'; '13:45'; '14:41'; '16:00'; '16:37'; '17:45'; '18:45'; '19:41'];
        nT=datenum(time);
    case 'sete_fontes'
        time= ['12:25'; '13:21'; '14:38'; '15:15'; '16:14'; '17:13'; '18:15'; '18:40'];
        nT=datenum(time);
    case 'mel5p'
        time= ['basl'; 'posi'; 'nega'; 'shuf'; 'chbd'; 'basl'];
        nT=1:6;
    otherwise
        nT= 1:length(mC);
        time=num2str(nT');
end

figure,
subplot(4,1,1)
errorbar(nT,mC,sC,'-o','LineWidth',2)
ylim([0 1.5])
xticks(nT)
xticklabels(time)
title(place)
ylabel('Melanopsin Contrast')
xlabel('Time of the day (HH:MM)')
grid on

subplot(4,1,2)
plot(nT,LocalExcitation','-o')
xticks(nT)
xticklabels(time)
ylabel('Melanopsin Excitation')
xlabel('Time of the day (HH:MM)')
legend(sections)

subplot(4,1,3)
errorbar(nT,mCs,sCs,'-o','LineWidth',2)
ylim([0 1])
xticks(nT)
xticklabels(time)
title('averaging per section')
ylabel('Melanopsin Contrast')
xlabel('Time of the day (HH:MM)')
grid on

subplot(4,1,4)
plot(nT,LocalContrast','-o')
xticks(nT)
xticklabels(time)
ylabel('Melanopsin contrast pixel')
xlabel('Time of the day (HH:MM)')
legend(sections)

savefig(['results\figdata_' place])

figure,
im = imread(['scenes_time\photos\' place '.bmp']);
imshow(im)
hold on
    for i = 1:4
        switch sections{i}
            case 'UpperLeft'
            evar.section=scene(1:ceil(end/2), 1:ceil(end/2),:);
            n0=[0,0];
            case 'UpperRight'
            evar.section=scene(1:ceil(end/2), ceil(end/2)+1:end,:);
            n0=[0,size(scene,2)/2];
            case 'LowerLeft'
            evar.section=scene(ceil(end/2)+1:end, 1:ceil(end/2),:);
            n0=[size(scene,1)/2,0];            
            case 'LowerRight'
            evar.section=scene(ceil(end/2)+1:end, ceil(end/2)+1:end,:);
            n0=[size(scene,1)/2,size(scene,2)/2];
        end
        matrixSize = size(evar.section);
        pdiam =  evar.dfdiam_px;
        patchRadius = pdiam / 2;        
        [X, Y] = meshgrid(1:matrixSize(2), 1:matrixSize(1));
        centerX = matrixSize(2) / 2;
        centerY = matrixSize(1) / 2;
        
        % Calculate the distance of each grid point from the center
        distances = sqrt((X - centerX).^2 + (Y - centerY).^2);
        
        
        % Find the indices of the elements within the circular patch
        [rowInd,colInd] = find(distances <= patchRadius);
        x0=colInd+n0(2);
        y0=rowInd+n0(1);
        s=plot(x0,y0,'o');
        alpha(s,.5)
    end
title(place)
legend(sections)
hold off

savefig(['results\ImPatch_' place])
end