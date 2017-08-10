%Testing affect of ICA on all data, all epochs, and high vs. low epochs

figure; pop_spectopo(afez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');
figure; pop_spectopo(nez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');

% Full Data
fullcontiez = afez;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    fullcontiez.(char(variableComps(i))) = fulliez.(char(variableComps(i)));
end
fullsez = pop_subcomp(fullcontiez, fullrej);
figure; pop_spectopo(fullsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');

% High vs Low Data
efullcontiez = nez;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    efullcontiez.(char(variableComps(i))) = efulliez.(char(variableComps(i)));
end
efullsez = pop_subcomp(efullcontiez, efullrej);
figure; pop_spectopo(efullsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');

% Concat Data
concatcontiez = nez;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    if i == 3 || i == 5
        concatcontiez.(char(variableComps(i))) = [lowiez.(char(variableComps(i)))];
    elseif i == 4
        concatcontiez.(char(variableComps(i))) = [lowiez.(char(variableComps(i))); highiez.(char(variableComps(i)))];
    else
        concatcontiez.(char(variableComps(i))) = [lowiez.(char(variableComps(i))) highiez.(char(variableComps(i)))];
    end
end
concatsez = pop_subcomp(concatcontiez, concatrej);
figure; pop_spectopo(concatsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');

% Low Only
lowcontiez = lowfreq_b;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    lowcontiez.(char(variableComps(i))) = lowiez.(char(variableComps(i)));
end
lowkeep = [6 9 12 19]; % 12 Only
lowrej = 1:26; lowrej(lowkeep) = [];
lowsez = pop_subcomp(lowcontiez, lowrej);

% High Only
highcontiez = highfreq_b;
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    highcontiez.(char(variableComps(i))) = highiez.(char(variableComps(i)));
end
highkeep = [4 11 14]; % 15 Only
highrej = 1:26; highrej(highkeep) = [];
highsez = pop_subcomp(highcontiez, highrej);

% Pre ICA
figure; pop_spectopo(lowiez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');
figure; pop_spectopo(highiez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');

% Post ICA
figure; pop_spectopo(lowsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');
figure; pop_spectopo(highsez, 1, [0  8998], 'EEG' , 'percent', 100, 'freq', [10 12 15], 'freqrange',[5 25],'electrodes','on');
