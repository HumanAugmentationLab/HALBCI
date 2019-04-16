%% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';
% File name without extension
% fnameeeg = '20190131150343_ZZZ-Pilot-1_Test';
fnameeeg = '20190131152830_ZZZ-Pilot-2_Test';
% fnameeeg = '20190131155150_ZZZ-Pilot-3_Test';

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

%% Epoch into small chunks
lastEEG = EEG;
% Markers for sustained attention
adetails.markers.types = {'51','52','53','54'};
adetails.markers.names = {'CHECK & LOW','CHECK & HIGH','VID & LOW','VID & HIGH'};
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
EEG = pop_rejepoch(EEG, 21, 1);

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
% direeg = 'C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava\VideoAttention\icafiles\';
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckerV4\';

pop_saveset(EEG, 'filename', 'EEG1', 'filepath', direeg)

%% Read ICA from each run
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckerV4\';
EEG1 = pop_loadset('filename', 'EEG1.set', 'filepath', direeg);
EEG2 = pop_loadset('filename', 'EEG2.set', 'filepath', direeg);
EEG3 = pop_loadset('filename', 'EEG3.set', 'filepath', direeg);

%% Inspect ICA components
EEG = pop_selectcomps(EEG);

%% Remove ICA components
% Store numbers of components to reject (set manually)
lastEEG = EEG;
rej1 = [1 4 11 18 31];

rej_comps = rej1;
adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('Subtracing ICA component from data...')
EEG = pop_subcomp(EEG, rej_comps);

pop_saveset(EEG, 'filename', 'EEG1sub', 'filepath', direeg)

%% Plot data after removal of ICA components
% Reference to original data
figure; pop_spectopo(lastEEG, 1, [1000*lastEEG.xmin  1000*lastEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(EEG, 1, [1000*EEG.xmin  1000*EEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

%% Combine post-ICA runs
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\CheckerV4';

EEG1sub = pop_loadset('filename', 'EEG1sub.set', 'filepath', direeg);
EEG2sub = pop_loadset('filename', 'EEG2sub.set', 'filepath', direeg);
EEG3sub = pop_loadset('filename', 'EEG3sub.set', 'filepath', direeg);

allEEG = set_merge(EEG1sub, EEG2sub, EEG3sub);
allEEG = exp_eval(allEEG);

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
    
    plow52(i,:) = bandpower(squeeze(EEG52.data(i,:,:)),EEG51.srate,[4 8]);
    phigh52(i,:) = bandpower(squeeze(EEG52.data(i,:,:)),EEG51.srate,[12 16]);
    
    plow53(i,:) = bandpower(squeeze(EEG53.data(i,:,:)),EEG51.srate,[4 8]);
    phigh53(i,:) = bandpower(squeeze(EEG53.data(i,:,:)),EEG51.srate,[12 16]);
    
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