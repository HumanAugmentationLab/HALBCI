direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% list of subject names in alphabetical order
ALLSUBJ = {'AI','BN','CV','DC','FE','GR','HL','IF','JR','LO','LT','MD','OP','QP','RM','VM'}; 


fnameeeg = 'VideoCheckOpacity';
adetails.markers.types = {'51','52','53','54','55','56','57','58'};
num_trials = 16;


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

    % find index and epoch at each new trial
    break_idx = [0];
    for i = 1:length(EEG.epoch)-1
        curr_epoch = EEG.epoch(i); next_epoch = EEG.epoch(i+1);
        if contains(curr_epoch.eventtype,adetails.markers.types) && ...
                (next_epoch.eventlatency_ms - curr_epoch.eventlatency_ms > 10000)
            break_idx = [break_idx; i];
        end
        
    end
    break_idx = [break_idx; length(EEG.epoch)];
    
    switch curr_subj
        case 'FE'
            break_idx(13) = []; % false break at 219
        case 'IF'
            break_idx(7) = []; % false break at 104
        case 'JR'
            break_idx(9) = []; % false break at 136
        case 'QP'
            break_idx(3) = []; break_idx(6) = [];
        case 'VM'
            break_idx(16) = []; % false break at event 285 or 288 ... chose to break at longer gap
    end
    
    if length(break_idx)-1 ~= num_trials
        error("Trial length error")
    end
    
    
    
    for t = 1:num_trials
    	curr_trial = pop_select(EEG, 'trial', break_idx(t)+1:break_idx(t+1));
        curr_marker = str2double(curr_trial.event(1).type);
        
        switch curr_marker
            case 51
                attendCond = 12; opacCond = "Full";
            case 52
                attendCond = 15; opacCond = "Full";
            case 53
                attendCond = 12; opacCond = "Strong";
            case 54
                attendCond = 15; opacCond = "Strong";
            case 55
                attendCond = 12; opacCond = "Medium";
            case 56
                attendCond = 15; opacCond = "Medium";
            case 57
                attendCond = 12; opacCond = "Weak";
            case 58
                attendCond = 15; opacCond = "Weak";
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
        ftbl.OpacLevel = [ftbl.OpacLevel; opacCond];
        ftbl.BP12 = [ftbl.BP12; bp12];
        ftbl.BP15 = [ftbl.BP15; bp15];

    
    end
   
    
    % -------------------- Attention Rating ---------------------- %
    root = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\2019\Log Files\';
    logfilestruct = dir(fullfile([root 'm*' curr_subj '*' fnameeeg '*.txt']));
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
    
    
    % -------------------- populate table with subj-specific data ---------------------- %

    ftbl.Subj = [ftbl.Subj; repmat(curr_subj + "", num_trials, 1)];
    ftbl.AttRating = [ftbl.AttRating; subj_attRating];
    
end

% check size was always 'small' in opacity experiments
ftbl.CheckLevel = repmat(categorical({'Small'}), num_trials*length(ALLSUBJ), 1);
ftbl.CheckOpac =  repmat(categorical({'Opac'}), num_trials*length(ALLSUBJ), 1);


tbl = table();
tbl.Subj = categorical(ftbl.Subj);
tbl.CheckOpac = ftbl.CheckOpac;
tbl.CheckLevel = ftbl.CheckLevel;
tbl.OpacLevel = categorical(ftbl.OpacLevel);
tbl.Attend = ftbl.Attend;
tbl.BP12 = ftbl.BP12;
tbl.BP15 = ftbl.BP15;
tbl.AttRating = ftbl.AttRating;