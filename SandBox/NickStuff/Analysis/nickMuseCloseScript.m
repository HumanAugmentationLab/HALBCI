%First we load the data set into matlab with io_loadset()
%{
traindata = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\onlySnap4.xdf');
traindata2 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\onlySnap5.xdf');
traindata3 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\onlySnapLong.xdf');

mytempdata = tryFindStart(traindata,3,0);
mytempdata = refactorFunc(mytempdata,1.5,3.5);
mytempdata2 = tryFindStart(traindata2,3,0);
mytempdata2 = refactorFunc(mytempdata2,1.5,3.5);
mytempdata3 = tryFindStart(traindata3,3,0);
mytempdata3 = refactorFunc(mytempdata3,3,15);
%}
%{
traindata = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\sabrinaOpen.xdf');
traindata2 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\sabrinaOpen2.xdf');
mytempdata = tryFindStart(traindata,3,14000);
mytempdata2 = tryFindStart(traindata2,3,0);
%}
%
traindata = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\ALClosed6Min.xdf');
mytempdata = tryFindStart(traindata,3,0);
traindata2 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\psychOpen2.xdf');
mytempdata2 = tryFindStart(traindata2,3,0);
traindata3 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\psychOpen3.xdf');
mytempdata3 = tryFindStart(traindata3,3,0);

mytempdata = refactorFunc(mytempdata,1, 3.5,.5)
mytempdata2 = refactorFunc(mytempdata2,1, 3.75,.5)
mytempdata3 = refactorFunc(mytempdata3,1, 3.75,.5)
%}
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
%myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[1.5 3.5],'FIRFilter',[7 8 28 32]}};

%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[1.5 4.5],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}};
myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[1.5 s3.5],'FIRFilter',[8 12 16 32]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2,'FreqWindows',[8 12;16 32;35 45]},'MachineLearning',{'learner','lda'}}};
%myapproach = {'Spectralmeans' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[search(1.5:.5:3),search(4:.5:4.5)],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}},'Prediction', {'FeatureExtraction',{'FreqWindows',[2 6;8 12;28 32]}}};

%myapproach = 'Spectralmeans'
%finally we train the model on the data, specifying the target markers
%[trainloss,mymodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'768','769'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true,'EvaluationMetric', 'mse'); 
[trainloss,mymodel,laststats] = bci_train('Data',mytempdata,'Approach',myapproach,'TargetMarkers',{'Closed','Open'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

%this will display the results of the cross-validation tests
%disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
%this will visualize the results of the csp for this case
%laststats
%bci_visualize(lastmodel)
%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
%annotateData = bci_annotate(lastmodel, mydata)
[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
%[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5];