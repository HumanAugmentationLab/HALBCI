% Tutorial on running bcilab analysis 
% S. Michalka 4/3/2018

% 1) Initialize BCILAB (cd to your BCILAB folder and type bcilab into the
% command window)
% 2) Load saved eeg data from a file

%% Load the EEG data from a file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settings for this section (put at top of analysis)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\';
% File name without extension
fnameeeg = '20170727114720_PatientW1-8v15_Record'; 
%fnameeeg = '20170710171359_Patient01_SSVEP-P0-8ch';

adetails.headset = 'enobio'; % 'enobio' or 'muse'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Code for analysis                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If using enobio data
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

% Plot the raw eeg data (it will be messy). 
% Make sure that the event markers make sense.
pop_eegplot(EEG,1,1,0);
% This removes the dc offset 
psettings=get(gcf,'UserData'); psettings.submean='on'; set(gcf,'Position',Pos,'UserData',psettings); eegplot('draws',0);
% When you are done scrolling through the data, hit CLOSE.

%% Inspect raw data in frequency domain
% This plots the channel spectra over big range.
% If no filtering has been done, we should see spikes at 60 and 120 Hz
figure; pop_spectopo(EEG, 1, [EEG.event(1).latency_ms EEG.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [30 60 120], 'freqrange',[.5 130],'electrodes','on');

% Also plot a zoomed in version of this to look in our range of interest.
figure; pop_spectopo(EEG, 1, [EEG.event(1).latency_ms EEG.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [6 10 22], 'freqrange',[2 24],'electrodes','on');

% SWM: There may weird spiking at every 1 Hz for all channels except ch 14 (Fz)
% This starts as low as 1.5 hz and continues on (only for enobio data_

%% Filter the continuous data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settings for this section (put at top of analysis)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

% For BCILAB flt_fir version

adetails.filter.mode = 'bandpass'; % band pass

%for a band-pass/stop filter, this is: [low-transition-start,
% low-transition-end, hi-transition-start, hi-transition-end], in Hz
adetails.filter.freqs = [.25 .75 50 54]; 
%adetails.filter.freqs = [.5 52]; 

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

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Code for analysis                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Look at filtering using EEGLAB and BCILAB for comparison
% Lots to explore here

% EEGLAB version
% two options for calling FIR filter (firws recommended)
%[E_eegbandpass] = pop_eegfiltnew(EEG,.5,52); 
[E_eegbandpass, adetails.filter.comm, adetails.filter.b]  = ...
    pop_firws(EEG,'fcutoff',adetails.filter.freqs,...
    'forder',826,'ftype',adetails.filter.mode,'wtype','hamming');


%%
% BCILAB version
[B_eegbandpass, adetails.filter.state] = exp_eval(flt_fir(EEG,adetails.filter.freqs, ...
    adetails.filter.mode, adetails.filter.type));

%% Plot the data from filtering
datatoplot = B_eegbandpass; 

% Plot the raw data
%figure; plot(datatoplot.data'); legend(EEG.chanlocs.labels); title('All filtered channels')
pop_eegplot(datatoplot,1,1,0);

% % Plot the first 5 channels from original and filtered
% selch = 1:5;
% figure; plot(EEG.data(selch,:)'); legend(EEG.chanlocs(selch).labels);
% hold on; plot(datatoplot.data(selch,:)','--');

% Plot the spectra
figure; pop_spectopo(datatoplot, 1, [datatoplot.event(1).latency_ms datatoplot.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [30 60 120], 'freqrange',[.5 130],'electrodes','on');
% again zoomed in
figure; pop_spectopo(datatoplot, 1, [datatoplot.event(1).latency_ms datatoplot.event(end).latency_ms], 'EEG' , 'percent', 15, 'freq', [6 10 22], 'freqrange',[2 24],'electrodes','on');

%% Use data that has been filtered (with whatever method you select)
% Normally you would just write over the EEG structure earlier, but this is
% here so that it's easy to look at different methods
oldEEG = EEG; % Save a backup of EEG so you don't need to reload.

EEG = B_eegbandpass;


%% Epoch the data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settings for this section (put at top of analysis)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Find all unique markers
for i = 1:size(EEG.event); evtype{i} = EEG.event(i).type;end; unique(evtype)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Markers for sustained attention
adetails.markers.types = {'111','121','211','221'};
adetails.markers.names = {'Left F1','Left F2','Right F1','Right F2'};
adetails.markers.epochwindow = [0 9];
% Attended location (left/right) and frequency (F1 F2)
% SWM: Should confirm that these marker labels are correct.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cue markers
% adetails.markers.types = {'110','120','210','220'};
% adetails.markers.names = {'Cue Left F1','Cue Left F2','Cue Right F1','Cue Right F2'};
% adetails.markers.epochwindow = [-1 2];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Code for analysis                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% EEGLAB method
epochEEG = pop_epoch(EEG,adetails.markers.types, adetails.markers.epochwindow);

% Remove baseline values from each epoch  if desired.
% pop_rmbase()


% % BCILAB method (incomplete)
% myapproach = {'DataflowSimplified','SignalProcessing', {'Resampling','off','EpochExtraction',adetails.markers.epochwindow}};
% %'FIRFilter',[6 12 16 32] % this could come from flt_filt function above
% %and filter frequencies specified there.. avoiding for now.
% 
% [trainloss,lastmodel,laststats] = bci_train('Data',EEG,'Approach',myapproach,'TargetMarkers',adetails.markers.types);
% disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
% 
% %The given dataset has non-trivial BCILAB filters applied to it. Such filters should be applied in the approach instead, and will not be reflected in the model:
%  %        set_targetmarkers('Signal', flt_fir(io_loadset('K:\HumanAugmentationLab\EEGdata\EnobioTests\Testing SSVEP\20170727114720_PatientW1-8v15_Record.easy'), [0.25 0.75 50 54], 'bandpass', 'linear-phase'), 'EventTypes', {'111', '121', '211', '221'}, 'EpochBounds', [-0.1 9.1], 'EventField', 'type', 'PruneNontarget', logical(false))

%% Remove bad channels and epochs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settings for this section (put at top of analysis)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
adetails.reject.strategy = 'interpolate'; % or 'remove'

% Plot the epoched data
pop_eegplot(epochEEG,1,1,0);

% Inspect raw data in frequency domain
figure; pop_spectopo(epochEEG, 1, [0  1000*epochEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [10 15 20], 'freqrange',[1 30],'electrodes','on');

% Show candidates for rejection 
[rejEEG,rejEEG.reject.indelec] = pop_rejchan(epochEEG,'elec',1:32,'threshold',5,'norm','on','measure','prob');
%,'elec',1:32,'threhold',5,'norm','on','measure','kurt');
% 'measure','probability'

%Manually note other channels to reject
rejEEG.reject.indelec = [2 6 7 25]; % manually in code
rejEEG.reject.indelec = input('Input vector of bad channels between [] \n');

rejchnames = {rejEEG.chanlocs([rejEEG.reject.indelec]).labels}
adetails.reject.channelnames = rejchnames;

% Actually remove the bad channels
if strcmp(adetails.reject.strategy, 'remove' )
    rejEEG = pop_select(rejEEG,'nochannel',rejchnames);
elseif strcmp(adetails.reject.strategy, 'interpolate' )
    % Interpolate rejected channels
    rejEEG = eeg_interp(rejEEG,rejEEG.reject.indelec,'spherical');
end

% Confirm that the new data look good
pop_eegplot(rejEEG,1,1,0);
figure; pop_spectopo(rejEEG, 1, [0  1000*epochEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [10 15 20], 'freqrange',[1 30],'electrodes','on');

%% Run ICA to find eye movements and other artifacts

% See this page for running and rejecting ICA componenets
% https://sccn.ucsd.edu/wiki/Chapter_09:_Decomposing_Data_Using_ICA

icarejEEG = pop_runica(rejEEG);

icaepochEEG = pop_runica(epochEEG);

% These give similar results

%% Remove ICA components

%pop_selectcomp
rejicarejEEG = pop_subcomp(icarejEEG);

%% Plot data after removal of ICA components
figure; pop_spectopo(rejicarejEEG, 1, [0  1000*rejicarejEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [8 10 15], 'freqrange',[1 30],'electrodes','on');

%% Generate plots for each condition
for i = 1:length(adetails.markers.types)
    tempEEG = pop_selectevent(icarejEEG, 'type', adetails.markers.types(i));
    figure; pop_spectopo(tempEEG, 1, [0  1000*tempEEG.xmax], 'EEG' ,...
    'percent', 100, 'freq', [8 10 15], 'freqrange',[1 30],'electrodes','on');
    title(adetails.markers.names(i));
end

%%