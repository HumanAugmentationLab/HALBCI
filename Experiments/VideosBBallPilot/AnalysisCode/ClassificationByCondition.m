% Classification of SSVEP Video Data

direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
fnameeeg = VideoCheckOpacity;% Base of file name
subjects = {'BN'}; % 

conditions = {'Compare Any'};
markersForConditions{1,1} = {'51','53'};
markersForConditions{1,2} = {'52','54'};

logTrainTestIndex = 'ttidx.txt'; % End root of test train indices (so we don't double dip)




for s = 1:length(subjects)
    clear EEG
    
    ioeasy = io_loadset(fullfile(direeg,strcat(subjects{s},'-',fnameeeg,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    
    
    for c = 1:length(conditions)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%    Run Classification   %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    disp('running spectral means logreg')
    myapproach = {'Spectralmeans' ...
        'SignalProcessing', { ...
            'EpochExtraction', {'TimeWindow',[0 epochsizes-0.002] } ...
         }, ...
         'Prediction', { ...
            'FeatureExtraction',{ 'FreqWindows', [5 7; 14 16] }, ...
            'MachineLearning', {'Learner', 'logreg'} ...
            }...
    };

    [trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
    'TargetMarkers',{{'53'}, {'54'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 
    disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

    [prediction,testloss,teststats,targets] = bci_predict(mymodel,EEGtest);
    disp(['test mis-classification rate: ' num2str(testloss*100,3) '%']);

    trainlossresults(s,c) = trainloss;
    testlossresults(s,c) = testloss;
    laststatsresults(s,c).laststats = laststats;
    
    end 
    
    
end
