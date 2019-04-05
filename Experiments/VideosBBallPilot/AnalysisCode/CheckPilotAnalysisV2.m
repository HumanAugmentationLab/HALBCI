cd C:\Users\Public\Research\BCILAB
bcilab

%% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';

% File name without extension
fnameeeg = '20190330095018_PKVideoCheckSizePilot-1_Test';
% fnameeeg = '20190330101406_PKVideoCheckSizePilot-2_Test';
% fnameeeg = '20190330103714_PKVideoCheckSizePilot-3_Test';
% fnameeeg = '20190330105913_PKVideoCheckSizePilot-4_Test';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data

%% Chop run between start and end markers 
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% EEG = eeg_eegrej(EEG, [1 start_pt-1]);        % use if missing end marker
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
figure; pop_eegplot(EEG, 1);

% Inspect epoched data in frequency domain
% figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
%     'percent', 100, 'freq', [5 11.9 15], 'freqrange',[1 30],'electrodes','on');

%% Interpolate/remove the bad channels from the data
adetails.reject.strategy = 'interpolate'; % or 'remove'

badelec = 22; %RUN 1

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
adetails.markers.types = {'51','52','53','54','55','56'};
% adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};
evtype = [];

adetails.markers.epochwindow = [2 60]; % window after standard markers to look at
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
        EEG.event(k) = lastEEG.event(i); % Write into new index
        k = k+1;
    end
end

disp('Epoching EEG into small increments...')
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
dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckSize-PK\';
pop_saveset(EEG, 'filename', 'EEG2', 'filepath', dirica)

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;
rej1 = [1 5 10 16 18 24 30];
rej_comps = rej1;
adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('Subtracing ICA component from data...')
EEG = pop_subcomp(EEG, rej_comps);

pop_saveset(EEG, 'filename', 'EEG2sub', 'filepath', dirica)

%% Plot data before/after removal of ICA components
freqsofinterest = [6 7.5 15 18 30];

figure; pop_spectopo(lastEEG, 1, [1000*lastEEG.xmin  1000*lastEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

%% Combine ICA runs
dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckSize-PK\';

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
EEG3sub = pop_loadset('filename', 'EEG3sub.set', 'filepath', dirica);
EEG4sub = pop_loadset('filename', 'EEG4sub.set', 'filepath', dirica);

% Set aside one run
EEGsub = set_merge(EEG1sub, EEG2sub, EEG3sub);
EEGsub = exp_eval(EEGsub);

% EEG = EEGsub;
EEG = EEG2sub;
adetails.markers.types = {'51','52','53','54','55','56'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

%% Select by condition
lastEEG = EEG;
EEG = EEG2sub;

% lowevents = {'51', '53'};
% highevents = {'52', '54'};
% 
% EEGlowall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, lowevents)));
% EEGhighall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, highevents)));

EEGbig = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'51', '52'})));
EEGmed = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'53', '54'})));
EEGsmall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, {'55', '56'})));

EEGbiglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
EEGbighigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
EEGsmalllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
EEGsmallhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));

%% Generate spectopo plots for each condition, if epochs trimmed to not include events.
freqsofinterest = [6 12 15 18 30];
%     
% EEGlow = EEGhighcheck;
% EEGhigh = EEGhighvid;

figure; pop_spectopo(EEGbig, 1, [1000*EEGbig.xmin 1000*EEGbig.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

figure; pop_spectopo(EEGmed, 1, [1000*EEGmed.xmin 1000*EEGmed.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

figure; pop_spectopo(EEGsmall, 1, [1000*EEGsmall.xmin 1000*EEGsmall.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

%% Put some epochs aside for prediction
EEG = EEGbig;

markertype = {'51','52'};

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,markertype));

markertypes = string();

keeppertrial = 4;
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


disp('Made data continuous')

%% BCILAB Training

% myapproach = {'CSP', ...
%     'SignalProcessing', { ...
%         'EpochExtraction',[0 9.996], ...
%         'FIRFilter', {'Frequencies', [1 2 48 49], 'Type','linear-phase'}...
%         } ...
%     'Prediction', {'FeatureExtraction',{'PatternPairs',2}} ...
%     };
% 
% myapproach = {'SpecCSP', ...
%     'SignalProcessing', { ...
%         'EpochExtraction', [0 9.99] , ...
%         'FIRFilter', {'Frequencies', [1 2 48 49], 'Type','linear-phase'}...
%         } , ... 
%     'Prediction', {'FeatureExtraction',{...
%         'PatternPairs',4, ...
%         'prior','@(f) f>=2 & f<=20' ...
%         }...
%     } ...
% };
% myapproach = {'Bandpower' ...
%     'SignalProcessing', { ...
%         'FIRFilter',[4 5 7 8], ...
%         'EpochExtraction', {'TimeWindow',[0 9.996] } ...
%      }, ...
% };
% myapproach = {'Bandpower' ...
%     'SignalProcessing', { ...
%         'FIRFilter',[13 14 16 17], ...
%         'EpochExtraction', {'TimeWindow',[0 9.996] } ...
%      }, ...
% };

myapproach = {'Spectralmeans' ...
    'SignalProcessing', { ...
        'EpochExtraction', {'TimeWindow',[0 9.996] } ...
     }, ...
     'Prediction', { ...
        'FeatureExtraction',{ 'FreqWindows', [5 7; 14 16] }, ...
        'MachineLearning', {'Learner', 'logreg'} ...
        }...
};


[trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
    'TargetMarkers',{{'51'}, {'52'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 


disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
bci_visualize(mymodel)

%annotateData = bci_annotate(lastmodel, mydata)
[prediction,loss,teststats,targets] = bci_predict(mymodel,EEGtest);

disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
% disp(['  predicted classes: ',num2str(round(prediction)')]);  % class probabilities * class values
% disp(['  true classes     : ',num2str(round(targets)')]);

%% Plot spectopo for single channel
singlelow = EEGlow;
singlehigh = EEGhigh;

for i = 1:32
    singlelow.data(i,:) = singlelow.data(4, :);
    singlehigh.data(i,:) = singlelow.data(4, :);
end

pop_spectopo(singlelow, 1, [0 2000], 'EEG', 'percent', 100, 'freq', [6.1 9 15 18], 'freqrange',[3 25],'electrodes','on')

%% Plot average power over posterior electrodes for each condition
lsize = size(EEGsmalllow.data);           % This value is the same for all conditions
lowfreq = 6;
highfreq = 15;
thresh = 0.25;
posterior_channels = [4] % 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3

powsm_lowATTlow = zeros(1, lsize(3));
powsmalllow = zeros(1, lsize(3));

powsmallhighATT = zeros(1, lsize(3));
powsmallhigh = zeros(1, lsize(3));

powmedlowATT = zeros(1, lsize(3));
powmedlow = zeros(1, lsize(3));

powmedhighATT = zeros(1, lsize(3));
powmedhigh = zeros(1, lsize(3));

powbiglowATT = zeros(1, lsize(3));
powbiglow = zeros(1, lsize(3));

powbighighATT = zeros(1, lsize(3));
powbighigh = zeros(1, lsize(3));

figure;
for i = 1:lsize(3)
    % ---------- CHECK SIZE : SMALL  ---------- %
    
    % ATTENDING LOW
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGsmalllow.data(posterior_channels,:,i), lsize(2), EEGsmalllow.srate);
    lowIDX = find(freq>lowfreq-thresh & freq<lowfreq+thresh);
    highIDX = find(freq>highfreq-thresh & freq<highfreq+thresh);
    powsm_lowATTlow(i) = 10^(mean(spectra(lowIDX))/10);
    powsm_highATTlow(i) = 10^(mean(spectra(highIDX))/10);
    
    % ATTENDING HIGH
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGsmallhigh.data(posterior_channels,:,i), lsize(2), EEGsmallhigh.srate);
    powsm_lowATThigh(i) = 10^(mean(spectra(lowIDX))/10);
    powsm_highATThigh(i) = 10^(mean(spectra(highIDX))/10);
    
    % ---------- CHECK SIZE : MED  ---------- %
    
    % ATTENDING LOW
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGmedlow.data(posterior_channels,:,i), lsize(2), EEGmedlow.srate);
    powmed_lowATTlow(i) = 10^(mean(spectra(lowIDX))/10);
    powmed_highATTlow(i) = 10^(mean(spectra(highIDX))/10);
    
    % ATTENDING HIGH    
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGmedhigh.data(posterior_channels,:,i), lsize(2), EEGmedhigh.srate);
    powmed_lowATThigh(i) = 10^(mean(spectra(lowIDX))/10);
    powmed_highATThigh(i) = 10^(mean(spectra(highIDX))/10);
    
    % ---------- CHECK SIZE : BIG  ---------- %
    
    % ATTENDING LOW
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGbiglow.data(posterior_channels,:,i), lsize(2), EEGbiglow.srate);
    powbig_lowATTlow(i) = 10^(mean(spectra(lowIDX))/10);
    powbig_highATTlow(i) = 10^(mean(spectra(highIDX))/10);
    
    % ATTENDING HIGH    
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGbighigh.data(posterior_channels,:,i), lsize(2), EEGbighigh.srate);
    powbig_lowATThigh(i) = 10^(mean(spectra(lowIDX))/10);
    powbig_highATThigh(i) = 10^(mean(spectra(highIDX))/10);
    
end
close;
%% Plotting power via spectopo
powsATTlow = [powsm_lowATTlow; powsm_lowATThigh; ...
    powmed_lowATTlow; powmed_lowATThigh; ...
    powbig_lowATTlow; powbig_lowATThigh];

powsATThigh = [powsm_highATTlow; powsm_highATThigh; ...
    powmed_highATTlow; powmed_highATThigh; ...
    powbig_highATTlow; powbig_highATThigh];

figure; hold on
bins = [10 20 35 45 60 70];
binlabels = {'Small Att. Low'; 'Small Att. High'; 'Med Att. Low'; 'Med Att. High'; 'Big Att. Low'; 'Big Att. High'};

subplot(2,1,1); hold on 
bar(bins, mean(powsATTlow, 2))          % Average across trials
plot(bins, powsATTlow, '*', 'LineWidth', 1);
title('6 Hz Power');
xticks(bins)
xticklabels(binlabels)

subplot(2,1,2); hold on
bar(bins, mean(powsATThigh, 2))
title('15 Hz Power');
xticks(bins)
xticklabels(binlabels)
plot(bins, powsATThigh, '*', 'LineWidth', 1);

% errorbar(bins, meanpower, maxes, 'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2, 'Marker', '.')

% plot(bins, maxes, '*', 'Color', 'r', 'LineWidth', 1);
% binscatter

%% Bandpower
numtrials = lsize(3);
posterior_channels = [4] ; % 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [5.6153 6.1035];
highbin = [14.8926  15.3809];

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

%% Plot bandpower
% Average power over channels (15 trials x 6 conds)
avgchanATTlow = [mean(powsm_lowATTlow,2) mean(powsm_lowATThigh,2) ...
    mean(powmed_lowATTlow,2) mean(powmed_lowATThigh,2) ...
    mean(powbig_lowATTlow,2) mean(powbig_lowATThigh,2)];

avgchanATThigh = [mean(powsm_highATTlow,2) mean(powsm_highATThigh,2) ...
    mean(powmed_highATTlow,2) mean(powmed_highATThigh,2) ...
    mean(powbig_highATTlow,2) mean(powbig_highATThigh,2)];

figure; hold on
bins = [10 20 35 45 60 70];

subplot(2,1,1); hold on 
bar(bins, mean(avgchanATTlow))          % Average across trials
binlabels = {'Small Att. Low'; 'Small Att. High'; 'Med Att. Low'; 'Med Att. High'; 'Big Att. Low'; 'Big Att. High'};

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

%% Scalp map

%% Plot relative powers while varying attention 
lowfreq = 6;
highfreq = 15;
thresh = 0.5;
channum = 20;

% EEGlow = EEGlowcheck;
% EEGhigh = EEGhighcheck;

% --------------- Attending LOW -------------- %
lsize = size(EEGlow.data);

llp = zeros(1, lsize(3)); hlp = llp;
llrel = zeros(1, lsize(3)); hlrel = llrel;

% for each epoch calculate relative power of target frequencies
for i = 1:lsize(3)
    % spectra: relative powers per frequency (dB)
    % freq: frequencies corresponding to spectra
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGlow.data(posterior_channels,:,i), lsize(2), EEGlow.srate);
    
    % find low and high index of freq array
    lowIDX = find(freq>lowfreq-thresh & freq<lowfreq+thresh);
    highIDX = find(freq>highfreq-thresh & freq<highfreq+thresh);

    mean(spectra(lowIDX))
    mean(spectra(highIDX))

    % calculate power of low/high freq when attending low/high
    llp(i) = 10^(mean(spectra(lowIDX))/10);
    hlp(i) = 10^(mean(spectra(highIDX))/10); 

end

% --------------- Attending HIGH -------------- %
hsize = size(EEGhigh.data);

lhp = zeros(1, hsize(3)); hhp = lhp;
lhrel = zeros(1, hsize(3)); hhrel = lhrel;

for i = 1:hsize(3)
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        EEGhigh.data(channum,:,i), hsize(2), EEGhigh.srate, 'limits', [0 30]);

    lowIDX = find(freq>lowfreq-thresh & freq<lowfreq+thresh);
    highIDX = find(freq>highfreq-thresh & freq<highfreq+thresh);

    lhp(i) = 10^(mean(spectra(lowIDX))/10);
    hhp(i) = 10^(mean(spectra(highIDX))/10);
end

close;
%
% Ignore trials below power threshold
powthresh = 0.75;
llp_trunc = llp(llp > powthresh);
lhp_trunc = lhp(lhp > powthresh);
hlp_trunc = hlp(hlp > powthresh);
hhp_trunc = hhp(hhp > powthresh);

% Always compare the same frequency and vary attention
% read X, attend X
% meanpower = [mean(llp) mean(lhp) mean(hlp) mean(hhp)];
% stds = [std(llp) std(lhp) std(hlp) std(hhp)];
% maxes = [max(llp) max(lhp) max(hlp) max(hhp)];

meanpower = [mean(llp_trunc) mean(lhp_trunc) mean(hlp_trunc) mean(hhp_trunc)];
stds = [std(llp_trunc) std(lhp_trunc) std(hlp_trunc) std(hhp_trunc)];
maxes = [max(llp_trunc) max(lhp_trunc) max(hlp_trunc) max(hhp_trunc)];

% plot 
figure; hold on
bins = [10 20 35 45];
bar(bins, meanpower)
title(sprintf('Relative Powers Attending: %s', EEGlow.chanlocs(channum).labels))

xticks(bins)
xticklabels({'Low att. Low'; 'Low att. High'; 'High att. Low'; 'High att. High'})
plot(bins, maxes, '*', 'Color', 'r', 'LineWidth', 1);
% errorbar(bins, meanpower, maxes, 'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2, 'Marker', '.')

legend('Mean trial power', 'Max Value', 'Location', 'northwest')

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
