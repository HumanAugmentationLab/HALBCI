% Classification of SSVEP Video Data

direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
direeg = 'C:\Users\saman\Documents\MATLAB\TMSdataTEMP'; %testing local

fnameeeg = 'VideoCheckOpacity';% Base of file name
fnameeeg = 'Run3-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej15epochs'; %just for testing
subjects = {'ZZ'};%{'BN'}; % 

% add something about train or test and put in loop


conditions = {'Compare Any'};
markersForConditions{1,1} = {'51','53'};
markersForConditions{1,2} = {'52','54'};

logTrainTestIndex = 'ttidx.txt'; % End root of test train indices (so we don't double dip)


% Parameters for classification
FreqWindows = [5 7; 14 16]; % For spectral means
epochsizes = 0; %size of epoch for classification. If 0, use the size of the epoch from the epoched data. If continuous, don't set this to zero



for s = 1:length(subjects)
    clear EEG
    
    ioeasy = io_loadset(fullfile(direeg,strcat(subjects{s},'-',fnameeeg,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    if epochsizes == 0, epochsizes = EEG.times(end); end % use given epoch sizes if not specified
    
    EEGtrain = eeg_epoch2continuous(EEG);
    
    for c = 1:length(conditions)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%    Run Classification - BCILAB  %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
        
        
        
        
        
        
        
        
        
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%    Run Classification - BCILAB  %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%     disp('running spectral means logreg')
%     myapproach = {'Spectralmeans' ...
%         'SignalProcessing', { ...
%             'EpochExtraction', {'TimeWindow',[0 epochsizes] } ...
%          }, ...
%          'Prediction', { ...
%             'FeatureExtraction',{ 'FreqWindows', FreqWindows }, ...
%             'MachineLearning', {'Learner', 'logreg'} ...
%             }...
%     };
% 
%     [trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
%     'TargetMarkers',{{'53'}, {'54'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 
%     disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
% 
%     if exists(EEGtest)
%         [prediction,testloss,teststats,targets] = bci_predict(mymodel,EEGtest);
%         disp(['test mis-classification rate: ' num2str(testloss*100,3) '%']);
%          testlossresults(s,c) = testloss;
%     end
% 
% 
%     trainlossresults(s,c) = trainloss;
%     laststatsresults(s,c).laststats = laststats;
    
    
    
    
    end 
    
    
end