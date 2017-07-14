a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.edf')
xd = exp_eval(a) % Load EDF for channel locations
accdata = xd.data(33:35, :);

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170710171359_Patient01_SSVEP-P0-8ch.easy','channels',1:8)
eaz2 = exp_eval(a) % Load EASY file
eaz2.chanlocs = xd.chanlocs; % Replace channel locations

feaz2 = pop_eegfilt(eaz2, 0.1, 56, 15000) %filter between .1 and 56
ieaz2 = pop_runica(feaz2) % run ICA on data

% Compare EEG data, ICA, and accelerometer movement to identify muscle artifacts
eegplot(feaz2.data); % plot filtered data (eegplot has trouble with raw data)
eegplot(accdata); % plot accelerometer data
pop_eegplot(ieaz2, 0); % plot ICA time series

% If you're using the EEGLAB GUI: load EASY file, select data channel range 1:8,
% filter, ICA, plot components