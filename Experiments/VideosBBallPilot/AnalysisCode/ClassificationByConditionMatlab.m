%% Classification of SSVEP Video Data
clear
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% list of subject names in alphabetical order
%subjects = {'AI','BN','CV','DC','FE','GR','HL','IF','JR','LO','LT','MD','OP','QP','RM','VM'}; 

subjects = {'MD'}
%% Run classification

train_probability = .8;

% fnameeeg = 'Run1-OpenClosed-Filt1to46-epochplus100closed-ica-pruned-rej6epochs'; %just for testing
% direeg = 'C:\Users\saman\Documents\MATLAB\TMSdataTEMP'; %testing local
% subjects = {'ZZ'};%
% add something about train or test and put in loop

% For checker size classification
fnameeeg = 'VideoCheckSize-CombinedStrongMedium'; % 
conditions = {'Compare All','Big Checker','Medium Checker','Small Checker'};
markersForConditions{1,1} = {'51','53','55'};
markersForConditions{1,2} = {'52','54','56'};
markersForConditions{2,1} = {'51'}; %Big checker, attend low freq
markersForConditions{2,2} = {'52'}; %Big checker, attend high freq
markersForConditions{3,1} = {'53'};
markersForConditions{3,2} = {'54'};
markersForConditions{4,1} = {'55'};
markersForConditions{4,2} = {'56'};

% For checker opacity classification

% fnameeeg = 'VideoCheckOpacity';% Base of file name
% conditions = {'Compare All', 'Full','Compare Video Only', 'Strong','Medium','Weak'};
% markersForConditions{1,1} = {'51','53','55','57'};
% markersForConditions{1,2} = {'52','54','56','58'};
% 
% markersForConditions{2,1} = {'51'};
% markersForConditions{2,2} = {'52'};
% 
% markersForConditions{3,1} = {'53','55','57'};
% markersForConditions{3,2} = {'54','56','58'};
% 
% markersForConditions{4,1} = {'53'};
% markersForConditions{4,2} = {'54'};
% markersForConditions{5,1} = {'55'};
% markersForConditions{5,2} = {'56'};
% markersForConditions{6,1} = {'57'};
% markersForConditions{6,2} = {'58'};


fnameTTidx = '-ttidx.txt'; % End root of test train indices (so we don't double dip)


% Parameters for Feature Selection
%FreqWindows = [5 7; 14 16]; % For spectral means
epochsizes = 0; %size of epoch for classification. If 0, use the size of the epoch from the epoched data. If continuous, don't set this to zero
FreqBins = [11.75  12.25; 14.75  15.25];
%FreqBins = [8.5 12.5];

%Parameters for classification
k = 5; % k-fold cross validation

selectedChannels = 1:32;
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
    
    % Create features in data that have already been preprocessed and epoched
    

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
            testbpfeat(:,ch) =  bandpower(squeeze(EEGtest.data(selectedCsehannels(ch),:,:)),EEGtest.srate,FreqBins(fb,:));

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
    
    %%%%%%%%%%%%%%%%%%% Build classifier %%%%%%%%%%%%%%%%%%%

%      trainedClassifier = fitcsvm(features(selectedepochs,:),response,'KernelScale','auto','Standardize',true,...
%     'OutlierFraction',0.05);
     
    %SVM, fit everything, assume 5% outliers
    trainedClassifier = fitcsvm(features(selectedepochs,:),response, 'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
    'expected-improvement-plus'),'OutlierFraction',0.05);

%     trainedClassifier(s,c) = fitcdiscr(features(selectedepochs,:),response, 'HyperparameterOptimizationOptions',struct('AcquisitionFunctionName',...
%     'expected-improvement-plus'),'OutlierFraction',0.05);


%     trainedClassifier = fitcdiscr(features(selectedepochs,:),response,...
%     'OptimizeHyperparameters','auto',...
%     'HyperparameterOptimizationOptions',struct('Holdout',0.3,...
%     'AcquisitionFunctionName','expected-improvement-plus'));

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
% classifname = '-LDAlog-search5pout';
classifname = '-SVMlog-search5pout';
classificationdatafile = strcat(direeg,'Classification\','ClassificationAccuracy-',fnameeeg,classifname,'-',datestr(now,'yyyy-mm-dd_at_HH-MM'),'.mat');
save(classificationdatafile, 'validationAccuracy','testAccuracy','testAccuracy',...
    'conditions','markersForConditions','subjects','fnameeeg', 'allPartitionedModel','allTrainedClassifier');

%% Load data (can start here! result of above process)
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
%fnameeeg = 'VideoCheckOpacity';% Base of file name

% load check opacity data and calculate mean train/test
load(strcat(direeg,'Classification\','ClassificationAccuracy-VideoCheckOpacity-SVMlog-search5pout-2020-01-26_at_19-10.mat'))
cond2plot = [2 4 5 6]; % Conditions for classifying opacity
opacity_acc_train = validationAccuracy(:,cond2plot);
opacity_acc_test = testAccuracy(:,cond2plot);
opacity_acc_train_mean = mean(opacity_acc_train);
opacity_acc_test_mean = mean(opacity_acc_test);

% load check size data and calculate mean train/test
load(strcat(direeg,'Classification\','ClassificationAccuracy-VideoCheckSize-CombinedStrongMedium-SVMlog-search5pout-2020-01-27_at_19-37.mat'))
cond2plot = [2 3 4];  % Conditions for classifying check size
checksize_acc_train = validationAccuracy(:,cond2plot);
checksize_acc_test = testAccuracy(:,cond2plot);
checksize_acc_train_mean = mean(checksize_acc_train);
checksize_acc_test_mean = mean(checksize_acc_test);

% load ergonomic preference ratings
load('K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\ergonomic_ratings.mat')
check_mean = checksize_mean';
opacity_mean = opac_mean';

%% plot condition vs. classification rate
cond2plot = [2  4 5 6]; % Conditions for classifying opacity
% cond2plot = [2 3 4];  % Conditions for classifying check size

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

%% compare classifiers (can skip)
figure
plot(checksvm(1,:),'b','LineWidth',2)
hold on
plot(checksvm(2,:),'b--','LineWidth',2)
plot(checklda(1,:),'r','LineWidth',2)
plot(checklda(2,:),'r--','LineWidth',2)
grid on
legend('SVM train','SVM test','LDA train','LDA test')

%% alpha values and classification rates (can skip)
alphacheck = [255 125 85 50]./255;

%% plot all ergonomic ratings vs. opac classification rates (can skip)
numsubj = length(subjects);
alorder = 1:numsubj;
newopac = opac(:,alorder);
 
cond2plot = [2  4 5 6]; % Conditions for classifying opacity

n = numsubj*length(cond2plot);

valaccsel = opacity_acc_train';

figure
scatter(reshape(newopac,1,n),reshape(valaccsel,1,n),'ko');
hold on;
for i = 1:4
scatter(newopac(i,:),valaccsel(i,:),'filled'); 
end

% corr(reshape(newopac,1,n),reshape(valaccsel,1,n),'ko')

p = polyfit(reshape(newopac,1,n),reshape(valaccsel,1,n), 1);
f = polyval(p, reshape(newopac,1,n));
[r2, rmse] = rsquare(reshape(newopac,1,n),f)


%% plot accuracy vs. erg rating means and save
figure
scatter(check_mean,checksize_acc_train_mean,'b','filled')
hold on
scatter(check_mean,checksize_acc_test_mean,'c','filled')
scatter(opacity_mean,opacity_acc_train_mean,'r','filled')
scatter(opacity_mean,opacity_acc_test_mean,'m','filled')

prefs = [opacity_mean check_mean];
acctrain = [opacity_acc_train_mean checksize_acc_train_mean];
acctest = [opacity_acc_test_mean checksize_acc_test_mean];

save('preferenceVSaccuracy.mat','opacity_acc_test','opacity_mean','opacity_acc_train','prefs','checksize_acc_test','checksize_acc_train','checksize_mean','acctest','acctrain')

%% calculate dropoff
% average dropoff across subjects
pref = [check_mean check_mean opacity_mean opacity_mean];
acc = 100*[checksize_acc_train_mean checksize_acc_test_mean ...
    opacity_acc_train_mean opacity_acc_test_mean];

% calculate for all subjects individually
% pref = [reshape(checksize, 1, 48) reshape(checksize, 1, 48) ...
%     reshape(opac, 1, 64) reshape(opac, 1, 64)];
% acc = 100*[reshape(checksize_acc_train, 1, 48) reshape(checksize_acc_test, 1, 48) ...
%     reshape(opacity_acc_train, 1, 64) reshape(opacity_acc_test, 1, 64)];

p = polyfit(pref, acc, 1);
f = polyval(p, pref);
[r2, rmse] = rsquare(acc,f);

figure; plot(pref,acc,'ko');
hold on; plot(pref,f,'r-');

title(strcat(['R2 = ' num2str(r2) '; RMSE = ' num2str(rmse)]))

ylim([50 90])
text(2.5, 85, sprintf('accuracy = %.3f * erg + %.3f', p(1), p(2)));
