%% Load all of post-ica data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% OPACITY EXPERIMENT
MD = pop_loadset('filename', 'MD-VideoCheckOpacity.set', 'filepath', direeg);
BN = pop_loadset('filename', 'BN-VideoCheckOpacity.set', 'filepath', direeg);
LO = pop_loadset('filename', 'LO-VideoCheckOpacity.set', 'filepath', direeg);
FE = pop_loadset('filename', 'FE-VideoCheckOpacity.set', 'filepath', direeg);
OP = pop_loadset('filename', 'OP-VideoCheckOpacity.set', 'filepath', direeg);
IF = pop_loadset('filename', 'IF-VideoCheckOpacity.set', 'filepath', direeg);
CV = pop_loadset('filename', 'CV-VideoCheckOpacity.set', 'filepath', direeg);
RM = pop_loadset('filename', 'RM-VideoCheckOpacity.set', 'filepath', direeg);
GR = pop_loadset('filename', 'GR-VideoCheckOpacity.set', 'filepath', direeg);
JR = pop_loadset('filename', 'JR-VideoCheckOpacity.set', 'filepath', direeg);
AI = pop_loadset('filename', 'AI-VideoCheckOpacity.set', 'filepath', direeg);
QP = pop_loadset('filename', 'QP-VideoCheckOpacity.set', 'filepath', direeg);
LT = pop_loadset('filename', 'LT-VideoCheckOpacity.set', 'filepath', direeg);
HL = pop_loadset('filename', 'HL-VideoCheckOpacity.set', 'filepath', direeg);
DC = pop_loadset('filename', 'DC-VideoCheckOpacity.set', 'filepath', direeg);
VM = pop_loadset('filename', 'VM-VideoCheckOpacity.set', 'filepath', direeg);


% CHECK SIZE EXPERIMENT
% MD = pop_loadset('filename', 'MD-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% BN = pop_loadset('filename', 'BN-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% LO = pop_loadset('filename', 'LO-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% FE = pop_loadset('filename', 'FE-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% OP = pop_loadset('filename', 'OP-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% IF = pop_loadset('filename', 'IF-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% CV = pop_loadset('filename', 'CV-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% RM = pop_loadset('filename', 'RM-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% GR = pop_loadset('filename', 'GR-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% JR = pop_loadset('filename', 'JR-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% AI = pop_loadset('filename', 'AI-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% QP = pop_loadset('filename', 'QP-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% LT = pop_loadset('filename', 'LT-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% HL = pop_loadset('filename', 'HL-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% DC = pop_loadset('filename', 'DC-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);
% VM = pop_loadset('filename', 'VM-VideoCheckSize-CombinedStrongMedium.set', 'filepath', direeg);


ALLSUBJ = {MD BN LO FE OP IF CV RM GR JR AI QP LT HL DC VM};          
disp('loaded all subject data')

%% ANOVA: OPACITY
% Select opacity conditions 
adetails.markers.types = {'51','52','53','54','55','56','57','58'};


% Create empty anova struct
clear highstruct lowstruct
highstruct.subj = []; highstruct.cond = []; highstruct.att = []; highstruct.pow_val = [];
lowstruct.subj = []; lowstruct.cond = []; lowstruct.att = []; lowstruct.pow_val = [];


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
        highstruct.pow_val = [highstruct.pow_val; mean(mean(powhighbin, 2))];
        lowstruct.pow_val = [lowstruct.pow_val; mean(mean(powlowbin, 2))];
        
        highstruct.subj = [highstruct.subj; curr_subj];     
        lowstruct.subj = [lowstruct.subj; curr_subj];              

        highstruct.cond = [highstruct.cond; cond];
        lowstruct.cond = [lowstruct.cond; cond];
       
       if mod(c,2) == 1
           lowstruct.att = [lowstruct.att; "Attend"];
           highstruct.att = [highstruct.att;"Not Attend"];
       else
           lowstruct.att = [lowstruct.att; "Not Attend"];
           highstruct.att = [highstruct.att;"Attend"];
       end
       
        
    end
end
%% ANOVA: CHECK SIZE
% Select opacity conditions 
adetails.markers.types = {'51','52','53','54','55','56'};

% Create empty anova struct
clear highstruct lowstruct;
% anovastruct.opacity = []; anovastruct.freq = [];
highstruct.subj = []; highstruct.cond = []; highstruct.att = []; highstruct.pow_val = []; 
lowstruct.subj = []; lowstruct.cond = []; lowstruct.att = []; lowstruct.pow_val = []; 

for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};
    
    % ----------------- Set subject name -------------- %
    curr_subj = EEG.filename(1:2) + "";    
    % ----------------- Set opacity condition -------------- %
%     if mod(s,2) == 1
%         curr_opac = "Strong";
%     else
%         curr_opac = "Med";
%     end
        
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
        lowstruct.pow_val = [lowstruct.pow_val; mean(mean(powlowbin, 2))];
        highstruct.pow_val = [highstruct.pow_val; mean(mean(powhighbin, 2))];
        
        lowstruct.subj = [lowstruct.subj; curr_subj];                
        highstruct.subj = [highstruct.subj; curr_subj];  
        
%         anovastruct.opacity = [anovastruct.opacity; curr_opac; curr_opac];        
        lowstruct.cond = [lowstruct.cond; cond];                    
        highstruct.cond = [highstruct.cond; cond];
        

       % ----------------- Set attention condition -------------- %
       if mod(c,2) == 1
           lowstruct.att = [lowstruct.att; "Attend"];
           highstruct.att = [highstruct.att; "Not Attend"];

       else
           lowstruct.att = [lowstruct.att; "Not Attend"];
           highstruct.att = [highstruct.att; "Attend"];
       end
    end
end

%% Results: OPACITY
% highstruct = anova_opac;

p_low = anovan(lowstruct.pow_val, ...
    {lowstruct.subj lowstruct.cond lowstruct.att}, ...
    'random', 1, 'model','interaction','varnames',...
    {'Subject','Opacity','Attend Condition'})

p_high = anovan(highstruct.pow_val, ...
    {highstruct.subj highstruct.cond highstruct.att}, ...
    'random', 1, 'model','interaction','varnames',...
    {'Subject','Opacity','Attend Condition'})



%% Results: CHECK SIZE

p_low = anovan(lowstruct.pow_val, ...
    {lowstruct.subj lowstruct.cond lowstruct.att}, ...
    'random', 1, 'model','interaction','varnames',...
    {'Subject','Checker Size','Attend Condition'})

p_high = anovan(highstruct.pow_val, ...
    {highstruct.subj highstruct.cond highstruct.att}, ...
     'random', 1,'model','interaction','varnames',...
    {'Subject','Checker Size','Attend Condition'})
