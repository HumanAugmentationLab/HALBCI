function [train_eeg_remove,test_eeg_remove] = makeIndexForTrainTest(EEG,train_probability,iotesttraintext)
%UNTITLED5 Determine train and test and write to a file
%   Detailed explanation goes here


        datasetFile = fopen(iotesttraintext,'w');
% For each marker, figure out how many events there are.
        marker_values = str2double(cell2mat({EEG.epoch.eventtype}'));
        marker_types = unique(marker_values);
        marker_frequencies = zeros(size(marker_types));

        % Get frequencies of each marker
        for mvi = 1:length(marker_types); marker_frequencies(mvi)= sum(marker_values==marker_types(mvi));  end
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
    train_eeg_remove = [];
    test_eeg_remove = [];
    current_index = 0;
    for marker_type = 1:size(marker_types)
        total_event_count = marker_frequencies(marker_type);
        selections = randperm(total_event_count);
        for training_idx = 1:(training_event_counts(marker_type))
            chosen_epoch = sorted_event_struct(selections(training_idx) + current_index);
            test_eeg_remove = [test_eeg_remove chosen_epoch.epoch];
            fprintf(datasetFile, "Train %d %d\n", marker_types(marker_type), chosen_epoch.epoch);
        end
        % Split up test set.
        for testing_idx = 1:testing_event_counts(marker_type)
            chosen_epoch = sorted_event_struct(selections(testing_idx + training_idx) + current_index);
            train_eeg_remove = [train_eeg_remove chosen_epoch.epoch];
            fprintf(datasetFile, "Test %d %d\n", marker_types(marker_type), chosen_epoch.epoch);
        end
        current_index = current_index + total_event_count;
    end


end

