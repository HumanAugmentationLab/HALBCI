

%% Directory for EEG data (K drive is \fsvs01\Research\)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\MLDebug\';
% File name without extension
fnameeeg = '20190423115609_ZZ-MagicLeapDucky_Record';
fnameeeg = '20190423120309_ZZ-MagicLeapDucky_Record';


% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data

%% Chop run between start and end markers 
[~, start_idx] = pop_selectevent(EEG, 'type', 10);
start_pt = EEG.event(start_idx).latency;

[~, end_idx] = pop_selectevent(EEG, 'type', 100);
end_pt = EEG.event(end_idx).latency;

% eeg_cropped = eeg_eegrej(EEG, [1 start_pt-1]);
disp('Cropping start and end of raw data...')
EEG = eeg_eegrej(EEG, [1 start_pt-1; end_pt+1 EEG.pnts]);

%% Select some Epochs to be train and test
switch_pt = EEG.event(294).latency;
switch_pt = EEG.event(245).latency;
EEGtrain = eeg_eegrej(EEG, [1 switch_pt-1]);
EEGtest = eeg_eegrej(EEG,[switch_pt EEG.pnts]);


%% Run classification

wnds = [0.05 0.1; 0.1 0.15; 0.15 0.2; 0.2 0.25; 0.25 0.3; 0.3 0.35; 0.35 0.4;];
mrks = {{'51'}, {'52'}}; 

myapproach = {'Windowmeans', ...
    'SignalProcessing',{...
        'EpochExtraction',{'TimeWindow',[0 .4]},...
        'SpectralSelection',[0.1 15]...
    }, ...
    'Prediction',{
        'FeatureExtraction',{'TimeWindows',wnds}, ...
        'MachineLearning',{'Learner',{'logreg',1,'variant','vb-ard'}}}...
    };

% myapproach = {'Spectralmeans' ...
%                     'SignalProcessing', { ...
%                         'EpochExtraction', {'TimeWindow',[0 epochsizes(es)-0.002] } ...
%                      }, ...
%                      'Prediction', { ...
%                         'FeatureExtraction',{ 'FreqWindows', [5 7; 14 16] }, ...
%                         'MachineLearning', {'Learner', 'logreg'} ...
%                         }...
%                 };
% 
%             [trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
% 'TargetMarkers',mrks,'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 
% disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

[trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
'TargetMarkers',mrks, 'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

[prediction,testloss,teststats,targets] = bci_predict(mymodel,EEGtest);
disp(['test mis-classification rate: ' num2str(testloss*100,3) '%']);     

%% Plotting
trainclassrate = (1-trainlossresults)*100;
testclassrate = (1-testlossresults)*100;

figure;
subplot(1,2,1)
plot(trainclassrate);
%xticklabels({'0.5', '1', '2', '5', '10'})
xlabel('Epoch Size (s)')
ylabel('Classification Rate (%)')
ylim([50 100])
legend(approaches)
title('Training')

subplot(1,2,2)
plot(testclassrate)
%xticklabels({'0.5', '1', '2', '5', '10'})
xlabel('Epoch Size (s)')
ylabel('Classification Rate (%)')
ylim([50 100])
legend(approaches)
title('Testing')
