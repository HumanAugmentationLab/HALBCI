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

options.headset = 'enobio'; % 'enobio' or 'muse'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Code for analysis                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% If using enobio data
if strcmp(options.headset,'enobio')
    
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
elseif strcmp(options.headset,'muse')
    disp('Need to write this code :) \n')
end

%% Inspect the raw data

% Things to look at:
%   raw data
%   event markers
%   channel locations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Settings for this section (put at top of analysis)                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Code for analysis                                                      %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the raw data


