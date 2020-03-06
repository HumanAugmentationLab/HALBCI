%% Load BCILAB
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab

%% Directory for EEG data (K drive is \fsvs01\Research\)

% As of FA19, data storage protocol places raw data in a separate folder on the K drive
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\';

% File name without extension
fnameeeg = '20191121162238_JR-VideoCheckOpacity_Test';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
ogEEG = EEG;

%% Load corrected data if markers were missing in NIC
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\';

% Create new marker file using fixmissingmarkersfromlog.m
fnameeeg = '20191118162721_AI-VideoCheckOpacity_Test_newmarkers.set';

EEG = pop_loadset('filename', fnameeeg, 'filepath', direeg);
ogEEG = EEG;
%% Chop run between start and end markers 
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% EEG = eeg_eegrej(EEG, [1 start_pt-1]);
disp('Cropping start and end of raw data...')
EEG = eeg_eegrej(EEG, [1 start_pt-1; end_pt+1 EEG.pnts*EEG.srate]);

%% Filter the continuous data
lastEEG = EEG;

adetails.filter.mode = 'bandpass'; % band pass

% for a band-pass/stop filter, this is: [low-transition-start,
% low-transition-end, hi-transition-start, hi-transition-end], in Hz
adetails.filter.freqs = [.25 .75 50 54]; 
% adetails.filter.freqs = [.25 .75]; 

%  Type         :   * 'minimum-phase' minimum-hase filter -- pro: introduces minimal signal delay;
%                         con: distorts the signal (default)
%                      * 'linear-phase' linear-phase filter -- pro: no signal distortion; con: delays
%                         the signal
%                      * 'zero-phase' zero-phase filter -- pro: no signal delay or distortion; con:
%                         can not be used for online purposes
adetails.filter.type = 'linear-phase';

adetails.filter.state = []; 
%previous filter state, as obtained by a previous execution of flt_fir on an
%immediately preceding data set (default: [])

disp('Filtering...')
[EEG, adetails.filter.state] = exp_eval(flt_fir(EEG,adetails.filter.freqs, ...
    adetails.filter.mode, adetails.filter.type));

%% Plot the filtered EEG data (may skip)

% Plot the raw data
pop_eegplot(EEG,1,1,0);

% Plot the spectra
% Event 2 skips over EEGLAB boundary marker
figure; pop_spectopo(EEG, 1, [EEG.event(2).latency_ms EEG.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [30 60 120], 'freqrange',[.5 130],'electrodes','on');
% again zoomed in
figure; pop_spectopo(EEG, 1, [EEG.event(2).latency_ms EEG.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [6 9 11 12 15], 'freqrange',[2 24],'electrodes','on');

%% Epoch each trial into long epochs OR skip this step and make short epochs below
lastEEG = EEG;

% Markers for sustained attention
adetails.markers.types = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

adetails.markers.epochwindow = [2 60]; 


EEG = pop_epoch(EEG,adetails.markers.types, adetails.markers.epochwindow);

%% Epoch into small chunks
% EEG = ogEEG;
lastEEG = EEG;
% Markers for sustained attention

% adetails.markers.types = {'51','52','53','54','55','56'};     % Check size
adetails.markers.types = {'51','52','53','54','55','56','57','58'};     % Check opacity

evtype = [];

% adetails.markers.epochwindow = [0 10];
adetails.markers.epochwindow = [0.1 60.1]; % window after standard markers to look at
adetails.markers.epochsize = 3; % size of miniepochs to chop regular markered epoch up into
adetails.markers.numeventsperwindow = floor((adetails.markers.epochwindow(2)-adetails.markers.epochwindow(1))/adetails.markers.epochsize);

disp('Adding EEG markers...')

k = 1; % New event index
for i = 1:length(lastEEG.event) 
    if any(contains(adetails.markers.types,lastEEG.event(i).type))
        markerstring = EEG.event(i).type;
        
        for j = 0:(adetails.markers.numeventsperwindow-1) %For how many markers we are doing per window     
            EEG.event(k).type = lastEEG.event(i).type;
            EEG.event(k).latency = lastEEG.event(i).latency + (j*lastEEG.srate*adetails.markers.epochsize); 
            EEG.event(k).latency_ms = lastEEG.event(i).latency_ms + (j*adetails.markers.epochsize*1000); 
            EEG.event(k).duration = adetails.markers.epochsize; % seconds for continuous data
            k = k+1; 
        end        
    else
%         EEG.event(k) = lastEEG.event(i); % Write into new index
%         disp(lastEEG.event(i))
%         disp(k)
        EEG.event(k).type = lastEEG.event(i).type;
        EEG.event(k).latency = lastEEG.event(i).latency; 
        EEG.event(k).latency_ms = lastEEG.event(i).latency_ms; 
        EEG.event(k).duration = 0; 
%         disp(EEG.event(k))
        k = k+1;
    end
end

disp('Epoching EEG...')
EEG = pop_epoch(EEG,adetails.markers.types, [0 adetails.markers.epochsize-0.002]);
% EEG = pop_epoch(EEG,adetails.markers.types, [0 adetails.markers.epochsize]);

% Inspect epoched data in frequency domain
% figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
%     'percent', 100, 'freq', [6 10 15], 'freqrange',[1 30],'electrodes','on');

%% Inspect for bad channels
lastEEG = EEG;
% Show candidates for rejection 
[~,badelec] = pop_rejchan(EEG,'elec',1:32,'threshold',5,'norm','on','measure','prob');

% Plot data to look at "bad" channels
% Plot the epoched data
pop_eegplot(EEG, 1);

%% Interpolate/remove the bad channels from the data
adetails.reject.strategy = 'interpolate'; % or 'remove'

% Here you can add additional bad electrodes, besides the ones in badelec
% badelec = [13 17]; % LO all runs
% badelec = [13 22 26]; % FE Check size med
% badelec = [13 17 26 27]; % FE strong opacity
% badelec = [13]; % MD opacity
% badelec = 27; % BN opacity
% badelec = [13 17]; % OP opacity, strong
% badelec = [17 26]; % OP med
% badelec = [15]; % IF opacity
% badelec = 19; % CV
% badelec = [18 30]; % RM 
% badelec = [1 18 30]; % RM med
% badelec = [10 31]; % GR med
% badelec = 10; % GR opacity
% badelec = [13 17]; % VM strong
% badelec = [13 17 31]; % VM med
% badelec = [28]; % DC med
% badelec = 8; % DC opac
% badelec = [6 9 20 30]; % LT strong
% badelec = [9 10 20 30]; % LT opac
% badelec = [20 21]; % LT med
% badelec = [16 28 31]; % QP Strong
% badelec = [16]; % QP opac, med
% badelec = [15 17 18 31]; % AI med
badelec = [8 17 19 32]; % AI opac
% badelec = [14 25 27 30]; % JR strong
% badelec = [8]; % JR med
% badelec = [14 19 23]; % JR opac

adetails.reject.channelidx = badelec;

adetails.reject.channelnames =  {EEG.chanlocs(adetails.reject.channelidx).labels};

% Actually remove the bad channels
if strcmp(adetails.reject.strategy, 'remove' )
    EEG = pop_select(EEG,'nochannel',adetails.reject.channelnames);
elseif strcmp(adetails.reject.strategy, 'interpolate' )
    % Interpolate rejected channels
    disp('Interpolating...')
    EEG = eeg_interp(EEG,adetails.reject.channelidx,'spherical');
end

%% Inspect and reject epochs for motion artifacts
lastEEG = EEG;
pop_eegplot(EEG, 1, 1, 1);  % removes epochs within original EEG struct
% EEG = pop_rejepoch(EEG, 21, 1);

% LO med  = [81 82 141 290];
% FE opac = [1 35 101:102 141 173 201:203 231:233 241:242 315];
% FE med = [1:4 73 121 141:142 201:202 213 222 237 242 287];
% FE strong = [1 9 21:22 47:48 61 106 154 161 163:164 181:183 197 201 221 222 238 263 287 288 291:297 299:302 322 344:349 356 357]
% MD opac = [41 42 61 62 75 77 101 102 104 121 126 128 141 142 161 182 190 221 222 240 261 263 271 272 281 282 301 302]
% MD med = = [62 63 82 101 104 161 295 211 212 215 221 241 261 282 302 346 358]
% MD strong = [21 61 101 102 106 107 139 142 143 161 163 164 179 181 182 187 188 201 205 221 241 261 263 281:283 286:290 323];
% BN opac = [289 290 301]
% BN med = [161 162 181 221 242 246 301 321 341:343]
% BN strong = [41 61 62 101 102 141 142 161 162 181 201:203 207 208 226:228 281:284 301 321 342 354]
% OP opacity = [14 41 101 161 162 181 208 221 241 242 289 301]
% OP med = [1 341:343]
% OP strong = [61 161 162 201 244 261 264 281:282 302 321]
% IF opac = [13 41 61:62 82 101:102 112:115 122 141 161:162 221 229 241 247 261 281]
% IF strong = [1 22 41 47:50 82 84 101 121 141 142 161 162 181 187 191 197 221 230 237 241 242 281 282 306 307 341]
% IF med = [4 21:23 41:42 61 76 83 101 121 141 161 181:182 201 241 261 277 279:281 309:310 321 337:338 341:342 354 359:360]
% CV_opac = [40 193 194 216 220 298]
% CV_strong = [241 317]
% RM_strong = [21 41 61 62 81 101 112 121 141 142 201 221 241 261 341]
% RM_med = [21 44 81 101 161 181 228:229 355]
% GR_opac = [1 101:102 150 232]
% GR_strong = [1 47 73 213 302 309 315 346:347 351];
% GR_med = [1];
% VM_strong = [40 60 121 139 161 182 201 202 227 242:243 263:264];
% VM_med = [41 59:60 62 81 84:85 101 124 141 145 171 181:185 222 243 261 303 321 323 346]
% VM_opac = [43 64 81 121:123 139 181 185 199 283 297 299:300 304:309 319:320];
% DC_opac = [221 301];
% DC_med = [1 9 49 82 241];
% DC_strong = [20 40 60 80 100 120 140 160 180 200 220 230 240 260 280 300 320 340];
% HL_med = [21 41 61 81 101 121 141 161 181 201 202 221 222 241 261 299 301 321 336 341];
% HL_opac = [21 24 37 39 41 55 61 81 104 121 141 145 161 179 181 182 198 199 201 221 222 241 261 281 282 301 302 307];
% HL_strong = [1 21 41 61 141 161 199 201 241 261 262 282 301 302];
% LT_strong = [61 101 141 162 181 198 199 201 202 209 215 221 227 233 261 276 281 282 304 321 322 355];
% LT_opac = [2 45 61 62 93 121 143 144 161 162 176 177 181 201:203 221 222 261 281 282];
% LT_med = [81 228 280 312 358];
% QP_strong = 290;
% QP_opac = [22:24 62:64 103 121 123 143 144 182 221:224 243:244 282 303];
% QP_med = [42 201 202 322];
% AI_med = [106 109];
% AI_strong = [231 291];
AI_opac = [81 183 204 249 261 298 300 301 312];
% JR_strong = [101 122 140 141 161 221 222 301 302 321 341];
% JR_med = [101 165 166 181];
% JR_opac = [41 61 101 102 121 122 124 141 145:147 150 301];

%% Confirm that the new data look good (can skip)
pop_eegplot(EEG,1,1,1);
figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 15], 'freqrange',[1 30],'electrodes','on');

%% Run ICA to find eye movements and other artifacts
% See this page for running and rejecting ICA componenets
% https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA
lastEEG = EEG;
EEG = pop_runica(EEG, 'runica');

% Run ICA on the version without channel rejection for comparison
% eeg_ica_epoch = pop_runica(eeg_ica_rej);
% These give similar results

% Write ICA to file for later use
dirpreica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\Pre-ICA\';

pop_saveset(EEG, 'filename', 'AI-VideoCheckOpacity-preica', 'filepath', dirpreica)

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;

LO_opac = [1 18 23:27 29:30];
LO_strong = [1 16 21 23:24 26:30];
LO_med = [1 4 18 19 21:23 25:28:30]; 
FE_opac = [1 3 5 8:11 14:15 19 21 23 25:30 32];
FE_strong = [2 5:6 9 11 12 15 16 18 19 23:25 27 29 30];
FE_med = [1 5:7 11:14 16 18 22 25 27 29];
MD_opac = [1 6 11 14:18 24:25 28:31];
MD_strong = [1 3 4 6 8 9 12:14 18 23:24 29 30 32];   
MD_med = [1 3:7 10 16 17 20 21 24 28:32];
BN_opac = [1 2 4 11 13 15:17 23 28:30];
BN_med = [1 3 7 9 13 16 17 23 25 28:30];
BN_strong = [1 3 4 12 14 15 21 23 24 26:28 30:32];
OP_opac = [1 7 8 13 14 17:22 24:27 29:31];
OP_med =  [5 7 10 13 14 18 19 21:25 27:30];
OP_strong = [1 6 10 11 16 18 19 23:28 30];
IF_opac = [2 10 12 15 17 18 20 22:25 27:29 31];
IF_strong = [2 9:15 19:21 24 26 32];
IF_med = [2 10:11 13:19 22:23 26:28 31:32];
CV_opac = [2 6 14 18 21 25 30 31];
CV_med = [1 6 20 22 28 30 31];
CV_strong = [1 6 11 15:16 20 22 28 30:31];
RM_opac = [3 6 11:12 15:19 21:22 24:30];
RM_strong = [1 9 13 14 16:17 19:26 29:32];
RM_med = [3 6 12:13 15:16 19:23 26:29];
GR_strong = [1 4:5 14:15 18:19 21:22 24 26:30 32];
GR_opac = [1 4 9 16:20 23:26 28:31];
VM_strong = [1 6 9 14:18 20 23:24 26 29];
VM_med = [2 7 9:11 13 16:17 19:21 23 27:29];
VM_opac = [1:3 8:9 15 17 20 25 29:30 32];
DC_opac = [1 3:6 8 12 17 23 25 27 30 32];
DC_med = [2 4 13:14 22:23 25 29:31];
DC_strong = [1 12 13 15 21 24 26 27 30:32];
HL_med = [2 7 13 17 18 20 22:24 26:29 31 32];
HL_opac = [1 3 4 6 9 12 14 16:18 26 29 30 32];
HL_strong = [1 6 13 15:16 22 24 27 31];
LT_strong = [1 4:6 9 11 14 17:18 21:28];
LT_opac = [1 2 8 10 13 14 16 20:23 25 27:30];
LT_med = [2:6 14 17:18 20 22 24 26 27 30]; % ICA1 has extremely high power values
QP_strong = [1 13:14 19:21 28:29];
QP_opac = [1 3 5 8 16 18:21 23:26 28 30];
QP_med = [1 4 10 12 14 20 24:26 28:29]; 
AI_med = [1 6:10 14:16 18 20:24 26:28]; 
AI_strong = [3 10:11 20 22 26:27 30:31];
AI_opac = [1 12 14:16 19:20 22 26 27];
JR_strong = [2 5:7 9:16 26:28];
JR_med = [5 7 10 14 16 21 22 25 27 30 31];
JR_opac = [3 5 9 10 12 13 15:17 19 21:23 25 27 29];

rej_comps = AI_opac;
adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('Subtracing ICA component from data...')
EEG = pop_subcomp(EEG, rej_comps);

dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
pop_saveset(EEG, 'filename', 'AI-VideoCheckOpacity.set', 'filepath', dirica)

%% Plot data after removal of ICA components
% Reference to original data
figure; pop_spectopo(lastEEG, 1, [1000*lastEEG.xmin  1000*lastEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');
%% Load pre-ICA runs
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\Pre-ICA\';
EEG = pop_loadset('filename', 'AI-VideoCheckOpacity-preica.set', 'filepath', direeg);

%% Load post-ICA runs
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
% ogEEG = pop_loadset('filename', 'TW-VideoCheckSize-Strong.set', 'filepath', direeg);
EEG = pop_loadset('filename', 'BN-VideoCheckOpacity.set', 'filepath', direeg);

EEG = ogEEG;
% EEG3 = pop_loadset('filename', 'GR-VideoCheckOpacity-03.set', 'filepath', direeg);


% Combine post-ICA runs
% allEEG = set_merge(EEG1, EEG2);
% EEG = exp_eval(allEEG);

%% CLASSIFICATION:
% Put some epochs aside for prediction
% EEG = EEGsmall;
EEG = ogEEG;

markertype = {'53', '54', '55', '56', '57', '58'};
% markertype = {'55', '56'};

evtype = [];
for i = 1:length(EEG.epoch)
    evtype = [evtype, ""+EEG.epoch(i).eventtype];
end

adetails.markers.trialevents = evtype(contains(evtype,markertype));

EEG = pop_select(ogEEG, 'trial', find(contains(evtype,markertype)));

markertypes = string(markertype);

keeppertrial = 2;   % ~20% of trials for testing
test_trials = [];

for i = 1:length(markertypes)
    marker = markertypes(i);
    idx = find(contains(adetails.markers.trialevents, marker));
    test_trials = [test_trials randsample(idx, keeppertrial)];
end

EEGtrain_epoch = pop_select(EEG, 'notrial', test_trials);
EEGtest_epoch = pop_select(EEG, 'trial', test_trials);

% Make epoched data 'continuous'

EEG1 = EEGtrain_epoch;
epochdata = EEG1.data;
contdata = reshape(epochdata,size(epochdata,1),[],1);
EEG1.data = contdata;
EEG1.epoch = [];
EEG1.event = rmfield(EEG1.event, {'duration', 'epoch'});
EEG1.event = EEG1.event';
EEG1.pnts = EEG1.pnts*EEG1.trials;
EEG1.trials = 1;
EEG1.times =  0:(1000/EEG1.srate):(1000/EEG1.srate)*EEG1.pnts-1;
EEG1.xmax = EEG1.times(end)/1000;
EEGtrain = EEG1;

EEG1 = EEGtest_epoch;
epochdata = EEG1.data;
contdata = reshape(epochdata,size(epochdata,1),[],1);
EEG1.data = contdata;
EEG1.epoch = [];
EEG1.event = rmfield(EEG1.event, {'duration', 'epoch'});
EEG1.event = EEG1.event';
EEG1.pnts = EEG1.pnts*EEG1.trials;
EEG1.trials = 1;
EEG1.times =  0:(1000/EEG1.srate):(1000/EEG1.srate)*EEG1.pnts-1;
EEG1.xmax = EEG1.times(end)/1000;
EEGtest = EEG1;

direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\combineddata\';

pop_saveset(EEGtrain, 'filename', 'MD_VideoCheckOpacity_train', 'filepath', direeg)
pop_saveset(EEGtest, 'filename', 'MD_VideoCheckOpacity_test', 'filepath', direeg)

% pop_saveset(EEGtest, 'filename', 'ZZZ20190423_EEGtest_small', 'filepath', direeg)

disp('Made data continuous')

%% Bandpower: CHECK SIZE
% Select by condition (check size)
% EEG = EEG2;
adetails.markers.types = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(EEG.epoch)
    evtype = [evtype, ""+EEG.epoch(i).eventtype];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

lastEEG = EEG;
 
EEGbig = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '52'})));
EEGmed = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'53', '54'})));
EEGsmall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'55', '56'})));

EEGbiglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
EEGbighigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
EEGsmalllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
EEGsmallhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));

EEGattlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '53', '55'})));
EEGatthigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'52', '54', '56'})));

% Bandpower (do not crop data)
posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [11.75  12.25];
highbin = [14.75  15.25];

clear powsm_lowATTlow powsm_highATTlow powsm_lowATThigh powsm_highATThigh ...
    powmed_lowATTlow powmed_highATTlow powmed_lowATThigh powmed_highATThigh ...
    powbig_lowATTlow powbig_highATTlow powbig_lowATThigh powbig_highATThigh
 
for i = 1:length(EEGsmalllow.event)
    powsm_lowATTlow(i,:) = bandpower(squeeze(EEGsmalllow.data(posterior_channels,:,i))',EEGsmalllow.srate,lowbin);
    powsm_highATTlow(i,:) = bandpower(squeeze(EEGsmalllow.data(posterior_channels,:,i))',EEGsmalllow.srate,highbin);
end

for i = 1:length(EEGsmallhigh.event)
    powsm_lowATThigh(i,:) = bandpower(squeeze(EEGsmallhigh.data(posterior_channels,:,i))',EEGsmallhigh.srate,lowbin);
    powsm_highATThigh(i,:) = bandpower(squeeze(EEGsmallhigh.data(posterior_channels,:,i)'),EEGsmallhigh.srate,highbin);
end

for i = 1:length(EEGmedlow.event)
    powmed_lowATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,lowbin);
    powmed_highATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,highbin);
end

for i = 1:length(EEGmedhigh.event)
    powmed_lowATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,lowbin);
    powmed_highATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,highbin);
end

for i = 1:length(EEGbiglow.event)
    powbig_lowATTlow(i,:) = bandpower(squeeze(EEGbiglow.data(posterior_channels,:,i)'),EEGbiglow.srate,lowbin);
    powbig_highATTlow(i,:) = bandpower(squeeze(EEGbiglow.data(posterior_channels,:,i)'),EEGbiglow.srate,highbin);
end

for i = 1:length(EEGbighigh.event)
    powbig_lowATThigh(i,:) = bandpower(squeeze(EEGbighigh.data(posterior_channels,:,i)'),EEGbighigh.srate,lowbin);
    powbig_highATThigh(i,:) = bandpower(squeeze(EEGbighigh.data(posterior_channels,:,i)'),EEGbighigh.srate,highbin);
end

%% BAR PLOT 
% Average power over channels (15 trials x 6 conds)
avgchanATTlow = {mean(powbig_lowATTlow,2) mean(powbig_lowATThigh,2) ...
    mean(powmed_lowATTlow,2) mean(powmed_lowATThigh,2) ...
    mean(powsm_lowATTlow,2) mean(powsm_lowATThigh,2) };

avgchanATThigh = {mean(powbig_highATTlow,2) mean(powbig_highATThigh,2)  ...
    mean(powmed_highATTlow,2) mean(powmed_highATThigh,2) ...
    mean(powsm_highATTlow,2) mean(powsm_highATThigh,2)};

figure; hold on
bins = [10 20 35 45 60 70];

subplot(2,1,1); hold on 
binlabels = {'Big Att. Low'; 'Big Att. High'; 'Med Att. Low'; 'Med Att. High'; 'Small Att. Low'; 'Small Att. High' };
title('12 Hz Power');
xticks(bins)
xticklabels(binlabels)

barmean = []; stderror = [];
for b = 1:length(bins)
    barmean(b) = mean(avgchanATTlow{b}); 
    stderror(b) =  std(avgchanATTlow{b}) / sqrt(length(avgchanATTlow{b}));
end
bar(bins, barmean)          % Average across trials
errorbar(bins, barmean, stderror, 'k.')
% for b = 1:length(bins); plot(bins(b), avgchanATTlow{b}, '*', 'LineWidth', 1); end

subplot(2,1,2); hold on
title('15 Hz Power');
xticks(bins)
xticklabels(binlabels)

barmean = []; stderror = [];
for b = 1:length(bins)
    barmean(b) = mean(avgchanATThigh{b}); 
    stderror(b) =  std(avgchanATThigh{b}) / sqrt(length(avgchanATThigh{b}));
end
bar(bins, barmean)          % Average across trials
errorbar(bins, barmean, stderror, 'k.')
% for b = 1:length(bins); plot(bins(b), avgchanATThigh{b}, '*', 'LineWidth', 1); end

sgtitle('GR Bandpower Check Size - Strong Opacity')
%% VIOLIN PLOT

alldataATThigh = []; grp = [];
for b = 1:length(bins)
    alldataATThigh = [alldataATThigh; avgchanATThigh{b}];
    grp = [grp; repelem(binlabels{b} + "", length(avgchanATThigh{b}))' ];
end

% figure
% boxplot(alldataATThigh,grp,'Notch','on','Labels',binlabels)
% title('MD Check Size - Med')
% ylabel('15 Hz Power')


alldataATTlow = []; grp = [];
for b = 1:length(bins)
    alldataATTlow = [alldataATTlow; avgchanATTlow{b}];
    grp = [grp; repelem(binlabels{b} + "", length(avgchanATThigh{b}))' ];
end

figure
violinplot(alldataATTlow,grp,'GroupOrder',binlabels, 'ShowData',true, 'ShowMean',true, 'ShowNotches', false);
% boxplot(alldataATTlow,grp,'Notch','on','Labels',binlabels)
title('MD: 12 Hz Power')
ylabel('Power')

figure
violinplot(alldataATThigh,grp,'GroupOrder',binlabels, 'ShowData',true, 'ShowMean',true, 'ShowNotches', false);
title('MD: 15 Hz Power')
ylabel('Power')


%% Bandpower: OPACITY
% Select opacity conditions 
% EEG = EEG3;
adetails.markers.types = {'51','52','53','54','55','56','57','58'};

evtype = [];
for i = 1:length(EEG.epoch)
    evtype = [evtype, ""+EEG.epoch(i).eventtype];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

lastEEG = EEG;
 
EEGfull = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '52'})));
EEGstrong = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'53', '54'})));
EEGmed = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'55', '56'})));
EEGweak = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'57', '58'})));

EEGfulllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
EEGfullhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
EEGstronglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
EEGstronghigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));
EEGweaklow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '57')));
EEGweakhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '58')));

EEGattlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '53', '55', '57'})));
EEGatthigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'52', '54', '56', '58'})));

% Bandpower (do not crop data)
posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [11.75 12.25];
highbin = [14.75 15.25];

clear powfull_lowATTlow powfull_highATTlow powfull_lowATThigh powfull_highATThigh ...
    powstrong_lowATTlow powstrong_highATTlow powstrong_lowATThigh powstrong_highATThigh ...
    powmed_lowATTlow powmed_highATTlow powmed_lowATThigh powmed_highATThigh ...
    powweak_lowATTlow powweak_highATTlow powweak_lowATThigh powweak_highATThigh
 
for i = 1:length(EEGfulllow.epoch)
    powfull_lowATTlow(i,:) = bandpower(squeeze(EEGfulllow.data(posterior_channels,:,i))',EEGfulllow.srate,lowbin);
    powfull_highATTlow(i,:) = bandpower(squeeze(EEGfulllow.data(posterior_channels,:,i))',EEGfulllow.srate,highbin);
end
for i = 1:length(EEGfullhigh.epoch)
    powfull_lowATThigh(i,:) = bandpower(squeeze(EEGfullhigh.data(posterior_channels,:,i))',EEGfullhigh.srate,lowbin);
    powfull_highATThigh(i,:) = bandpower(squeeze(EEGfullhigh.data(posterior_channels,:,i)'),EEGfullhigh.srate,highbin);
end
for i = 1:length(EEGstronglow.epoch)
    powstrong_lowATTlow(i,:) = bandpower(squeeze(EEGstronglow.data(posterior_channels,:,i)'),EEGstronglow.srate,lowbin);
    powstrong_highATTlow(i,:) = bandpower(squeeze(EEGstronglow.data(posterior_channels,:,i)'),EEGstronglow.srate,highbin);
end
for i = 1:length(EEGstronghigh.epoch)
    powstrong_lowATThigh(i,:) = bandpower(squeeze(EEGstronghigh.data(posterior_channels,:,i)'),EEGstronghigh.srate,lowbin);
    powstrong_highATThigh(i,:) = bandpower(squeeze(EEGstronghigh.data(posterior_channels,:,i)'),EEGstronghigh.srate,highbin);
end
for i = 1:length(EEGmedlow.epoch)
    powmed_lowATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,lowbin);
    powmed_highATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,highbin);
end
for i = 1:length(EEGmedhigh.epoch)
    powmed_lowATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,lowbin);
    powmed_highATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,highbin);
end
for i = 1:length(EEGweaklow.epoch)
    powweak_lowATTlow(i,:) = bandpower(squeeze(EEGweaklow.data(posterior_channels,:,i)'),EEGweaklow.srate,lowbin);
    powweak_highATTlow(i,:) = bandpower(squeeze(EEGweaklow.data(posterior_channels,:,i)'),EEGweaklow.srate,highbin);
end
for i = 1:length(EEGweakhigh.epoch)
    powweak_lowATThigh(i,:) = bandpower(squeeze(EEGweakhigh.data(posterior_channels,:,i)'),EEGweakhigh.srate,lowbin);
    powweak_highATThigh(i,:) = bandpower(squeeze(EEGweakhigh.data(posterior_channels,:,i)'),EEGweakhigh.srate,highbin);
end
disp('done');
% Plot bandpower
% Average power over channels (N trials x 8 conds)
avgchanATTlow = {mean(powfull_lowATTlow,2) mean(powfull_lowATThigh,2) ...
    mean(powstrong_lowATTlow,2) mean(powstrong_lowATThigh,2) ...
    mean(powmed_lowATTlow,2) mean(powmed_lowATThigh,2) ...
    mean(powweak_lowATTlow,2) mean(powweak_lowATThigh,2) };

avgchanATThigh = {mean(powfull_highATTlow,2) mean(powfull_highATThigh,2)  ...
    mean(powstrong_highATTlow,2) mean(powstrong_highATThigh,2) ...
    mean(powmed_highATTlow,2) mean(powmed_highATThigh,2) ...
    mean(powweak_highATTlow,2) mean(powweak_highATThigh,2)};
%% Opacity Plot
figure; hold on
bins = [10 20 35 45 60 70 85 95];
binlabels = {'Full Att. Low'; 'Full Att. High'; 'Strong Att. Low'; 'Strong Att. High'; 'Med Att. Low'; 'Med Att. High'; 'Weak Att. Low'; 'Weak Att. High'; };

subplot(2,1,1); hold on 
title('12 Hz Power');
xticks(bins)
xticklabels(binlabels)

barmean = []; stderror = [];
for b = 1:length(bins)
    barmean(b) = mean(avgchanATTlow{b}); 
    stderror(b) =  std(avgchanATTlow{b}) / sqrt(length(avgchanATTlow{b}));
end
bar(bins, barmean)          % Average across trials
errorbar(bins, barmean, stderror, 'k.')
% for b = 1:length(bins); plot(bins(b), avgchanATTlow{b}, '*', 'LineWidth', 1); end
% ylim([0 8])
subplot(2,1,2); hold on
title('15 Hz Power');
xticks(bins)
xticklabels(binlabels)

barmean = []; stderror = [];
for b = 1:length(bins)
    barmean(b) = mean(avgchanATThigh{b}); 
    stderror(b) =  std(avgchanATThigh{b}) / sqrt(length(avgchanATThigh{b}));
end
bar(bins, barmean)          % Average across trials
errorbar(bins, barmean, stderror, 'k.')
% for b = 1:length(bins); plot(bins(b), avgchanATThigh{b}, '*', 'LineWidth', 1); end
% ylim([0 3])
sgtitle('GR Bandpower Opacity')



%% Generate spectopo plots for each condition, if epochs trimmed to not include events.
freqsofinterest = [6 12 15];
    
figure; pop_spectopo(EEGlow, 1, [1000*EEGlow.xmin 1000*EEGlow.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEGhigh, 1, [1000*EEGhigh.xmin 1000*EEGhigh.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');
%% Look at hemisphere suppression/excitation

% EEG = pop_loadset('filename', 'TW-VideoCheckOpacity-03.set', 'filepath', direeg);
% EEG = pop_loadset('filename', 'GR-VideoCheckOpacity-03.set', 'filepath', direeg);
EEG = pop_loadset('filename', 'MD-VideoCheckOpacity.set', 'filepath', direeg);
% EEG = pop_loadset('filename', 'BN-VideoCheckOpacity-01.set', 'filepath', direeg);

evtype = [];
for i = 1:length(EEG.epoch)
    evtype = [evtype, ""+EEG.epoch(i).eventtype];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

EEGhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '53', '55', '57'})));
freqsofinterest = [6 12 15];
    
figure; title('GR: Attend RIGHT 6 Hz')
pop_spectopo(EEGhigh, 1, [1000*EEGhigh.xmin 1000*EEGhigh.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');