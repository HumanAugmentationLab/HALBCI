%% Start BCILAB
cd 'C:\Users\alakmazaheri\Documents\BCI\BCILAB';
bcilab

%% 1. Load the EEG data from a file

% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\';
% File name without extension
fnameeeg = '20181029150401_-ZZZ-VideosPilot2_RECORD';
% fnameeeg = '20181029151624_-ZZZ-VideosPilot3_RECORD';
% fnameeeg = '20181029152928_-ZZZ-VideosPilot4_RECORD';
% fnameeeg = '20181029154331_-ZZZ-VideosPilot5_RECORD';
% fnameeeg = '20181029155409_-ZZZ-VideosPilot6_RECORD';
% fnameeeg = '20181029160603_-ZZZ-VideosPilot7_RECORD';


adetails.headset = 'enobio'; % 'enobio' or 'muse'

% If using enobio d ata
if strcmp(adetails.headset,'enobio')
    
    % Load the .easy file version of the data
    ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy')));
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    % If missing the .info file, the .easy file will give us improper
    % channel locations, so we need to get from elsewhere (.edf)
    if ~exist(fullfile(direeg,strcat(fnameeeg,'.info')),'file') 
        % Note: as of 2017, we are getting mproper channel labels from the .easy file and 
        % improper events from the edf file, so as a short-term fix, we will load both and combine them
        % Load the edf file just to get the channel locations, you will get a warning about events 
        disp('WARNING: No .info file, potential issue with channel locations, loading from .edf')
        ioedf = io_loadset(fullfile(direeg,strcat(fnameeeg,'.edf')),'channels',1:max(size(EEG.chanlocs)));
        tempchlocs = exp_eval(ioedf); % Load the .edf file
        EEG.chanlocs = tempchlocs.chanlocs; % Replace the channel locations
        clear tempchlocs ioedf;
    end

% If using the Muse headset
elseif strcmp(adetails.headset,'muse')
    disp('Need to write this code :) \n')
end

%% Inspect the raw data in time domain

% Plot the raw eeg data (it will be messy). Make sure that the event markers make sense.
pop_eegplot(EEG,1,1,0);
% This removes the dc offset 
psettings=get(gcf,'UserData'); psettings.submean='on'; 
set(gcf,'UserData',psettings); eegplot('draws',0);
% When you are done scrolling through the data, hit CLOSE.

%% 2. Chop run between start/end markers (10 to 100)
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% eeg_cropped = eeg_eegrej(EEG, [1 start_pt-1]);
eeg_cropped = eeg_eegrej(EEG, [1 start_pt-1; end_pt+1 EEG.pnts]);

%% 3. Filter the continuous data
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

[eeg_bandpass, adetails.filter.state] = exp_eval(flt_fir(eeg_cropped,adetails.filter.freqs, ...
    adetails.filter.mode, adetails.filter.type));

%% Plot the data from filtering
datatoplot = eeg_bandpass; 

% Plot the raw data
%figure; plot(datatoplot.data'); legend(EEG.chanlocs.labels); title('All filtered channels')
pop_eegplot(datatoplot,1,1,0);

% % Plot the first 5 channels from original and filtered
% selch = 1:5;
% figure; plot(EEG.data(selch,:)'); legend(EEG.chanlocs(selch).labels);
% hold on; plot(datatoplot.data(selch,:)','--');

% Plot the spectra
% Event 2 skips over EEGLAB boundary marker
figure; pop_spectopo(datatoplot, 1, [datatoplot.event(2).latency_ms datatoplot.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [30 60 120], 'freqrange',[.5 130],'electrodes','on');
% again zoomed in
figure; pop_spectopo(datatoplot, 1, [datatoplot.event(2).latency_ms datatoplot.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [6 9 11 12 15], 'freqrange',[2 24],'electrodes','on');

%% 4. Epoch each trial
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

eeg_epoch = pop_epoch(eeg_bandpass,adetails.markers.types, adetails.markers.epochwindow);

%% 5. Inspect for bad channels and epochs
adetails.reject.strategy = 'interpolate'; % or 'remove'

% Plot the epoched data
pop_eegplot(eeg_epoch,1,1,0);

% Inspect epoched data in frequency domain
figure; pop_spectopo(eeg_epoch, 1, [1000*eeg_epoch.xmin  1000*eeg_epoch.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 15], 'freqrange',[1 30],'electrodes','on');

% Show candidates for rejection 
[eeg_rej,eeg_rej.reject.indelec] = pop_rejchan(eeg_epoch,'elec',1:32,'threshold',5,'norm','on','measure','prob');
%,'elec',1:32,'threhold',5,'norm','on','measure','kurt');
% 'measure','probability'

%% Manually reject bad channels
%Manually note other channels to reject

%eeg_rej.reject.indelec = [1 8]; % run 5
eeg_rej.reject.indelec = [];
%eeg_rej.reject.indelec = input('Input vector of bad channels between [] \n');
%rejEEG.reject.indelec = [2 6 7 24 25]; % manually in code, for ERP to cue


rejchnames = {eeg_rej.chanlocs([eeg_rej.reject.indelec]).labels}
adetails.reject.channelnames = rejchnames;

% Actually remove the bad channels
if strcmp(adetails.reject.strategy, 'remove' )
    eeg_rej = pop_select(eeg_rej,'nochannel',rejchnames);
elseif strcmp(adetails.reject.strategy, 'interpolate' )
    % Interpolate rejected channels
    eeg_rej = eeg_interp(eeg_rej,eeg_rej.reject.indelec,'spherical');
    % Note: rejEEG.reject.indelec gets deleted when you run this
    % interpolation
    
end

% Confirm that the new data look good
pop_eegplot(eeg_rej,1,1,0);
figure; pop_spectopo(eeg_rej, 1, [1000*eeg_epoch.xmin  1000*eeg_epoch.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 15], 'freqrange',[1 30],'electrodes','on');

%% Reject bad epochs (may skip this step for now)

% Generate a list of all epochs and mark the ones for rejection with the number 1
adetails.reject.epochs = zeros(1,size(eeg_rej.data,3)); 
adetails.reject.epochs(6) = 1;                           % rejects epoch 1

% Actually remove the epochs from your data
eeg_rej = pop_rejepoch(eeg_rej, adetails.reject.epochs);

pop_eegplot(eeg_rej,1,1,0);

%% Run ICA to find eye movements and other artifacts

% See this page for running and rejecting ICA componenets
% https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA

eeg_ica = pop_runica(eeg_rej, 'runica');

% Run ICA on the version without channel rejection for comparison
% eeg_ica_epoch = pop_runica(eeg_ica_rej);
% These give similar results

% Write ICA to file for later use
path = 'C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava\VideoAttention\icafiles\';
pop_saveset(eeg_ica, 'filename', 'eeg_ica7', 'filepath', path)

%%  6. Read ICA from file
path = 'C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Ava\VideoAttention\icafiles\';

eeg_ica2 = pop_loadset('filename', 'eeg_ica2.set', 'filepath', path);
eeg_ica3 = pop_loadset('filename', 'eeg_ica3.set', 'filepath', path);
eeg_ica4 = pop_loadset('filename', 'eeg_ica4.set', 'filepath', path);
eeg_ica5 = pop_loadset('filename', 'eeg_ica5.set', 'filepath', path);
eeg_ica6 = pop_loadset('filename', 'eeg_ica6.set', 'filepath', path);
eeg_ica7 = pop_loadset('filename', 'eeg_ica7.set', 'filepath', path);

% cannot combine sets because different channel numbers
% set_merge(eeg_ica2, eeg_ica3, eeg_ica4, eeg_ica5, eeg_ica6, eeg_ica7)

%% Plot the ICA components
eeg_ica = pop_selectcomps(eeg_ica2);

%% 7. Remove ICA components
% Store numbers of components to reject (set manually)

% ------------- RUN 2 ---------------- %
rej_art2 = [4 30 31];
rej_elec2 = [rej_art2 1 5 6 8 10 12 14:18 23 29];

% ------------- RUN 3 ---------------- %
rej_art3 = [1 2 10 18 29:31];
rej_elec3 = [rej_art3 5 11:13 20 22];

% ------------- RUN 4 ---------------- %
rej_art4 = [1 22 31];
rej_elec4 = [rej_art4 4 5 8 11 13:14 18:19];

% ------------- RUN 5 ---------------- %
rej_art5 = [1 21 31];
rej_elec5 = [rej_art5 6 8 13 18 22 26 28 31];

% ------------- RUN 6 ---------------- %
rej_art6 = [3 7 13 20 21 23 28];
rej_elec6 = [rej_art6 9 10 14 15 17 24 31 32];

% ------------- RUN 7 ---------------- %
rej_art7 = [2 20 30];
rej_elec7 = [rej_art7 6 7 12:13 16 26:27];

rej_comps = rej_elec4;
eeg_ica = eeg_ica4;

adetails.reject.icacomponents = rej_comps;

% Running this way will cause a pop-up, which allows you to see the before
% and after by hitting Plot Single Trial (or plot ERPs, if this is what you're looking at),
%before you actually reject these components. 
% Here you're looking to see that this removed the eyeblinks and other
% artifacts without drastically changing the overall signal.
disp('subtracing ICA component from data...')
eeg_ica_sub = pop_subcomp(eeg_ica, rej_comps);

%% Plot data after removal of ICA components
% Reference to original data
figure; pop_spectopo(eeg_ica, 1, [1000*eeg_ica.xmin  1000*eeg_ica.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(eeg_ica_sub, 1, [1000*eeg_ica_sub.xmin  1000*eeg_ica_sub.xmax], 'EEG' ,...
    'percent', 100, 'freq', [6 10 12 15], 'freqrange',[1 30],'electrodes','on');

%% 8. Epoch post-ICA to categorize high/low freq
lowevents = {'51', '53'};
highevents = {'52', '54'};

eeg_low_sub = pop_select(eeg_ica_sub, 'trial', find(contains(adetails.markers.trialevents, lowevents)));
eeg_high_sub = pop_select(eeg_ica_sub, 'trial', find(contains(adetails.markers.trialevents, highevents)));

%% Generate spectopo plots for each condition, if epochs trimmed to not include events.
freqsofinterest = [6 12 15];
    
figure; pop_spectopo(eeg_low_sub, 1, [1000*eeg_low_sub.xmin 1000*eeg_low_sub.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

figure; pop_spectopo(eeg_high_sub, 1, [1000*eeg_high_sub.xmin 1000*eeg_high_sub.xmax], 'EEG' ,...
    'percent', 100, 'freq', freqsofinterest, 'freqrange',[1 30],'electrodes','on');

%% Plot relative powers while attending
bins = [5 10 20 25]; numbins = size(bins,2);

% --------------- Attending LOW -------------- %
lsize = size(eeg_low_sub.data);

llp = zeros(1, lsize(3)); hlp = llp;
llrel = zeros(1, lsize(3)); hlrel = llrel;

% for each epoch calculate relative power of target frequencies
for i = 1:lsize(3)
    % spectra: relative powers per frequency (dB)
    % freq: frequencies corresponding to spectra
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        eeg_low_sub.data(lsize(1),:,i), lsize(2), eeg_low_sub.srate);
    
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
hsize = size(eeg_high_sub.data);

lhp = zeros(1, hsize(3)); hhp = lhp;
lhrel = zeros(1, hsize(3)); hhrel = lhrel;

for i = 1:hsize(3)
    [spectra, freq, speccomp, contrib, specstd] = spectopo( ...
        eeg_high_sub.data(hsize(1),:,i), hsize(2), eeg_high_sub.srate);
    
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

%% Generate ERP plots for each condition by left or right
for i = 1:2:3 %length(adetails.markers.types)
    %tempEEG = pop_selectevent(icarejEEG, 'type', adetails.markers.types(i));
    eeg_temp = pop_selectevent(rejEEG, 'type', {adetails.markers.types{i} adetails.markers.types{i+1}});
    figure; pop_timtopo(eeg_temp, [-100  1000], [NaN], adetails.markers.names{i});
    title(adetails.markers.names(i));
end

%% Generate time frequency plots

selchan = 5;

selevents = {'221','121'};
%selevents = {'211','111'};

selevents = {'111', '121'}; % left
%selevents = {'211', '221'}; %Right


eeg_temp = pop_select(rejicarejEEG, 'trial', find(contains(adetails.markers.trialevents,selevents)));

figure; pop_newtimef( eeg_temp, 1, 1, [1000*eeg_temp.xmin  1000*eeg_temp.xmax],...
    [3 0.5] , 'ntimesout',10, 'topovec', selchan, 'elocs', eeg_temp.chanlocs, 'chaninfo', eeg_temp.chaninfo,...
     'baseline',[0], 'freqs', [[5 18]], 'plotphase', 'off', 'plotitc','off','padratio', 1,'caption',eeg_temp.chanlocs(selchan).labels);

%% Look to see how ICA components change after first removal
eeg_ica_2 = pop_runica(eeg_ica_sub, 'runica');

eeg_ica_2 = pop_selectcomps(eeg_ica_2);
