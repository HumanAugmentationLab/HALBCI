%% Dependency Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;
cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\AvaMuseProcess

%% Load Data
traindata1 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W4-Intrinsic.xdf');
mytempdata1 = tryFindStart(traindata1,4,0);

traindata2 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W3IntrinsicSelf.xdf');
mytempdata2 = tryFindStart(traindata2,4,0);

traindata3 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W1MuseIntrinsic.xdf');
mytempdata3 = tryFindStart(traindata3,4,0);

traindataA1 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\C1MuseIntrinsic.xdf');
mytempdataA1 = tryFindStart(traindataA1,4,0);

% Delete any markers not keyed on onset
mytempdata1.event(8:10) = [];
mytempdata1.event(9:14) = [];
mytempdata1.event(10:12) = [];

mytempdata2.event(20:21) = [];
mytempdata2.event(21) = [];
mytempdata2.event(23:24) = [];
mytempdata2.event(37) = [];

mytempdata3.event(25) = [];
mytempdata3.event(50) = [];

%% Visually Check Data
close all; 
vis_data(mytempdata1,[2 5])
vis_data(mytempdata2,[2 5])
vis_data(mytempdata3,[2 5])

vis_data(mytempdataA1,[2 5])

%% Train
clear trainloss mymodel laststats prediction loss teststats targets myapproach
wnds = [-0.4 -0.3; -0.3 -0.2; -0.2 -0.1; -0.1 0; 0 0.1; 0.1 0.2; 0.2 0.3; 0.3 0.4];

myapproach = {'Windowmeans' 'SignalProcessing', {'EpochExtraction',{'TimeWindow',[-.4 .4]}, ...
    'SpectralSelection', 'off', 'ChannelSelection', {{'TP9' 'TP10'}}},...
    'Prediction', {'FeatureExtraction',{'TimeWindows',wnds},'MachineLearning',{'Learner',{'logreg'}}}...
             };

[trainloss,mymodel,laststats] = bci_train('Data',mytempdataA1,'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',10,5}); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata1);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
