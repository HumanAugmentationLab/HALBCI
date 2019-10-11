%% Load BCILAB
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab
%% Load all of post-ica data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% OPACITY EXPERIMENT
MD = pop_loadset('filename', 'MD-VideoCheckOpacity.set', 'filepath', direeg);
MD.logfile = 'marker_20190914-MD-VideoCheckOpacity-01';
BN = pop_loadset('filename', 'BN-VideoCheckOpacity.set', 'filepath', direeg);
BN.logfile = 'marker_20190915-BN-VideoCheckOpacity-01';
LO = pop_loadset('filename', 'LO-VideoCheckOpacity.set', 'filepath', direeg);
LO.logfile = 'marker_20190919-LO-VideoCheckOpacity';
FE = pop_loadset('filename', 'FE-VideoCheckOpacity.set', 'filepath', direeg);
FE.logfile = 'marker_20190921-FE-VideoCheckOpacity';
OP = pop_loadset('filename', 'OP-VideoCheckOpacity.set', 'filepath', direeg);
OP.logfile = 'marker_20190926-OP-VideoCheckOpacity';
IF = pop_loadset('filename', 'IF-VideoCheckOpacity.set', 'filepath', direeg);
IF.logfile = 'marker_20190928-IF-VideoCheckOpacity';
CV = pop_loadset('filename', 'CV-VideoCheckOpacity.set', 'filepath', direeg);
CV.logfile = 'marker_20190926-OP-VideoCheckOpacity';
RM = pop_loadset('filename', 'RM-VideoCheckOpacity.set', 'filepath', direeg);
RM.logfile = 'marker_20191003-RM-VideoCheckOpacity';
GR = pop_loadset('filename', 'GR-VideoCheckOpacity.set', 'filepath', direeg);
GR.logfile = 'marker_20191006-GR-VideoCheckOpacity';


% CHECK SIZE STRONG EXPERIMENT
% MD_Strong = pop_loadset('filename', 'MD-VideoCheckSize-Strong.set', 'filepath', direeg);
% BN_Strong = pop_loadset('filename', 'BN-VideoCheckSize-Strong.set', 'filepath', direeg);
% LO_Strong = pop_loadset('filename', 'LO-VideoCheckSize-Strong.set', 'filepath', direeg);
% FE_Strong = pop_loadset('filename', 'FE-VideoCheckSize-Strong.set', 'filepath', direeg);

% CHECK SIZE MEDIUM EXPERIMENT
% MD_Med = pop_loadset('filename', 'MD-VideoCheckSize-Med.set', 'filepath', direeg);
% BN_Med = pop_loadset('filename', 'BN-VideoCheckSize-Med.set', 'filepath', direeg);
% LO_Med = pop_loadset('filename', 'LO-VideoCheckSize-Med.set', 'filepath', direeg);
% FE_Med = pop_loadset('filename', 'FE-VideoCheckSize-Med.set', 'filepath', direeg);

% ALLSUBJ = {MD BN LO FE OP IF CV RM GR};  
ALLSUBJ = {LO};
figure; sgtitle('Opacity: Reported Attention vs. Attended Power')


%% Select target EEG data

for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};
    
    % Select opacity conditions 
    adetails.markers.types = {'51','52','53','54','55','56','57','58'};

    root = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\Log Files\';
    logfilename = [root EEG.logfile '.txt'];

    logmarker = load_marker_times(logfilename);

    og_markers = []; og_response = []; og_latency = [];

    for i = 1:length(logmarker)
        if contains(logmarker(i).type,adetails.markers.types)
            logmarker(i)
            logmarker(i+2)
           og_markers = [og_markers str2double(logmarker(i).type)];
           og_response = [og_response str2double(logmarker(i+2).type) - 82];
           og_latency = [og_latency logmarker(i+3).latency_ms];
        end
    end


% Create empty anova struct
lowstruct.pow_val = []; lowstruct.var = []; lowstruct.survey = [];
highstruct.pow_val = []; highstruct.var = []; highstruct.survey = [];

% ----------------- Crop EEG for various conditions -------------- %
% Find relevant marker and indices
evtype = [];

for i = 1:length(EEG.epoch)
    evtype = [evtype, ""+EEG.epoch(i).eventtype];
%         evtype = [evtype, str2num(EEG.epoch(i).eventtype)];
end

unique(evtype)
adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

new_markers = []; new_response = [];
first_latency = EEG.epoch(1).eventlatency_ms;
nextgoodindex = 1;
switch_idx = ones(1, length(og_markers));

for t = 1:length(og_markers)
    curr_marker = ""+og_markers(t);
    
    for i = nextgoodindex:length(EEG.epoch)
        if strcmp(curr_marker, ""+EEG.epoch(i).eventtype) && EEG.epoch(i).eventlatency_ms < first_latency + 60000
            new_markers = [new_markers str2double(EEG.epoch(i).eventtype)];
            new_response = [new_response og_response(t)];
            nextgoodindex = i+1;
        else
            % when markers stop matching, start over with next marker
            first_latency = EEG.epoch(nextgoodindex).eventlatency_ms;
            switch_idx(t+1) = nextgoodindex;
            break;
        end
        
    end
 end



% Bandpower (do not crop data)
posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [11.75 12.25];
highbin = [14.75 15.25];


% ----------------- For each epoch  -------------- %
for c = 1:length(og_markers)
    if c < length(og_markers)
        croppedEEG = pop_select(EEG, 'trial', switch_idx(c):switch_idx(c+1)-1);
    else
        croppedEEG = pop_select(EEG, 'trial', switch_idx(c):length(EEG.epoch));
    end
   % ----------------- Calculate and set power value -------------- %
   clear powlowbin powhighbin;
   
   % only populate structures for attended power
   

       
   % returns power matrix (1 epochs x 6 channels)
   for i = 1:length(croppedEEG.epoch)
       % returns power matrix (# epochs x 6 channels)
       powlowbin(i,:) = bandpower(squeeze(croppedEEG.data(posterior_channels,:,i))',croppedEEG.srate,lowbin);
       powhighbin(i,:) = bandpower(squeeze(croppedEEG.data(posterior_channels,:,i))',croppedEEG.srate,highbin);
   end
   
   % # epochs x avg chan
   powlowbin_mergechan = mean(powlowbin, 2);
   powhighbin_mergechan = mean(powhighbin, 2);

   % only populate structures for attended power
      if mod(c,2) == 1
        lowstruct.pow_val = [lowstruct.pow_val; mean(powlowbin_mergechan)];
        lowstruct.var = [lowstruct.var; var(powlowbin_mergechan)];
        lowstruct.survey = [lowstruct.survey;  og_response(c)];
      else
        highstruct.pow_val = [highstruct.pow_val; mean(powhighbin_mergechan)];
        highstruct.var = [highstruct.var; var(powhighbin_mergechan)];
        highstruct.survey = [highstruct.survey; og_response(c)];

      end
   
    % calculate mean across channels (avg epoch x avg chan)
%     lowstruct.pow_val = [lowstruct.pow_val; mean(powlowbin_mergechan)];
%     highstruct.pow_val = [highstruct.pow_val; mean(powhighbin_mergechan)];
% 
%     lowstruct.var = [lowstruct.var; var(powlowbin_mergechan)];
%     highstruct.var = [lowstruct.var; var(powhighbin_mergechan)];

end

% Plot attention score vs. attended powers and variance 
subplot(2,2,1); hold on; xlim([1 5])
title('12 Hz: Power'); xlabel('Attention Score'); ylabel('Attend Power');
scatter(lowstruct.survey, lowstruct.pow_val, 'filled')

subplot(2,2,3); hold on; xlim([1 5])
title('12 Hz: Variance'); xlabel('Attention Score'); ylabel('Attend Variance');
scatter(lowstruct.survey, lowstruct.var,  'filled')

subplot(2,2,2); hold on; xlim([1 5])
title('15 Hz: Power'); xlabel('Attention Score'); ylabel('Attend Power');
scatter(highstruct.survey, highstruct.pow_val,  'filled')

subplot(2,2,4); hold on; xlim([1 5])
title('15 Hz: Variance'); xlabel('Attention Score'); ylabel('Attend Variance');
scatter(highstruct.survey, highstruct.var, 'filled')

end