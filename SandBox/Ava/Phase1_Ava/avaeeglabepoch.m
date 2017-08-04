%% BCILAB Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;

%% Data
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.edf','channels',1:8)
xd = exp_eval(a)

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.easy','channels',1:8)
eaz2 = exp_eval(a)
eaz2.chanlocs = xd.chanlocs; % Replace channel locations
%feaz2 = pop_eegfilt(eaz2, 0.1, 56, 3*fix(eaz2.srate/0.1), 'firtype', 'fir1');
feaz2 = pop_eegfilt(eaz2) %filter between .1 and 56
neaz2 = pop_epoch(feaz2, {'101', '201'}, [0 9]); %epoch by events '101' '201' from 0 to 9 s
left6hz2 = pop_selectevent(neaz2, 'type', '101'); % select '101' epochs
right10hz2 = pop_selectevent(neaz2, 'type', '201'); % select '201' epochs

%% Plot spectr
figure; pop_spectopo(left6hz2, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[5 20],'electrodes','on');
figure; pop_spectopo(right10hz2, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[2 25],'electrodes','on');

%% Plot time freq
figure; pop_newtimef( left6hz2, 1, 1, [0  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'O1', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);
figure; pop_newtimef( left6hz2, 1, 1, [0  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'O1', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);


%
figure; pop_newtimef( left6hz2, 1, 4, [0  8998], [3         0.5] , 'topovec', 4, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);


%% Freq analysis for trials
selchan  = 8;
figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot tdata] = newtimef(left6hz2.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 9);
% tdata is the freq for each trial
tdatapower = abs(tdata).^2;

figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot righttdata] = newtimef(right10hz2.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 9);
righttdatapower = abs(righttdata).^2;

% Histogram of freq power
selfreq = 7; %index in freq variable
figure
tempdata = [reshape(tdatapower(selfreq,:,:),size(tdatapower,2)*size(tdatapower,3),1)...
    reshape(righttdatapower(selfreq,:,:),size(tdatapower,2)*size(tdatapower,3),1)];
hist(tempdata,50)
xlim([0 5e5])

