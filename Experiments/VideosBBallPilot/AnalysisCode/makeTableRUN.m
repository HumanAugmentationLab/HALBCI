%% Load and organize all the data in a table

% ------------------- Load the ergonomic rating data ------------------- %
load K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\ergonomic_ratings.mat; % should have checksize and opac scores for each person (averaged across their ratings)

subjerg = {'MD', 'BN', 'LO', 'FE', 'OP', 'IF', 'CV', 'RM', 'GR', 'JR', 'AI', 'QP', 'LT', 'HL', 'DC', 'VM'};
[Subj,i] = sort(subjerg);
checksize = checksize(:,i); % reorder to have subj in alphabetical
opac = opac(:,i); % reorder to have subj in alphabetical


% ------------------- Load the bandpower data -------------------------- %
load K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\bandpower_ALLSUBJ_checksize.mat; % should have checksize and opac scores for each person (averaged across their ratings)
BP12_Check_ = (meanpow_lowATTlow + meanpow_lowATThigh)/2;
BP15_Check_ = (meanpow_highATTlow + meanpow_highATThigh)/2;

load K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\bandpower_ALLSUBJ_opacity.mat; % should have checksize and opac scores for each person (averaged across their ratings)
BP12_Opac_ = (meanpow_lowATTlow + meanpow_lowATThigh)/2;
BP15_Opac_ = (meanpow_highATTlow + meanpow_highATThigh)/2;

% Order used in BP calculations
chron_subj = {'MD' 'BN' 'LO' 'FE' 'OP' 'IF' 'CV' 'RM' 'GR' 'JR' 'AI' 'QP' 'LT' 'HL' 'DC' 'VM'};
[~,idx] = sort(chron_subj);
BP12_Check = BP12_Check_(idx,:);
BP15_Check = BP15_Check_(idx,:);
BP12_Opac = BP12_Opac_(idx,:);
BP15_Opac = BP15_Opac_(idx,:);


% ---------------------- Load classification data --------------------- %
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% load check opacity data and calculate mean train/test
load(strcat(direeg,'Classification\','ClassificationAccuracy-VideoCheckOpacity-SVMlog-search5pout-2020-01-26_at_19-10.mat'))
cond2plot = [2 4 5 6]; % Conditions for classifying opacity
opacity_acc_train = validationAccuracy(:,cond2plot);
opacity_acc_test = testAccuracy(:,cond2plot);

% load check size data and calculate mean train/test
load(strcat(direeg,'Classification\','ClassificationAccuracy-VideoCheckSize-CombinedStrongMedium-SVMlog-search5pout-2020-01-27_at_19-37.mat'))
cond2plot = [2 3 4];  % Conditions for classifying check size
checksize_acc_train = validationAccuracy(:,cond2plot);
checksize_acc_test = testAccuracy(:,cond2plot);

%% Create and populate table
%'VariableNames',{'Subj','CheckOpac','Level','ErgRating','ClassScore','BP12','BP15'}
tbl = table();

% Check the order of all of these align with the data; 
% We are doing checker first and then opacity 
tbl.Subj = repmat(subjects,1,7)';
tbl.CheckOpac = [repmat(categorical({'Check'}),1,16*3), repmat(categorical({'Opac'}),1,16*4)]';
tbl.CheckLevel = [repmat(categorical({'Big'}),1,16), repmat(categorical({'Medium'}),1,16), repmat(categorical({'Small'}),1,16),... %check
    repmat(categorical({'Small'}),1,16*4)]'; %Where all the opacity ones have small checker sizes
tbl.OpacLevel = [repmat(categorical({'Medium'}),1,16*3), ... %for all checker size, though this might not actually be medium??? should we break these out?
    repmat(categorical({'Full'}),1,16), repmat(categorical({'Strong'}),1,16), repmat(categorical({'Med'}),1,16), repmat(categorical({'Small'}),1,16)]';


tbl.ErgRating = [checksize(1,:), checksize(2,:), checksize(3,:), opac(1,:), opac(2,:), opac(3,:), opac(4,:)]';

tbl.ClassScore = [checkclasstrain(:,1); checkclasstrain(:,2); checkclasstrain(:,3);... %big, med, small
    opacityclasstrain(:,2); opacityclasstrain(:,4); opacityclasstrain(:,5); opacityclasstrain(:,6)]; % last is weak


tbl.BP12 = [BP12_Check(:,1); BP12_Check(:,2); BP12_Check(:,3); BP12_Opac(:,1); BP12_Opac(:,2); BP12_Opac(:,3); BP12_Opac(:,4)];
tbl.BP15 = [BP15_Check(:,1); BP15_Check(:,2); BP15_Check(:,3); BP15_Opac(:,1); BP15_Opac(:,2); BP15_Opac(:,3); BP15_Opac(:,4)];

% Saved as AllDataTable_Run.mat on the K drive
% (K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed)