% Entire SSVEP Process, tailored for data collection set 1
%% -1. Dependency Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;
cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava
%% 0. Load Data
% 8 vs 15 Hz
disp('loading 8 vs. 15 Hz data...')
a = io_loadset('C:\Users\alakmazaheri\Desktop\EEGfiles\20170727114720_PatientW1-8v15_Record.edf');
edf815 = exp_eval(a); % Load EDF for channel locations
a = io_loadset('C:\Users\alakmazaheri\Desktop\EEGfiles\20170727114720_PatientW1-8v15_Record.easy');
ez815 = exp_eval(a); % Load EASY file
ez815.chanlocs = edf815.chanlocs; % Replace channel locations

% 12 vs 15
disp('loading 12 vs. 15 Hz data...')
a = io_loadset('C:\Users\alakmazaheri\Desktop\EEGfiles\20170727113703_PatientW1-12v15_Record.edf');
edf1215 = exp_eval(a); % Load EDF for channel locations
a = io_loadset('C:\Users\alakmazaheri\Desktop\EEGfiles\20170727113703_PatientW1-12v15_Record.easy');
ez1215 = exp_eval(a); % Load EASY file
ez1215.chanlocs = edf1215.chanlocs; % Replace channel locations

% 15 vs 20 Hz
disp('loading 15 vs. 20 Hz data...')
a = io_loadset('C:\Users\alakmazaheri\Desktop\EEGfiles\20170727112030_PatientW1-15v20_Record.edf');
edf1520 = exp_eval(a); % Load EDF for channel locations
a = io_loadset('C:\Users\alakmazaheri\Desktop\EEGfiles\20170727112030_PatientW1-15v20_Record.easy');
ez1520 = exp_eval(a); % Load EASY file
ez1520.chanlocs = edf1520.chanlocs; % Replace channel locations
%% 1. Channel selection
    disp('removing bad channels')

    a = flt_selchans(ez815, {'P8', 'P4', 'O1', 'Oz', 'FC6', 'CP6'}, 'dataset-order', 1);
    cez815 = exp_eval(a);
    newoz = ez815.chanlocs(20); newo1 = ez815.chanlocs(7); 
    cez815.chanlocs(6) = newoz; cez815.chanlocs(16) = newo1;
    
    a = flt_selchans(ez1215, {'P8', 'P4', 'O1', 'Oz', 'FC6', 'CP6'}, 'dataset-order', 1);
    cez1215 = exp_eval(a);
    newoz = ez1215.chanlocs(20); newo1 = ez1215.chanlocs(7);
    cez1215.chanlocs(6) = newoz; cez1215.chanlocs(16) = newo1;
    
    a = flt_selchans(ez1520, {'P8', 'P4', 'O1', 'Oz', 'FC6', 'CP6'}, 'dataset-order', 1);
    cez1520 = exp_eval(a);
    newoz = ez1520.chanlocs(20); newo1 = ez1520.chanlocs(7);
    cez1520.chanlocs(6) = newoz; cez1520.chanlocs(16) = newo1;
%% 2. Filter
disp('filtering...');
afez815 = exp_eval(flt_fir(cez815,[0.1 0.5 48 56]));
afez1215 = exp_eval(flt_fir(cez1215,[0.1 0.5 48 56]));
afez1520 = exp_eval(flt_fir(cez1520,[0.1 0.5 48 56]));
%% 3. Epoch Response
disp('epoching...')
nez815 = pop_epoch(afez815, {'111', '121', '211', '221'}, [-.5 9]);
lowfreq815 = pop_selectevent(nez815, 'type', {'121', '221'});
highfreq815 = pop_selectevent(nez815, 'type', {'111', '211'});

nez1215 = pop_epoch(afez1215, {'111', '121', '211', '221'}, [-.5 9]);
lowfreq1215 = pop_selectevent(nez1215, 'type', {'121', '221'});
highfreq1215 = pop_selectevent(nez1215, 'type', {'111', '211'});

nez1520 = pop_epoch(afez1520, {'111', '121', '211', '221'}, [-.5 9]);
lowfreq1520 = pop_selectevent(nez1520, 'type', {'121', '221'});
highfreq1520 = pop_selectevent(nez1520, 'type', {'111', '211'});
%% 4. Load ICA
disp('loading ica...')
% 8 vs 15
lowiez815 = importdata('C:\Users\alakmazaheri\Desktop\EEGfiles\8both.mat');
highiez815 = importdata('C:\Users\alakmazaheri\Desktop\EEGfiles\15-8both.mat');

% 12 vs 15
lowiez1215 = importdata('C:\Users\alakmazaheri\Desktop\EEGfiles\12both.mat');
highiez1215 = importdata('C:\Users\alakmazaheri\Desktop\EEGfiles\15-12both.mat');

% 15 vs 20
lowiez1520 = importdata('C:\Users\alakmazaheri\Desktop\EEGfiles\15-20both.mat');
highiez1520 = importdata('C:\Users\alakmazaheri\Desktop\EEGfiles\20both.mat');
%% 5. Combine Data into File
disp('making file...')
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};

trainlowiez = lowiez1520; % take ica info from low freq
trainhighiez = highiez1520; % take ica info from high freq

applow = lowfreq1520; % take low freq data
apphigh = highfreq1520; % take high freq data

% add ica variables to struct with data 
for i = 1:length(variableComps)
    if i == 3 || i == 5
        applow.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i)))];
        apphigh.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i)))];
    elseif i == 4         
        applow.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))); trainhighiez.(char(variableComps(i)))];
        apphigh.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))); trainhighiez.(char(variableComps(i)))];
    else
        applow.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))) trainhighiez.(char(variableComps(i)))];
        apphigh.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))) trainhighiez.(char(variableComps(i)))];
    end
end
%% 6. Visually Inspect Components
% 8 vs 15
pop_selectcomps(lowiez815, [1:26])
pop_selectcomps(highiez815, [1:26])

% 12 vs 15
pop_selectcomps(lowiez1215, [1:26])
pop_selectcomps(highiez1215, [1:26])

% 15 vs 20
pop_selectcomps(lowiez1520, [1:26])
pop_selectcomps(highiez1520, [1:26])
%% 7. Select Components
%lowkeep = [8 11]; % 8
%lowkeep = [6 9 12 19]; % 12
%lowkeep = [3:6 9 12 14 18 19]; % 12 Open
lowkeep = [5 9 17]; % 15
lowrej = 1:26; lowrej(lowkeep) = [];

%highkeep = [2 26]; % 15(8)
%highkeep = [4 11 14]; % 15(12)
%highkeep = [4 11 14 24]; % 15(12) Open
highkeep = [18 24]; % 20
highrej = 1:26; highrej(highkeep) = [];

concatkeep = [lowkeep lowkeep(end)+highkeep];
concatrej = 1:52; concatrej(concatkeep) = [];

lowsez = pop_subcomp(applow, concatrej);
highsez = pop_subcomp(apphigh, concatrej);
%% 8. Visualize Freq. Response
figure; pop_spectopo(lowsez, 1, zw[0  8998], 'EEG' , 'percent', 100, 'freq', [10.5 15.2 20], 'freqrange',[5 25],'electrodes','on');
figure; pop_spectopo(highsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10.5 15.2 20], 'freqrange',[5 25],'electrodes','on');