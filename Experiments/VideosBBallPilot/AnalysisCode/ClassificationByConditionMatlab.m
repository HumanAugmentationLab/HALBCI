% Classification of SSVEP Video Data
clear

train_probability = .8;

direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
fnameeeg = 'VideoCheckOpacity';% Base of file name
% fnameeeg = 'VideoCheckSize-CombinedStrongMedium'; % 
subjects = {'BN','CV','FE', 'GR','IF','LO','MD','OP','RM'}; % 

% fnameeeg = 'Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs'; %just for testing
% direeg = 'C:\Users\saman\Documents\MATLAB\TMSdataTEMP'; %testing local
% subjects = {'ZZ'};%
% add something about train or test and put in loop

% conditions = {'Compare All','Big Checker','Medium Checker','Small Checker'};
% markersForConditions{1,1} = {'51','53','55'};
% markersForConditions{1,2} = {'52','54','56'};
% markersForConditions{2,1} = {'51'};
% markersForConditions{2,2} = {'52'};
% markersForConditions{3,1} = {'53'};
% markersForConditions{3,2} = {'54'};
% markersForConditions{4,1} = {'55'};
% markersForConditions{4,2} = {'56'};


conditions = {'Compare All', 'Full','Compare Video Only', 'Strong','Medium','Weak'};
markersForConditions{1,1} = {'51','53','55','57'};
markersForConditions{1,2} = {'52','54','56','58'};

markersForConditions{2,1} = {'51'};
markersForConditions{2,2} = {'52'};

markersForConditions{3,1} = {'53','55','57'};
markersForConditions{3,2} = {'54','56','58'};

markersForConditions{4,1} = {'53'};
markersForConditions{4,2} = {'54'};
markersForConditions{5,1} = {'55'};
markersForConditions{5,2} = {'56'};
markersForConditions{6,1} = {'57'};
markersForConditions{6,2} = {'58'};



% conditions = {'open vs closed'};
% markersForConditions{1,1} = {'51','52'};
% markersForConditions{1,2} = {'151','152'};

fnameTTidx = '-ttidx.txt'; % End root of test train indices (so we don't double dip)


% Parameters for Feature Selection
%FreqWindows = [5 7; 14 16]; % For spectral means
epochsizes = 0; %size of epoch for classification. If 0, use the size of the epoch from the epoched data. If continuous, don't set this to zero
FreqBins = [11.75  12.25; 14.75  15.25];
%FreqBins = [8.5 12.5];

%Parameters for classification
k = 5; % k-fold cross validation

selectedChannels = 1:32;%
%selectedChannels = [4 7 8 20 21 32];


for s = 1:length(subjects)
    clear EEG
    
    ioeasy = io_loadset(fullfile(direeg,strcat(subjects{s},'-',fnameeeg,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    iotesttraintext = fullfile(direeg,strcat(subjects{s},'-',fnameeeg, fnameTTidx));
    if isfile(iotesttraintext)
        disp("Text file already exists. Will not make new file. ");
        train_eeg_remove = []; test_eeg_remove = [];    
        datasetFile = fopen(iotesttraintext,'r');
        configuration = textscan(datasetFile, '%s %d %d\n');
        for index = 1:size(configuration{1, 1},1)
            if (configuration{1, 1}(index) == "Train") 
                test_eeg_remove = [test_eeg_remove configuration{1,3}(index)];
            else
                train_eeg_remove = [train_eeg_remove configuration{1,3}(index)];
            end 
        end          
    else
        disp(strcat('Will generate text file.',iotesttraintext));
        [train_eeg_remove, test_eeg_remove] = makeIndexForTrainTest(EEG,train_probability,iotesttraintext);    
    end
    
    % Create datasets from the train and test data structures.
    EEGtrain = pop_select(EEG, 'notrial', train_eeg_remove)
    EEGtest = pop_select(EEG, 'notrial', test_eeg_remove)
    
    %if epochsizes == 0, epochsizes = EEG.times(end); end % use given epoch sizes if not specified
    
    %EEGtrain = eeg_epoch2continuous(EEG);
    
    % Create features in data that have already been preprocessed and
    % epoched
    
    

    %% test and train generation of features
    
    EEG = EEGtrain;
    features = [];
    testfeatures = [];
    
    %Band power as features 
    for fb = 1: size(FreqBins,1)
        bpfeat = [];
        testbpfeat = [];
        for ch = 1:length(selectedChannels)
            bpfeat(:,ch) =  bandpower(squeeze(EEGtrain.data(selectedChannels(ch),:,:)),EEGtrain.srate,FreqBins(fb,:));
            testbpfeat(:,ch) =  bandpower(squeeze(EEGtest.data(selectedChannels(ch),:,:)),EEGtest.srate,FreqBins(fb,:));

        end
        features = [features bpfeat];
        testfeatures = [testfeatures testbpfeat];
    end
    
    features = log(features);
    testfeatures = log(testfeatures);
    
    for c = 1:length(conditions) % Comparisons of group of conditions
        
        % It would be more efficient to run this before feature selection
        % if the conditions of interest are sparse and you're only running
        % one comparison
        
        
        % Could rewrite the code below to use EEG.epoch.eventtype instead,
        % which would avoid this silly looping.
        
        % Find the appropriate labels
        epochsofinterest = zeros(EEGtrain.trials,1); %size of epochs different than size of events
        for i = 1:size(EEGtrain.event,2) %cycle through all events
            
            for m = 1:size(markersForConditions,2)
                if any(strcmp(markersForConditions{c,m},EEGtrain.event(i).type))
                    epochsofinterest(EEGtrain.event(i).epoch) = m; %index this by epoch number
                end
            end
        end
        
        testepochsofinterest = zeros(EEGtest.trials,1); %size of epochs different than size of events
        for i = 1:size(EEGtest.event,2) %cycle through all events
            
            for m = 1:size(markersForConditions,2)
                if any(strcmp(markersForConditions{c,m},EEGtest.event(i).type))
                    testepochsofinterest(EEGtest.event(i).epoch) = m; %index this by epoch number
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
    
    
    testselectedepochs = testepochsofinterest > 0;
    testresponse = testepochsofinterest(testselectedepochs);
    
    % Build classifier
%      trainedClassifier = fitcsvm(features(selectedepochs,:),response,'KernelScale','auto','Standardize',true,...
%     'OutlierFraction',0.05);
     
    %SVM, fit everything, assume 5% outliers
%     trainedClassifier = fitcsvm(features(selectedepochs,:),response, 'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
%     'expected-improvement-plus'),'OutlierFraction',0.05);

%     trainedClassifier(s,c) = fitcdiscr(features(selectedepochs,:),response, 'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
%     'expected-improvement-plus'),'OutlierFraction',0.05);


    trainedClassifier = fitcdiscr(features(selectedepochs,:),response,...
    'OptimizeHyperparameters','auto',...
    'HyperparameterOptimizationOptions',struct('Holdout',0.3,...
    'AcquisitionFunctionName','expected-improvement-plus'));

     % k-fold cross validation
     group = response; %Not sure why this is getting renamed
     cpart = cvpartition(group,'KFold',k); % 5-fold stratified cross validation
     partitionedModel = crossval(trainedClassifier,'CVPartition',cpart);
     
     % Cross validation output
     validationAccuracy(s,c) = 1 - kfoldLoss(partitionedModel);%, 'LossFun', 'ClassifError');
     fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy(s,c)*100);
     
     [label,score] = predict(trainedClassifier,testfeatures(testselectedepochs,:));
     testAccuracy(s,c) = sum(testresponse==label)./length(testresponse);
     fprintf('\nTest accuracy = %.2f%%\n', testAccuracy(s,c)*100);
     
     allTrainedClassifier{s,c} = trainedClassifier;
     allPartitionedModel{s,c} = partitionedModel;
%      % non log features
%      bcimodel = ml_train({features,response},'logreg');
%      bcipredictions_train = ml_predict(features,bcimodel);
%      [bciloss, bcistats] = ml_calcloss('mse',response,bcipredictions_train)
%      bciaccuracy(s,c) = sum(((bcipredictions_train{2}(:,2)>bcipredictions_train{2}(:,1)) +1)==response)./length(response);
%      
     %bcimodel = ml_train({log(features),response},'logreg');
     %bcipredictions_train = ml_predict(features,bcimodel);
     
     %validationPredictions = kfoldPredict(partitionedModel);
%     figure
%     cm = confusionchart(response,validationPredictions,'title','Validation Accuracy');
%     cm.ColumnSummary = 'column-normalized';
%     cm.RowSummary = 'row-normalized';
%         
        
        
    end 
    
    
end

%% Save data
classifname = '-LDAlog-search5pout';
classificationdatafile = strcat(direeg,'Classification\','ClassificationAccuracy-',fnameeeg,classifname,'-',datestr(now,'yyyy-mm-dd_at_HH-MM'),'.mat');
save(classificationdatafile, 'validationAccuracy','testAccuracy','testAccuracy',...
    'conditions','markersForConditions','subjects','fnameeeg', 'allPartitionedModel','allTrainedClassifier');

%% Load data
direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
%fnameeeg = 'VideoCheckOpacity';% Base of file name

%load(strcat(direeg,'Classification\','ClassificationAccuracy-VideoCheckOpacity-SVMlog-search5pout-2019-10-14_at_16-29.mat'))

load(strcat(direeg,'Classification\','ClassificationAccuracy-Checker-SVMlog-search5pout-2019-10-14_at_16-10.mat'))


%%
cond2plot = [2  4 5 6];
%cond2plot = [2 3 4];

figure;
subplot(2,1,1)
plot(validationAccuracy(:,cond2plot)'*100,'-','Color',[.6 .6 .6 .4],'LineWidth',1);
hold on;
ba = bar(mean(validationAccuracy(:,cond2plot)));
ba.FaceAlpha = 0.2;
er = errorbar(mean(validationAccuracy(:,cond2plot))*100,1.96*std(validationAccuracy(:,cond2plot))*100./sqrt(size(validationAccuracy(:,cond2plot),1)),'LineWidth',2);
er.Color = [.4 .4 .4 .7];  %er.LineStyle = 'none';  
ylim([50 100]);
xticks(1:length(conditions(cond2plot)));
xticklabels(conditions(cond2plot));
xlim([0.9 length(conditions(cond2plot))+.1]);
title('Train Accuracy')
set(gca,'FontSize',14)


subplot(2,1,2)
plot(testAccuracy(:,cond2plot)'*100,'-','Color',[.6 .6 .6 .4],'LineWidth',1);
hold on;
%ba = bar(mean(testAccuracy));
%ba.FaceAlpha = 0.2;
er = errorbar(mean(testAccuracy(:,cond2plot))*100,1.96*std(testAccuracy(:,cond2plot))*100./sqrt(size(testAccuracy(:,cond2plot),1)),'LineWidth',2);
er.Color = [.4 .4 .4 .7];       %er.LineStyle = 'none';  
ylim([50 100]);
xticks(1:length(conditions(cond2plot)));
xticklabels(conditions(cond2plot));
xlim([0.9 length(conditions(cond2plot))+.1]);
title('Test Accuracy')
set(gca,'FontSize',14)


%%
figure
plot(checksvm(1,:),'b','LineWidth',2)
hold on
plot(checksvm(2,:),'b--','LineWidth',2)
plot(checklda(1,:),'r','LineWidth',2)
plot(checklda(2,:),'r--','LineWidth',2)
grid on
legend('SVM train','SVM test','LDA train','LDA test')


%%  Alpha values and classification rates
alphacheck = [255 125 85 50]./255;

%% Preferences by classification rates
% Conds x [MD BN LO FE OP IF CV RM GR]
full_pref = [1 1 1 1 2 1 1 1 1];
strong_pref = [1 1 2.5 3.6 2 1 2.5 1.5 1];
med_pref = [1 1 3.2 4.2 3 5 3.5 2 2];
weak_pref = [3 2 4.5 4.7 5 5 5 2.5 3];
opac = [full_pref; strong_pref; med_pref; weak_pref];

subjects = {'BN','CV','FE', 'GR','IF','LO','MD','OP','RM'}; % 
alorder = [2 7 4 9 6 3 1 5 8];
newopac = opac(:,alorder);

cond2plot = [2  4 5 6];

valaccsel = validationAccuracy(:,cond2plot)';


figure
scatter(reshape(newopac,1,36),reshape(valaccsel,1,36),'ko');
hold on;
for i = 1:4
scatter(newopac(i,:),valaccsel(i,:),'filled'); 
end

corr(reshape(newopac,1,36),reshape(valaccsel,1,36),'ko')


p = polyfit(reshape(newopac,1,36),reshape(valaccsel,1,36), 1);
f = polyval(p, reshape(newopac,1,36));
%[r2, rmse] = rsquare(mean(newopac),f)

%% 
checksize_mean
checksize_acc_train = mean(validationAccuracy(:,cond2plot))
checksize_acc_test = mean(testAccuracy(:,cond2plot))

%%
opacity_mean = opac_mean'
opacity_acc_train = mean(validationAccuracy(:,cond2plot))
opacity_acc_test = mean(testAccuracy(:,cond2plot))
%%
prefs = [opacity_mean checksize_mean];
acctrain = [opacity_acc_train checksize_acc_train];
acctest = [opacity_acc_test checksize_acc_test];
%%
figure
scatter(checksize_mean,checksize_acc_train,'b','filled')
hold on
scatter(checksize_mean,checksize_acc_test,'c','filled')
scatter(opacity_mean,opacity_acc_train,'r','filled')
scatter(opacity_mean,opacity_acc_test,'m','filled')

save('preferenceVSaccuracy.mat','opacity_acc_test','opacity_mean','opacity_acc_train','prefs','checksize_acc_test','checksize_acc_train','checksize_mean','acctest','acctrain')

