direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% list of subject names in alphabetical order
ALLSUBJ = {'AI','BN','CV','DC','FE','GR','HL','IF','JR','LO','LT','MD','OP','QP','RM','VM'}; 

num_trials = 18;

% fnameeeg = 'VideoCheckSize-Strong'; OpacLevel = categorical({'Strong'});
fnameeeg = 'VideoCheckSize-Med'; OpacLevel = categorical({'Medium'});
adetails.markers.types = {'51','52','53','54','55','56'};

% bandpower params
posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
lowbin = [11.75  12.25];
highbin = [14.75  15.25];
        

%%
ftbl.Subj = []; ftbl.BP12 = []; ftbl.BP15 = []; ftbl.Attend = []; ...
    ftbl.OpacLevel = []; ftbl.CheckLevel = []; ftbl.CheckOpac = []; ftbl.AttRating = [];
    

for s = 1:length(ALLSUBJ)
    clear EEG
    
    ioeasy = io_loadset(fullfile(direeg,strcat(ALLSUBJ{s},'-',fnameeeg,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    curr_subj = ALLSUBJ{s};

    time_threshold = 10000;
    
    if strcmp(curr_subj, 'DC')
       time_threshold = 5700; 
    end
    if strcmp(curr_subj, 'FE') || strcmp(curr_subj, 'IF') || strcmp(curr_subj, 'JR') || strcmp(curr_subj, 'MD')
        time_threshold = 7000;
    end
    
    % find index and epoch at each new trial
    break_idx = [0];
    for i = 1:length(EEG.epoch)-1
        curr_epoch = EEG.epoch(i); next_epoch = EEG.epoch(i+1);
        if contains(curr_epoch.eventtype,adetails.markers.types) && ...
                (next_epoch.eventlatency_ms - curr_epoch.eventlatency_ms > time_threshold)
            break_idx = [break_idx; i];
        end
        
    end
    break_idx = [break_idx; length(EEG.epoch)];
    length(break_idx)

    
    
    % trial corrections -- strong
%     switch curr_subj
%         case 'BN'
%             break_idx(13) = []; % false break at 210
%         case 'FE'
%             break_idx(16) = []; break_idx(19) = []; % false break at 305 (shorter than 308)
%         case 'IF'
%             break_idx(4) = []; % false break at 39
%         case 'MD'
%             break_idx(16) = []; % ... 259
%     end

    % trial corrections -- med
    switch curr_subj
        case 'DC'
            break_idx(8) = [];
        case 'FE'
            break_idx(5) = []; 
        case 'IF'
            break_idx(17) = []; break_idx(20) = [];
        case 'JR'
            break_idx(10) = [];
        case 'MD'
            break_idx(5) = []; break_idx(13) = [];
    end

    
    if length(break_idx)-1 ~= num_trials
        error("Trial length error")
    end
    
    
    
    for t = 1:num_trials
    	curr_trial = pop_select(EEG, 'trial', break_idx(t)+1:break_idx(t+1));
        curr_marker = str2double(curr_trial.event(1).type);
        
        switch curr_marker
            case 51
                attendCond = 12; checkCond = "Big";
            case 52
                attendCond = 15; checkCond = "Big";
            case 53
                attendCond = 12; checkCond = "Medium";
            case 54
                attendCond = 15; checkCond = "Medium";
            case 55
                attendCond = 12; checkCond = "Strong";
            case 56
                attendCond = 15; checkCond = "Strong";
        end
        
        for i = 1:length(curr_trial.epoch)
            bp12_trial_chan(i,:) = bandpower(squeeze(curr_trial.data(posterior_channels,:,i))',curr_trial.srate,lowbin);
            bp15_trial_chan(i,:) = bandpower(squeeze(curr_trial.data(posterior_channels,:,i))',curr_trial.srate,highbin);
        end
        
        % average across channels and epochs for one BP value/trial
        bp12 = mean(mean(bp12_trial_chan), 2);
        bp15 = mean(mean(bp15_trial_chan), 2);

        % -------------------- populate table with trial-specific data ---------------------- %
        ftbl.Attend = [ftbl.Attend; attendCond];
        ftbl.CheckLevel = [ftbl.CheckLevel; checkCond];
        ftbl.BP12 = [ftbl.BP12; bp12];
        ftbl.BP15 = [ftbl.BP15; bp15];

    
    end
   
% missing log file for DC Checker Size Medium - uncomment if statement for 
% placeholder values
%         if strcmp(curr_subj, 'DC') 
%             subj_attRating = zeros(num_trials, 1);
%         else
            % -------------------- Attention Rating ---------------------- %
            root = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\Log Files\';
            logfilestruct = dir(fullfile([root 'm*' curr_subj '-' fnameeeg '.txt']));
            logfilename = [logfilestruct.folder '\' logfilestruct.name];
            logmarker = load_marker_times(logfilename);

            subj_attRating = [];

            for i = 1:length(logmarker)
                if contains(logmarker(i).type,adetails.markers.types)
                    curr_attRating = str2double(logmarker(i+2).type) - 82;
                    subj_attRating = [subj_attRating; curr_attRating];
                end
            end

            if length(subj_attRating) ~= num_trials
                error("attention rating length error")
            end
%         end
    
    % -------------------- populate table with subj-specific data ---------------------- %

    ftbl.Subj = [ftbl.Subj; repmat(curr_subj + "", num_trials, 1)];
    ftbl.AttRating = [ftbl.AttRating; subj_attRating];
    
end

ftbl.OpacLevel = repmat(OpacLevel, num_trials*length(ALLSUBJ), 1);
ftbl.CheckOpac =  repmat(categorical({'Check'}), num_trials*length(ALLSUBJ), 1);


tbl = table();
tbl.Subj = categorical(ftbl.Subj);
tbl.CheckOpac = ftbl.CheckOpac;
tbl.CheckLevel = categorical(ftbl.CheckLevel);
tbl.OpacLevel = ftbl.OpacLevel;
tbl.Attend = ftbl.Attend;
tbl.BP12 = ftbl.BP12;
tbl.BP15 = ftbl.BP15;
tbl.AttRating = ftbl.AttRating;