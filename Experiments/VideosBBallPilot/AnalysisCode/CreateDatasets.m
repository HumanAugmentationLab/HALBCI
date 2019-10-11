%% 
% The purpose of this script is to create repeatable and customizable
% training and test sets for EEG data for a given experiment. 
% It should check that the files have already not been split into 
% training and test, and then it should check if there is a specified 
% file with the markers associated with the dataset that has already been
% made. Otherwise, it should create a randomized test and training set
% with the specified percentage train and also create a file with the 
% specified event numbers. 

% This assumes that the dataset has been epoched by the event markers.

%% Configuration variables.
% Directory for preprocessed EEG data (K drive is \fsvs01\Research\).
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
% File name without extension.
fnameeeg = 'BN-VideoCheckOpacity';
% File name of training set.
fname_train = 'Classification\Train-BN-VideoCheckOpacity';
% File name of test set.
fname_test = 'Classification\Test-BN-VideoCheckOpacity';
% File name of text file of markers for data split.
fname_spec = 'Classification\BN-VideoCheckOpacity';
% Probability that a data point is in the training set (between 0 and 1).
train_probability = .8;
%% Load data if needed.
if isfile(strcat(direeg, fnameeeg, '.set'))
    disp("Original processed data file found.");
end

% TODO Change these to not run if these procedures have already happened.
if isfile(strcat(direeg, fname_train, '.set')) && isfile(strcat(direeg, fname_test, '.set'))
    disp("Datasets already exist. Will not make new datasets - should be all set to classify.");
    process_datasets = 1;
else
    disp("Generating datasets.")
    process_datasets = 1;
end 
if isfile(strcat(direeg, fname_spec, '.txt'))
    disp("Text file already exists. Will not make new file. ");
    generate_text_file = 1;
else
    disp("Will generate text file.")
    generate_text_file = 1;
end
%%
% Load the .set file for the preprocessed data.
if process_datasets
    ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.set')));
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
end
%% If the text file has not already been generated, generate it and the EEG objects.
if generate_text_file
    datasetFile = fopen(strcat(direeg, fname_spec, '.txt'),'w');
    % For each marker, figure out how many events there are.
    marker_values = str2double(cell2mat({EEG.event.type}'));
    marker_types = unique(marker_values);
    marker_frequencies = zeros(size(marker_types))
    
    % Get frequencies of each marker
    for marker_index = 1:size(marker_values)
        disp(marker_values(marker_index));
        table_index = find(marker_types == marker_values(marker_index));
        marker_frequencies(table_index) = marker_frequencies(table_index)+ 1;
    end 
    
    % Find total number of training objects for each marker.
    training_event_counts = floor(train_probability.*(marker_frequencies));
    % Find total number of testing objects for each marker.
    testing_event_counts = marker_frequencies - training_event_counts;
    
    % Create a copy of the events structure, sorted by event.
    sorted_event_table = sortrows(struct2table(EEG.event), 'type'); % sort the table by 'type'
    sorted_event_struct = table2struct(sorted_event_table); % change it back to struct array if necessary

    % Grab randomized values from each, specified by epoch number, for each
    % marker index.
    % These marker types correspond directly to the frequency lists.      
    train_eeg_remove = []
    test_eeg_remove = []
    current_index = 0;
    for marker_type = 1:size(marker_types)
        total_event_count = marker_frequencies(marker_type);
        selections = randperm(total_event_count);
        fprintf(datasetFile, "\nTraining for Marker %d", marker_values(marker_type));
        for training_idx = 1:(training_event_counts(marker_type))
            chosen_epoch = sorted_event_struct(selections(training_idx) + current_index);
            test_eeg_remove = [test_eeg_remove chosen_epoch.epoch];
            fprintf(datasetFile, "\n%d ", chosen_epoch.epoch);
        end
        % Split up test set.
        fprintf(datasetFile, "\nTesting for Marker %d", marker_values(marker_type));
        for testing_idx = 1:testing_event_counts(marker_type)
            chosen_epoch = sorted_event_struct(selections(testing_idx + training_idx) + current_index);
            train_eeg_remove = [train_eeg_remove chosen_epoch.epoch];
            fprintf(datasetFile, "\n%d ", chosen_epoch.epoch);
        end
        current_index = current_index + total_event_count;
    end
end

%% TODO : Parse existing file to create datasets.
if generate_text_file
    train_eeg_remove = [];
    test_eeg_remove = [];
    datasetFile = fopen(strcat(direeg, fname_spec, '.txt'),'r');
    configuration = fscanf(datasetFile, '%c')
    
end

%% Create datasets from the train and test data structures.
training_EEG_struct = pop_select(EEG, 'notrial', train_eeg_remove)
testing_EEG_struct = pop_select(EEG, 'notrial', test_eeg_remove)
%% Save the datasets to the file system.
pop_saveset(EEG, 'filename', fname_train, 'filepath', direeg)
pop_saveset(EEG, 'filename', fname_test, 'filepath', direeg)
