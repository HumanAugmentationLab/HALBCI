%% BCILAB Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;

%% Load Data
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.edf','channels',1:8)
xd = exp_eval(a) % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.easy','channels',1:8)
eaz2 = exp_eval(a) % Load EASY file
eaz2.chanlocs = xd.chanlocs; % Replace channel locations

%% Filter
feaz2 = pop_eegfilt(eaz2, 0.1, 56, 15000) %filter between .1 and 56

%% ERP Analysis
beaz2 = pop_epoch(feaz2, {'100', '200'}, [-0.5 1.5]); %epoch for arrow onset events '100' '200'
pop_timtopo(beaz2) % plot ERP response

%% ICA
ieaz2 = pop_runica(feaz2) % run ICA on data
% pop_topoplot(ieaz2, 0)
pop_selectcomps(ieaz2, [1:8]) % manually check ICs
seaz2 = pop_subcomp(ieaz2) % subtract select ICs and save as new data set

%% Epoch
neaz2 = pop_epoch(seaz2, {'101', '201'}, [0 9]); %epoch by events '101' '201' from 0 to 9 s
left6hz2 = pop_selectevent(neaz2, 'type', '101'); % select '101' epochs
right10hz2 = pop_selectevent(neaz2, 'type', '201'); % select '201' epochs

neaz3 = pop_epoch(feaz2, {'101', '201'}, [0 9]); %do the same as above to data w/artifacts to check impact
left6hz3 = pop_selectevent(neaz3, 'type', '101'); 
right10hz3 = pop_selectevent(neaz3, 'type', '201');

%% Plot spectr
% Plot power/frequency for artifact removed
figure; pop_spectopo(left6hz2, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[5 20],'electrodes','on');
figure; pop_spectopo(right10hz2, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[2 25],'electrodes','on');

figure; pop_spectopo(left6hz3, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[5 20],'electrodes','on');
figure; pop_spectopo(right10hz3, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[2 25],'electrodes','on');
