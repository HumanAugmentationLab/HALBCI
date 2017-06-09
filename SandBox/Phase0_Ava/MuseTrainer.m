% Load EEG and Marker data from XDF
EEG = preprocess('C:\Users\gsteelman\Desktop\SummerResearch\HALBCI\SandBox\AvaStuff\markertest1.xdf');
traindata = io_loadset('C:\Users\gsteelman\Desktop\bob3.gdf','channels',1:4);
% Define custom approach (parameters based on OpenVibe Graz Motor Imagery Simulator)
myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[1.5 3.5],'FIRFilter',[7 8 12 13]}};
    
% Learn predictive model
[trainloss,lastmodel,laststats] = bci_train('Data',EEG,'Approach',myapproach,'TargetMarkers',{'768','769'}, 'EvaluationMetric', 'mse'); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

% Test on itself
[prediction,loss,teststats,targets] = bci_predict(lastmodel,EEG);
 
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);