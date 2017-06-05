%% Calibration
% read training data from XDF (already recorded, has both EEG and marker info)
[EEG] = pop_loadxdf('C:\Users\alakmazaheri\Desktop\untitled.xdf')
traindata = EEG.data(1:4,:);

% define custom approach
    % NOTE: placeholder values copied from tutorial
myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0.5 3],'FIRFilter',[7 8 26 28]}};

% learn predictive model
    % TO DO: change target marker string to match types in XDF }(in this
    % case, the two relevant OpenVibe stimulation names
[trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'OVname1','OVName2'}); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

%% Evaluation
% stream EEG and markers over LSL
run_readlsl('DataStreamQuery','type=''EEG''', 'MarkerQuery','type=''Markers''');

% predict states according to model defined in calib.
    % QUESTION: does this assume that the live data will come with markers?
    % Will itse them? (hopefully no bc this is not the marker-locked version)
[prediction,loss,teststats,targets] = bci_predict(lastmodel,traindata);

% display the results
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);

% send results live over LSL
    % is this writing out the predictions?
run_writelsl('Model',lastmodel,'LabStreamName','BCI-Continuous');
