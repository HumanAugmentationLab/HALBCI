% Experimenting with paradigms that may work on ICA data

clear myapproach trainloss mymodel laststats prediction loss teststats targets
%Filter Banked CSP with epochs from .5 to 3.5. 8 different frequency bands were also selected to be processed
%{
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0.5 3.5]}, ...
           'Prediction', {'FeatureExtraction',{'FreqWindows',[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5],'TimeWindows',[]}, ...
                          'MachineLearning',{'Learner','lda'}}}
%}
myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[0 1],'FIRFilter',[2 4 47 49]}};
%myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',3}, 'FIRFilter',[2 4 47 49]}};
%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[0 4]}};
%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 3]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',3},'MachineLearning',{'learner','logreg'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0 3]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',3,'FreqWindows',[5 7;7 9;9 11;11 13;14 16;16 18;21 23]},'MachineLearning',{'learner','logreg'}}};
%myapproach = {'Spectralmeans' 'SignalProcessing',{'EpochExtraction',[0 3]},'Prediction', {'FeatureExtraction',{'FreqWindows',[4 8;8 10;10 12;12 14;14 16;16 20]},'MachineLearning',{'learner','logreg'}}};
%myapproach = {'SPoC' 'SignalProcessing',{'EpochExtraction',[0 3],'FIRFilter',[2 4 47 49]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',4},'MachineLearning',{'learner','logreg'}}};


[trainloss,mymodel,laststats] = bci_train('Data',efullcontiez,'Approach',myapproach,'TargetMarkers',{{'111' '211'},{'121' '221'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 

disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

[prediction,loss,teststats,targets] = bci_predict(mymodel,efullcontiez);
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);