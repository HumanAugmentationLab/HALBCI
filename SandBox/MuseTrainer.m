% Load EEG and Marker data from XDF
EEG = pop_loadxdf('C:\Users\alakmazaheri\Desktop\markertest1.xdf', 'streamtype', 'signal');
x = EEG;

% Sync marker latencies
eventlen = length(x.event);
latencies = zeros(eventlen, 1);
for i = 1:eventlen
    curr = x.event(i).latency + x.xmin*x.srate; % Add data offset in samples
    EEG.event(i).latency = curr;
end

% Remove accelerometer channels
EEG.nbchan = 4;
EEG.data = EEG.data(1:4,:);
EEG.chanlocs(5:6) = [];

% Define custom approach (parameters based on OpenVibe Graz Motor Imagery Simulator)
myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[0.1 1.5],'FIRFilter',[7 8 12 13]}};
    
% Learn predictive model
[trainloss,lastmodel,laststats] = bci_train('Data',EEG,'Approach',myapproach,'TargetMarkers',{'770','769'}, 'EvaluationMetric', 'mse'); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);