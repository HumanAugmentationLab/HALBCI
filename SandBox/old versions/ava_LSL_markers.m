%% Calibration
% read training data from XDF (already recorded, has both EEG and marker info)
[tempEEG] = pop_loadxdf('C:\Users\alakmazaheri\Desktop\untitled.xdf')
EEG = exp_eval(tempEEG);
EEG.nbchan = 4;
EEG.data = EEG.data(1:4,:);
    % EEG.chanlocs(5).labels = 'acc1';
    % EEG.chanlocs(6).labels = 'acc2';
    % testchan = trimstruct(EEG.chanlocs);
    % EEG = io_loadset('C:\Users\alakmazaheri\Desktop\untitled.xdf', 'channels', 1:4)

markers = EEG.event; % using OpenVibe Graz, R = 770 L = 769

% define custom approach
%myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0.5 3],'FIRFilter',[7 8 26 28]}, {'FeatureExtraction',{'PatternPairs',2}}};
myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',1}}};


% learn predictive model
    % TO DO: change target marker string to match types in XDF }(in this
    % case, the two relevant OpenVibe stimulation names
[trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'770','769'}); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

%% Evaluation
% % stream EEG and markers over LSL
% run_readlsl('DataStreamQuery','type=''EEG''', 'MarkerQuery','type=''Markers''');
% 
% % predict states according to model defined in calib.
%     % QUESTION: does this assume that the live data will come with markers?
%     % Will itse them? (hopefully no bc this is not the marker-locked version)
% [prediction,loss,teststats,targets] = bci_predict(lastmodel,traindata);
% 
% % display the results
% disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
% disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
% disp(['  true classes     : ',num2str(round(targets)')]);
% 
% % send results live over LSL
%     % is this writing out the predictions?
% run_writelsl('Model',lastmodel,'LabStreamName','BCI-Continuous');

