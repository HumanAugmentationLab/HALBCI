%% Load 15 vs 20 Hz
if ~exist('ez','var')
    pathToData = '/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727112030_PatientW1-15v20_Record.easy';
    a = io_loadset(pathToData);
    edf = exp_eval(a); % Load EDF for channel locations

    a = io_loadset(pathToData);
    ez = exp_eval(a); % Load EASY file
    ez.chanlocs = edf.chanlocs; % Replace channel locations
end

%% Channel selection
% figure; plot(ez.data'); legend(ez.chanlocs.labels)

a = flt_selchans(ez, {'P8', 'P4', 'O1', 'Oz', 'FC6', 'CP6'}, 'dataset-order', 1);
sez = exp_eval(a);
newoz = ez.chanlocs(20); newo1 = ez.chanlocs(7);
sez.chanlocs(6) = newoz; sez.chanlocs(16) = newo1;

%% Filter
afez = exp_eval(flt_fir(sez,[0.1 0.5 48 56]));
figure; plot(afez.data'); legend(sez.chanlocs.labels)

%% ICA
%lowiez = pop_runica(lowfreq_b) % run ICA on data
%highiez = pop_runica(highfreq_b) % run ICA on data
nez = pop_epoch(afez, {'111', '121', '211', '221'}, [-.5 9]);


iez = pop_runica(nez);

variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    afez.(char(variableComps(i))) = iez.(char(variableComps(i)));
   
end


%pop_selectcomps(lowiez, [1:26])
pop_selectcomps(afez, [1:26])
%sezKeep1520 = [3 11 14 15 16 17 26];
sezKeep1215 = [3 4 6 11 16 19]
keep = sezKeep1520;
reject = [1:keep(1)-1];

for i = 2:length(keep)
    reject = [reject keep(i-1)+1:keep(i)-1];
end
reject = [1 7 9 15 18]


sez = pop_subcomp(afez,reject)