%% Load BCILAB
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab

%% Directory for EEG data (K drive is \fsvs01\Research\)

% As of FA19, data storage protocol places raw data in a separate folder on the K drive
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\';

% File name without extension
% fnameeeg = '20190908153814_GR-VideoCheckSize-01_Test';
% fnameeeg = '20190908160918_GR-VideoCheckSize-02_Test';
fnameeeg = '20190908163723_GR-VideoCheckOpacity-03_Test';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
ogEEG = EEG;

%% Load corrected data if markers were missing in NIC
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\';

% Create new marker file using fixmissingmarkersfromlog.m
% fnameeeg = '20190908163723_GR-VideoCheckOpacity-03_Test_newmarkers.set';
fnameeeg = '20190907122124_TW-VideoCheckSize-02_RECORD_newmarkers.set';
EEG = pop_loadset('filename', fnameeeg, 'filepath', direeg);

%% Chop run between start and end markers 
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% eeg_cropped = eeg_eegrej(EEG, [1 start_pt-1]);
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
lastEEG = EEG;
% Markers for sustained attention
adetails.markers.types = {'51','52','53','54','55','56'};
% adetails.markers.types = {'51','52','53','54','55','56','57','58'};

evtype = [];

adetails.markers.epochwindow = [0.1 60.1]; % window after standard markers to look at
adetails.markers.epochsize = 10; % size of miniepochs to chop regular markered epoch up into
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
        disp(k)
        EEG.event(k).type = lastEEG.event(i).type;
        EEG.event(k).latency = lastEEG.event(i).latency; 
        EEG.event(k).latency_ms = lastEEG.event(i).latency_ms; 
        EEG.event(k).duration = 0; 
        disp(EEG.event(k))
        k = k+1;
    end
end

disp('Epoching EEG...')
EEG = pop_epoch(EEG,adetails.markers.types, [0 adetails.markers.epochsize-0.002]);

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

pop_saveset(EEG, 'filename', 'tw-VideoCheckSize-02-preica', 'filepath', dirpreica)

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;
rej1 = [3 4 8:11 14 17:18 20 24 25 27:32];
rej2 = [1 5 8 11 15 17:23 27:32];
rej3 = [1 4 6 8 10 11 14 16 18:20 22 27 28 31 32]; 
rej_comps = rej3;
adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('Subtracing ICA component from data...')
EEG = pop_subcomp(EEG, rej_comps);

dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
pop_saveset(EEG, 'filename', 'GR-VideoCheckOpacity-03', 'filepath', dirica)

%% Plot data after removal of ICA components
% Reference to original data
figure; pop_spectopo(lastEEG, 1, [1000*lastEEG.xmin  1000*lastEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

%% Load post-ICA runs
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
EEG1 = pop_loadset('filename', 'GR-VideoCheckSize-01.set', 'filepath', direeg);
EEG2 = pop_loadset('filename', 'GR-VideoCheckSize-02.set', 'filepath', direeg);
EEG3 = pop_loadset('filename', 'GR-VideoCheckOpacity-03.set', 'filepath', direeg);


% Combine post-ICA runs
% allEEG = set_merge(EEG1sub, EEG2sub, EEG3sub);
% allEEG = exp_eval(allEEG);

%% Select by condition
EEG = EEG2;
adetails.markers.types = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(EEG.epoch)
    evtype = [evtype, ""+EEG.epoch(i).eventtype{1}];
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

%% NEW: Bandpower
numtrials = 12;
posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [5 7];
highbin = [14  16];

clear powsm_lowATTlow powsm_highATTlow powsm_lowATThigh powsm_highATThigh ...
    powmed_lowATTlow powmed_highATTlow powmed_lowATThigh powmed_highATThigh ...
    powbig_lowATTlow powbig_highATTlow powbig_lowATThigh powbig_highATThigh
 
for i = 1:numtrials
    powsm_lowATTlow(i,:) = bandpower(squeeze(EEGsmalllow.data(posterior_channels,:,i))',EEGsmalllow.srate,lowbin);
    powsm_highATTlow(i,:) = bandpower(squeeze(EEGsmalllow.data(posterior_channels,:,i))',EEGsmalllow.srate,highbin);
    
    powsm_lowATThigh(i,:) = bandpower(squeeze(EEGsmallhigh.data(posterior_channels,:,i))',EEGsmallhigh.srate,lowbin);
    powsm_highATThigh(i,:) = bandpower(squeeze(EEGsmallhigh.data(posterior_channels,:,i)'),EEGsmallhigh.srate,highbin);
    
    powmed_lowATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,lowbin);
    powmed_highATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,highbin);
    
    powmed_lowATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,lowbin);
    powmed_highATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,highbin);
    
    powbig_lowATTlow(i,:) = bandpower(squeeze(EEGbiglow.data(posterior_channels,:,i)'),EEGbiglow.srate,lowbin);
    powbig_highATTlow(i,:) = bandpower(squeeze(EEGbiglow.data(posterior_channels,:,i)'),EEGbiglow.srate,highbin);
    
    powbig_lowATThigh(i,:) = bandpower(squeeze(EEGbighigh.data(posterior_channels,:,i)'),EEGbighigh.srate,lowbin);
    powbig_highATThigh(i,:) = bandpower(squeeze(EEGbighigh.data(posterior_channels,:,i)'),EEGbighigh.srate,highbin);
end
disp('done');
%% Plot bandpower
% Average power over channels (15 trials x 6 conds)
avgchanATTlow = [mean(powbig_lowATTlow,2) mean(powbig_lowATThigh,2) ...
    mean(powmed_lowATTlow,2) mean(powmed_lowATThigh,2) ...
    mean(powsm_lowATTlow,2) mean(powsm_lowATThigh,2) ];

avgchanATThigh = [mean(powbig_highATTlow,2) mean(powbig_highATThigh,2)  ...
    mean(powmed_highATTlow,2) mean(powmed_highATThigh,2) ...
    mean(powsm_highATTlow,2) mean(powsm_highATThigh,2)];

figure; hold on
bins = [10 20 35 45 60 70];

subplot(2,1,1); hold on 
bar(bins, mean(avgchanATTlow))          % Average across trials
binlabels = {'Big Att. Low'; 'Big Att. High'; 'Med Att. Low'; 'Med Att. High'; 'Small Att. Low'; 'Small Att. High'; };

plot(bins, avgchanATTlow, '*', 'LineWidth', 1);
title('6 Hz Power');
xticks(bins)
xticklabels(binlabels)

subplot(2,1,2); hold on
bar(bins, mean(avgchanATThigh))
title('15 Hz Power');
xticks(bins)
xticklabels(binlabels)
plot(bins, avgchanATThigh, '*', 'LineWidth', 1);

%% BP opacity (bulky)
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

%% NEW: Bandpower
numtrials = 8;
posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [5 7];
highbin = [14  16];

clear powfull_lowATTlow powfull_highATTlow powfull_lowATThigh powfull_highATThigh ...
    powstrong_lowATTlow powstrong_highATTlow powstrong_lowATThigh powstrong_highATThigh ...
    powmed_lowATTlow powmed_highATTlow powmed_lowATThigh powmed_highATThigh ...
    powweak_lowATTlow powweak_highATTlow powweak_lowATThigh powweak_highATThigh
 
for i = 1:numtrials
    powfull_lowATTlow(i,:) = bandpower(squeeze(EEGfulllow.data(posterior_channels,:,i))',EEGfulllow.srate,lowbin);
    powfull_highATTlow(i,:) = bandpower(squeeze(EEGfulllow.data(posterior_channels,:,i))',EEGfulllow.srate,highbin);
    
    powfull_lowATThigh(i,:) = bandpower(squeeze(EEGfullhigh.data(posterior_channels,:,i))',EEGfullhigh.srate,lowbin);
    powfull_highATThigh(i,:) = bandpower(squeeze(EEGfullhigh.data(posterior_channels,:,i)'),EEGfullhigh.srate,highbin);
    
    powstrong_lowATTlow(i,:) = bandpower(squeeze(EEGstronglow.data(posterior_channels,:,i)'),EEGstronglow.srate,lowbin);
    powstrong_highATTlow(i,:) = bandpower(squeeze(EEGstronglow.data(posterior_channels,:,i)'),EEGstronglow.srate,highbin);
    
    powstrong_lowATThigh(i,:) = bandpower(squeeze(EEGstronghigh.data(posterior_channels,:,i)'),EEGstronghigh.srate,lowbin);
    powstrong_highATThigh(i,:) = bandpower(squeeze(EEGstronghigh.data(posterior_channels,:,i)'),EEGstronghigh.srate,highbin);
    
    powmed_lowATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,lowbin);
    powmed_highATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,highbin);
    
    powmed_lowATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,lowbin);
    powmed_highATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,highbin);
    
    powweak_lowATTlow(i,:) = bandpower(squeeze(EEGweaklow.data(posterior_channels,:,i)'),EEGweaklow.srate,lowbin);
    powweak_highATTlow(i,:) = bandpower(squeeze(EEGweaklow.data(posterior_channels,:,i)'),EEGweaklow.srate,highbin);
    
    powweak_lowATThigh(i,:) = bandpower(squeeze(EEGweakhigh.data(posterior_channels,:,i)'),EEGweakhigh.srate,lowbin);
    powweak_highATThigh(i,:) = bandpower(squeeze(EEGweakhigh.data(posterior_channels,:,i)'),EEGweakhigh.srate,highbin);
end
disp('done');
%% Plot bandpower
% Average power over channels (15 trials x 6 conds)
avgchanATTlow = [mean(powfull_lowATTlow,2) mean(powfull_lowATThigh,2) ...
    mean(powstrong_lowATTlow,2) mean(powstrong_lowATThigh,2) ...
    mean(powmed_lowATTlow,2) mean(powmed_lowATThigh,2) ...
    mean(powweak_lowATTlow,2) mean(powweak_lowATThigh,2) ];

avgchanATThigh = [mean(powfull_highATTlow,2) mean(powfull_highATThigh,2)  ...
    mean(powstrong_highATTlow,2) mean(powstrong_highATThigh,2) ...
    mean(powmed_highATTlow,2) mean(powmed_highATThigh,2) ...
    mean(powweak_highATTlow,2) mean(powweak_highATThigh,2)];

figure; hold on
bins = [10 20 35 45 60 70 85 95];

subplot(2,1,1); hold on 
bar(bins, mean(avgchanATTlow))          % Average across trials
binlabels = {'Full Att. Low'; 'Full Att. High'; 'Strong Att. Low'; 'Strong Att. High'; 'Med Att. Low'; 'Med Att. High'; 'Weak Att. Low'; 'Weak Att. High'; };

plot(bins, avgchanATTlow, '*', 'LineWidth', 1);
title('6 Hz Power');
xticks(bins)
xticklabels(binlabels)

subplot(2,1,2); hold on
bar(bins, mean(avgchanATThigh))
title('15 Hz Power');
xticks(bins)
xticklabels(binlabels)
plot(bins, avgchanATThigh, '*', 'LineWidth', 1);

%% Compare high and low freq trials
lowevents = {'51', '53'};
highevents = {'52', '54'};

EEGlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
EEGhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));

%% Generate spectopo plots for each condition, if epochs trimmed to not include events.
freqsofinterest = [6 12 15];
    
figure; pop_spectopo(EEGlow, 1, [1000*EEGlow.xmin 1000*EEGlow.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEGhigh, 1, [1000*EEGhigh.xmin 1000*EEGhigh.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

%% Plot relative powers while attending
bins = [5 10 20 25]; numbins = size(bins,2);

% --------------- Attending LOW -------------- %
lsize = size(EEGlow.data);

llp = zeros(1, lsize(3)); hlp = llp;
llrel = zeros(1, lsize(3)); hlrel = llrel;

% for each epoch calculate relative power of target frequencies
for i = 1:lsize(3)
    % spectra: relative powers per frequency (dB)
    % freq: frequencies corresponding to spectra
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGlow.data(lsize(1),:,i), lsize(2), EEGlow.srate);
    
    % find low and high index of freq array
    lowIDX = find(freq>5.5 & freq<6.5);
    highIDX = find(freq>14.5 & freq<15.5);
    
    mean(spectra(lowIDX))
    mean(spectra(highIDX))
    
    % calculate power of low/high freq when attending low/high
    llp(i) = 10^(mean(spectra(lowIDX))/10);
    hlp(i) = 10^(mean(spectra(highIDX))/10); 
    
    % compute relative power of low vs. high
    llrel(i) = llp/(llp+hlp); 
    hlrel(i) = hlp/(llp+hlp);
end

% --------------- Attending HIGH -------------- %
hsize = size(EEGhigh.data);

lhp = zeros(1, hsize(3)); hhp = lhp;
lhrel = zeros(1, hsize(3)); hhrel = lhrel;

for i = 1:hsize(3)
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGhigh.data(hsize(1),:,i), hsize(2), EEGhigh.srate);
    
    lowIDX = find(freq>5.5 & freq<6.5);
    highIDX = find(freq>14.5 & freq<15.5);
    
    lhp(i) = 10^(mean(spectra(lowIDX))/10);
    hhp(i) = 10^(mean(spectra(highIDX))/10);
    
    lhrel(i) = lhp/(lhp+hhp);
    hhrel(i) = hhp/(lhp+hhp);
end

meanpower = [mean(llp) mean(hlp) mean(lhp) mean(hhp)];
meanrel = [mean(llrel) mean(hlrel) mean(lhrel) mean(hhrel)];
stds = [std(llrel) std(llrel) std(llrel) std(llrel)];

% plot 
figure; hold on
bar(bins, meanpower)
errorbar(bins, meanpower, stds, 'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2, 'Marker', '.')

%%

% run ica 
% reject components that have eye blinks and other artifacts

% do this for all runs

% combine all runs

% compare high and low freq trials 

%%
for i = 1:size(allEEG.event,2)
    eventtype(i) = str2double(allEEG.event(i).type);
    eventlatency(i) = allEEG.event(i).latency;
    eventlatencyms(i) = allEEG.event(i).latency_ms;
    eventepoch(i) = allEEG.event(i).epoch;
end

eventtrialslow = eventepoch(eventtype==51 | eventtype==53);
eventtrialshigh = eventepoch(eventtype==52 | eventtype==54);

%%
EEGnewlow = pop_select(allEEG, 'trial', evtl);
EEGnewhigh = pop_select(allEEG, 'trial', evth);
%%
EEGlow = EEGnewlow;
EEGhigh = EEGnewhigh;


%% Generate spectopo plots for each condition, if epochs trimmed to not include events.

freqsofinterest = [6 12 15];
    
figure; pop_spectopo(EEGlow, 1, [1000*EEGlow.xmin 1000*EEGlow.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEGhigh, 1, [1000*EEGhigh.xmin 1000*EEGhigh.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

%% separate by marker
et51 = unique(eventepoch(eventtype==51));
et54 = unique(eventepoch(eventtype==54));
et52 = unique(eventepoch(eventtype==52));
et53 = unique(eventepoch(eventtype==53));
%eventtrialshigh = eventepoch(eventtype==52 | eventtype==54);

EEG51 = pop_select(allEEG, 'trial', et51);
EEG54 = pop_select(allEEG, 'trial', et54);
EEG52 = pop_select(allEEG, 'trial', et52);
EEG53 = pop_select(allEEG, 'trial', et53);
%%
for i = 1:32
    plow51(i,:) = bandpower(squeeze(EEG51.data(i,:,:)),EEG51.srate,[4 8]);
    phigh51(i,:) = bandpower(squeeze(EEG51.data(i,:,:)),EEG51.srate,[12 16]);
    
    plow52(i,:) = bandpower(squeeze(EEG52.data(i,:,:)),EEG52.srate,[4 8]);
    phigh52(i,:) = bandpower(squeeze(EEG52.data(i,:,:)),EEG52.srate,[12 16]);
    
    plow53(i,:) = bandpower(squeeze(EEG53.data(i,:,:)),EEG53.srate,[4 8]);
    phigh53(i,:) = bandpower(squeeze(EEG53.data(i,:,:)),EEG53.srate,[12 16]);
    
    plow54(i,:) = bandpower(squeeze(EEG54.data(i,:,:)),EEG54.srate,[4 8]);
    phigh54(i,:) = bandpower(squeeze(EEG54.data(i,:,:)),EEG54.srate,[12 16]);
end
%% write over with alpha
for i = 1:32
    plow51(i,:) = bandpower(squeeze(EEG51.data(i,:,:)),EEG51.srate,[9 11]);
    phigh51(i,:) = bandpower(squeeze(EEG51.data(i,:,:)),EEG51.srate,[23 24]);
    
    plow52(i,:) = bandpower(squeeze(EEG52.data(i,:,:)),EEG51.srate,[9 11]);
    phigh52(i,:) = bandpower(squeeze(EEG52.data(i,:,:)),EEG51.srate,[23 24]);
    
    plow53(i,:) = bandpower(squeeze(EEG53.data(i,:,:)),EEG51.srate,[9 11]);
    phigh53(i,:) = bandpower(squeeze(EEG53.data(i,:,:)),EEG51.srate,[23 24]);
    
    plow54(i,:) = bandpower(squeeze(EEG54.data(i,:,:)),EEG54.srate,[9 11]);
    phigh54(i,:) = bandpower(squeeze(EEG54.data(i,:,:)),EEG54.srate,[23 24]);
end
    
%% sloppy means

mplow51 = median(plow51(selchan,:),2);
mphigh51 = median(phigh51(selchan,:),2);
mplow54 = median(plow54(selchan,:),2);
mphigh54 = median(phigh54(selchan,:),2);

mplow52 = median(plow52(selchan,:),2);
mphigh52 = median(phigh52(selchan,:),2);
mplow53 = median(plow53(selchan,:),2);
mphigh53 = median(phigh53(selchan,:),2);
%%
figure
for i = 1:10
    subplot(2,5,i)
    bar([mplow51(i),mplow52(i),mplow53(i), mplow54(i)]);
    title(EEG.chanlocs(selchan(i)).labels)
end

figure
for i = 1:10
    subplot(2,5,i)
    bar([mphigh51(i),mphigh52(i),mphigh53(i), mphigh54(i)]);
    title(EEG.chanlocs(selchan(i)).labels)
end

%% plot power over trials
selchan = [1, 2, 3, 4, 5, 7, 8, 20, 21, 32]
figure
for i = 1:10
    subplot(2,5,i)
    plot(1:size(plow51,2),plow51(selchan(i),:),'b'); %left low
    hold on
    plot(1:size(plow53,2),plow53(selchan(i),:),'c'); %right low
    
    plot(1:size(plow52,2),plow52(selchan(i),:),'r'); %left high
    plot(1:size(plow54,2),plow54(selchan(i),:),'m'); %right high
    title(strcat(EEG.chanlocs(selchan(i)).labels, ' : ','Low Freq Band'))
end
%%
figure
for i = 1:10
    subplot(2,5,i)
    plot(1:size(phigh51,2),phigh51(selchan(i),:),'b'); %left low
    hold on
    plot(1:size(phigh53,2),phigh53(selchan(i),:),'c'); %right low
    
    plot(1:size(phigh52,2),phigh52(selchan(i),:),'r'); %left high
    plot(1:size(phigh54,2),phigh54(selchan(i),:),'m'); %right high
    title(strcat(EEG.chanlocs(selchan(i)).labels, ' : ','High Freq Band'))
end