% Classification of SSVEP Video Data
clear

direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
%direeg = 'C:\Users\saman\Documents\MATLAB\TMSdataTEMP'; %testing local

fnameeeg = 'VideoCheckOpacity';% Base of file name
%fnameeeg = 'Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs'; %just for testing
subjects = {'BN','CV','FE', 'GR','IF','LO','MD','OP','RM'}; % {'ZZ'};%

% add something about train or test and put in loop


conditions = {'Compare All', 'Compare Checks Only','Compare Video Only'};
markersForConditions{1,1} = {'51','53','55','57'};
markersForConditions{1,2} = {'52','54','56','58'};

markersForConditions{2,1} = {'51'};
markersForConditions{2,2} = {'52'};

markersForConditions{3,1} = {'53','55','57'};
markersForConditions{3,2} = {'54','56','58'};

% conditions = {'open vs closed'};
% markersForConditions{1,1} = {'51'};
% markersForConditions{1,2} = {'151'};

logTrainTestIndex = 'ttidx.txt'; % End root of test train indices (so we don't double dip)


% Parameters for Feature Selection
%FreqWindows = [5 7; 14 16]; % For spectral means
epochsizes = 0; %size of epoch for classification. If 0, use the size of the epoch from the epoched data. If continuous, don't set this to zero
FreqBins = [11.75  12.25; 14.75  15.25];

%Parameters for classification
k = 5; % k-fold cross validation

selectedChannels = [4 7 8 20 21 32];


for s = 1:length(subjects)
    clear EEG
    
    ioeasy = io_loadset(fullfile(direeg,strcat(subjects{s},'-',fnameeeg,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    
    
    
    if epochsizes == 0, epochsizes = EEG.times(end); end % use given epoch sizes if not specified
    
    %EEGtrain = eeg_epoch2continuous(EEG);
    
    % Create features in data that have already been preprocessed and
    % epoched
    
    features = [];
    %Band power as features 
    for fb = 1: size(FreqBins,1)
        bpfeat = [];
        for ch = 1:length(selectedChannels)
            bpfeat(:,ch) =  bandpower(squeeze(EEG.data(selectedChannels(ch),:,:)),EEG.srate,FreqBins(fb,:));
        end
        features = [features bpfeat];
    end
    
    
    for c = 1:length(conditions) % Comparisons of group of conditions
        
        % It would be more efficient to run this before feature selection
        % if the conditions of interest are sparse and you're only running
        % one comparison
        
        % Find the appropriate labels
        epochsofinterest = zeros(EEG.trials,1); %size of epochs different than size of events
        for i = 1:size(EEG.event,2) %cycle through all events
            
            for m = 1:size(markersForConditions,2)
                if any(strcmp(markersForConditions{c,m},EEG.event(i).type))
                    epochsofinterest(EEG.event(i).epoch) = m; %index this by epoch number
                end
            end
        end
        
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%    Run Classification - MATLAB  %%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    
    
    
        
    % Labels for classification
    %response = zeros(size(EEG.epoch));
    %response(round(length(response)./2):end) = 1;
    
    selectedepochs = epochsofinterest>0;
    response = epochsofinterest(selectedepochs);
    
    % Build classifier
     trainedClassifier = fitcknn(features(selectedepochs),response)
     
     % k-fold cross validation
     group = response; %Not sure why this is getting renamed
     cpart = cvpartition(group,'KFold',k); % 5-fold stratified cross validation
     partitionedModel = crossval(trainedClassifier,'CVPartition',cpart);
     
     % Cross validation output
     validationAccuracy(s,c) = 1 - kfoldLoss(partitionedModel);%, 'LossFun', 'ClassifError');
     fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy(s,c)*100);
     
    
     validationPredictions = kfoldPredict(partitionedModel);
%     figure
%     cm = confusionchart(response,validationPredictions,'title','Validation Accuracy');
%     cm.ColumnSummary = 'column-normalized';
%     cm.RowSummary = 'row-normalized';
%         
        
        
        
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