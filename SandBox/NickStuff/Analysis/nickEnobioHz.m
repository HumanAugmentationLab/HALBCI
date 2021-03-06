%This is a dirty general use script for testing out data recorded on the
%enobio
addpath(genpath('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/NickStuff'))


%pathToData = '/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727114720_PatientW1-8v15_Record.easy';
pathToData = '/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727113703_PatientW1-12v15_Record.easy';
%pathToData = '/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727112030_PatientW1-15v20_Record.easy';
% 20170806165229_PatientW1-12v15-medium.easy
% 20170806164107_PatientW1-7.5v12-small.easy
% 20170806162852_PatientW1-12v30-small.easy
% 20170806161942_PatientW1-15v20-big.easy
% 20170806160959_PatientW1-7.5v12-big.easy
% 20170806154747_PatientW1-7.5v12-small.easy
% 20170806153807_PatientW1-15v20-small.easy
% 20170806152814_PatientW1-7.5v12-small.easy
% 20170806151821_PatientW1-7.5v20-small.easy
% 20170806150345_PatientW1-15v20-small.easy

traindata = io_loadset(pathToData)
%mytempdata = exp_eval(traindata)
mytempdatat = sez


mytempdataTest = refactorFunc(mytempdatat,1, 9,3);
mytempdata2 = refactorFunc(mytempdatat,1, 9,3);
%mytempdata2 = tryFindStart(traindata2,3,0);
%here we specifiy the approach to detangle the data
%this one is Filter Banked CSP with epochs from .5 to 3.5. 8 different
%frequency bands were also selected to be processed
%{
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0.5 3.5]}, ...
           'Prediction', {'FeatureExtraction',{'FreqWindows',[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5],'TimeWindows',[]}, ...
                          'MachineLearning',{'Learner','lda'}}}
%}
%myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[1.5 3.5],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2}}};
myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[0 1],'FIRFilter',[2 4 47 49]}};

%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[0 4]}};
%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 3]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',3},'MachineLearning',{'learner','logreg'}}};
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0 3]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',3,'FreqWindows',[5 7;7 9;9 11;11 13;14 16;16 18;21 23]},'MachineLearning',{'learner','logreg'}}};
%myapproach = {'Spectralmeans' 'SignalProcessing',{'EpochExtraction',[0 3]},'Prediction', {'FeatureExtraction',{'FreqWindows',[4 8;8 10;10 12;12 14;14 16;16 20]},'MachineLearning',{'learner','logreg'}}};
%myapproach = {'SPoC' 'SignalProcessing',{'EpochExtraction',[0 3],'FIRFilter',[2 4 47 49]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',4},'MachineLearning',{'learner','logreg'}}};


%myapproach = 'Spectralmeans'
%finally we train the model on the data, specifying the target markers
%[trainloss,mymodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'768','769'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true,'EvaluationMetric', 'mse'); 
[trainloss,mymodel,laststats] = bci_train('Data',mytempdata2,'Approach',myapproach,'TargetMarkers',{{'111' '211'},{'121' '221'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 

%this will display the results of the cross-validation tests
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
%this will visualize the results of the csp for this case
%laststats
%bci_visualize(lastmodel)
%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
%annotateData = bci_annotate(lastmodel, mydata)
[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdataTest);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
%disp(['  predicted classes: ',num2str(round(prediction)')]);  % class probabilities * class values
%disp(['  true classes     : ',num2str(round(targets)')]);

%[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5];