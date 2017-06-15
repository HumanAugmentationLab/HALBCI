% Load EEG and Marker data from XDF
EEG = preprocess('C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Phase0_Ava\markertest1.xdf');

% Define custom approach (parameters based on OpenVibe Graz Motor Imagery Simulator)
myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[1.5 3.5],'FIRFilter',[7 8 12 13]}};
    
% Learn predictive model
[trainloss,lastmodel,laststats] = bci_train('Data',EEG,'Approach',myapproach,'TargetMarkers',{'769','770'}, 'EvaluationMetric', 'mse'); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

% Test on itself
[prediction,loss,teststats,targets] = bci_predict(lastmodel,EEG);
 
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);