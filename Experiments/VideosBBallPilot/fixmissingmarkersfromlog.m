% Fix missing markers
% This currently removes the high 80s markers, which are not in the log
% file. I could write something to add them back in if we use them.

logfilename = 'K:/HumanAugmentationLab/EEGdata/EnobioTests/VideoSSVEP/Log Files/marker_experiment3-30_PK_log4.txt';
baseinfo = '20190330105913_PKVideoCheckSizePilot-4_Test';


eegfilenamein = strcat('K:/HumanAugmentationLab/EEGdata/EnobioTests/VideoSSVEP/',baseinfo,'.easy');
eegfilenameout = strcat('K:/HumanAugmentationLab/EEGdata/EnobioTests/VideoSSVEP/',baseinfo,'_newmarkers.set');

logmarker = load_marker_times(logfilename);

ioeasy = io_loadset(eegfilenamein); %requires .info file
EEG = exp_eval(ioeasy);
origeegmarkers = EEG.event;

%% now view the two data sets (EEG.event and log markers)
% find a marker that is the same in the two, and put the corresponding row
% numbers
%logmarkerrow = 195; 
%eegmarkerrow = 210;
logmarkerrow = 1; 
eegmarkerrow = 1;


%%


for i = 1:length(origeegmarkers)
    lattp(i) = origeegmarkers(i).latency;
    latms(i) = origeegmarkers(i).latency_ms;
end
figure 
plot(lattp,latms,'o'); xlabel('TP');ylabel('MS');title('origeeg');
P = polyfit(lattp,latms,1) % this gives you slope and offset (slope should be 2 for 500 hz)
corr(lattp',latms') %if not 1, then issue

a = round(latms./P(1) - P(2));
b =mean(lattp-a) % single value offset -1 ?? for latency ms vs tp difference in original eegdata
% I don't understand why P(2) is not capturing this.. perhaps using floor
% instead of round for P(2) would solve this

% for log markers
for i = 1:length(logmarker)
    log_latms(i) = round(logmarker(i).latency_ms);
    %log_lat(i) = logmarker(i).latency;
    log_mn{i} = logmarker(i).type;
end


%
% Find the event latency (ms for eeg)
Ems = latms(eegmarkerrow) %eeg markers
Lms = log_latms(logmarkerrow) %log markers

LminusE = Lms-Ems %offset to get log to EEG

newmarkers_ms = log_latms - LminusE;

%
newmarker_tp = round(newmarkers_ms./P(1) - P(2) + b); %the minus 1 is because the values were offset for the eeg data
figure;
plot(newmarker_tp, newmarkers_ms,'o'); title('newmarkers');xlabel('TP');ylabel('MS');

% sort the markers
[snewmarkers_ms, sortind] = sort(newmarkers_ms);
snewmarker_tp = newmarker_tp(sortind);
slog_mn = log_mn(sortind);

%% Put the data into eeg
% first clear the data (but preserve the format)
EEG.event = [];
for i = 1:length(newmarker_tp)
    EEG.event(i).type = slog_mn{i};
    EEG.event(i).latency = snewmarker_tp(i);
    EEG.event(i).latency_ms = snewmarkers_ms(i);
end
%% after checking, save file

pop_saveset(EEG,'filename',eegfilenameout)

