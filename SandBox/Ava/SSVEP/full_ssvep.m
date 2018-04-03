% less organized version of streamline_ssvep
%% -1. Dependency Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;
cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava
%% 0. Load 8 vs 15 Hz
disp('loading 8 vs. 15 Hz data...')
a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%% 0. Load 12 vs 15 Hz
disp('loading 12 vs. 15 Hz data...')

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727113703_PatientW1-12v15_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727113703_PatientW1-12v15_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%% 0. Load 15 vs 20 Hz
disp('loading 15 vs. 20 Hz data...')

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727112030_PatientW1-15v20_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727112030_PatientW1-15v20_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%% 1. Channel selection
disp('removing bad channels')
a = flt_selchans(ez, {'P8', 'P4', 'O1', 'Oz', 'FC6', 'CP6'}, 'dataset-order', 1);
cez = exp_eval(a);
newoz = ez.chanlocs(20); newo1 = ez.chanlocs(7);
cez.chanlocs(6) = newoz; cez.chanlocs(16) = newo1;
%% 2. Filter
disp('filtering...');
afez = exp_eval(flt_fir(cez,[0.1 0.5 48 56]));
%% 3. Epoch Response
disp('epoching...')
nez = pop_epoch(afez, {'111', '121', '211', '221'}, [-.5 9]);

lowfreq_l = pop_selectevent(nez, 'type', '121');
lowfreq_r = pop_selectevent(nez, 'type', '221');
lowfreq_b = pop_selectevent(nez, 'type', {'121', '221'});

highfreq_l = pop_selectevent(nez, 'type', '111');
highfreq_r = pop_selectevent(nez, 'type', '211');
highfreq_b = pop_selectevent(nez, 'type', {'111', '211'});

lowfreqs = {lowfreq_l lowfreq_r lowfreq_b};
highfreqs = {highfreq_l highfreq_r highfreq_b};
alldata = {lowfreq_l lowfreq_r lowfreq_b highfreq_l highfreq_r highfreq_b};
%% 4. Run ICA
% All Data
fulliez = pop_runica(afez);
efulliez = pop_runica(nez);

% Low vs. High
lowiez = pop_runica(lowfreq_b)
highiez = pop_runica(highfreq_b)

% L/H -- R/L
rightlowiez = pop_runica(lowfreq_r);
leftlowiez = pop_runica(lowfreq_l);
righthighiez = pop_runica(highfreq_r);
lefthighiez = pop_runica(highfreq_l);
%% 4. Load ICA from 8 vs 15
% All Data
fulliez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\ICA8v15.mat')

% Low vs. High
lowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\8both.mat');
highiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-8both.mat');

% L/H -- R/L
rightlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\8right.mat');
leftlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\8left.mat');
righthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-8right.mat');
lefthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-8left.mat');
%% 4. Load ICA from 12 vs 15
% All Data
fulliez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\ICA12v15.mat')

% High vs. Low
lowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\12both.mat');
highiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-12both.mat');

% H/L -- L/R
rightlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\12right.mat');
leftlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\12left.mat');
righthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-12right.mat');
lefthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-12left.mat');
%% 4. Load ICA from 15 vs 20
% All Data
fulliez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\ICA15v20.mat')

% Low vs. High
lowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-20both.mat');
highiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\20both.mat');

% L/H -- R/L
rightlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-20right.mat');
leftlowiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\15-20left.mat');
righthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\20right.mat');
lefthighiez = importdata('K:HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\ica_files\20left.mat');
%% 5. Make the data file you want!!!!!
% Full Data
fullcontiez = afez;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    fullcontiez.(char(variableComps(i))) = fulliez.(char(variableComps(i)));
end

% High vs Low Data
efullcontiez = nez;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    efullcontiez.(char(variableComps(i))) = efulliez.(char(variableComps(i)));
end

concatcontiez = highfreq_b;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    if i == 3 || i == 5
        concatcontiez.(char(variableComps(i))) = [lowiez.(char(variableComps(i)))];
    elseif i == 4
        concatcontiez.(char(variableComps(i))) = [lowiez.(char(variableComps(i))); highiez.(char(variableComps(i)))];
    else
        concatcontiez.(char(variableComps(i))) = [lowiez.(char(variableComps(i))) highiez.(char(variableComps(i)))];
    end
end
highsez = pop_subcomp(concatcontiez, concatrej);
figure; pop_spectopo(highsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');
%% 6. Visually Inspect Components
pop_selectcomps(fulliez, [1:26])
pop_selectcomps(efulliez, [1:26])

pop_selectcomps(lowiez, [1:26])
pop_selectcomps(highiez, [1:26])
%% 7. HARSH - Remove Components from ICA variables AND DATA
fullkeep = [9 10 11 13 14]; % Full Full
fullrej = 1:26; fullrej(fullkeep) = [];
fullsez = pop_subcomp(fullcontiez, fullrej);

efullkeep = [5 8 11 17 18]; % 12 vs. 15 Full 
efullrej = 1:26; efullrej(efullkeep) = [];
efullsez = pop_subcomp(efullcontiez, efullrej);

lowkeep = [6 9 12 19]; % 12 Only
lowrej = 1:26; lowrej(lowkeep) = [];
highkeep = [4 11 14]; % 15 Only
highrej = 1:26; highrej(highkeep) = [];
concatkeep = [lowkeep lowkeep(end)+highkeep];
concatrej = 1:52; concatrej(concatkeep) = [];
concatsez = pop_subcomp(concatcontiez, concatrej);
%% 7. open - Remove Components from ICA variables AND DATA
fullkeep = [5 8:11 13 14 20]; % Full Full
fullrej = 1:26; fullrej(fullkeep) = [];
fullsez = pop_subcomp(fullcontiez, fullrej);

efullkeep = [2:6 8 11 14 17 18]; % 12 vs. 15 Full
efullrej = 1:26; efullrej(efullkeep) = [];
efullsez = pop_subcomp(efullcontiez, efullrej);

lowkeep = [3:6 9 12 14 18 19]; % 12 Only
lowrej = 1:26; lowrej(lowkeep) = [];
highkeep = [4 11 14 24]; % 15 Only
highrej = 1:26; highrej(highkeep) = [];
concatkeep = [lowkeep lowkeep(end)+highkeep];
concatrej = 1:52; concatrej(concatkeep) = [];
concatsez = pop_subcomp(concatcontiez, concatrej);
%% 8. Train
clear myapproach trainloss mymodel laststats prediction loss teststats targets
EEG = teshighsez;
%EEG = refactorFunc(EEG0,1,9,3);

myapproach = {'SPoC' 'SignalProcessing',{'EpochExtraction',[1 8],'FIRFilter',[2 4 47 49]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',4},'MachineLearning',{'learner','logreg'}}};
[trainloss,mymodel,laststats] = bci_train('Data',EEG,'Approach',myapproach,'TargetMarkers',{{'121' '221'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',10,0}); 
[prediction,loss,teststats,targets] = bci_predict(mymodel,EEG, 'EvaluationMetric', 'mse');

disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);