cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\AvaMuseProcess

clear trainloss mymodel laststats prediction loss teststats targets myapproach

traindata0 = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\opencloseava.xdf');
mytempdata0 = tryFindStart(traindata0,3,0);

traindata1 = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\W1MuseExtrinsic.xdf');
mytempdata1 = tryFindStart(traindata1,4,0);
 
traindata2 = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\W2MuseExtrinsic.xdf');
mytempdata2 = tryFindStart(traindata2,4,0);

traindata3 = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\W1MuseIntrinsic.xdf');
mytempdata3 = tryFindStart(traindata3,4,0);

%mytempdataNick = refactorFunc(mytempdata, 0.5, 3.5, 1);
%mytempdataSam = makeExtraEvents(mytempdata, 0.5, 3.5, 1);

%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0.5 1.5],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',1},'MachineLearning',{'learner','lda'}}};
myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[-0.5 1],'FIRFilter',[2 4 32 48],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',1},'MachineLearning',{'learner','lda'}}};

[trainloss,mymodel,laststats] = bci_train('Data',mytempdata0,'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata0);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
