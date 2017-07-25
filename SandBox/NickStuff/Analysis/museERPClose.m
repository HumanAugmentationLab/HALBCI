
%% Load Data
addpath(genpath('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/NickStuff'))
Stim1 = '151';
Stim2 = '149';
if ~exist('mytempdata','var') && ~exist('mytempdata2','var') && ~exist('mytempdata3','var')
    pathToData = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/W1MuseIntrinsic.xdf';
    pathToData2 = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/W3IntrinsicSelf.xdf';
    pathToData3 = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/W4-Intrinsic.xdf';
    traindata = reconfigSNAP(pathToData)
    mytempdata = tryFindStart(traindata,4,0);
    traindata = reconfigSNAP(pathToData2)
    mytempdata2 = tryFindStart(traindata,4,0);
    traindata = reconfigSNAP(pathToData3)
    mytempdata3 = tryFindStart(traindata,4,0);
end


%% Train
clear trainloss mymodel laststats prediction loss teststats targets myapproach
t = 1
wnds = []
for i = -0.5:.1:0.5
    wnds(t,1:2) = [i i+.1]
    t = t +1
end
%wnds = [-.25 -0.15;-.15 -.1; -.1 -.5;;0.25 0.3;0.3 0.35;0.35 0.4; 0.4 0.45;0.45 0.5;0.5 0.55;0.55 0.6]

myapproach = {'Windowmeans' 'SignalProcessing', {'EpochExtraction',{'TimeWindow',[-1 1]}, ...
    'SpectralSelection', 'off', 'ChannelSelection', {{'TP9' 'TP10'}}},...
    'Prediction', {'FeatureExtraction',{'TimeWindows',wnds},'MachineLearning',{'Learner',{'lda'}}}...
             };

%myapproach = {'Windowmeans' 'SignalProcessing',{'EpochExtraction',[0.5 1.5],'FIRFilter',[2 4 32 48],'ChannelSelection',{'TP9' 'TP10'}, 'Prediction',{'FeatureExtraction',{'PatternPairs',1},'MachineLearning',{'learner','lda'}}};

[trainloss,mymodel,laststats] = bci_train('Data',{mytempdata2 mytempdata3},'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata2);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
