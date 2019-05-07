cd C:\Users\Public\Research\BCILAB
bcilab

%% Directory for EEG data (K drive is \fsvs01\Research\)

% load raw data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';

% File name without extension
fnameeeg = '20190503112903_ZZ-VideoCheckCovertPilot-4_Test';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data

% load corrected data
% dircorr = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';
% fnameeeg = '20190330095018_PKVideoCheckSizePilot-1_Test_newmarkers.set';
% EEG = pop_loadset('filename', fnameeeg, 'filepath', dircorr);

%% Check that all trial markers came through
adetails.markers.types = {'51','52','53','54'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype);
numTrials = length(evtype(find(contains(evtype,adetails.markers.types))))

%% Chop run between start and end markers 
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% EEG = eeg_eegrej(EEG, [1 1;end_pt+1 EEG.pnts ]);        % use if missing start marker
%EEG = eeg_eegrej(EEG, [1 start_pt-1]);        % use if missing end marker
disp('Cropping start and end of raw data...')
EEG = eeg_eegrej(EEG, [1 start_pt-1; end_pt+1 EEG.pnts]);

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

%% Inspect for bad channels
lastEEG = EEG;
% Show candidates for rejection 
[~,badelec] = pop_rejchan(EEG,'elec',1:32,'threshold',5,'norm','on','measure','prob');

% Plot data to look at "bad" channels
% Plot the epoched data
pop_eegplot(EEG, 1);

% Inspect epoched data in frequency domain
% figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
%     'percent', 100, 'freq', [5 11.9 15], 'freqrange',[1 30],'electrodes','on');

%% Interpolate/remove the bad channels from the data
adetails.reject.strategy = 'interpolate'; % or 'remove'

badelec = [8];

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

%% Epoch into small trials
lastEEG = EEG;

% Markers for sustained attention
adetails.markers.types = {'51','52','53','54'};
% adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};
evtype = [];

adetails.markers.epochwindow = [0 60]; % window after standard markers to look at
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
            EEG.event(k).duration = 0; %adetails.markers.epochsize; % seconds for continuous data
            k = k+1; 
        end        
    else
        EEG.event(k).type = lastEEG.event(i).type;
        EEG.event(k).latency = lastEEG.event(i).latency; 
        EEG.event(k).latency_ms = lastEEG.event(i).latency_ms; 
        EEG.event(k).duration = 0;
        k = k+1;
    end
end

EEG = pop_epoch(EEG,adetails.markers.types, [0 adetails.markers.epochsize-0.002]);

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

%% Inspect and reject epochs for motion artifacts
lastEEG = EEG;
pop_eegplot(EEG, 1, 1, 1);  % removes epochs within original EEG struct

%% Run ICA to find eye movements and other artifacts
% See this page for running and rejecting ICA componenets
% https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA
lastEEG = EEG;
EEG = pop_runica(EEG, 'runica');

% Run ICA on the version without channel rejection for comparison
% eeg_ica_epoch = pop_runica(eeg_ica_rej);
% These give similar results

% Write ICA to file for later use
dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\Covert-ZZZ\';
pop_saveset(EEG, 'filename', 'EEG4', 'filepath', dirica)

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;

rej_comps = [1 8 12 15 16 19 22 25 27:31];
adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('Subtracing ICA component from data...')
EEG = pop_subcomp(EEG, rej_comps);

pop_saveset(EEG, 'filename', 'EEG4sub', 'filepath', dirica)

%% Plot data before/after removal of ICA components
freqsofinterest = [6 7.5 15 18 30];

figure; pop_spectopo(lastEEG, 1, [1000*lastEEG.xmin  1000*lastEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

%% Combine ICA runs
dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\Covert-ZZZ';

% EEG = pop_loadset('filename', 'EEG1.set', 'filepath', dirica);
% EEG2 = pop_loadset('filename', 'EEG2.set', 'filepath', dirica);
% EEG3 = pop_loadset('filename', 'EEG3.set', 'filepath', dirica);
% EEG4 = pop_loadset('filename', 'EEG4.set', 'filepath', dirica);
% EEG5 = pop_loadset('filename', 'EEG5.set', 'filepath', dirica);
% 
% allEEG = set_merge(EEG1, EEG2, EEG3, EEG4, EEG5);
% allEEG = exp_eval(allEEG);

EEG1sub = pop_loadset('filename', 'EEG1sub.set', 'filepath', dirica);
EEG2sub = pop_loadset('filename', 'EEG2sub.set', 'filepath', dirica);
% EEG3sub = pop_loadset('filename', 'EEG3sub.set', 'filepath', dirica);
EEG4sub = pop_loadset('filename', 'EEG4sub.set', 'filepath', dirica);

% Set aside one run ?
EEGsub = set_merge(EEG1sub, EEG2sub, EEG4sub);
EEGsub = exp_eval(EEGsub);

EEG = EEGsub;
% adetails.markers.types = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

%% Also read opacity data
dirica2 = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckOpacity-PK\';
opacEEG1sub = pop_loadset('filename', 'EEG1sub.set', 'filepath', dirica);
opacEEG2sub = pop_loadset('filename', 'EEG2sub.set', 'filepath', dirica);
opacEEG3sub = pop_loadset('filename', 'EEG3sub.set', 'filepath', dirica);
opacEEG4sub = pop_loadset('filename', 'EEG4sub.set', 'filepath', dirica);

opacEEG = set_merge(opacEEG1sub, opacEEG2sub, opacEEG3sub, opacEEG4sub);
opacEEG = exp_eval(opacEEG);

opac_markertypes = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(opacEEG.event)
    evtype = [evtype, ""+opacEEG.event(i).type];
end
unique(evtype)
opac_marker_trialevents = evtype(contains(evtype,opac_markertypes));


%% Select by condition
% adetails.markers.types = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));


EEGcov_attlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51'})));
EEGcov_atthigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'52'})));
EEGov_attlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'53'})));
EEGov_atthigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'54'})));

lastEEG = EEG;
 
% EEGbig = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '52'})));
% EEGmed = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'53', '54'})));
% EEGsmall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'55', '56'})));
% 
% EEGbiglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
% EEGbighigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
% EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
% EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
% EEGsmalllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
% EEGsmallhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));
% 
% EEGattlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '53', '55'})));
% EEGatthigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'52', '54', '56'})));

%% Put some epochs aside for prediction
EEG = EEGsmall;

% markertype = {'51', '52', '53', '54', '55', '56'};
markertype = {'55', '56'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,markertype));

markertypes = string(markertype);

keeppertrial = 12;
test_trials = [];

for i = 1:length(markertypes)
    marker = markertypes(i);
    idx = find(contains(adetails.markers.trialevents, marker));
    test_trials = [test_trials randsample(idx, keeppertrial)];
end

EEGtrain_epoch = pop_select(EEG, 'notrial', test_trials);
EEGtest_epoch = pop_select(EEG, 'trial', test_trials);

%% Make epoched data 'continuous'

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

pop_saveset(EEGtrain, 'filename', 'ZZZ20190423_EEGtrain_small', 'filepath', direeg)
pop_saveset(EEGtest, 'filename', 'ZZZ20190423_EEGtest_small', 'filepath', direeg)

disp('Made data continuous')

%% Generate spectopo plots for each condition, if epochs trimmed to not include events.
freqsofinterest = [6 12 15 18 30];

figure; pop_spectopo(EEGcovert, 1, [1000*EEGcovert.xmin 1000*EEGcovert.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

figure; pop_spectopo(EEGovert, 1, [1000*EEGovert.xmin 1000*EEGovert.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');
%
% figure; pop_spectopo(EEGsmall, 1, [1000*EEGsmall.xmin 1000*EEGsmall.xmax], 'EEG' ,...
%     'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

%% Bandpower
numtrials_covert = size(EEGcov_atthigh.data, 3);
numtrials_overt = size(EEGov_atthigh.data, 3);

posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [5 7];
highbin = [14 16];

clear powcov_lowATTlow powcov_highATTlow powcov_lowATThigh powcov_highATThigh ...
    powovert_lowATTlow powovert_highATTlow powovert_lowATThigh powovert_highATThigh
 
for i = 1:numtrials_covert
    powcov_lowATTlow(i,:) = bandpower(squeeze(EEGcov_attlow.data(posterior_channels,:,i))',EEGcov_attlow.srate,lowbin);
    powcov_highATTlow(i,:) = bandpower(squeeze(EEGcov_attlow.data(posterior_channels,:,i))',EEGcov_attlow.srate,highbin);
    
    powcov_lowATThigh(i,:) = bandpower(squeeze(EEGcov_atthigh.data(posterior_channels,:,i))',EEGcov_atthigh.srate,lowbin);
    powcov_highATThigh(i,:) = bandpower(squeeze(EEGcov_atthigh.data(posterior_channels,:,i)'),EEGcov_atthigh.srate,highbin);
end

for i = 1:numtrials_overt
    powovert_lowATTlow(i,:) = bandpower(squeeze(EEGov_attlow.data(posterior_channels,:,i)'),EEGov_attlow.srate,lowbin);
    powovert_highATTlow(i,:) = bandpower(squeeze(EEGov_attlow.data(posterior_channels,:,i)'),EEGov_attlow.srate,highbin);
    
    powovert_lowATThigh(i,:) = bandpower(squeeze(EEGov_atthigh.data(posterior_channels,:,i)'),EEGov_atthigh.srate,lowbin);
    powovert_highATThigh(i,:) = bandpower(squeeze(EEGov_atthigh.data(posterior_channels,:,i)'),EEGov_atthigh.srate,highbin);
end
disp('done');
%% Plot bandpower
% Average power over channels (15 trials x 6 conds)
avgchanlowCOVERT = [mean(powcov_lowATTlow,2) mean(powcov_highATTlow,2) ];
avgchanhighCOVERT = [mean(powcov_highATTlow,2) mean(powcov_highATThigh,2)];

avgchanATTlowOVERT = [mean(powovert_lowATTlow,2) mean(powovert_highATTlow,2)];
avgchanATThighOVERT = [mean(powovert_lowATThigh,2) mean(powovert_highATThigh,2)];

figure; hold on
bins = [10 20 35 45];
binlabels = {'Covert Att. Low'; 'Covert Att. High'; 'Overt Att. Low'; 'Overt Att. High'; };

subplot(2,1,1); hold on 
bar(bins, [mean(avgchanlowCOVERT) mean(avgchanATTlowOVERT)])          % Average across trials
plot(bins(1:2), avgchanlowCOVERT, '*', 'LineWidth', 1);               % All trials
plot(bins(3:4), avgchanATTlowOVERT, '*', 'LineWidth', 1);

title('6 Hz Power');
xticks(bins)
xticklabels(binlabels)

subplot(2,1,2); hold on
bar(bins, [mean(avgchanhighCOVERT) mean(avgchanATThighOVERT)])          % Average across trials
plot(bins(1:2), avgchanhighCOVERT, '*', 'LineWidth', 1);               % All trials
plot(bins(3:4), avgchanATThighOVERT, '*', 'LineWidth', 1);

title('15 Hz Power');
xticks(bins)
xticklabels(binlabels)

%% Scalp map
lowbin = [5 7];
highbin = [14 16];

currEEGlow = EEGcovert;
currEEGhigh = EEGsmallhigh;
chanlocs = currEEGlow.chanlocs; % Same for all conditions

for i = 1:size(currEEGlow.data, 3)
    pow_lowATTlow(i,:) = bandpower(squeeze(currEEGlow.data(:,:,i))', currEEGlow.srate, lowbin);
    pow_highATTlow(i,:) = bandpower(squeeze(currEEGlow.data(:,:,i))', currEEGlow.srate, highbin);
end

for i = 1:size(currEEGhigh.data, 3)
    pow_lowATThigh(i,:) = bandpower(squeeze(currEEGhigh.data(:,:,i))', currEEGhigh.srate, lowbin);
    pow_highATThigh(i,:) = bandpower(squeeze(currEEGhigh.data(:,:,i)'), currEEGhigh.srate, highbin);
end

figure; suptitle('Small Check (200x200)')
subplot(2,3,1)
topoplot(mean(pow_lowATTlow), chanlocs);
title('6 Hz att Low');

subplot(2,3,2)
topoplot(mean(pow_lowATThigh), chanlocs);
title('6 Hz att High');

subplot(2,3,3)
topoplot(mean(pow_lowATTlow) - mean(pow_lowATThigh), chanlocs);
title('6 Hz diff (Low - High)');

subplot(2,3,4)
topoplot(mean(pow_highATTlow), chanlocs);
title('15 Hz att Low');

subplot(2,3,5)
topoplot(mean(pow_highATThigh), chanlocs);
title('15 Hz att High');

subplot(2,3,6)
topoplot(mean(pow_highATTlow) - mean(pow_highATThigh), chanlocs);
title('15 Hz diff (Low - High)');

%% Plot FFT of data for each channel (average trials)
Fs = EEG.srate;
T = 1/Fs;
L = 4999;

EEGlow = EEGlowall;
EEGhigh = EEGhighall;

figure;
for i = 1:32
    subplot(4,8, i)
    X = squeeze(EEGlow.data(i,:,:));
    Y = fft(X);
    Y = mean(Y, 2);
    
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(L/2))/L;
    plot(f, P1,  'Color', 'b');
    hold on;
    
    X = squeeze(EEGhigh.data(i,:,:));
    Y = fft(X);
    Y = mean(Y, 2);
    
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(L/2))/L;
    plot(f, P1, 'Color', 'r');
    
    title(sprintf('%s', EEGlow.chanlocs(i).labels))

    if i == 1
        xlabel('f (Hz)')
        ylabel('|P1(f)|')
        legend('Low Trials', 'High Trials', 'Location', 'southeast')
    end
    
    xlim([2 18])
    ylim([0 0.2])
    
    
    xticks([5 9 12 15])
    xticklabels({'5', '9', '12', '15'})
        
    hold on;

end

%% Plot FFT of data for one channel(all trials)
Fs = EEG.srate;
T = 1/Fs;
L = 4999;
t = (0:L-1)*T; % Time vector
channum = 20;
data = squeeze(EEGlowall.data(channum,:,:));

figure; hold on;
title(sprintf('FFT: %s attend Low', EEGlow.chanlocs(channum).labels))

for i = 1:size(data, 2)
    
    X = data(:,i);
    Y = fft(X);
    Y = mean(Y, 2);
    
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);

    f = Fs*(0:(L/2))/L;
    plot(f, P1, '.');
    xlabel('f (Hz)')
    ylabel('|P1(f)|')
    xlim([0 20])
    ylim([0 6])

end
