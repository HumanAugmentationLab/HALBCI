% 20170806165229_PatientW1-12v15-medium.easy
% 20170806164107_PatientW1-7.5v12-small.easy
% 20170806162852_PatientW1-12v30-small.easy
% 20170806161942_PatientW1-15v20-big.easy
% 20170806160959_PatientW1-7.5v12-big.easy
% 20170806154747_PatientW1-7.5v12-small.easy
% 20170806153807_PatientW1-15v20-small.easy
% 20170806152814_PatientW1-7.5v12-small.easy
% 20170806151821_PatientW1-7.5v20-small.easy
% 20170806150345_PatientW1-15v20-small.easy

%% Load 8 vs 15 Hz
%{
a = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727114720_PatientW1-8v15_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727114720_PatientW1-8v15_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%}
%% Load 12 vs 15 Hz
%{
a = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727113703_PatientW1-12v15_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727113703_PatientW1-12v15_Record.easy');
ez = exp_eval(a); % Load EASY file
ez.chanlocs = edf.chanlocs; % Replace channel locations
%}
%% Load 15 vs 20 Hz
a = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727112030_PatientW1-15v20_Record.edf');
edf = exp_eval(a); % Load EDF for channel locations

a = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727112030_PatientW1-15v20_Record.easy');
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

%% ICA
%lowiez = pop_runica(lowfreq_b) % run ICA on data
%highiez = pop_runica(highfreq_b) % run ICA on data
iez = pop_runica(afez)

%pop_selectcomps(lowiez, [1:26])
pop_selectcomps(iez, [1:26])
sezKeep1520 = [11 13 16 21 22 26];

keep = sezKeep1520;
reject = [1:keep(1)-1];
for i = 2:length(keep)
    reject = [reject keep(i-1)+1:keep(i)-1];
end
sez = pop_subcomp(iez,reject)

%rightlowiez = pop_runica(lowfreq_r);
%leftlowiez = pop_runica(lowfreq_l);
%righthighiez = pop_runica(highfreq_r);
%lefthighiez = pop_runica(highfreq_l);

%pop_selectcomps(rightlowiez, [1:26])
%pop_selectcomps(leftlowiez, [1:26])
%pop_selectcomps(righthighiez, [1:26])
%pop_selectcomps(lefthighiez, [1:26])

%% Remove Components
%low keep: IC6, IC11
keep = [6 10];
reject = [1:keep(1)-1];
for i = 2:length(keep)
    reject = [reject keep(i-1)+1:keep(i)-1];
end
lowsez = pop_subcomp(lowiez,reject);
%high keep: IC10, 12, 13, 15, 23
keep = [10 18 23];
reject = [1:keep(1)-1];
for i = 2:length(keep)
    reject = [reject keep(i-1)+1:keep(i)-1];
end
highsez = pop_subcomp(highiez);

variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    ez.(char(variableComps(i))) = [lowsez.(char(variableComps(i))) highsez.(char(variableComps(i)))];
    if i == 3
        ez.(char(variableComps(i))) = [lowsez.(char(variableComps(i)))];
        
    elseif i == 4
        
        ez.(char(variableComps(i))) = [lowsez.(char(variableComps(i))); highsez.(char(variableComps(i)))];
    end
end





%% Plot spectr
% Plot power/frequency for artifact removed
figure; pop_spectopo(lowsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 15 25], 'freqrange',[5 25],'electrodes','on');
figure; pop_spectopo(highsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [6 15 25], 'freqrange',[5 25],'electrodes','on');

%% Training
