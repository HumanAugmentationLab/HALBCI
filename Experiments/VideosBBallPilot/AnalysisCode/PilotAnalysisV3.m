%% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';
% File name without extension
% fnameeeg = '20181029150401_-ZZZ-VideosPilot2_RECORD';
% fnameeeg = '20181029151624_-ZZZ-VideosPilot3_RECORD';
% fnameeeg = '20181029152928_-ZZZ-VideosPilot4_RECORD';
% fnameeeg = '20181029154331_-ZZZ-VideosPilot5_RECORD';
% fnameeeg = '20181029155409_-ZZZ-VideosPilot6_RECORD';
fnameeeg = '20181029160603_-ZZZ-VideosPilot7_RECORD';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data

%% Chop run between start and end markers 
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% eeg_cropped = eeg_eegrej(EEG, [1 start_pt-1]);
disp('Cropping start and end of raw data...')
EEG = eeg_eegrej(EEG, [1 start_pt-1; end_pt+1 EEG.pnts]);

%% Filter the continuous data
lastEEG = EEG;

adetails.filter.mode = 'highpass'; % band pass

% for a band-pass/stop filter, this is: [low-transition-start,
% low-transition-end, hi-transition-start, hi-transition-end], in Hz
%adetails.filter.freqs = [.25 .75 50 54]; 
adetails.filter.freqs = [.25 .75]; 

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
adetails.markers.types = {'51','52','53','54'};
adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};
evtype = [];
for i = 1:length(EEG.event)
    evtype = [evtype, ""+EEG.event(i).type];
end
unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

adetails.markers.epochwindow = [2 60]; 


EEG = pop_epoch(EEG,adetails.markers.types, adetails.markers.epochwindow);

%% Epoch into one second chunks
lastEEG = EEG;
% Markers for sustained attention
adetails.markers.types = {'51','52','53','54'};
adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};
evtype = [];

adetails.markers.epochwindow = [2 60]; % window after standard markers to look at
adetails.markers.epochsize = 1; % size of miniepochs to chop regular markered epoch up into
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
        EEG.event(k) = lastEEG.event(i); % Write into new index
        k = k+1;
    end
end

disp('Epoching EEG into 1s increments...')
EEG = pop_epoch(EEG,adetails.markers.types, [0 adetails.markers.epochsize]);

%% Inspect for bad channels
lastEEG = EEG;
% Show candidates for rejection 
[~,badelec] = pop_rejchan(EEG,'elec',1:32,'threshold',5,'norm','on','measure','prob');

% Plot data to look at "bad" channels
% Plot the epoched data
figure; pop_eegplot(EEG, 1);

% Inspect epoched data in frequency domain
figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 15], 'freqrange',[1 30],'electrodes','on');

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
path = 'C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava\VideoAttention\icafiles\';
pop_saveset(EEG, 'filename', 'EEG7', 'filepath', path)

%% Read ICA from each run
path = 'C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava\VideoAttention\icafiles\';

EEG2 = pop_loadset('filename', 'EEG2.set', 'filepath', path);
EEG3 = pop_loadset('filename', 'EEG3.set', 'filepath', path);
EEG4 = pop_loadset('filename', 'EEG4.set', 'filepath', path);
EEG5 = pop_loadset('filename', 'EEG5.set', 'filepath', path);
EEG6 = pop_loadset('filename', 'EEG6.set', 'filepath', path);
EEG7 = pop_loadset('filename', 'EEG7.set', 'filepath', path);

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;
rej2 = [2 11 16 18 30];
rej3 = [1 3 8 9 11 13 29 31];
rej4 = [1 7 13 17 20 32];
rej5 = [1 9 10 15 19 21 23 25];
rej6 = [1 8 9 14 16 18 20 22 28 32];
rej7 = [1 3 10 12 20 30 32];

rej_comps = rej7;
adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('Subtracing ICA component from data...')
EEG = pop_subcomp(EEG, rej_comps);

path = 'C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava\VideoAttention\icafiles\';
pop_saveset(EEG, 'filename', 'EEG7sub', 'filepath', path)

%% Plot data after removal of ICA components
% Reference to original data
figure; pop_spectopo(lastEEG, 1, [1000*lastEEG.xmin  1000*lastEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

%% Combine post-ICA runs
EEG2sub = pop_loadset('filename', 'EEG2sub.set', 'filepath', path);
EEG3sub = pop_loadset('filename', 'EEG3sub.set', 'filepath', path);
EEG4sub = pop_loadset('filename', 'EEG4sub.set', 'filepath', path);
EEG5sub = pop_loadset('filename', 'EEG5sub.set', 'filepath', path);
EEG6sub = pop_loadset('filename', 'EEG6sub.set', 'filepath', path);
EEG7sub = pop_loadset('filename', 'EEG7sub.set', 'filepath', path);

allEEG = set_merge(EEG2sub, EEG3sub, EEG4sub, EEG5sub, EEG6sub, EEG7sub);
allEEG = exp_eval(allEEG);

%% Compare high and low freq trials
lowevents = {'51', '53'};
highevents = {'52', '54'};

EEGlow = pop_select(allEEG, 'trial', find(contains(adetails.markers.trialevents, lowevents)));
EEGhigh = pop_select(allEEG, 'trial', find(contains(adetails.markers.trialevents, highevents)));

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

