% Write data for all subjects to a .mat file table to be loaded elsewhere

direeg = 'K:HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';
%fnameeeg = 'VideoCheckOpacity';% Base of file name
fnameeeg = 'VideoCheckSize-CombinedStrongMedium'; % 
subjects = {'BN','CV','FE', 'GR','IF','LO','MD','OP','RM'}; % 

for s = 1:length(subjects)
    clear EEG
    
    ioeasy = io_loadset(fullfile(direeg,strcat(subjects{s},'-',fnameeeg,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    EEG
end

    