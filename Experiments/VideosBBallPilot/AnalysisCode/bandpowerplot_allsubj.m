%% OPACITY EXPERIMENTS

% Load all of post-ica data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

% OPACITY EXPERIMENT
MD = pop_loadset('filename', 'MD-VideoCheckOpacity.set', 'filepath', direeg);
BN = pop_loadset('filename', 'BN-VideoCheckOpacity.set', 'filepath', direeg);
LO = pop_loadset('filename', 'LO-VideoCheckOpacity.set', 'filepath', direeg);
FE = pop_loadset('filename', 'FE-VideoCheckOpacity.set', 'filepath', direeg);
OP = pop_loadset('filename', 'OP-VideoCheckOpacity.set', 'filepath', direeg);
IF = pop_loadset('filename', 'IF-VideoCheckOpacity.set', 'filepath', direeg);
CV = pop_loadset('filename', 'CV-VideoCheckOpacity.set', 'filepath', direeg);
RM = pop_loadset('filename', 'RM-VideoCheckOpacity.set', 'filepath', direeg);
GR = pop_loadset('filename', 'GR-VideoCheckOpacity.set', 'filepath', direeg);

ALLSUBJ = {MD BN LO FE OP IF CV RM GR};          
disp('Loaded all subject data from opacity exp...');

%% CHECK SIZE EXPERIMENTS
% Load all of post-ica data
direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19\';

MD = pop_loadset('filename', 'MD-VideoCheckSize-Strong.set', 'filepath', direeg);
BN = pop_loadset('filename', 'BN-VideoCheckSize-Strong.set', 'filepath', direeg);
LO = pop_loadset('filename', 'LO-VideoCheckSize-Strong.set', 'filepath', direeg);
FE = pop_loadset('filename', 'FE-VideoCheckSize-Strong.set', 'filepath', direeg);
OP = pop_loadset('filename', 'OP-VideoCheckSize-Strong.set', 'filepath', direeg);
IF = pop_loadset('filename', 'IF-VideoCheckSize-Strong.set', 'filepath', direeg);
CV = pop_loadset('filename', 'CV-VideoCheckSize-Strong.set', 'filepath', direeg);
RM = pop_loadset('filename', 'RM-VideoCheckSize-Strong.set', 'filepath', direeg);
GR = pop_loadset('filename', 'GR-VideoCheckSize-Strong.set', 'filepath', direeg);

MD_Med = pop_loadset('filename', 'MD-VideoCheckSize-Med.set', 'filepath', direeg);
BN_Med = pop_loadset('filename', 'BN-VideoCheckSize-Med.set', 'filepath', direeg);
LO_Med = pop_loadset('filename', 'LO-VideoCheckSize-Med.set', 'filepath', direeg);
FE_Med = pop_loadset('filename', 'FE-VideoCheckSize-Med.set', 'filepath', direeg);
OP_Med = pop_loadset('filename', 'OP-VideoCheckSize-Med.set', 'filepath', direeg);
IF_Med = pop_loadset('filename', 'IF-VideoCheckSize-Med.set', 'filepath', direeg);
CV_Med = pop_loadset('filename', 'CV-VideoCheckSize-Med.set', 'filepath', direeg);
RM_Med = pop_loadset('filename', 'RM-VideoCheckSize-Med.set', 'filepath', direeg);
GR_Med = pop_loadset('filename', 'GR-VideoCheckSize-Med.set', 'filepath', direeg);

MD.data = cat(3, MD.data, MD_Med.data);
BN.data = cat(3, BN.data, BN_Med.data);
LO.data = cat(3, LO.data, LO_Med.data);
FE.data = cat(3, FE.data, FE_Med.data);
OP.data = cat(3, OP.data, OP_Med.data);
IF.data = cat(3, IF.data, IF_Med.data);
CV.data = cat(3, CV.data, CV_Med.data);
RM.data = cat(3, RM.data, RM_Med.data);
GR.data = cat(3, GR.data, GR_Med.data);

ALLSUBJ = {MD BN LO FE OP IF CV RM GR};          
disp('Loaded all subject data from check size exp...');      

%% Calculate Bandpower: OPACITY
% Select opacity conditions 
adetails.markers.types = {'51','52','53','54','55','56','57','58'};
binlabels = {'Full', 'Strong', 'Medium', 'Weak'};

meanpow_lowATTlow = zeros(length(ALLSUBJ), length(binlabels));
meanpow_lowATThigh = zeros(length(ALLSUBJ), length(binlabels));
meanpow_highATTlow = zeros(length(ALLSUBJ), length(binlabels));
meanpow_highATThigh =  zeros(length(ALLSUBJ), length(binlabels));

highstruct.subj = []; highstruct.powval = [];
lowstruct.subj = []; lowstruct.powval = [];

for s = 1:length(ALLSUBJ)
    EEG = ALLSUBJ{s};
    curr_subj = EEG.filename(1:2);
        
    % Populate subject grouping vector
    highstruct.subj = [highstruct.subj repelem(curr_subj, length(EEG.epoch))];
    lowstruct.subj = [lowstruct.subj repelem(curr_subj, length(EEG.epoch))];

    % Find relevant marker and indices
    evtype = [];
    for i = 1:length(EEG.epoch)
        evtype = [evtype, ""+EEG.epoch(i).eventtype];
    end
    unique(evtype)
    adetails.markers.trialevents = evtype(contains(evtype,adetails.markers.types));

    % Crop data for each stimulus and attend condition
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

    % # subjects x # conds
    for b = 1:length(binlabels)
        meanpow_lowATTlow(s, b) = mean(avgchan_lowATTlow{b});
        meanpow_lowATThigh(s, b) = mean(avgchan_lowATThigh{b}); 
        meanpow_highATTlow(s, b) = mean(avgchan_highATTlow{b}); 
        meanpow_highATThigh(s, b) = mean(avgchan_highATThigh{b}); 
    end
    
end

%% Calculate Bandpower: CHECK SIZE

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

%%
difflow = meanpow_lowATTlow - meanpow_lowATThigh;
diffhigh = meanpow_highATThigh - meanpow_highATTlow;
meanlow = mean(difflow); cilow = 1.96*std(difflow)/sqrt(length(ALLSUBJ));
meanhigh = mean(diffhigh); cihigh = 1.96*std(diffhigh)/sqrt(length(ALLSUBJ));
figure; ALLSUBJ = 1:9;
subplot(1,2,1); ylabel('12 Hz Power');
subplot(1,2,2); ylabel('15 Hz Power');
dotcolor = [217,235,211]/255; % [107,168,215]/255;
linecolor = [11,137,1]/255; % [32,80,189]/255;
fs = 16;

binlabels = {'Full', 'Strong', 'Medium', 'Weak'};
for s = 1:length(ALLSUBJ)
    subplot(1,2,1)
    s1 = plot(difflow(s,:), 'o', 'Color', dotcolor,  'MarkerSize', 8, 'MarkerFaceColor', dotcolor, 'MarkerEdgeColor', 'k'); hold on;
    subplot(1,2,2)
    s2 = plot(diffhigh(s,:), 'o', 'Color', dotcolor, 'MarkerSize', 8,  'MarkerFaceColor', dotcolor, 'MarkerEdgeColor', 'k'); hold on;
end

% binlabels = {'Big', 'Medium', 'Small'};
subplot(1,2,1); hold on
e1 = errorbar(1:length(binlabels), meanlow, cilow, 'Color', linecolor, 'LineWidth', 3.5,'CapSize', 18);
yline(0, 'k', 'LineWidth', 2); ylim([-0.51 6]);
xlim([0.8 length(binlabels)+0.2]);
xticks(1:length(binlabels)); xticklabels(binlabels);
ax = gca;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = -0.5:0.5:6;
set(gca,'FontSize',fs);

subplot(1,2,2); hold on
e2 = errorbar(1:length(binlabels), meanhigh, cihigh, 'Color', linecolor, 'LineWidth', 3.5,'CapSize', 18);
yline(0, 'k', 'LineWidth', 2);
xlim([0.8 length(binlabels)+0.2]); ylim([-0.51 6])
xticks(1:length(binlabels)); xticklabels(binlabels);
ax = gca;
ax.YAxis.MinorTick = 'on';
ax.YAxis.MinorTickValues = -0.5:0.5:6;
set(gca,'FontSize',fs);



%% Bandpower Comparison Plot
ALLSUBJ = 1:9;
stderror_lowATTlow = 1.96*std(meanpow_lowATTlow) / sqrt( num_subj );
stderror_lowATThigh = 1.96*std(meanpow_lowATThigh) / sqrt( num_subj );
stderror_highATTlow = 1.96*std(meanpow_highATTlow) / sqrt( num_subj );
stderror_highATThigh = 1.96*std(meanpow_highATThigh) / sqrt( num_subj );
        
disp('populated all check size power data')

% meanpowLOW : 12 Hz power (4 subj x N  stim cond)
% meanpowHIGH : 15 Hz power (4 subj x N  stim cond)

linecolor = [0,93,255]/255; color2 = [160,0,149]/255;
% blue = [0, 0.4470, 0.7410]; orange = [0.8500, 0.3250, 0.0980];
lineopac = 0.3;
lw = 3; lw_sub = 2; fs = 14;
figure; 

% sgtitle('ALL Subjects: Opacity Experiment');  
binlabels = {'Full', 'Strong', 'Medium', 'Weak'};
% sgtitle('ALL Subjects: Check Size Experiment'); 
% binlabels = {'Big Checker', 'Medium Checker', 'Small Checker'};

subplot(1,2,1); ylim([0 7]); set(gca,'FontSize',fs); hold on
ylabel('12 Hz Power'); % xlabel('Stimuli Type');
xticks(1:length(binlabels)); xticklabels(binlabels);
% use error bars to plot the range of subject values
% plot individual subject lines
for s = 1:length(ALLSUBJ)
    s1 = plot(meanpow_lowATTlow(s,:), '-', 'Color', linecolor, 'LineWidth', lw_sub); hold on;
    s2 = plot(meanpow_lowATThigh(s,:), '-', 'Color', color2, 'LineWidth', lw_sub);
    s1.Color(4) = lineopac; s2.Color(4) = lineopac;
end
e1 = errorbar(1:length(binlabels), mean(meanpow_lowATTlow), stderror_lowATTlow, 'LineWidth', lw, 'Color', linecolor);
e2 = errorbar(1:length(binlabels), mean(meanpow_lowATThigh), stderror_lowATThigh, 'LineWidth', lw, 'Color', color2);
legend([e1, e2], {'Attend 12 Hz', 'Attend 15 Hz'})
xlim([0.9 4.1]);

subplot(1,2,2); ylim([0 12]); set(gca,'FontSize',fs); hold on
ylabel('15 Hz Power'); % xlabel('Stimuli Type');
xticks(1:length(binlabels)); xticklabels(binlabels);
% use error bars to plot the range of subject values
% plot individual subject lines
for s = 1:length(ALLSUBJ)
    s1 = plot(meanpow_highATTlow(s,:), '-', 'Color', linecolor, 'LineWidth', lw_sub); hold on;
    s2 = plot(meanpow_highATThigh(s,:), '-', 'Color', color2, 'LineWidth', lw_sub);
    s1.Color(4) = lineopac; s2.Color(4) = lineopac;
end
e1 = errorbar(1:length(binlabels), mean(meanpow_highATTlow), stderror_highATTlow, 'LineWidth', lw, 'Color', linecolor);
e2 = errorbar(1:length(binlabels), mean(meanpow_highATThigh), stderror_highATThigh, 'LineWidth', lw, 'Color', color2);
xlim([0.9 4.1]);

legend([e1, e2], {'Attend 12 Hz', 'Attend 15 Hz'})

%% T-tests on opacity

[~, p_lowfull, ~, ~] = ttest(meanpow_lowATTlow(:,1), meanpow_lowATThigh(:,1));
[~, p_lowstrong, ~, ~] = ttest(meanpow_lowATTlow(:,2), meanpow_lowATThigh(:,2));
[~, p_lowmed, ~, ~] = ttest(meanpow_lowATTlow(:,3), meanpow_lowATThigh(:,3));
[~, p_lowweak, ~, ~] = ttest(meanpow_lowATTlow(:,4), meanpow_lowATThigh(:,4));

p_low = [p_lowfull p_lowstrong p_lowmed p_lowweak]
[~,~,~,p_lowadj] = fdr_bh(p_low)

[~, p_highfull, ~, ~] = ttest(meanpow_highATTlow(:,1), meanpow_highATThigh(:,1));
[~, p_highstrong, ~, ~] = ttest(meanpow_highATTlow(:,2), meanpow_highATThigh(:,2));
[~, p_highmed, ~, ~] = ttest(meanpow_highATTlow(:,3), meanpow_highATThigh(:,3));
[~, p_highweak, ~, ~] = ttest(meanpow_highATTlow(:,4), meanpow_highATThigh(:,4));

p_high = [p_highfull p_highstrong p_highmed p_highweak]
[~,~,~,p_highadj] = fdr_bh(p_high)

%% T-test on check size
[~, p_lowbig, ~, ~] = ttest(meanpow_lowATTlow(:,1), meanpow_lowATThigh(:,1));
[~, p_lowmed, ~, ~] = ttest(meanpow_lowATTlow(:,2), meanpow_lowATThigh(:,2));
[~, p_lowsm, ~, ~] = ttest(meanpow_lowATTlow(:,3), meanpow_lowATThigh(:,3));

p_low = [p_lowbig p_lowmed p_lowsm]
[~,~,~,p_lowadj] = fdr_bh(p_low)

[~, p_highbig, ~, ~] = ttest(meanpow_highATTlow(:,1), meanpow_highATThigh(:,1));
[~, p_highmed, ~, ~] = ttest(meanpow_highATTlow(:,2), meanpow_highATThigh(:,2));
[~, p_highsm, ~, ~] = ttest(meanpow_highATTlow(:,3), meanpow_highATThigh(:,3));

p_high = [p_highbig p_highmed p_highsm]
[~,~,~,p_highadj] = fdr_bh(p_high)


%% Load ergonomics responses
% Responses: Conds x [MD BN LO FE OP IF CV RM GR]
full_pref = [1 1 1 1 2 1 1 1 1];
strong_pref = [1 1 2.5 3.6 2 1 2.5 1.5 1];
med_pref = [1 1 3.2 4.2 3 5 3.5 2 2];
weak_pref = [3 2 4.5 4.7 5 5 5 2.5 3];
opac = [full_pref; strong_pref; med_pref; weak_pref];

% missing GR all
big_strong_pref = [1 2 3.2 3.9 3 4 2 1 1];
med_strong_pref = [1 1 1 1.4 1 1 1 1.5 1];
small_strong_pref = [2 2 3.8 4.6 5 4 4 4 2];
strong = [big_strong_pref; med_strong_pref; small_strong_pref];

% missing IF
big_med_pref = [2 2 3 3.5 3       3     3 4 1];
med_med_pref = [1 1 1 2 1         1    1 1 1];
small_med_pref = [2 1 4.2 4.6 5   5    4.5 3 3];
med = [big_med_pref; med_med_pref; small_med_pref];

checksize = (strong + med)/2;

opac_mean = mean(opac, 2);
checksize_mean = mean(checksize, 2); 

%% Conglomerate matrix
% [full strong med weak] x [rating diff12 diff15 ... classification]

lowdiff = mean(meanpow_lowATTlow) - mean(meanpow_lowATThigh);
highdiff =  mean(meanpow_highATThigh) - mean(meanpow_highATTlow);

% alldata_opac = [opac_mean lowdiff' highdiff']
alldata_checksize = [checksize_mean lowdiff' highdiff']

%% Conglomerate plot
mymap = [1 0 0; 1 1 0; 0 1 0];  % color map of red, yellow, green

figure; hold on; subplot(1,3,1);
sgtitle('Opacity Experiment');  imagesc(opac_mean); 
% sgtitle('Check Size Experiment');  imagesc(checksize_mean);
colormap(mymap); caxis([0 4]); % colorbar;
nx = size(alldata,2); ny = size(alldata,1);
set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
xticklabels({'Ergonomics'})
yticklabels({'Full', 'Strong', 'Medium', 'Weak'})
% yticklabels({'Big', 'Medium', 'Small'})

% montage([ergim lowdiffim highdiffim])

subplot(1,3,[2 3]); imagesc(alldata); 
colormap(mymap); caxis([0 1]); % colorbar; 
nx = size(alldata,2); ny = size(alldata,1);
set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
xticklabels({'12 Hz Power Diff', '15 Hz Power Diff'})
yticklabels({'', '', '', ''})

