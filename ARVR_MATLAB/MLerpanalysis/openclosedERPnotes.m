% Load open and closed from 20190823113301_ZZ-MagicLeapDuckyOpenClosed-1-Open_RECORD.easy
% 


% Chop extra
%EEG = pop_select(EEG,'time',[26 589]) % run 1
EEG = pop_select(EEG,'time',[23 570]) % run 3


% High pass filter at 1 hz
% Low pass filter at 46 Hz
EEG = eeg_checkset(EEG, 'makeur') % need to create ur for later.


%Change the markers to have plus 100 for eyes closed condition... then put
%this back into EEG file
idxofclosed = 490;
idxofclosed = 490; %run 3
idxofclosed = 488
% if open first
for i = idxofclosed:length(EEG.event) % replace with finding 100 then 10
    EEG.event(i).type = num2str(str2double(EEG.event(i).type)+100);
    display(str2double(EEG.event(i).type)+100)
end

idxofclosed = 488; %run 2
for i = 1:idxofclosed % replace with finding 100 then 10
    EEG.event(i).type = num2str(str2double(EEG.event(i).type)+100);
    display(str2double(EEG.event(i).type)+100)
end


% Epoch using 51 52 151 152\
% Downsample here to 100 hz
% Do baseline correction for whole epoch after downsample


% Interpolate to remove t8
%skip: Autoreject w/ kurtosis F4, FC2, AF3 need to remove t8

% Run 9 - rejected 20 trials (mostly from eyes open) before ica

% Interpolated channel T8
% Run ICA on 32 after epoch
% Run ICA - reject eye channels (perhaps skip this for looking at pure
% stimulus onsets?)
% Rejected 2 components (same for run 3)
% rejected improbable data epochs 5 stdevs (6 total) (15 total in run 3)

EEG.subject = 'ZZ'; % set subject name

fdir = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\MLDebug\MagicLeapInterference\ERP\';
% Use mass univariate analysis toolbox
% https://openwetware.org/wiki/Mass_Univariate_ERP_Toolbox:_creating_GND_variables
fnamein = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs.set');
fnameout = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs-bin.set');
%fnamein = strcat(fdir,'ZZ-Run3-fast.set');
%fnameout = strcat(fdir,'ZZ-Run3-fast-bin.set');
fnamein = 'ZZ-Run3-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej15epochs.set'

% Run 2 has not had ica removed... was creating artifacts. Can remove
% trials and try again. Removed 23 trials, then reran ica

[types type_count]=list_event_types(fnamein)
%  Note, if you have multiple set files per subject, you need to put the subject's codename in the EEG.subject field of the EEG variable

%%

% Create files with things organized into bins.
bin_info2EEG(fnamein,'fourbins.txt',fnameout) 

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


%% Loading group data.. this is only one subject though

% Use Run 1 decimated
load Run1-4cond-down100.GND -MAT
% This only saves the average, so need to back up a step to do individual
% subject analysis. Can use this grou group analysis someday.

%% Load individual data and create plots

pop_loadset('K:\EEGdata\EnobioTests\MLDebug\MagicLeapInterference\ERP\ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs.set')
% Resampled to 100 hz
% Then baseline corrected again over whole time

%% Find relevant event indices and make one plot 

ch = [1 1];
cond = [51 52];

% This only works if the event number is first)
for i = 1:size(EEG.epoch,2)
    epochcondidx(i) = str2double(EEG.epoch(i).eventtype{1});
end

colors{1} = [.1 .3 .7];
colors{2} = [.7 .1 .2];
alphaval = .2;
leglabels = {'Duck', 'Goose'};

for j = 1:length(cond)
    data = [];
    data = squeeze(EEG.data(ch(j),:,epochcondidx==cond(j)));

% Calcuate the confidence interval
    N = size(data,2);                                      % Number of ‘Experiments’ In Data Set
    yMean(j,:) = mean(data,2);                                    % Mean Of All Experiments At Each Value Of ‘x’
    ySEM = std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
    CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
    yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

    % Plot these both first.
    % Plot the confidence interval and mean
    ciplot(yCI95(1,:)+yMean(j,:),yCI95(2,:)+yMean(j,:),EEG.times,colors{j},alphaval);
    hold on   
end
xline(0,'k--','LineWidth',2)

for j = 1:length(cond)
    plot(EEG.times,yMean(j,:),'Color',colors{j},'LineWidth',2);
end

set(gca,'FontSize',14)
legend(leglabels)
xlabel('Time (ms)');
ylabel('Signal (uV)');

%% Make subplots of each channel
clear yMean epochcondidx ySEM yCI95 
po = []; for a = 1:32; if (abs(EEG.chanlocs(a).theta) > 90); po= [po a];end; end
ch = po;%17:32; %1:16;%
numrows = 4;
cond = [51 52];
leglabels = {'Duck', 'Goose'};
xlimvals = [-50 450];% [-200 800];

ylimvals = [-10 14];

colors{1} = [.1 .3 .7];
colors{2} = [.7 .1 .2];
alphaval = .2;
    
% This only works if the event number is first)
for i = 1:size(EEG.epoch,2)
    epochcondidx(i) = str2double(EEG.epoch(i).eventtype{1});
end

figure
for c = 1:length(ch)
    subplot(numrows,ceil(length(ch)./numrows),c)
    for j = 1:length(cond)
        data = [];
        data = squeeze(EEG.data(ch(c),:,epochcondidx==cond(j)));

    % Calcuate the confidence interval
        N = size(data,2);                                      % Number of ‘Experiments’ In Data Set
        yMean(j,:) = mean(data,2);                                    % Mean Of All Experiments At Each Value Of ‘x’
        ySEM = std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
        CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
        yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

        % Plot these both first.
        % Plot the confidence interval and mean
        ciplot(yCI95(1,:)+yMean(j,:),yCI95(2,:)+yMean(j,:),EEG.times,colors{j},alphaval);
        hold on   
    end
    xline(0,'k--','LineWidth',2)
    yline(0,'k')

    for j = 1:length(cond)
        plot(EEG.times,yMean(j,:),'Color',colors{j},'LineWidth',2);
    end
    xlim(xlimvals);
    ylim(ylimvals);
    %grid on
    set(gca,'FontSize',12)
    %legend(leglabels)
    xlabel('Time (ms)');
    ylabel('Signal (uV)');
    title(EEG.chanlocs(ch(c)).labels);
end

%% Make topoplots for each condition

timepoints = [130 80];
ylimvals = [-10 10];

for j = 1:length(cond)
    for t = 1:length(timepoints)
        figure
        idxtimepoint = find(EEG.times==timepoints(t)); % Will only work if exact
        topoplot(mean(EEG.data(:,idxtimepoint,epochcondidx==cond(j)),3),EEG.chanlocs,'maplimits',ylimvals,'whitebk','on','electrodes','labels')
        title(strcat(leglabels{j}, ' at time = ', num2str(timepoints(t)),' ms'))
        cbar('vert',0,ylimvals)
    end
end

%% Difference topo
     
for t = 1:length(timepoints)
        figure
        idxtimepoint = find(EEG.times==timepoints(t)); % Will only work if exact
        topoplot(mean(EEG.data(:,idxtimepoint,epochcondidx==cond(2)),3)-mean(EEG.data(:,idxtimepoint,epochcondidx==cond(1)),3),EEG.chanlocs,'maplimits',ylimvals,'whitebk','on','electrodes','labels')
        title(strcat(leglabels{2},' minus ', leglabels{1}, ' at time = ', num2str(timepoints(t)),' ms'))
        cbar('vert',0,ylimvals)
end


%% Make difference plots
po = []; for a = 1:32; if (abs(EEG.chanlocs(a).theta) > 90); po= [po a];end; end
ch = po; %1:16;%17:32; %1:16;%
cond = [51 52];
leglabels = {'Duck', 'Goose'};
xlimvals = [-50 450];
ylimvals = [-10 10];
colors{3} = [.5 .4 .5];

% This only works if the event number is first)
for i = 1:size(EEG.epoch,2)
    epochcondidx(i) = str2double(EEG.epoch(i).eventtype{1});
end

figure
for c = 1:length(ch)
    clear ySEM CI95 yCI95
    subplot(numrows,ceil(length(ch)./numrows),c)
    
    econdidx1 =  epochcondidx==cond(1);
    econdidx2 = epochcondidx==cond(2);
    allchcond1 = mean(EEG.data(ch(c),:,econdidx1),3);
    allchcond2 = mean(EEG.data(ch(c),:,econdidx2),3);
    allchdiff = allchcond2 - allchcond1;
    varchcond1 = var(EEG.data(ch(c),:,econdidx1),0,3);
    varchcond2 = var(EEG.data(ch(c),:,econdidx2),0,3);



    ySEM = sqrt((varchcond1./sum(econdidx1)) + (varchcond2./sum(econdidx2)));
    %ySEM = sqrt(std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
    CI95 = tinv([0.025 0.975], N-2);                    % Calculate 95% Probability Intervals Of t-Distribution
    yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

    
    % Record in shared matrix
    AcrossRunsGDmeandiffOpen(runnum,ch(c),:) = allchdiff;
    AcrossRunsGD95diffOpen(runnum,ch(c),:,:) = yCI95;
    
    % Plot these both first.
    % Plot the confidence interval and mean
    ciplot(yCI95(1,:)+allchdiff,yCI95(2,:)+allchdiff,EEG.times,colors{3},alphaval);
    hold on  

    plot(EEG.times,allchdiff,'Color',colors{3},'LineWidth',2)
    hold on;
    xline(0,'k--','LineWidth',2)
        yline(0,'k')

    xlim(xlimvals);
    ylim(ylimvals);
    %grid on
    set(gca,'FontSize',12)
    %legend(leglabels)
    xlabel('Time (ms)');
    ylabel('Signal Difference (uV)');
    title(EEG.chanlocs(ch(c)).labels);

    
end

%% Make subplots of each channel  combine for 51 and 52
ch = 1:16;%17:32; %1:16;%
numrows = 4;
cond = [51]% 52];
xlimvals = [-200 800];

ylimvals = [-10 10];

colors{1} = [.1 .3 .7];
    colors{2} = [.7 .1 .2];
    alphaval = .2;
    %leglabels = {'Duck', 'Goose'};


% This only works if the event number is first)
for i = 1:size(EEG.epoch,2)
    epochcondidx(i) = str2double(EEG.epoch(i).eventtype{1});
end

figure
for c = 1:length(ch)
    subplot(numrows,ceil(length(ch)./numrows),c)
    
    for j = 1:length(cond)
        data = [];
        data = squeeze(EEG.data(ch(c),:,:));

    % Calcuate the confidence interval
        N = size(data,2);                                      % Number of ‘Experiments’ In Data Set
        yMean(j,:) = mean(data,2);                                    % Mean Of All Experiments At Each Value Of ‘x’
        ySEM = std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
        CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
        yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

        % Plot these both first.
        % Plot the confidence interval and mean
        ciplot(yCI95(1,:)+yMean(j,:),yCI95(2,:)+yMean(j,:),EEG.times,colors{j},alphaval);
        hold on   
    end
    xline(0,'k--','LineWidth',2)
    yline(0,'k')

    for j = 1:length(cond)
        plot(EEG.times,yMean(j,:),'Color',colors{j},'LineWidth',2);
    end
    xlim(xlimvals);
    ylim(ylimvals);
    set(gca,'FontSize',12)
    %legend(leglabels)
    xlabel('Time (ms)');
    ylabel('Signal (uV)');
    title(EEG.chanlocs(ch(c)).labels);
end

%% Make topoplots

timepoints = [0 500];
ylimvals = [-10 10];

for t = 1:length(timepoints)
    figure
    idxtimepoint = find(EEG.times==timepoints(t)); % Will only work if exact
    topoplot(mean(EEG.data(:,idxtimepoint,:),3),EEG.chanlocs,'maplimits',ylimvals,'whitebk','on','electrodes','labels')
    title(strcat(num2str(timepoints(t)),' ms'))
    cbar('vert',0,ylimvals)
end

%% Generating plots
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


%% Difference plots across run
figure
for c = 1:length(ch)
    subplot(numrows,ceil(length(ch)./numrows),c)
     plot(EEG.times,squeeze(AcrossRunsGDmeandiffOpen(:,ch(c),:)),'LineWidth',2);
     hold on
     xline(0,'k--','LineWidth',2)
    yline(0,'k')
    xlim(xlimvals);
   %ylim(ylimvals);
    set(gca,'FontSize',12)
    %legend(leglabels)
    xlabel('Time (ms)');
    ylabel('Signal (uV)');
    title(EEG.chanlocs(ch(c)).labels);
end


%% Make subplots of each channel across RUNS (separate per run)
clear yMean epochcondidx ySEM yCI95 
po = []; for a = 1:32; if (abs(EEG.chanlocs(a).theta) > 90); po= [po a];end; end
ch = po;%17:32; %1:16;%
numrows = 4;
cond = [51 52];
leglabels = {'Duck', 'Goose'};
xlimvals = [-50 450];% [-200 800];

ylimvals = [-10 14];
runs = [ 1 2 4 5]; %match all eeg
colors{1} = [.1 .3 .7];
colors{2} = [.7 .1 .2];
alphaval = .2;
    
% This only works if the event number is first)
for i = 1:size(EEG.epoch,2)
    epochcondidx(i) = str2double(EEG.epoch(i).eventtype{1});
end

figure
i = 1
for c = 1:length(ch)
    subplot(numrows,ceil(length(ch)./numrows),c)
    for r = 1:length(runs)
        for j = 2:length(cond)
            data = [];
            data = squeeze(ALLEEG(runs(r)).data(ch(c),:,epochcondidx==cond(j)));
            
            plot(ALLEEG(runs(r)).times,mean(data,2),'LineWidth',2);
            hold on
            legvals{i} = strcat('Run ',num2str(runs(r)), ' - ', leglabels{j});
            i = i+1;
        end
    end
     xline(0,'k--','LineWidth',2)
    yline(0,'k')
    xlim(xlimvals);
   %ylim(ylimvals);
    set(gca,'FontSize',12)
    %legend(leglabels)
    xlabel('Time (ms)');
    ylabel('Signal (uV)');
    title(EEG.chanlocs(ch(c)).labels);
end
legend(legvals)

    
%% Notes on data
% each run seems to have different delay in markers... might drift over
% time, which could be an issue.
% probably need to do difference plots per run

% in order to reject blinks, could use a threshold of ~45 or more on ch 13
% and 17 (could add other frontal electrodes). 

% 
