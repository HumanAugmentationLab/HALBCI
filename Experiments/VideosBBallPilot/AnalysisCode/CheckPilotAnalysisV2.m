%% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';

% File name without extension
% fnameeeg = '20190131150343_ZZZ-Pilot-1_Test';
fnameeeg = '20190131152830_ZZZ-Pilot-2_Test';
% fnameeeg = '20190131155150_ZZZ-Pilot-3_Test';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data

%% Load data with corrected condition markers
dirload = 'C:\Users\alakmazaheri\Desktop\';
EEG = importdata([dirload 'EEG5corr.mat']);

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
EEG.history = adetails;

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

%% Re-reference data against average of all channels
lastEEG = EEG;
EEG = pop_reref(EEG);

%% Epoch into small trials
lastEEG = EEG;
% Markers for sustained attention
adetails.markers.types = {'51','52','53','54'};
adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};
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

%% Confirm that the new data look good (skip)
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
dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckerV4\';
pop_saveset(EEG, 'filename', 'EEG2', 'filepath', dirica)

%% Read ICA from each run
dirica = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckerV4\';

EEG = pop_loadset('filename', 'EEG1.set', 'filepath', dirica);
EEG2 = pop_loadset('filename', 'EEG2.set', 'filepath', dirica);
EEG3 = pop_loadset('filename', 'EEG3.set', 'filepath', dirica);
EEG4 = pop_loadset('filename', 'EEG4.set', 'filepath', dirica);
EEG5 = pop_loadset('filename', 'EEG5.set', 'filepath', dirica);

allEEG = set_merge(EEG1, EEG2, EEG3, EEG4, EEG5);
allEEG = exp_eval(allEEG);

evtype = [];
for i = 1:length(allEEG.event)
    evtype = [evtype, ""+allEEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;
rej1 = [1 10 21];
rej2 = [1 15 22 24:26 29];

rej_comps = rej2;
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

%% Combine post-ICA runs

EEG1sub = pop_loadset('filename', 'EEG1sub.set', 'filepath', dirica);
EEG2sub = pop_loadset('filename', 'EEG2sub.set', 'filepath', dirica);
EEG3sub = pop_loadset('filename', 'EEG3sub.set', 'filepath', dirica);
EEG4sub = pop_loadset('filename', 'EEG4sub.set', 'filepath', dirica);
EEG5sub = pop_loadset('filename', 'EEG5sub.set', 'filepath', dirica);

allEEGsub = set_merge(EEG1sub, EEG2sub, EEG3sub, EEG4sub, EEG5sub);
allEEGsub = exp_eval(allEEGsub);

adetails.markers.types = {'51','52','53','54'};
adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};

lastEEG = EEG;
EEG = allEEGsub;

evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));


%% Compare high and low freq trials
lastEEG = EEG;
EEG = allEEGsub;

lowevents = {'51', '53'};
highevents = {'52', '54'};

EEGlowall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, lowevents)));
EEGhighall = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, highevents)));

EEGlowcheck = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
EEGhighcheck = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));

EEGlowvid = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
EEGhighvid = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));

%% Generate spectopo plots for each condition, if epochs trimmed to not include events.
freqsofinterest = [6 12 15 18 30];
    
EEGlow = EEGlowall;
EEGhigh = EEGhighall;

figure; pop_spectopo(EEGlow, 1, [1000*EEGlow.xmin 1000*EEGlow.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');

figure; pop_spectopo(EEGhigh, 1, [1000*EEGhigh.xmin 1000*EEGhigh.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 35],'electrodes','on');


%% Plot spectopo for single channel
singlelow = EEGlow;
singlehigh = EEGhigh;

for i = 1:32
    singlelow.data(i,:) = singlelow.data(20, :);
    singlehigh.data(i,:) = singlelow.data(20, :);
end

pop_spectopo(singlelow, 1, [0 2000], 'EEG', 'percent', 100, 'freq', [6.1 9 15 18], 'freqrange',[3 25],'electrodes','on')

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
        EEGlow.data(channum,:,i), lsize(2), EEGlow.srate);
    
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
title(sprintf('Relative Powers Attending: %s | CHECK', EEGlow.chanlocs(channum).labels))

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

%% Cheat single channel spectopo
singlelow = EEGlowcheck;
singlehigh = EEGhighcheck;

chan = 3;
for i = 1:32
    singlelow.data(i,:) = singlelow.data(chan, :);
    singlehigh.data(i,:) = singlehigh.data(chan, :);
end

figure; pop_spectopo(singlelow, 1, [0 2000], 'EEG', 'percent', 100, 'freq', freqsofinterest, 'freqrange',[3 25],'electrodes','on')
figure; pop_spectopo(singlehigh, 1, [0 2000], 'EEG', 'percent', 100, 'freq', freqsofinterest, 'freqrange',[3 25],'electrodes','on')

%% Plot 