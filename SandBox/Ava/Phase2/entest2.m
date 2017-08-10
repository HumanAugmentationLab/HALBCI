%% Dependency Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;
cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava
%% Load 8 vs 15 Hz
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%% Load 12 vs 15 Hz
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727113703_PatientW1-12v15_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727113703_PatientW1-12v15_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%% Load 15 vs 20 Hz
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727112030_PatientW1-15v20_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727112030_PatientW1-15v20_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations

%% Channel selection
% figure; plot(ez.data'); legend(ez.chanlocs.labels)

a = flt_selchans(ez, {'P8', 'P4', 'O1', 'Oz', 'FC6', 'CP6'}, 'dataset-order', 1);
sez = exp_eval(a);
newoz = ez.chanlocs(20); newo1 = ez.chanlocs(7);
sez.chanlocs(6) = newoz; sez.chanlocs(16) = newo1;
%% Filter
afez = exp_eval(flt_fir(sez,[0.1 0.5 48 56]));
figure; plot(afez.data'); legend(sez.chanlocs.labels)
%% Epoch Response
% chech erp of one marker (300+ ms)
% vis_data2(afez, 1:26, [5.88e4 5.93e4]); %.5e4 data points = 10 s

% find all epochs
nez = pop_epoch(afez, {'111', '121', '211', '221'}, [-.5 9]);

lowfreq_l = pop_selectevent(nez, 'type', '121');
lowfreq_r = pop_selectevent(nez, 'type', '221');
lowfreq_b = pop_selectevent(nez, 'type', {'121', '221'});

highfreq_l = pop_selectevent(nez, 'type', '111');
highfreq_r = pop_selectevent(nez, 'type', '211');
highfreq_b = pop_selectevent(nez, 'type', {'111', '211'});

% figure; pop_newtimef( lowfreq_l, 1, 1, [-500  8998], [3         0.5] , 'topovec', 1, 'elocs', lowfreq_l.chanlocs, 'chaninfo', lowfreq_l.chaninfo, 'caption', 'P7', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1);
% figure; pop_newtimef( lowfreq_r, 1, 1, [-500  8998], [3         0.5] , 'topovec', 1, 'elocs', lowfreq_r.chanlocs, 'chaninfo', lowfreq_r.chaninfo, 'caption', 'P7', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1);
% figure; pop_newtimef( lowfreq_b, 1, 1, [-500  8998], [3         0.5] , 'topovec', 1, 'elocs', lowfreq_b.chanlocs, 'chaninfo', lowfreq_b.chaninfo, 'caption', 'P7', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1);
% 
% figure; pop_newtimef( highfreq_l, 1, 1, [-500  1998], [3         0.5] , 'topovec', 1, 'elocs', highfreq_l.chanlocs, 'chaninfo', highfreq_l.chaninfo, 'caption', 'P7', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1);
% figure; pop_newtimef( highfreq_r, 1, 1, [-500  1998], [3         0.5] , 'topovec', 1, 'elocs', highfreq_r.chanlocs, 'chaninfo', highfreq_r.chaninfo, 'caption', 'P7', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1);
% figure; pop_newtimef( highfreq_b, 1, 1, [-500  1998], [3         0.5] , 'topovec', 1, 'elocs', highfreq_b.chanlocs, 'chaninfo', highfreq_b.chaninfo, 'caption', 'P7', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1);


lowfreqs = {lowfreq_l lowfreq_r lowfreq_b};
highfreqs = {highfreq_l highfreq_r highfreq_b};
alldata = {lowfreq_l lowfreq_r lowfreq_b highfreq_l highfreq_r highfreq_b};

% Check for ERP
% for i = 1:6
%     EEG = alldata{i};
% figure; pop_newtimef( EEG, 1, 17, [-500  998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'PO4', 'baseline',[0], 'plotphase', 'off', 'ntimesout', 50, 'padratio', 1);
% end

% Check whole epoch
for i = 1:6
    EEG = alldata{i};
    figure; pop_newtimef( EEG, 1, 3, [-500  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline',[0], 'freqs', [[2 35]], 'plotphase', 'off', 'padratio', 1, 'winsize', 200);
end
%% Run ICA
fulliez = pop_runica(nez)

lowiez = pop_runica(lowfreq_b)
highiez = pop_runica(highfreq_b)

rightlowiez = pop_runica(lowfreq_r);
leftlowiez = pop_runica(lowfreq_l);
righthighiez = pop_runica(highfreq_r);
lefthighiez = pop_runica(highfreq_l);
%% Load ICA from 8 vs 15
fulliez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\ICA8v15.mat');

lowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\8both.mat');
highiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-8both.mat');

rightlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\8right.mat');
leftlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\8left.mat');
righthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-8right.mat');
lefthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-8left.mat');
%% Load ICA from 12 vs 15
fulliez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\ICA12v15.mat');

lowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\12both.mat');
highiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-12both.mat');

rightlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\12right.mat');
leftlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\12left.mat');
righthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-12right.mat');
lefthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-12left.mat');
%% Load ICA from 15 vs 20
fulliez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\ICA15v20.mat');

lowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-20both.mat');
highiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\20both.mat');

rightlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-20right.mat');
leftlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-20left.mat');
righthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\20right.mat');
lefthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\20left.mat');

%% Visually Inspect Components for Selection/Removal
pop_selectcomps(fulliez, [1:26])

pop_selectcomps(lowiez, [1:26])
pop_selectcomps(highiez, [1:26])

pop_selectcomps(rightlowiez, [1:26])
pop_selectcomps(leftlowiez, [1:26])
pop_selectcomps(righthighiez, [1:26])
pop_selectcomps(lefthighiez, [1:26])
%% Remove Components
% low keep:
% 8 vs 15: IC8, IC11 (IC7)
% 12 vs 15: IC6, IC11
% 15 vs 20: IC7, IC9
lowsez = pop_subcomp(lowiez)

%high keep: 
% 8 vs 15: IC26? IC12? IC4
% 12 vs 15: IC4, IC11, IC14
% 15 vs 20: IC10, IC18, IC24
highsez = pop_subcomp(highiez)
%% Plot spectr
% Plot power/frequency for artifact removed
figure; pop_spectopo(lowsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');
figure; pop_spectopo(highsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');

% comparisons
figure; pop_spectopo(lowfreq_b, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 15 20], 'freqrange',[5 30],'electrodes','on');
figure; pop_spectopo(highfreq_b, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 15 20], 'freqrange',[5 30],'electrodes','on');

%% Training
outdata = afez;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    if i == 3
        outdata.(char(variableComps(i))) = [lowsez.(char(variableComps(i)))];
    elseif i == 4
        outdata.(char(variableComps(i))) = [lowsez.(char(variableComps(i))); highsez.(char(variableComps(i)))];
    else
       outdata.(char(variableComps(i))) = [lowsez.(char(variableComps(i))) highsez.(char(variableComps(i)))];
    end
end