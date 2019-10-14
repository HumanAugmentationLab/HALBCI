% Make combined files for Strong and Weak in fnameeeg = 'VideoCheckSize'; % 
% Read in both of their train-test split text files, and create a new file
% for train and test combined

clear

direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
%fnameeeg = 'VideoCheckOpacity';% Base of file name
finnameeeg = {'VideoCheckSize-Strong','VideoCheckSize-Med'};
foutnameeeg = 'VideoCheckSize-CombinedStrongMedium'; % 
subjects = {'BN','CV','FE', 'GR','IF','LO','MD','OP','RM'}; %

fnameTTidx = '-ttidx.txt'; % End root of test train indices (so we don't double dip)


for s = 1:length(subjects)
    
    % See if combined file exists, if not, create it, if so, error
    iotesttraintextcombined= fullfile(direeg,strcat(subjects{s},'-',foutnameeeg, fnameTTidx));
    if isfile(iotesttraintextcombined)
        input(strcat('File already exists, do you want to continue? This may cause errors. File: ',iotesttraintextcombined))
    end
    datasetFileout = fopen(iotesttraintextcombined,'w');
    
    for f = 1:length(finnameeeg)
        clear EEGpart

        EEGpart = pop_loadset(fullfile(direeg,strcat(subjects{s},'-',finnameeeg{f},'.set'))); 
    
    
    
        iotesttraintext = fullfile(direeg,strcat(subjects{s},'-',finnameeeg{f}, fnameTTidx));
        if isfile(iotesttraintext)
            disp("Loading individual text file");
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
            error('Does not have individual text files. Run this first')
            %disp(strcat('Will generate text file.',iotesttraintext));
            %[train_eeg_remove, test_eeg_remove] = makeIndexForTrainTest(EEG,train_probability,iotesttraintext);    
        end
        
        if f == 1
            EEG = EEGpart;
            
            % Write the combined text file
            
            for line = 1:length(configuration{1,3})
                fprintf(datasetFileout,'%s %d %d\n',configuration{1,1}{line},configuration{1,2}(line),configuration{1,3}(line));
            end
            
        else
            % Write text to combined file with added offset for merged eeg
            for line = 1:length(configuration{1,3})
                fprintf(datasetFileout,'%s %d %d\n',configuration{1,1}{line},configuration{1,2}(line),(configuration{1,3}(line)+size(EEG.data,3)));
            end
            
            
            % Merge EEG sets after adding index to the text file
            EEG = pop_mergeset(EEG,EEGpart);
        end
            
    end
    
    %close text fileEE
    fclose(datasetFileout);
    
    % Save the combined EEG data as a set file
    feegout = fullfile(direeg,strcat(subjects{s},'-',foutnameeeg,'.set'));
    disp('Writing output file text')
    pop_saveset(EEG,'filename',feegout);
    
end

    
