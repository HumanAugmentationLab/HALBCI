
%% Load Data
offSet = 0;
epoch = 1;

clear traindata2 mytempdata2 traindata3 mytempdata3

addpath(genpath('../'));
%addpath(genpath('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/NickStuff'))

Stim1 = '151';
Stim2 = '149';
if ~exist('mytempdata','var') && ~exist('mytempdata2','var') && ~exist('mytempdata3','var')
    pathToData = 'K:\HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/W1MuseIntrinsic.xdf';
    %pathToData2 = 'K:\HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/N3MuseIntrinsic.xdf';
    %pathToData2 = 'K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\NickTest2.xdf';
    %pathToData3 = 'K:\HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/N4MuseIntrinsic.xdf';
    pathToData3 = 'K:\HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/NickTest.xdf';
    traindata = reconfigSNAP(pathToData);
    mytempdata2 = tryFindStart(traindata,4,0); %W1
    %traindata2 = reconfigSNAP(pathToData2);
    %mytempdata2 = tryFindStart(traindata2,3,0);
    traindata3 = reconfigSNAP(pathToData3);
    mytempdata3 = tryFindStart(traindata3,4,0);
end


%% Train
%
clear trainloss mymodel laststats prediction loss teststats targets myapproach
t = 1;
wnds = [];
for i = -.5:.1:.5
    wnds(t,1:2) = [i i+.1];
    t = t +1;
end
%wnds = [-.25 -0.15;-.15 -.1; -.1 -.5;;0.25 0.3;0.3 0.35;0.35 0.4; 0.4 0.45;0.45 0.5;0.5 0.55;0.55 0.6]

myapproach = {'Windowmeans' 'SignalProcessing', {'FIRFilter',[1 2 16 24],'EpochExtraction',{'TimeWindow',[-.5 .6]}, ...
    'SpectralSelection', 'off', 'ChannelSelection', {{'TP9' 'TP10'}}},...
    'Prediction', {'FeatureExtraction',{'TimeWindows',wnds},'MachineLearning',{'Learner',{'logreg'}}}...
             };

%myapproach = {'Windowmeans' 'SignalProcessing',{'EpochExtraction',[0.5 1.5],'FIRFilter',[2 4 32 48],'ChannelSelection',{'TP9' 'TP10'}, 'Prediction',{'FeatureExtraction',{'PatternPairs',1},'MachineLearning',{'learner','lda'}}};
[trainloss,mymodel,laststats] = bci_train('Data',{mytempdata2},'Approach',myapproach,'TargetMarkers',{Stim1,Stim2},'EvaluationMetric', 'mse','EvaluationScheme',0); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata3);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
%disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
%disp(['  true classes     : ',num2str(round(targets)')]);
%}


%% Sam model
clear trainloss laststats myapproach predition loss teststats targets mymodelsam myapproach

t = 1;
wnds = [];
for i = -.5:.1:.5
    wnds(t,1:2) = [i i+.1];
    t = t +1;
end

myapproach = {'Windowmeans' 'SignalProcessing', {'BaselineRemoval',[-5.6 -0.6],'EpochExtraction',{'TimeWindow',[-.5 .6]}, ...
    'SpectralSelection', 'off', 'ChannelSelection', {{'TP9' 'TP10'}}},...
    'Prediction', {'FeatureExtraction',{'TimeWindows',wnds},'MachineLearning',{'Learner',{'logreg'}}}...
             };


[trainloss,mymodelsam,laststats] = bci_train('Data',{mytempdata2},'Approach',myapproach,'TargetMarkers',{Stim1,Stim2},'EvaluationMetric', 'mse','EvaluationScheme',0); 
[prediction,loss,teststats,targets] = bci_predict(mymodelsam,mytempdata3);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);


%% Load 2
StimArr = {'149','151','0','200'};
StimArr2 = {'151','149','0','200'};
%myrefacdata = refactorMarkersVariable(mytempdata,offSet,epoch,StimArr,StimArr2);
%myrefacdata2 = refactorMarkersVariable(mytempdata2,offSet,epoch,StimArr,StimArr2);
myrefacdata3 = refactorMarkersVariable(mytempdata3,offSet,epoch,StimArr,StimArr2);
myrefacdata2 = refactorMarkersVariable(mytempdata2,offSet,epoch,StimArr,StimArr2);


%% Train 2
%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[1.5 s3.5],'FIRFilter',[8 12 16 32]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2,'FreqWindows',[8 12;16 32;35 45]},'MachineLearning',{'learner','lda'}}};
t = 1;
Freqwnds = [];
span = 8
for i = 2:span:47
    Freqwnds(t,1:2) = [i i+span];
    t = t +1;
end



myapproach = {'Spectralmeans' 'SignalProcessing',{'FIRFilter',[2 4 47 49],'EpochExtraction',[0 1],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}},'Prediction', {'FeatureExtraction',{'FreqWindows',[2 6;8 12;16 32;40 50]},'MachineLearning',{'Learner',{'logreg'}}}};
myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[2 4 47 49],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','logreg'}}};
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[2 4 47 49]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2,'FreqWindows',Freqwnds},'MachineLearning',{'learner','logreg'}}};
%myapproach = 'Spectralmeans'
%finally we train the model on the data, specifying the target markers
%[trainloss,mymodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'768','769'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true,'EvaluationMetric', 'mse'); 
[trainloss,mymodel2,laststats] = bci_train('Data',{myrefacdata3},'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

%this will display the results of the cross-validation tests
%disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
%this will visualize the results of the csp for this case
%laststats
%bci_visualize(lastmodel)
%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
%annotateData = bci_annotate(lastmodel, mydata)
[prediction,loss,teststats,targets] = bci_predict(mymodel2,myrefacdata2);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
[prediction,loss,teststats,targets] = bci_predict(mymodel2,myrefacdata3);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
%disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
%disp(['  true classes     : ',num2str(round(targets)')]);