cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\AvaMuseProcess

traindata = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\untitled.xdf');
mytempdata = tryFindStart(traindata,3,0);
 
mytempdata = refactorFunc(mytempdata,1, 3.5,.5)

myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};

[trainloss,mymodel,laststats] = bci_train('Data',mytempdata,'Approach',myapproach,'TargetMarkers',{'Closed','Open'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);