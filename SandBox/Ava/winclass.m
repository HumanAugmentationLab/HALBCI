%% Dependency Setup
cd C:\Users\alakmazaheri\Documents\BCI\BCILAB
bcilab;

%% Load Data
cd C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\AvaMuseProcess

traindata1 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W4-Intrinsic.xdf');
dat1 = tryFindStart(traindata1,4,0);

traindata2 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W3IntrinsicSelf.xdf');
dat2 = tryFindStart(traindata2,4,0);

traindata3 = reconfigSNAP('K:\HumanAugmentationLab\EEGdata\Muse_EyesOpenClosed\W1MuseIntrinsic.xdf');
dat3 = tryFindStart(traindata3,4,0);

% Delete any markers not keyed on onset
dat1.event(8:10) = [];
dat1.event(9:14) = [];
dat1.event(10:12) = [];

dat2.event(20:21) = [];
dat2.event(21) = [];
dat2.event(23:24) = [];
dat2.event(37) = [];

dat3.event(25) = [];
dat3.event(50) = [];

%% Visually Check Data
close all;
hzlim = [5e4 5.25e4];
upvlim = [400 1400]; lowvlim = [-500 500];
vis_data(dat1,[2 5],upvlim,hzlim, 'Original Data')


movavdat1 = exp_eval(flt_movavg(dat1,4)); 
vis_data(movavdat1,[2 5],upvlim,hzlim, 'Moving Average');
baseremdat1 = exp_eval(flt_rmbase(dat1)); 
vis_data(baseremdat1,[2 5],lowvlim,hzlim, 'Baseline Removal');
hpfiltdat1 = exp_eval(flt_fir(dat1,[0.1 0.5],'highpass'));
vis_data(hpfiltdat1,[2 5],lowvlim,hzlim, 'Highpass Filter');


fltmovav = exp_eval(flt_movavg(hpfiltdat1));
vis_data(fltmovav,[2 5],lowvlim,hzlim, 'HP Filter then Moving Average');
movavflt = exp_eval(flt_fir(movavdat1, [0.1 0.5], 'highpass'));
vis_data(movavflt,[2 5],lowvlim,hzlim, 'Moving Average then HP Filter');

movavdat2 = exp_eval(flt_movavg(dat2,4)); 
baseremdat2 = exp_eval(flt_rmbase(dat2)); 
hpfiltdat2 = exp_eval(flt_fir(dat2,[0.1 0.5],'highpass'));
fltmovav2 = exp_eval(flt_movavg(hpfiltdat2));

%% Train
clear trainloss mymodel laststats prediction loss teststats targets myapproach

minsec = -0.5;
maxsec = 0.5;
inc = 0.1;

wnd1 = (minsec : inc : maxsec-inc)';
wnd2 = (minsec+inc:  inc : maxsec)';
wnds = horzcat(wnd1,wnd2);

myapproach = {'Windowmeans' 'SignalProcessing', {  'EpochExtraction',{'TimeWindow',[minsec maxsec]}, ...
    'SpectralSelection', 'off', 'ChannelSelection', {{'TP9' 'TP10'}} ... %, 'BaselineRemoval', [-0.75 -0.5] ...
    , 'FIRFilter',{[0.1 0.5],'highpass'}...
    }, ...
    'Prediction', {'FeatureExtraction',{'TimeWindows',wnds},'MachineLearning',{'Learner',{'logreg'}}}...
             };

[trainloss,mymodel,laststats] = bci_train('Data',movavdat1,'Approach',myapproach,'TargetMarkers',{'149','151'},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',10,5}); 

[prediction,loss,teststats,targets] = bci_predict(mymodel,movavdat2);

%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
