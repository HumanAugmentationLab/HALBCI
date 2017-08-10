% Run ICA and Spectral Analysis, tailored for SSVEP recording session 2

%------------------------Load data -----------------------------%
dirica = 'C:\Users\alakmazaheri\Documents\BCI\Enobio\ICA-session-2\'
%fnameica = '15v20-low-small.mat'; fnameica2 = '15v20-high-small.mat';    
fnameica = '15v20-low-big.mat'; fnameica2 = '15v20-high-big.mat';          
% fnameica = '12v30-low-small.mat'; fnameica2 = '12v30-high-small.mat';            
% fnameica = '12v15-low-med.mat'; fnameica2 = '12v15-high-med.mat';           
% fnameica = '7.5v20-low-small.mat'; fnameica2 = '7.5v20-high-small.mat';             
% fnameica = '7.5v12-low-small-3.mat'; fnameica2 = '7.5v12-high-small-3.mat';            
% fnameica = '7.5v12-low-small-2.mat'; fnameica2 = '7.5v12-high-small-2.mat';           
% fnameica = '7.5v12-low-small.mat'; fnameica2 = '7.5v12-high-small.mat';        
% fnameica = '7.5v12-low-big.mat'; fnameica2 = '7.5v12-high-big.mat';

A = importdata(fullfile(dirica, fnameica));
B = importdata(fullfile(dirica, fnameica2));

trainlowiez = A; trainhighiez = B; % take ica info
applow = A; apphigh = B; % take data

% add ica variables to struct with data 
variableComps = {'icaact' 'icawinv' 'icasphere' 'icaweights' 'icachansind' 'reject' 'splinefile' 'icasplinefile'};
for i = 1:length(variableComps)
    if i == 3 || i == 5
        applow.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i)))];
        apphigh.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i)))];
    elseif i == 4         
        applow.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))); trainhighiez.(char(variableComps(i)))];
        apphigh.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))); trainhighiez.(char(variableComps(i)))];
    else
        applow.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))) trainhighiez.(char(variableComps(i)))];
        apphigh.(char(variableComps(i))) = [trainlowiez.(char(variableComps(i))) trainhighiez.(char(variableComps(i)))];
    end
end

%------------------------subtract components -----------------------------%

%lowkeep = [4]; highkeep = 1:26; % [6 12]           % 15v20s 
lowkeep = [19 25]; highkeep = [11]; %[8]            % 15v20b
%lowkeep = [13]; highkeep = [9 14];                 % 12v15
%lowkeep = [6]; highkeep = [6 10];                  % 7.5v12--1
%lowkeep = [4]; highkeep = [4];                     % 7.5v12--2
%lowkeep = [8 21]; highkeep = [19];                 % 7.5v12--3
%lowkeep = [3 5]; highkeep = [5 10 18];             % 7.5v12b
%lowkeep = [6 15]; highkeep = [23];                 % 7.5v20
%lowkeep =  [2] highkeep = [13 16];                 %12v30

lowrej = 1:26; lowrej(lowkeep) = [];
highrej = 1:26; highrej(highkeep) = [];
concatkeep = [lowkeep lowkeep(end)+highkeep];
concatrej = 1:52; concatrej(concatkeep) = [];

lowsez = pop_subcomp(applow, concatrej);
highsez = pop_subcomp(apphigh, concatrej);

%------------------------ plot -----------------------------%
figure;
bins = [5 10 20 25]; numbins = size(bins,2);x1 = [1:numbins];

llall = []; hlall = []; llrelall = []; hlrelall = [];

lowsize = size(lowsez.data);
for i = 1:lowsize(3)
    [spectra, freq] = spectopo(lowsez.data(25,:,i), lowsize(2), lowsez.srate);
    
    %lowIDX = find(freq>7 & freq<9);
    %lowIDX = find(freq>11 & freq<13.5);
    lowIDX = find(freq>14 & freq<16);
    
    %highIDX = find(freq>11 & freq<13.5);
    %highIDX = find(freq>14 & freq<16);
    highIDX = find(freq>19 & freq<21);
    %highIDX = find(freq>28 & freq<32);
    
    llp = 10^(mean(spectra(lowIDX))/10); llall = [llall llp];
    hlp = 10^(mean(spectra(highIDX))/10); hlall = [hlall hlp];
    
    llrel = llp/(llp+hlp); hlrel = hlp/(llp+hlp);
    llrelall = [llrelall llrel]; hlrelall = [hlrelall hlrel];
end


lhall = []; hhall = []; lhrelall = []; hhrelall = [];
highsize = size(highsez.data);
for i = 1:highsize(3)
    [spectra, freq] = spectopo(highsez.data(25,:,i), highsize(2), highsez.srate);
    
    %lowIDX = find(freq>7 & freq<9);
    %lowIDX = find(freq>11 & freq<13.5);
    lowIDX = find(freq>14 & freq<16);
    
    %highIDX = find(freq>11 & freq<13.5);
    %highIDX = find(freq>14 & freq<16);
    highIDX = find(freq>19 & freq<21);
    %highIDX = find(freq>28 & freq<32);
    
    lhp = 10^(mean(spectra(lowIDX))/10); lhall = [lhall lhp];
    hhp = 10^(mean(spectra(highIDX))/10); hhall = [hhall hhp];
    
    lhrel = lhp/(lhp+hhp); hhrel = hhp/(lhp+hhp);
    lhrelall = [lhrelall lhrel]; hhrelall = [hhrelall hhrel];
end
%meanconds = [mean(llall) mean(hlall) mean(lhall) mean(hhall)];
meanrel = [mean(llrelall) mean(hlrelall) mean(lhrelall) mean(hhrelall)];
stds = [std(llrelall) std(hlrelall) std(lhrelall) std(hhrelall)];

% plot 
figure; hold on
bar(bins, meanrel)
errorbar(bins,meanrel,stds,'Color', 'k', 'LineStyle', 'none', 'LineWidth', 2, 'Marker', '.')