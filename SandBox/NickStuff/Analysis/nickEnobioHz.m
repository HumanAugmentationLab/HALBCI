%This is a dirty general use script for testing out data recorded on the
%enobio


traindata = io_loadset('C:\Users\gsteelman\Desktop\SummerResearch\10v15Hz_Flashing.easy')
mytempdata = exp_eval(traindata)
mytempdataTest = refactorFunc(mytempdata,2, 9,1)
mytempdata = refactorFunc(mytempdata,2, 9,1)
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

%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[0 4]}};
%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 8]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',3},'MachineLearning',{'learner','lda'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0 1]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',3,'FreqWindows',[5 7;7 9;9 11;11 13;14 16;16 18;21 23]},'MachineLearning',{'learner','logreg'}}};
%myapproach = {'Spectralmeans' 'SignalProcessing',{'EpochExtraction',[0 8]},'Prediction', {'FeatureExtraction',{'FreqWindows',[4 8;8 12;12 16;16 20]}}};
myapproach = {'SPoC' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[8 10 14 16]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',4}}};


%myapproach = 'Spectralmeans'
%finally we train the model on the data, specifying the target markers
%[trainloss,mymodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'768','769'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true,'EvaluationMetric', 'mse'); 
[trainloss,mymodel,laststats] = bci_train('Data',mytempdata,'Approach',myapproach,'TargetMarkers',{'101','201'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

%this will display the results of the cross-validation tests
%disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
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
disp(['  predicted classes: ',num2str(round(prediction)')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
t = 0
for i = 1:length(prediction)
    if round(prediction(i)) == round(targets(i))
        t = t+1;
    end
    
    
    
end
%[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5];