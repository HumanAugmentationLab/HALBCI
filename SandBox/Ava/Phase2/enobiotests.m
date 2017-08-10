%% Load Data
% 8 vs 15 test
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.edf');
edf815 = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.easy');
ez815 = exp_eval(a); % Load EASY file
ez815.chanlocs = edf815.chanlocs; % Replace channel locations

%%
plot(ez815.data')

hpez815 = exp_eval(flt_fir(ez815,[0.1 0.5],'highpass'));
figure; vis_data2(hpez815, 0:32);

%% Filter
fez815 = pop_eegfilt(hpez815, 0.1, 56, 15000) %filter between .1 and 56

%% ERP Analysis
bez815 = pop_epoch(fez815, {'110', '120', '210', '220'}, [-0.5 1.5]); %epoch for arrow onset events '100' '200'
pop_timtopo(bez815) % plot ERP response

%% ICA
iez815 = pop_runica(fez815) % run ICA on data
% pop_topoplot(iez815, 0)
pop_selectcomps(iez815, [1:29]) % manually check ICs
sez815 = pop_subcomp(iez815) % subtract select ICs and save as new data set

%% Epoch
nez815 = pop_epoch(iez815, {'110', '120', '210', '220'}, [0 9]);
left8hz = pop_selectevent(nez815, 'type', '110');
right8hz = pop_selectevent(nez815, 'type', '120');
both8hz = pop_selectevent(nez815, 'type', {'110', '120'});

left15hz = pop_selectevent(nez815, 'type', '210');
right15hz = pop_selectevent(nez815, 'type', '220');
both15hz = pop_selectevent(nez815, 'type', {'210', '220'});

%% Plot spectr
% Plot power/frequency for artifact removed
figure; pop_spectopo(both8hz, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[5 20],'electrodes','on');
figure; pop_spectopo(both15hz, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 10 15], 'freqrange',[2 25],'electrodes','on');