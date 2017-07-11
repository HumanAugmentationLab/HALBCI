%easy file seems to have wrong channel labels
% .edf has right channel labels, but wrong events
% quick cheat: load edf file and copy the hannel locs from that
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.edf','channels',1:8)
xd = exp_eval(a)

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.easy','channels',1:8)
eaz2 = exp_eval(a)
eaz2.chanlocs = xd.chanlocs; % Replace channel locations
feaz2 = pop_eegfilt(eaz2); %filter between .1 and 56
neaz2 = pop_epoch(feaz2); %events '101' '201' time from 0 to 9 s
left6hz2 = pop_selectevent(neaz2); % select event type '101', remove others
right10hz2 = pop_selectevent(neaz2); % select event type '201', remove others

%% Set which data you're lookin at
left = left6hz;
right = right15hz;

%% Plot spectr
figure; pop_spectopo(left, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [7 11 15], 'freqrange',[2 25],'electrodes','on');
figure; pop_spectopo(right, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [7 11 15], 'freqrange',[2 25],'electrodes','on');

%% Plot time freq
figure; pop_newtimef( left, 1, 1, [0  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'O1', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);
figure; pop_newtimef( right, 1, 1, [0  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'O1', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);


%figure; pop_newtimef( left6hz2, 1, 4, [0  8998], [3         0.5] , 'topovec', 4, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);


%% Freq analysis for trials
selchan  = 4;
figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot tdata] = newtimef(left.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 9);
% tdata is the freq for each trial
tdatapower = abs(tdata).^2;

figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot righttdata] = newtimef(right.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 9);
righttdatapower = abs(righttdata).^2;

% Histogram of freq power
selfreq = 4; %index in freq variable
figure
tempdata = [reshape(tdatapower(selfreq,:,:),size(tdatapower,2)*size(tdatapower,3),1)...
    reshape(righttdatapower(selfreq,:,:),size(tdatapower,2)*size(tdatapower,3),1)];
hist(tempdata,10)
xlim([0 5e5])
title(num2str(freqs(selfreq)))

%% Compare
figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot tdata] = newtimef({left.data(selchan,:,:) right.data(selchan,:,:)}, 4500,[0  8998],500, [3  0.5] , 'freqs', [[4 18]],'nfreqs',2,'ntimesout', 4);


