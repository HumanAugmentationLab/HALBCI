%First we load the data set into matlab with io_loadset()
traindata = io_loadset('C:\Users\gsteelman\Desktop\bob1.gdf','channels',1:4);
mydata = exp_eval(traindata);
answer = refactorFunc(mydata);
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

%here we specifiy the approach to detangle the data
%this one is Filter Banked CSP with epochs from .5 to 3.5. 8 different
%frequency bands were also selected to be processed
%{
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0.5 3.5]}, ...
           'Prediction', {'FeatureExtraction',{'FreqWindows',[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5],'TimeWindows',[]}, ...
                          'MachineLearning',{'Learner','lda'}}}
%}
myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0 1]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2}}};
%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[6 8 14 15],'EpochExtraction',[.5 3.5]}};
%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[-1 1]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[-1 1],'FIRFilter',[8 12 28 32]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2,'FreqWindows',[8 12;28 32]},'MachineLearning',{'learner','lda'}}};
%myapproach = {'Spectralmeans' 'SignalProcessing',{'FIRFilter',[6 8 28 32],'EpochExtraction',[-1 1]},'Prediction', {'FeatureExtraction',{'FreqWindows',[8 12;28 32]}}};

%myapproach = 'Spectralmeans'
%finally we train the model on the data, specifying the target markers
[trainloss,mymodel,laststats] = bci_train('Data',mydata,'Approach',myapproach,'TargetMarkers',{'68','69'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true); 
%this will display the results of the cross-validation tests
%disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
%this will visualize the results of the csp for this case
%laststats
%bci_visualize(lastmodel)
%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
%annotateData = bci_annotate(lastmodel, mydata)
[prediction,loss,teststats,targets] = bci_predict(mymodel,mydata);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
%[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5];