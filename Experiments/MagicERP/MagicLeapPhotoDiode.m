direeg = 'C:\Users\saman\Documents\NIC'
fnameeeg = '20200221134713_Patient01_Run';

% Load the .easy file version of the data
ioeasy = io_loadset(fullfile(direeg,strcat(fnameeeg,'.easy'))); %requires .info file
EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data

%% try again
direeg = 'C:\Users\saman\Documents\NIC'
fnameeeg = '20200221134713_Patient01_Run';
EEG = pop_easy(strcat(direeg,'\',fnameeeg,'.easy'),0,1,'1')


%%
eeg51= pop_epoch(EEG);
eeg52= pop_epoch(EEG);
%%
figure
plot(eeg51.times,squeeze(eeg51.data(1,:,110:114)),'b.')
hold on
plot(eeg52.times,squeeze(eeg52.data(1,:,30:40)),'r.')

%% Analyze with 
idxtimes= eeg51.times < 200 & eeg51.times > -1;
max51 = max(eeg51.data(1,idxtimes,:));
max52 = max(eeg52.data(1,idxtimes,:));
mean(max52)
mean(max51)

figure
histogram(max51)
hold on
mean(max52)
histogram(max52)
