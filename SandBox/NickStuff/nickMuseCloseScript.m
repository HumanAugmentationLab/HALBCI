%First we load the data set into matlab with io_loadset()
traindata = preprocess('C:\Users\gsteelman\Desktop\SummerResearch\bob4.xdf');
traindata2 = preprocess('C:\Users\gsteelman\Desktop\SummerResearch\bob6.xdf');
traindata3 =preprocess('C:\Users\gsteelman\Desktop\SummerResearch\bob7.xdf');
%mydata = exp_eval(traindata);
%answer = refactorFunc(mydata);
%{
for i = 1:length(mydata.event)
    if length(answer(:,1))>i
        mydata.event(i).type = char(answer(i,1));
        mydata.event(i).latency = cell2mat(answer(i,2));
        mydata.event(i).urevent = cell2mat(answer(i,3));
        mydata.urevent(i).type = char(answer(i,1));
        mydata.urevent(i).latency = cell2mat(answer(i,2));
    else
        break
    end
end
%}
%here we specifiy the approach to detangle the data
%this one is Filter Banked CSP with epochs from .5 to 3.5. 8 different
%frequency bands were also selected to be processed
%{
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0.5 3.5]}, ...
           'Prediction', {'FeatureExtraction',{'FreqWindows',[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5],'TimeWindows',[]}, ...
                          'MachineLearning',{'Learner','lda'}}}
%}
%myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[1.5 4.5],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2}}};
%myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[1.5 3.5],'FIRFilter',[7 8 28 32]}};

%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[1.5 4.5],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}};
myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[1.5 3.5],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[1.5 3.5],'FIRFilter',[8 12 16 32]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2,'FreqWindows',[8 12;16 32]},'MachineLearning',{'learner','lda'}}};
%myapproach = {'Spectralmeans' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[1.5 4.5],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}},'Prediction', {'FeatureExtraction',{'FreqWindows',[2 6;8 12;28 32]}}};

%myapproach = 'Spectralmeans'
%finally we train the model on the data, specifying the target markers
%[trainloss,mymodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'768','769'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true,'EvaluationMetric', 'mse'); 
%[trainloss,mymodel,laststats] = bci_train('Data',{traindata traindata2 traindata3},'Approach',myapproach,'TargetMarkers',{'770','769'},'EvaluationMetric', 'mse'); 

%this will display the results of the cross-validation tests
%disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
%this will visualize the results of the csp for this case
%laststats
%bci_visualize(lastmodel)
%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
%annotateData = bci_annotate(lastmodel, mydata)
[prediction,loss,teststats,targets] = bci_predict(mymodel,traindata3);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
%[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5];