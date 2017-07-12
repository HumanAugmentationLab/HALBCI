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
feaz2 = pop_eegfilt(eaz2) %filter between .1 and 20

%% ERP Analysis
beaz2 = pop_epoch(feaz2, {'100', '200'}, [-0.5 1.5]); %epoch by events '101' '201' from 0 to 9 s
pop_timtopo(beaz2)

%% ICA
ieaz2 = pop_runica(feaz2)
pop_topoplot(ieaz2, 0)
pop_selectcomps(ieaz2, [1:8])