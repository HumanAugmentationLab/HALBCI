% EEGLAB history file generated on the 27-Jul-2017
% ------------------------------------------------

EEG.setname='Sam815';
EEG = eeg_checkset( EEG );
figure; topoplot([],EEG.chanlocs, 'style', 'blank',  'electrodes', 'labelpoint', 'chaninfo', EEG.chaninfo);
pop_eegplot( EEG, 1, 1, 1);
figure; pop_spectopo(EEG, 1, [0  473998], 'EEG' , 'percent', 15, 'freq', [6 10 22], 'freqrange',[2 25],'electrodes','on');
EEG = pop_eegfiltnew(EEG, 0.5, 56, 3300, 0, [], 1);
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
EEG = eeg_checkset( EEG );
