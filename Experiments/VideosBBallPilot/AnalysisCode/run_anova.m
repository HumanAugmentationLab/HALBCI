%% Load all of post-ica data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% OPACITY EXPERIMENT
% MD = pop_loadset('filename', 'MD-VideoCheckOpacity.set', 'filepath', direeg);
% BN = pop_loadset('filename', 'BN-VideoCheckOpacity.set', 'filepath', direeg);
% LO = pop_loadset('filename', 'LO-VideoCheckOpacity.set', 'filepath', direeg);
% FE = pop_loadset('filename', 'FE-VideoCheckOpacity.set', 'filepath', direeg);
% OP = pop_loadset('filename', 'OP-VideoCheckOpacity.set', 'filepath', direeg);
% IF = pop_loadset('filename', 'IF-VideoCheckOpacity.set', 'filepath', direeg);
% CV = pop_loadset('filename', 'CV-VideoCheckOpacity.set', 'filepath', direeg);
% RM = pop_loadset('filename', 'RM-VideoCheckOpacity.set', 'filepath', direeg);
% GR = pop_loadset('filename', 'GR-VideoCheckOpacity.set', 'filepath', direeg);

% CHECK SIZE STRONG EXPERIMENT
MD_Strong = pop_loadset('filename', 'MD-VideoCheckSize-Strong.set', 'filepath', direeg);
BN_Strong = pop_loadset('filename', 'BN-VideoCheckSize-Strong.set', 'filepath', direeg);
LO_Strong = pop_loadset('filename', 'LO-VideoCheckSize-Strong.set', 'filepath', direeg);
FE_Strong = pop_loadset('filename', 'FE-VideoCheckSize-Strong.set', 'filepath', direeg);
OP_Strong = pop_loadset('filename', 'OP-VideoCheckSize-Strong.set', 'filepath', direeg);
IF_Strong = pop_loadset('filename', 'IF-VideoCheckSize-Strong.set', 'filepath', direeg);
CV_Strong = pop_loadset('filename', 'CV-VideoCheckSize-Strong.set', 'filepath', direeg);
RM_Strong = pop_loadset('filename', 'RM-VideoCheckSize-Strong.set', 'filepath', direeg);
GR_Strong = pop_loadset('filename', 'GR-VideoCheckSize-Strong.set', 'filepath', direeg);

% CHECK SIZE MEDIUM EXPERIMENT
MD_Med = pop_loadset('filename', 'MD-VideoCheckSize-Med.set', 'filepath', direeg);
BN_Med = pop_loadset('filename', 'BN-VideoCheckSize-Med.set', 'filepath', direeg);
LO_Med = pop_loadset('filename', 'LO-VideoCheckSize-Med.set', 'filepath', direeg);
FE_Med = pop_loadset('filename', 'FE-VideoCheckSize-Med.set', 'filepath', direeg);
OP_Med = pop_loadset('filename', 'OP-VideoCheckSize-Med.set', 'filepath', direeg);
IF_Med = pop_loadset('filename', 'IF-VideoCheckSize-Med.set', 'filepath', direeg);
CV_Med = pop_loadset('filename', 'CV-VideoCheckSize-Med.set', 'filepath', direeg);
RM_Med = pop_loadset('filename', 'RM-VideoCheckSize-Med.set', 'filepath', direeg);
GR_Med = pop_loadset('filename', 'GR-VideoCheckSize-Med.set', 'filepath', direeg);

% ANOVA: Opacity
% ALLSUBJ = {MD BN LO FE OP IF CV RM GR};          

% ANOVA: Check Size -- keep Strong/Med order for ANOVA struct
ALLSUBJ = {MD_Strong MD_Med BN_Strong BN_Med LO_Strong LO_Med FE_Strong FE_Med OP_Strong OP_Med IF_Strong IF_Med CV_Strong CV_Med RM_Strong RM_Med GR_Strong GR_Med};   

disp('loaded all subject data')

%% ANOVA: OPACITY
% Select opacity conditions 
adetails.markers.types = {'51','52','53','54','55','56','57','58'};


% Create empty anova struct
clear anovastruct
anovastruct.subj = []; anovastruct.cond = []; anovastruct.att = []; anovastruct.pow_val = []; anovastruct.freq = [];


for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};
    
    % ----------------- Set subject name -------------- %
    curr_subj = EEG.filename(1:2) + "";    


    % ----------------- Crop EEG for various conditions -------------- %
    % Find relevant marker and indices
    evtype = [];
    for i = 1:length(EEG.epoch)
        evtype = [evtype, ""+EEG.epoch(i).eventtype];
    end
    unique(evtype)
    adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

    % Crop data for each stimulus and attend condition
    EEGfulllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
    EEGfullhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
    EEGstronglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
    EEGstronghigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
    EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
    EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));
    EEGweaklow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '57')));
    EEGweakhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '58')));

    % Bandpower (do not crop data)
    posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
    lowbin = [11.75 12.25];
    highbin = [14.75 15.25];
    
    % Specify all condition permutations (order matters for indexing below)
    allcroppedEEG = {EEGfulllow EEGfullhigh EEGstronglow EEGstronghigh ...
        EEGmedlow EEGmedhigh EEGweaklow EEGweakhigh};
    
    % ----------------- For each stimulus/attend condition ...  -------------- %
    for c = 1:length(allcroppedEEG)
       croppedEEG = allcroppedEEG{c};
       numepochs = length(croppedEEG.epoch);
       
       % ----------------- Set stimulus condition -------------- %
       if c == 1 || c == 2
           cond = "Full";
       elseif c == 3 || c == 4
           cond = "Strong";
       elseif c == 5 || c == 6
           cond = "Medium";
       else
           cond = "Weak";
       end
       
       
       % ----------------- Set attention condition -------------- %
       
       % ----------------- Calculate and set power value -------------- %
       clear powlowbin powhighbin;
       for i = 1:numepochs
           % returns power matrix (# epochs x 6 channels)
           powlowbin(i,:) = bandpower(squeeze(croppedEEG.data(posterior_channels,:,i))',croppedEEG.srate,lowbin);
           powhighbin(i,:) = bandpower(squeeze(croppedEEG.data(posterior_channels,:,i))',croppedEEG.srate,highbin);
       end
       
        % calculate mean across channels (avg over epochs x avg over chan)
        anovastruct.pow_val = [anovastruct.pow_val; mean(mean(powlowbin, 2));  mean(mean(powhighbin, 2))];
        anovastruct.freq = [anovastruct.freq; 12; 15];
        anovastruct.subj = [anovastruct.subj; curr_subj; curr_subj];                
        anovastruct.cond = [anovastruct.cond; cond; cond];
       
       if mod(c,2) == 1
           anovastruct.att = [anovastruct.att; "Attend"; "Not Attend"];
       else
           anovastruct.att = [anovastruct.att; "Not Attend"; "Attend"];
       end
       
        
    end
end
%% ANOVA: CHECK SIZE
% Select opacity conditions 
adetails.markers.types = {'51','52','53','54','55','56'};

% Create empty anova struct
clear anovastruct;
anovastruct.opacity = []; anovastruct.subj = []; anovastruct.cond = []; anovastruct.att = []; anovastruct.pow_val = []; anovastruct.freq = [];

for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};
    
    % ----------------- Set subject name -------------- %
    curr_subj = EEG.filename(1:2) + "";    
    % ----------------- Set opacity condition -------------- %
    if mod(s,2) == 1
        curr_opac = "Strong";
    else
        curr_opac = "Med";
    end
        
    % ----------------- Crop EEG for various conditions -------------- %
    % Find relevant marker and indices
    evtype = [];
    for i = 1:length(EEG.epoch)
        evtype = [evtype, ""+EEG.epoch(i).eventtype];
    end
    unique(evtype)
    adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

    % Crop data for each stimulus and attend condition
    EEGbiglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
    EEGbighigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
    EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
    EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
    EEGsmalllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
    EEGsmallhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));

    % Bandpower (do not crop data)
    posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
    lowbin = [11.75 12.25];
    highbin = [14.75 15.25];
    
    % Specify all condition permutations (order matters for indexing below)
    allcroppedEEG = {EEGbiglow EEGbighigh EEGmedlow EEGmedhigh EEGsmalllow EEGsmallhigh};
    
    % ----------------- For each stimulus/attend condition ...  -------------- %
    for c = 1:length(allcroppedEEG)
       croppedEEG = allcroppedEEG{c};
       numepochs = length(croppedEEG.epoch);
       
       
       % ----------------- Set stimulus condition -------------- %
       if c == 1 || c == 2
           cond = "Big Check";
       elseif c == 3 || c == 4
           cond = "Medium Check";
       else
           cond = "Small Check";
       end
       
       % ----------------- Calculate and set power value -------------- %
       clear powlowbin powhighbin;
       for i = 1:numepochs
           % returns power matrix (# epochs x 6 channels)
           powlowbin(i,:) = bandpower(squeeze(croppedEEG.data(posterior_channels,:,i))',croppedEEG.srate,lowbin);
           powhighbin(i,:) = bandpower(squeeze(croppedEEG.data(posterior_channels,:,i))',croppedEEG.srate,highbin);
       end
       
        % calculate mean across channels (# epochs x 1)
        anovastruct.pow_val = [anovastruct.pow_val; mean(mean(powlowbin, 2)); mean(mean(powhighbin, 2))];
        anovastruct.subj = [anovastruct.subj; curr_subj; curr_subj];                
        anovastruct.freq = [anovastruct.freq; 12; 15];
        anovastruct.opacity = [anovastruct.opacity; curr_opac; curr_opac];        
        anovastruct.cond = [anovastruct.cond; cond; cond];
        

       % ----------------- Set attention condition -------------- %
       if mod(c,2) == 1
           anovastruct.att = [anovastruct.att; "Attend"; "Not Attend"];
       else
           anovastruct.att = [anovastruct.att; "Not Attend"; "Attend"];
       end
    end
end

%% Results: OPACITY
anovastruct = anova_opac;

p_opac = anovan(anovastruct.pow_val, {anovastruct.subj anovastruct.freq anovastruct.cond anovastruct.att}, ...
    'random', 1, 'model','full','varnames',...
    {'Subject','Frequency', 'Opacity','Attend Condition'})
%% Results: CHECK SIZE
anovastruct = anova_checksize;
p_checksize = anovan(anovastruct.pow_val, ...
    {anovastruct.subj anovastruct.opacity anovastruct.freq anovastruct.cond anovastruct.att}, ...
    'random', 1, 'model','interaction','varnames',...
    {'Subject','Opacity','Frequency','Check Size','Attend Condition'})