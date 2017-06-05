%load training data
traindata = io_loadset('BCICIV_calib_ds1a.mat');

%define approach
%myapproach = 'CSP';
myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0.5 4.5],'FIRFilter',[7 8 26 28]}};

%learn a predictive model
[trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'1','-1'}); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

% visualize results
bci_visualize(lastmodel)