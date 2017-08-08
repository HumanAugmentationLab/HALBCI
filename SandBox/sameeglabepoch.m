%easy file seems to have wrong channel labels
% .edf has right channel labels, but wrong events
% quick cheat: load edf file and copy the hannel locs from that
if ~exist('xd','var')
    a = io_loadset('C:\Users\gsteelman\Desktop\SummerResearch\10v15Hz_Flashing.edf','channels',1:8)
    xd = exp_eval(a)
end


if ~exist('eaz2','var')
    a = io_loadset('C:\Users\gsteelman\Desktop\SummerResearch\10v15Hz_Flashing.easy','channels',1:8)
    eaz2 = exp_eval(a)
end
eaz2.chanlocs = xd.chanlocs; % Replace channel locations
%NOTE: I CHANGED A SETTING IN eegfilt! I changed the default from "firls"
%to "firl". If not changed, it will give bad data
feaz2 = pop_eegfilt(eaz2,.1,56); %filter between .1 and 56
neaz2 = pop_epoch(feaz2,{'101' '201'},[-1 9]); %events '101' '201' time from 0 to 9 s
left10hz2 = pop_selectevent(neaz2,'type','101'); % select event type '101', remove others
right15hz2 = pop_selectevent(neaz2,'type','201'); % select event type '201', remove others

%% Set which data you're lookin at
left = left10hz2;
right = right15hz2;
pop_timtopo(left)
pop_timtopo(right)

%% Plot spectr
figure; pop_spectopo(left, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [7 11 15], 'freqrange',[2 25],'electrodes','on');
figure; pop_spectopo(right, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [7 11 15], 'freqrange',[2 25],'electrodes','on');

%% Plot time freq
figure; pop_newtimef( left, 1, 1, [0  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'O1', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);
figure; pop_newtimef( right, 1, 1, [0  8998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'O1', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);


%figure; pop_newtimef( left6hz2, 1, 4, [0  8998], [3         0.5] , 'topovec', 4, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline',[0], 'freqs', [[2 16]], 'plotphase', 'off', 'padratio', 1);


%% Freq analysis for trials
selchan  = 4;
figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot tdata] = newtimef(left.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 9);
% tdata is the freq for each trial
tdatapower = abs(tdata).^2;

figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot righttdata] = newtimef(right.data(selchan,:,:), 4500,[0  8998],500, [3  0.5] , 'freqs', [[2 16]],'nfreqs',8,'ntimesout', 9);
righttdatapower = abs(righttdata).^2;

% Histogram of freq power
selfreq = 4; %index in freq variable
figure
tempdata = [reshape(tdatapower(selfreq,:,:),size(tdatapower,2)*size(tdatapower,3),1)...
    reshape(righttdatapower(selfreq,:,:),size(tdatapower,2)*size(tdatapower,3),1)];
hist(tempdata,10)
xlim([0 5e5])
title(num2str(freqs(selfreq)))

%% Compare
figure; [ersp,itc,powbase,times,freqs,erspboot,itcboot tdata] = newtimef({left.data(selchan,:,:) right.data(selchan,:,:)}, 4500,[0  8998],500, [3  0.5] , 'freqs', [[4 18]],'nfreqs',2,'ntimesout', 4);

%%
td = io_loadset('C:\Users\smichalka\Documents\NIC\20170718150546_Patient017_Start.easy')
d = exp_eval(td)
%%
td1 = io_loadset('C:\Users\smichalka\Documents\NIC\20170718152739_Patient018_Start.easy')
d1 = exp_eval(td1)
%%
td2 = io_loadset('C:\Users\smichalka\Documents\NIC\20170718154026_Patient018_Start.easy')
d2 = exp_eval(td2)

%%
td3 = io_loadset('C:\Users\smichalka\Documents\NIC\20170718161317_PatientH1.easy')
d3 = exp_eval(td3)
%%
td4 = io_loadset('C:\Users\smichalka\Documents\NIC\20170718163008_PatientH1.easy')
d4 = exp_eval(td4)

%%
%td5 = io_loadset('K:HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W1MuseExtrinsic.xdf')
%d5 = exp_eval(td5)
td5 = reconfigSNAP('K:HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W1MuseExtrinsic.xdf');
d5 = tryFindStart(td5,4,0);

%%
%td5 = io_loadset('K:HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W1MuseExtrinsic.xdf')
%d5 = exp_eval(td5)
td6 = reconfigSNAP('K:HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W2MuseExtrinsic.xdf');
d6 = tryFindStart(td6,4,0);

%%
td7 = reconfigSNAP('K:HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W1MuseIntrinsic.xdf');
d7 = tryFindStart(td7,4,0);

%%
td8 = reconfigSNAP('C:\Recordings\CurrentStudy\subj1\W3IntrinsicSelf.xdf');
% ntd8 = td8; % Trim off beginning and add in a little buffer
% ntd8.data = td8.data(:,17000:end);
% ntd8.data = [ntd8.data(:,1:2000) ntd8.data];
% ntd8.pnts = size(ntd8.data,2);
% ntd8.times = ntd8.times(1:ntd8.pnts);
d8 = tryFindStart(td8,4,0);
%%
td9 = reconfigSNAP('C:\Recordings\CurrentStudy\subj1\W4-Intrinsic.xdf');
d9 = tryFindStart(td9,4,0);
  

%%
td10 = io_loadset('C:\Users\smichalka\Documents\NIC\20170720140844_PatientW5.easy')
d10 = exp_eval(td10)
%%
datatouse = d9;
datatotest = d9;
%%
figure
plot(datatouse.data(2,:)','LineWidth',1);
hold on
for i = 1:length(datatouse.event)
    plot(datatouse.event(i).latency,50,'ks')
end
%%
figure
plot(datatouse.data(2,:)','LineWidth',1);
hold on
for i = 1:length(datatouse.event)
    if str2num(datatouse.event(i).type) == 149
        plot([datatouse.event(i).latency datatouse.event(i).latency],[0 2000],'c--','LineWidth',1);
    elseif str2num(datatouse.event(i).type) == 151
        plot([datatouse.event(i).latency datatouse.event(i).latency],[0 2000],'m--','LineWidth',1);
    end
end
%%
clear myapproach trainloss mymodel laststats prediction loss teststats targets 

% {'TP9' 'FP1' 'FP2' 'TP10'}
%myapproach = {'SpecCSP' ...
%    'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'P7' 'P4' 'Cz' 'Pz'}}},...
%    'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
% 
% myapproach = {'SpecCSP' ...
%     'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[2 14 16 32],'ChannelSelection',{{'P7' 'P4' 'Cz' 'Pz'}}},...
%     'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};


myapproach = {'Windowmeans' ...
    'SignalProcessing', { ...
        'MovingAverage', 'on' ...
        'BaselineRemoval', { ...
            'BaselineWindow', 8} ...
        'WindowSelection', 'on','ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}},...
    'Prediction', { ...
        'FeatureExtraction', { ...
            'TimeWindows', [-2 -1;-0.15 -0.1;-0.1 -0.05;-0.05 0]}}}
   
    

%'ChannelSelection',{{'P7' 'P4' 'Cz' 'Pz'}}}


myapproach = {'SpecCSP' ...
    'SignalProcessing',{'EpochExtraction',[0 2],'FIRFilter',[.1 .5 32 48],'ChannelSelection',{{'P7' 'P4' 'Cz' 'Pz'}}},...
    'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};



myapproach = {'Windowmeans' ...
    'SignalProcessing', { ...
        'EpochExtraction', { ...
            'TimeWindow', [2 0]} ...
        'SpectralSelection', { ...
            'FrequencySpecification', [0.1 30]}} ...
    'Prediction', { ...
        'FeatureExtraction', { ...
            'TimeWindows', [-2 -1;-0.15 -0.1;-0.1 -0.05;-0.05 0]}}}

myapproach =         {'Windowmeans' ...
    'SignalProcessing', { ...
        'MovingAverage', 'on' ...
        'BaselineRemoval', { ...
            'BaselineWindow', 8} ...
        'WindowSelection', 'on'}}

    {'TP9' 'FP1' 'FP2' 'TP10'}
    
    %%
  myapproach =   {'Windowmeans' ...
    'SignalProcessing', { ...
        'AdaptiveZscore', { ...
            'Verbosity', true} ...
        'MovingAverage', 'on' ...
        'ChannelSelection', { ...
            'Channels', {{'TP9' 'FP1' 'FP2' 'TP10'}}} ...
        'EpochExtraction', { ...
            'TimeWindow', [-1.28 1.28]} ...
        'BaselineRemoval', { ...
            'BaselineWindow', 10}},...
            }
 %%   
 
 myapproach =   {'Windowmeans' ...
    'SignalProcessing', { ...
        'MovingAverage', 'on' ...
        'ChannelSelection', { ...
            'Channels', {'{''TP9'' ''FP1'' ''FP2'' ''TP10''}'}} ...
        'EpochExtraction', { ...
            'TimeWindow', [-1.28 1.28]} ...
        },...
            }
 
 %%
[trainloss,mymodel,laststats] = bci_train('Data',datatouse,'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',0); 
%%
[prediction,loss,teststats,targets] = bci_predict(mymodel,datatotest);


%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
