% Making all of the power graphics for bball video experiment (fall 2019)

% Load all of post-ica data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% OPACITY EXPERIMENT
% MD = pop_loadset('filename', 'MD-VideoCheckOpacity.set', 'filepath', direeg);
% BN = pop_loadset('filename', 'BN-VideoCheckOpacity.set', 'filepath', direeg);
% LO = pop_loadset('filename', 'LO-VideoCheckOpacity.set', 'filepath', direeg);
% FE = pop_loadset('filename', 'FE-VideoCheckOpacity.set', 'filepath', direeg);

% CHECK SIZE STRONG EXPERIMENT
% MD = pop_loadset('filename', 'MD-VideoCheckSize-Strong.set', 'filepath', direeg);
% BN = pop_loadset('filename', 'BN-VideoCheckSize-Strong.set', 'filepath', direeg);
% LO = pop_loadset('filename', 'LO-VideoCheckSize-Strong.set', 'filepath', direeg);
% FE = pop_loadset('filename', 'FE-VideoCheckSize-Strong.set', 'filepath', direeg);

% CHECK SIZE MEDIUM EXPERIMENT
MD = pop_loadset('filename', 'MD-VideoCheckSize-Med.set', 'filepath', direeg);
BN = pop_loadset('filename', 'BN-VideoCheckSize-Med.set', 'filepath', direeg);
LO = pop_loadset('filename', 'LO-VideoCheckSize-Med.set', 'filepath', direeg);
FE = pop_loadset('filename', 'FE-VideoCheckSize-Med.set', 'filepath', direeg);

ALLSUBJ = {MD BN LO FE};
disp('loaded all subject data')

%% Bandpower: OPACITY
% Select opacity conditions 
adetails.markers.types = {'51','52','53','54','55','56','57','58'};
binlabels = {'Full', 'Strong', 'Medium', 'Weak'};

meanpow_lowATTlow = zeros(length(ALLSUBJ), length(binlabels));
meanpow_lowATThigh = zeros(length(ALLSUBJ), length(binlabels));
meanpow_highATTlow = zeros(length(ALLSUBJ), length(binlabels));
meanpow_highATThigh =  zeros(length(ALLSUBJ), length(binlabels));

for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};

    evtype = [];
    for i = 1:length(EEG.epoch)
        evtype = [evtype, ""+EEG.epoch(i).eventtype];
    end
    unique(evtype)
    adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

    EEGfulllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
    EEGfullhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
    EEGstronglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
    EEGstronghigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
    EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
    EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));
    EEGweaklow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '57')));
    EEGweakhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '58')));

    % Bandpower (do not crop data)
    posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
    lowbin = [11.75 12.25];
    highbin = [14.75 15.25];

    clear powfull_lowATTlow powfull_highATTlow powfull_lowATThigh powfull_highATThigh ...
        powstrong_lowATTlow powstrong_highATTlow powstrong_lowATThigh powstrong_highATThigh ...
        powmed_lowATTlow powmed_highATTlow powmed_lowATThigh powmed_highATThigh ...
        powweak_lowATTlow powweak_highATTlow powweak_lowATThigh powweak_highATThigh

    for i = 1:length(EEGfulllow.epoch)
        powfull_lowATTlow(i,:) = bandpower(squeeze(EEGfulllow.data(posterior_channels,:,i))',EEGfulllow.srate,lowbin);
        powfull_highATTlow(i,:) = bandpower(squeeze(EEGfulllow.data(posterior_channels,:,i))',EEGfulllow.srate,highbin);
    end
    for i = 1:length(EEGfullhigh.epoch)
        powfull_lowATThigh(i,:) = bandpower(squeeze(EEGfullhigh.data(posterior_channels,:,i))',EEGfullhigh.srate,lowbin);
        powfull_highATThigh(i,:) = bandpower(squeeze(EEGfullhigh.data(posterior_channels,:,i)'),EEGfullhigh.srate,highbin);
    end
    for i = 1:length(EEGstronglow.epoch)
        powstrong_lowATTlow(i,:) = bandpower(squeeze(EEGstronglow.data(posterior_channels,:,i)'),EEGstronglow.srate,lowbin);
        powstrong_highATTlow(i,:) = bandpower(squeeze(EEGstronglow.data(posterior_channels,:,i)'),EEGstronglow.srate,highbin);
    end
    for i = 1:length(EEGstronghigh.epoch)
        powstrong_lowATThigh(i,:) = bandpower(squeeze(EEGstronghigh.data(posterior_channels,:,i)'),EEGstronghigh.srate,lowbin);
        powstrong_highATThigh(i,:) = bandpower(squeeze(EEGstronghigh.data(posterior_channels,:,i)'),EEGstronghigh.srate,highbin);
    end
    for i = 1:length(EEGmedlow.epoch)
        powmed_lowATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,lowbin);
        powmed_highATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,highbin);
    end
    for i = 1:length(EEGmedhigh.epoch)
        powmed_lowATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,lowbin);
        powmed_highATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,highbin);
    end
    for i = 1:length(EEGweaklow.epoch)
        powweak_lowATTlow(i,:) = bandpower(squeeze(EEGweaklow.data(posterior_channels,:,i)'),EEGweaklow.srate,lowbin);
        powweak_highATTlow(i,:) = bandpower(squeeze(EEGweaklow.data(posterior_channels,:,i)'),EEGweaklow.srate,highbin);
    end
    for i = 1:length(EEGweakhigh.epoch)
        powweak_lowATThigh(i,:) = bandpower(squeeze(EEGweakhigh.data(posterior_channels,:,i)'),EEGweakhigh.srate,lowbin);
        powweak_highATThigh(i,:) = bandpower(squeeze(EEGweakhigh.data(posterior_channels,:,i)'),EEGweakhigh.srate,highbin);
    end

    % Plot bandpower
    % Average power over channels (N trials x 4 conds)
    avgchan_lowATTlow = {mean(powfull_lowATTlow,2) mean(powstrong_lowATTlow,2)  ...
        mean(powmed_lowATTlow,2) mean(powweak_lowATTlow,2) };
    
    avgchan_lowATThigh = {mean(powfull_lowATThigh,2) mean(powstrong_lowATThigh,2) ...
        mean(powmed_lowATThigh,2) mean(powweak_lowATThigh,2) };

    avgchan_highATTlow = {mean(powfull_highATTlow,2) mean(powstrong_highATTlow,2)  ...
        mean(powmed_highATTlow,2) mean(powweak_highATTlow,2)};
    
    avgchan_highATThigh = {mean(powfull_highATThigh,2) mean(powstrong_highATThigh,2) ...
        mean(powmed_highATThigh,2) mean(powweak_highATThigh,2)};

    for b = 1:length(binlabels)
        meanpow_lowATTlow(s, b) = mean(avgchan_lowATTlow{b});
        meanpow_lowATThigh(s, b) = mean(avgchan_lowATThigh{b}); 
        meanpow_highATTlow(s, b) = mean(avgchan_highATTlow{b}); 
        meanpow_highATThigh(s, b) = mean(avgchan_highATThigh{b}); 
       
    end

end

%% Bandpower: CHECK SIZE

% Select by condition (check size)
adetails.markers.types = {'51','52','53','54','55','56'};
binlabels = {'Big Check', 'Medium Check', 'Small Check'};

meanpow_lowATTlow = zeros(length(ALLSUBJ), length(binlabels));
meanpow_lowATThigh = zeros(length(ALLSUBJ), length(binlabels));
meanpow_highATTlow = zeros(length(ALLSUBJ), length(binlabels));
meanpow_highATThigh =  zeros(length(ALLSUBJ), length(binlabels));

for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};

    evtype = [];
    for i = 1:length(EEG.epoch)
        evtype = [evtype, ""+EEG.epoch(i).eventtype];
    end
    unique(evtype)
    adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

    lastEEG = EEG;

    EEGbiglow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '51')));
    EEGbighigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '52')));
    EEGmedlow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '53')));
    EEGmedhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '54')));
    EEGsmalllow = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '55')));
    EEGsmallhigh = pop_select(EEG, 'trial', find(contains(adetails.markers.trialevents, '56')));

    % Bandpower (do not crop data)
    posterior_channels = [4 7 8 20 21 32];    % Pz O1 O2 Oz PO4 PO3
    lowbin = [11.75  12.25];
    highbin = [14.75  15.25];

    clear powsm_lowATTlow powsm_highATTlow powsm_lowATThigh powsm_highATThigh ...
        powmed_lowATTlow powmed_highATTlow powmed_lowATThigh powmed_highATThigh ...
        powbig_lowATTlow powbig_highATTlow powbig_lowATThigh powbig_highATThigh

    for i = 1:length(EEGsmalllow.event)
        powsm_lowATTlow(i,:) = bandpower(squeeze(EEGsmalllow.data(posterior_channels,:,i))',EEGsmalllow.srate,lowbin);
        powsm_highATTlow(i,:) = bandpower(squeeze(EEGsmalllow.data(posterior_channels,:,i))',EEGsmalllow.srate,highbin);
    end

    for i = 1:length(EEGsmallhigh.event)
        powsm_lowATThigh(i,:) = bandpower(squeeze(EEGsmallhigh.data(posterior_channels,:,i))',EEGsmallhigh.srate,lowbin);
        powsm_highATThigh(i,:) = bandpower(squeeze(EEGsmallhigh.data(posterior_channels,:,i)'),EEGsmallhigh.srate,highbin);
    end

    for i = 1:length(EEGmedlow.event)
        powmed_lowATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,lowbin);
        powmed_highATTlow(i,:) = bandpower(squeeze(EEGmedlow.data(posterior_channels,:,i)'),EEGmedlow.srate,highbin);
    end

    for i = 1:length(EEGmedhigh.event)
        powmed_lowATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,lowbin);
        powmed_highATThigh(i,:) = bandpower(squeeze(EEGmedhigh.data(posterior_channels,:,i)'),EEGmedhigh.srate,highbin);
    end

    for i = 1:length(EEGbiglow.event)
        powbig_lowATTlow(i,:) = bandpower(squeeze(EEGbiglow.data(posterior_channels,:,i)'),EEGbiglow.srate,lowbin);
        powbig_highATTlow(i,:) = bandpower(squeeze(EEGbiglow.data(posterior_channels,:,i)'),EEGbiglow.srate,highbin);
    end

    for i = 1:length(EEGbighigh.event)
        powbig_lowATThigh(i,:) = bandpower(squeeze(EEGbighigh.data(posterior_channels,:,i)'),EEGbighigh.srate,lowbin);
        powbig_highATThigh(i,:) = bandpower(squeeze(EEGbighigh.data(posterior_channels,:,i)'),EEGbighigh.srate,highbin);
    end
    
    % Average power over channels (N trials x 4 conds)
    avgchan_lowATTlow = {mean(powbig_lowATTlow,2) mean(powmed_lowATTlow,2) mean(powsm_lowATTlow,2) };
    avgchan_lowATThigh = {mean(powbig_lowATThigh,2) mean(powmed_lowATThigh,2) mean(powsm_lowATThigh,2) };
    avgchan_highATTlow = {mean(powbig_highATTlow,2) mean(powmed_highATTlow,2) mean(powsm_highATTlow,2)};
    avgchan_highATThigh = {mean(powbig_highATThigh,2) mean(powmed_highATThigh,2) mean(powsm_highATThigh,2)};

    for b = 1:length(binlabels)
        meanpow_lowATTlow(s, b) = mean(avgchan_lowATTlow{b});
        meanpow_lowATThigh(s, b) = mean(avgchan_lowATThigh{b}); 
        meanpow_highATTlow(s, b) = mean(avgchan_highATTlow{b}); 
        meanpow_highATThigh(s, b) = mean(avgchan_highATThigh{b}); 
       
    end
end

disp('populated all check size power data')

%% Plot
% meanpowLOW : 12 Hz power (4 subj x 4  cond)
% meanpowHIGH : 15 Hz power (4 subj x 4  cond)

figure; 
% sgtitle('ALL Subjects: Opacity Experiment'); 
sgtitle('ALL Subjects: Check Size Medium Experiment'); 

subplot(1,2,1); hold on
ylabel('12 Hz Power'); xlabel('Stimuli Type');
xticks(1:length(binlabels)); xticklabels(binlabels);
% use error bars to plot the range of subject values
errorbar(1:length(binlabels), mean(meanpow_lowATTlow), min(meanpow_lowATTlow), max(meanpow_lowATTlow), 'LineWidth', 2)
errorbar(1:length(binlabels), mean(meanpow_lowATThigh), min(meanpow_lowATThigh), max(meanpow_lowATThigh), 'LineWidth', 2)
legend({'Attend 12 Hz', 'Attend 15 Hz'})

subplot(1,2,2); hold on
ylabel('15 Hz Power'); xlabel('Stimuli Type');
xticks(1:length(binlabels)); xticklabels(binlabels);
% use error bars to plot the range of subject values
errorbar(1:length(binlabels), mean(meanpow_highATTlow), min(meanpow_highATTlow), max(meanpow_highATTlow), 'LineWidth', 2)
errorbar(1:length(binlabels), mean(meanpow_highATThigh), min(meanpow_highATThigh), max(meanpow_highATThigh), 'LineWidth', 2)
legend({'Attend 12 Hz', 'Attend 15 Hz'})



