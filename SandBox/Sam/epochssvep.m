%% Load data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\';
fnameeeg = '20170727114720_PatientW1-8v15_Record.easy';
ioeeg = io_loadset(fullfile(direeg,fnameeeg));
deeg = exp_eval(ioeeg)
%01 is ch7; T8 is ch9; F7 is ch19; Oz is ch20

EEG = deeg;
%%
for i=1:26
    allchnames{i} = EEG.chanlocs(i).labels;
end

chanocc = [5 6 16];
chanpar = [1 3 4 17 26];

%% Freq analysis for trials
selchan  = 2;
figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot, tdata] = newtimef(EEG.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 3);
% tdata is the freq for each trial
tdatapower = abs(tdata).^2;
%%
EEG.setname
[spectra,freqs,speccomp,contrib,specstd] = spectopo(EEG.data, 0, EEG.srate,'freqrange',[2 24]);

%%
spectra8=spectra;%%
%%
spectra12 = spectra;
%%
spectra15 =spectra;
%%
selchan = [chanocc];
figure
plot(freqs(1:60),spectra12(selchan,1:60)')
hold on
plot(freqs(1:60),spectra15(selchan,1:60)','--')
title('15Hz (dashed) and 8Hz (solid) for posterior channels')
legend([allchnames(selchan) allchnames(selchan)])

%%
%subtract from each other (not actually okay mathematically... just for peeking)
specdiff = spectraB-spectraA;
figure
plot(freqs(1:60),specdiff(selchan,1:60)')
legend(allchnames(selchan))
vline(8,'k');
vline(15,'k');
hline(0,'k');
title('15Hz minus 8Hz for posterior channels')

%% compare target freqs
fr1 = 12;
fr2 = 15;
spectraA = spectra12;
spectraB = spectra15;

halfbuffer = 0.6;
ifr1 = find(freqs>(fr1-halfbuffer)&freqs<(fr1+halfbuffer)) % select freqs that match fr1
ifr2 = find(freqs>(fr2-halfbuffer)&freqs<(fr2+halfbuffer))

psA = [mean(spectraA(:,ifr1),2) mean(spectraA(:,ifr2),2)];
psB = [mean(spectraB(:,ifr1),2) mean(spectraB(:,ifr2),2)];

psAB = [psA(selchan,:) psB(selchan,:)]; %Afr1 Afr2 Bfr1 Bfr2
%%
figure
for i = 1:length(selchan)
    subplot(2,ceil(length(selchan)/2),i)
    plot([fr1 fr2],[psA(selchan(i),:); psB(selchan(i),:)],'Marker','s','MarkerFaceColor','k')
    xlim([fr1-1 fr2+1])
    ylim([-4 9])
    xlabel('Frequency Analyzed')
    title(strcat(allchnames(selchan(i))));
    legend({strcat('DataAttend',num2str(fr1)),strcat('DataAttend',num2str(fr2))})
end

