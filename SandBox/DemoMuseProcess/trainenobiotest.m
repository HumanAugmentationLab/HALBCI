cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\AvaMuseProcess

traindataZ = io_loadset('K:\HumanAugmentationLab\EEGdata\EnobioTests\EyesOpenClosed\20170720140844_PatientW5.easy');
mytempdataZ = exp_eval(traindataZ)

traindataX = io_loadset('C:\Users\alakmazaheri\Documents\BCI\EnobioData\W1EnobioIntrinsic.xdf');
mytempdataX = exp_eval(traindata4)
mytempdataX.chanlocs = mytempdataZ.chanlocs; 

myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[-0.5 1],'FIRFilter',[2 4 32 48],'ChannelSelection',{{'P7' 'P4' 'Cz' 'Pz'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',1},'MachineLearning',{'learner','lda'}}};

[trainloss,mymodel,laststats] = bci_train('Data',mytempdataX,'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdataX);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
