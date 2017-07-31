cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;
cd C:\Users\alakmazaheri\Documents\BCI\HALBCI

cd C:\Users\alakmazaheri\Documents\BCI\BCILAB\dependencies\eeglab13_4_4b
eeglab

EEG = pop_loadxdf('C:\Users\alakmazaheri\Documents\BCI\Enobio Data\SamTest2.xdf');
EEGOUT = pop_eegfilt( EEG, 0.1, 56, 4);

theta = bandpower(EEG.data,EEG.srate,[4 8]);
alpha = bandpower(x,srate,[8 12]);