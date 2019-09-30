% See openclosedERP notes for details on preprocessing. This presumes that
% data have already been preprocessed, with markers of 51(duck open),
% 52(goose open), 151 (duck closed), 152 (goose closed)

%% List file names

fdir = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\MLDebug\MagicLeapInterference\ERP\';

fnamein = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs.set'); % Run 1
fnamein = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs.set');
fnamein = strcat(fdir,'Esmerelda-Run10-Filt1to46-rej8epochs-int3ch-bin.set'); %Esmerelda run 10


% local
fdir = 'C:\Users\saman\Documents\MATLAB\TMSdataTEMP';
fnamein = strcat(fdir,'ZZ-Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs.set');

fnamein = strcat(fdir,'ZZ-Run2-ClosedOpen-Filt1to46-epochplus100closed-ica-pruned.set'); %Run2
fnamein = strcat(fdir,''); % Run 3

%% Load .set files from the run(s) you want
% do this from eeglab gui

% whatever data set is currently selected in the gui is what you will plot

%% Longer time, two datasets compared, one cond

clear yMean epochcondidx ySEM yCI95 
po = []; for a = 1:32; if (abs(EEG.chanlocs(a).theta) > 90); po= [po a];end; end
ch = [7 2 3 19];%1:32;%po;%17:32; %1:16;%
numrows = 4;
cond = [51];
leglabels = {'Human', 'Esmerelda'};
runs = [ 1 2 ]; %match alleeg
xlimvals = [-200 800];
ylimvals = [-10 10];

colors{1} = [.7 .4 .6]; %purple?
colors{2} = [.2 .7 .4]; %green?
%colors{1} = [.1 .3 .7];
%colors{2} = [.7 .1 .2];
alphaval = .2;
    


figure
for c = 1:length(ch)
    subplot(numrows,ceil(length(ch)./numrows),c)
    for r = 1:length(runs)
        % This only works if the event number is first)
        epochcondidx = [];
        for i = 1:size(ALLEEG(runs(r)).epoch,2)
            epochcondidx(i) = str2double(ALLEEG(runs(r)).epoch(i).eventtype{1});
        end
        for j = 1:length(cond)
            data = [];
            data = squeeze(ALLEEG(runs(r)).data(ch(c),:,epochcondidx==cond(j)));
            
            % Calcuate the confidence interval
        N = size(data,2);                                      % Number of ‘Experiments’ In Data Set
        yMean(j,:) = mean(data,2);                                    % Mean Of All Experiments At Each Value Of ‘x’
        ySEM = std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
        CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
        yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

        % Plot these both first.
        % Plot the confidence interval and mean
        ciplot(yCI95(1,:)+yMean(j,:),yCI95(2,:)+yMean(j,:),ALLEEG(runs(r)).times,colors{r},alphaval);
            hold on;
            
            plot(ALLEEG(runs(r)).times,mean(data,2),'Color',colors{r},'LineWidth',2);
            
        end
    end
     xline(0,'k--','LineWidth',2)
    yline(0,'k')
    xlim(xlimvals);
    ylim(ylimvals);
    set(gca,'FontSize',12)
    %legend(leglabels)
    xlabel('Time (ms)');
    ylabel('Signal (uV)');
    title(EEG.chanlocs(ch(c)).labels);
end
%legend(leglabels)

%% Make topoplots for multiple runs and times

runs = [ 1 2 ]; %match all eeg
timepoints = [0 150 230 500 660];
ylimvals = [-4 4];
figure;
i = 1;
for r = 1:length(runs)
    for t = 1:length(timepoints)
        
        subplot(length(runs),length(timepoints),i)
        
        idxtimepoint = find(ALLEEG(runs(r)).times==timepoints(t)); % Will only work if exact
        topoplot(mean(ALLEEG(runs(r)).data(:,idxtimepoint,:),3),ALLEEG(runs(r)).chanlocs,'maplimits',ylimvals,'whitebk','on','electrodes','labels')
        title(strcat(num2str(timepoints(t)),' ms'))
        cbar('vert',0,ylimvals)
        i = i+1;
        %if i == length(timepoints)+1
        %    cbar('vert',0,ylimvals)
        %    i = i+1; % 
        %end
    end
end
    
%% Two datasets, subplots, two conditions compared

clear yMean epochcondidx ySEM yCI95 
po = []; for a = 1:32; if (abs(EEG.chanlocs(a).theta) > 90); po= [po a];end; end
ch = [4 2 7 8];%2;%20;% [7 2 3 19];%1:32;%po;%17:32; %1:16;%
numrows = 2;
cond = [51 52];
leglabels = {'Standard', 'Rare'};
runs = [ 1 2 ]; %match alleeg
xlimvals = [-50 450];
ylimvals = [-10 10];
ylimvalsdiff = ylimvals;

%colors{1} = [.7 .4 .6]; %purple?
%colors{2} = [.2 .7 .4]; %green?
colors{1} = [.1 .3 .7]; % blue
colors{2} = [.7 .1 .2]; % red
colors{3} = [.5 .4 .5];
alphaval = .2;
    

for c = 1:length(ch)
    figure
    for r = 1:length(runs)
        subplot(numrows,2,r)

        % This only works if the event number is first)
        epochcondidx = [];
        for i = 1:size(ALLEEG(runs(r)).epoch,2)
            epochcondidx(i) = str2double(ALLEEG(runs(r)).epoch(i).eventtype{1});
        end
        for j = 1:length(cond)
            data = [];
            data = squeeze(ALLEEG(runs(r)).data(ch(c),:,epochcondidx==cond(j)));
            
            % Calcuate the confidence interval
            N = size(data,2);                                      % Number of ‘Experiments’ In Data Set
            yMean(j,:) = mean(data,2);                                    % Mean Of All Experiments At Each Value Of ‘x’
            ySEM = std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
            CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
            yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

            % Plot these both first.
            % Plot the confidence interval and mean
            ciplot(yCI95(1,:)+yMean(j,:),yCI95(2,:)+yMean(j,:),ALLEEG(runs(r)).times,colors{j},alphaval);
            hold on;
                
        end
        xline(0,'k--','LineWidth',2)
        yline(0,'k')
        for j = 1:length(cond)
            plot(ALLEEG(runs(r)).times,yMean(j,:),'Color',colors{j},'LineWidth',2);
        end
        xlim(xlimvals);
        ylim(ylimvals);
        set(gca,'FontSize',12)
        %legend(leglabels)
        xlabel('Time (ms)');
        ylabel('Signal (uV)');
        title(EEG.chanlocs(ch(c)).labels);
    end
    
  
    % Make difference plots
    for r = 1:length(runs)
        subplot(numrows,2,r+2)
        clear ySEM CI95 yCI95
        
        % This only works if the event number is first)
        epochcondidx = [];
        for i = 1:size(ALLEEG(runs(r)).epoch,2)
            epochcondidx(i) = str2double(ALLEEG(runs(r)).epoch(i).eventtype{1});
        end

        econdidx1 =  epochcondidx==cond(1);
        econdidx2 = epochcondidx==cond(2);
        allchcond1 = mean(ALLEEG(runs(r)).data(ch(c),:,econdidx1),3);
        allchcond2 = mean(ALLEEG(runs(r)).data(ch(c),:,econdidx2),3);
        allchdiff = allchcond2 - allchcond1;
        varchcond1 = var(ALLEEG(runs(r)).data(ch(c),:,econdidx1),0,3);
        varchcond2 = var(ALLEEG(runs(r)).data(ch(c),:,econdidx2),0,3);
        ySEM = sqrt((varchcond1./sum(econdidx1)) + (varchcond2./sum(econdidx2)));
        %ySEM = sqrt(std(data,0,2)'/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
        CI95 = tinv([0.025 0.975], N-2);                    % Calculate 95% Probability Intervals Of t-Distribution
        yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

        % Record in shared matrix
        AcrossRunsGDmeandiffOpen(r,ch(c),:) = allchdiff;
        AcrossRunsGD95diffOpen(r,ch(c),:,:) = yCI95;

        % Plot these both first.
        % Plot the confidence interval and mean
        ciplot(yCI95(1,:)+allchdiff,yCI95(2,:)+allchdiff,ALLEEG(runs(r)).times,colors{3},alphaval);
        hold on  

        plot(ALLEEG(runs(r)).times,allchdiff,'Color',colors{3},'LineWidth',2)
        hold on;
        xline(0,'k--','LineWidth',2)
        yline(0,'k')

        xlim(xlimvals);
        ylim(ylimvalsdiff);
        %grid on
        set(gca,'FontSize',12)
        %legend(leglabels)
        xlabel('Time (ms)');
        ylabel('Rare minus Standard (uV)');
        title(EEG.chanlocs(ch(c)).labels);
    end
end
%legend(leglabels)


%% Make topoplots for multiple conditions and times

runs = [ 2 ]; %match all eeg
cond = [51 52];
timepoints = [110 140 330 380];%[110 120 150 230 250 330 380];
ylimvals = [-4 4];


for r = 1:length(runs)
    figure
    i = 1;
    bothcond = []
    for j = 1:length(cond)
        % This only works if the event number is first)
        epochcondidx = [];
        for q = 1:size(ALLEEG(runs(r)).epoch,2)
            epochcondidx(q) = str2double(ALLEEG(runs(r)).epoch(q).eventtype{1});
        end
        
        for t = 1:length(timepoints)

            subplot(length(cond),length(timepoints),i)

            idxtimepoint = find(ALLEEG(runs(r)).times==timepoints(t)); % Will only work if exact
            bothcond(j,:) = mean(ALLEEG(runs(r)).data(:,idxtimepoint,epochcondidx==cond(j)),3);
            topoplot(bothcond(j,:),ALLEEG(runs(r)).chanlocs,'maplimits',ylimvals,'whitebk','on','electrodes','labels')
            title(strcat(num2str(timepoints(t)),' ms'))
            %cbar('vert',0,ylimvals)
            
            %if i == length(timepoints)+1
            %    cbar('vert',0,ylimvals)
            %    i = i+1; % 
            %end
%             if j == 2 % if second condition
%                 subplot(length(cond)+1,length(timepoints),i+length(timepoints))
%                 topoplot(bothcond(2,:)-bothcond(1,:),ALLEEG(runs(r)).chanlocs,'maplimits',ylimvals,'whitebk','on','electrodes','labels')
%        
%             end
            i = i+1;
        end
    end
end
