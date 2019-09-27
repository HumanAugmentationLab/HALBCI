% Load open and closed from 20190823113301_ZZ-MagicLeapDuckyOpenClosed-1-Open_RECORD.easy



% Chop extra
EEG = pop_select(EEG,'time',[26 589])


% High pass filter at 1 hz
% Low pass filter at 46 Hz
EEG = eeg_checkset(EEG, 'makeur') % need to create ur for later.



%Change the markers to have plus 100 for eyes closed condition... then put
%this back into EEG file
idxofclosed = 490;
idxofclosed = 489; %run 3
for i = idxofclosed:length(EEG.event) % replace with finding 100 then 10
    EEG.event(i).type = num2str(str2double(EEG.event(i).type)+100);
    display(str2double(EEG.event(i).type)+100)
end
% Interpolate to remove t8
%skip: Autoreject w/ kurtosis F4, FC2, AF3 need to remove t8

% Epoch using 51 52 151 152\
% Do baseline correction for whole epoch

% Interpolated channel T8
% Run ICA on 32 after epoch
% Run ICA - reject eye channels (perhaps skip this for looking at pure
% stimulus onsets?)
% Rejected 2 components
% rejected abmornal epochs 5 stdevs (6 total)
EEG.subject = 'ZZ'; % set subject name

fdir = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\MLDebug\MagicLeapInterference\ERP\';
% Use mass univariate analysis toolbox
% https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox:_creating_GND_variables
fnamein = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs.set');
fnameout = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs-bin.set');
fnamein = strcat(fdir,'ZZ-Run3-fast.set');
fnameout = strcat(fdir,'ZZ-Run3-fast-bin.set');
[types type_count]=list_event_types(fnamein)
%  Note, if you have multiple set files per subject, you need to put the subject's codename in the EEG.subject field of the EEG variable



bin_info2EEG(fnamein,'fourbins.txt',fnameout) 
% this is just 2 bins right now, fix

% to load load synVSnonsyn.GND -MAT

% create gnd file
GND = sets2GND('gui') % choose your set file

% Plot EPS for first two bins:
 plot_wave(GND,[1 2]);
 plot_wave(GND,[3 4]);
 
% To compute the difference between targets and standards in the X/O task (i.e., Bins 2 and 1 respectively), enter the following:
GND=bin_dif(GND,2,1,'Open Eyes Goose-Duck');
GND=bin_dif(GND,4,3,'Closed Eyes Goose-Duck');
GND=bin_dif(GND,2,1,'Open Eyes Goose-Duck');
%GND=bin_dif(GND,4,3,'Closed Eyes Goose-Duck');
gui_erp(GND,'bin',3);

% Try decimating (downsampling data) to smooth things out
GND=decimateGND(GND,5,'boxcar',[-200 800]);


%% Generate plots

% Use Run 1 decimated
load Run1-4cond-down100.GND -MAT

%%
ch = [1 1];
cond = [1 2];
colors{1} = [.1 .3 .7];
colors{2} = [.7 .1 .2];
alphaval = .2;
leglabels = {'Duck', 'Goose'};
numlines = length(cond);

figure
for i = 1:numlines
LM = squeeze(GND.grands(ch(i),:,cond(i))) - squeeze(GND.grands_stder(ch(i),:,cond(i)));
UM = GND.grands(ch(i),:,cond(i)) + GND.grands_stder(ch(i),:,cond(i));

ciplot(LM,UM,GND.time_pts,colors{i},alphaval);
hold on
end
for i = 1:numlines
    plot(GND.time_pts,squeeze(GND.grands(ch(i),:,cond(i))),'Color',colors{i},'LineWidth',2);
end
