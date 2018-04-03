%% Run BCILAB
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;
%% Load Raw Data and Run ICA
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\';
fnameeeg = ... '20170806165229_PatientW1-12v15-medium.easy';
         ...'20170806164107_PatientW1-7.5v12-small.easy';
         ...'20170806162852_PatientW1-12v30-small.easy';
         '20170806161942_PatientW1-15v20-big.easy';
        %...'20170806160959_PatientW1-7.5v12-big.easy';
        %...'20170806154747_PatientW1-7.5v12-small.easy';
        %... '20170806153807_PatientW1-15v20-small.easy';
        %...'20170806152814_PatientW1-7.5v12-small.easy';
        %...'20170806151821_PatientW1-7.5v20-small.easy';
        %'20170806150345_PatientW1-15v20-small.easy';

ioeeg = io_loadset(fullfile(direeg,fnameeeg));
deeg = exp_eval(ioeeg)

%remove channel AF3 - placed on mastoid
deeg.chanlocs = mychanlocs;
deeg.data(31,:) = [];

% Pre-Processing
disp('filtering...');
afez = exp_eval(flt_fir(deeg,[0.1 0.5 48 56]));

disp('epoching...')
nez = pop_epoch(afez, {'111', '121', '211', '221'}, [-.5 9]);
lowfreq_epochs = pop_selectevent(nez, 'type', {'111', '121'});
lowfreq_epochs.chanlocs = mychanlocs;
%figure; pop_spectopo(lowfreq_epochs, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [7.5 10 12 15], 'freqrange',[2 35],'electrodes','on');

highfreq_epochs = pop_selectevent(nez, 'type', {'211', '221'}); %13, 16
highfreq_epochs.chanlocs = mychanlocs;
%figure; pop_spectopo(highfreq_epochs, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [7.5 10 12 15], 'freqrange',[2 35],'electrodes','on');

% Run ICA
lowiez = pop_runica(lowfreq_epochs)
highiez = pop_runica(highfreq_epochs)

lowiez.chanlocs = mychanlocs;
highiez.chanlocs = mychanlocs;