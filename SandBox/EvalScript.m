%% Predict on pre-recorded data
evaldataset = preprocess('C:\Users\alakmazaheri\Desktop\actualdata.xdf');
[prediction,loss,teststats,targets] = bci_predict(lastmodel,evaldataset);

disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);

%% Predict on live data
% stream EEG and markers over LSL
run_readlsl('DataStreamQuery','type=''EEG''', 'MarkerQuery','type=''Markers''');

% uses laststream -- can also open stream and specify it in arg
%onl_newpredictor('mypredictor',lastmodel)


% send results live over LSL
%run_writelsl('Model',lastmodel,'LabStreamName','BCI-Continuous');

