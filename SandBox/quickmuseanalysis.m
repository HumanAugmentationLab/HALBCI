
%%
%Subtract latencies from start
starttime = b.event(1).latency;
for i = 1:size(b.event,2)
    b.event(i).latency = (b.event(i).latency - starttime)./b.srate; % subtract initial event and turn into seconds from time points 
end


mytempdata = b;
% Might want to add a piece here to align and remove up to actual start
% time
%%
myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',1},'MachineLearning',{'learner','lda'}}};

[trainloss,mymodel,laststats] = bci_train('Data',mytempdata,'Approach',myapproach,'TargetMarkers',{'10','11'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

%%
[prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdata);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);