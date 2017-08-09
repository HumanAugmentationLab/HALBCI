%This script will take the data we just recorded and turn it into a super
%matrix that contains the frequency analysis of all the channels for all
%the trials.
allData = struct
nameList = {'20170806165229_PatientW1-12v15-medium'
'20170806164107_PatientW1-7.5v12-small'
'20170806162852_PatientW1-12v30-small'
'20170806161942_PatientW1-15v20-big'
'20170806160959_PatientW1-7.5v12-big'
'20170806154747_PatientW1-7.5v12-small'
'20170806153807_PatientW1-15v20-small'
'20170806152814_PatientW1-7.5v12-small'
'20170806151821_PatientW1-7.5v20-small'
'20170806150345_PatientW1-15v20-small'};

if ~exist('nameListLoaded','var')
    for i = 1:length(nameList)
        pathToData = strcat('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/',char(nameList(i)),'.easy');
        disp(pathToData);
        %Load the data set
        a = io_loadset(pathToData);
        ez = exp_eval(a); % Load EASY file
        nameListLoaded(i) = ez; 
    end
end

freqList = [12, 15; 7.5, 12; 12, 30; 15, 20; 7.5, 12; 7.5, 12; 15, 20; 7.5, 12; 7.5, 20; 15, 20];
sizeList = [6, 2, 2, 20, 20, 2, 2, 2, 2, 2];
%channels = {'P3', 'P4','O1','O2','CP1','CP2','CP6','PO3','PO4'};
channels = {ez.chanlocs.labels}
numberTrials = 36;
numberChannels = length(channels);
numberFrequencies = 513;


allData.nameList = nameList;
allData.freqList = freqList;
allData.channels = channels;
allData.sizeList = sizeList;
%Trials by Frequency by Channels
allData.DataTCF = zeros(numberTrials*length(nameList), numberChannels, numberFrequencies);
allData.attIndex = zeros(numberTrials*length(nameList),1);
allData.unattIndex = zeros(numberTrials*length(nameList),1);
allData.sizeIndex = zeros(numberTrials*length(nameList),1);
allData.channels = channels;



for i = 1:length(nameList)
    %Declare the dataset path we are using
    ez = nameListLoaded(i);
    %Declare what each stimulus maps to what frequency and which
    %checkerboard size we are using
    freqs = freqList(i,:);
    checker = sizeList(i);
    %Filter the data
    afez = exp_eval(flt_fir(ez,[0.1 0.5 48 56]));
    %Extract the Epochs and the desired channesl
    nez = exp_eval(flt_selchans(afez, channels));
    firstFreqEpochs = exp_eval(pop_epoch(nez, {'110', '120'}, [1 9]));
    secondFreqEpochs = exp_eval(pop_epoch(nez, {'210', '220'}, [1 9]));
   
    firstSize = size(firstFreqEpochs.data);
    secondSize =  size(secondFreqEpochs.data);
    if firstSize(3)+secondSize(3) ~= 36
        disp(i)
        disp(firstSize(3))
        disp(secondSize(3))
    end
    for j = 1:firstSize(3)+secondSize(3) % calculate spectra for each epoch
        if j <= firstSize(3)
            [spectra, freq,~,~,~] = spectopo(firstFreqEpochs.data(:,:,j), ...
                firstSize(2), firstFreqEpochs.srate,'plot','off');
            marker = freqs(1);
            unmarker = freqs(2);
        else
            [spectra, freq,~,~,~] = spectopo(secondFreqEpochs.data(:,:,j-firstSize(3)),...
                secondSize(2), secondFreqEpochs.srate,'plot','off');
            marker = freqs(2);
            unmarker = freqs(1);
        end
        allData.DataTCF((i-1)*numberTrials+j,:,:) = spectra;
        allData.attIndex((i-1)*numberTrials+j) = double(marker);
        allData.unattIndex((i-1)*numberTrials+j) = double(unmarker);
        allData.sizeIndex((i-1)*numberTrials+j) = checker;
        disp((i-1)*numberTrials+j)
        
    end
    allData.freq = freq;
    

    
    
end

save('superMatrix.mat','allData')