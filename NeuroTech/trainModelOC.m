%This is the main script to train a model in BCILAB

%When reviewing this, you should be familiar with general experiment design
%for binary classification of eeg data, especially the function of markers

%For the OC (Open Closed) Training data, all time after a closed marker
%(149) is when the subjects eyes are closed until there is another marker,
%and vice versa for open.

%These are some important variables you may want to mess with
%to augment your model.
filename = 'OCtesting';%Dictates which file to load
minOffset = 0;%A variable offset when refactoring markers (explained later)
epochLength = 1; %The distance between markers when refactoring (explained later)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%These variables and code should be constant redgaurdless of which data you use
%so please do not change these
Stim1 = {'149' '151'};
Stim2 = {'151' '149'};
StimArr = {'149','151','12','0','200'}
StimArr2 = {'151','149','12','0','200'}
PhotodiodeStimulationChannel = 3;
load(strcat(filename,'.mat'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%If you uncomment vizData it will take one channel of the loaded data and
%display it with its markers. Stim1 and Stim2 dictate which color to make
%markers. 
%vizData(mytraindata, PhotodiodeStimulationChannel,Stim1, Stim2)

%refatorMarkersVariable will take each event marker wait the min offset
%and then place the same marker every epochLength apart until the next
%marker.

%The best way to see what refatorMarkersVariable does is to just
%visualize the data before and after running.
mytraindata = refactorMarkersVariable(mytraindata,minOffset,epochLength,StimArr,StimArr2);
vizData(mytraindata, PhotodiodeStimulationChannel,Stim1, Stim2)
%%
%Below are some examples of paradigms to try out on the data. To find out
%more about each one you can type 'edit [paradigm name]' to bring up the
%docs. Or to find more paradigms or learn about the function of different
%techniques you can google BCILAB paradigms. 

%{
myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0.5 3.5]}, ...
           'Prediction', {'FeatureExtraction',{'FreqWindows',[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5],'TimeWindows',[]}, ...
                          'MachineLearning',{'Learner','lda'}}}
%}
%myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[1.5 3.5],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2}}};
%myapproach = {'CSP' 'SignalProcessing',{'FeatureExtraction',{'PatternPairs',2}, 'EpochExtraction',[1.5 3.5],'FIRFilter',[7 8 28 32]}};

%myapproach = {'ParadigmBandpower' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[1.5 4.5],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}};
%myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
%myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[1.5 3.5],'FIRFilter',[8 12 16 32]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2,'FreqWindows',[8 12;16 32;35 45]},'MachineLearning',{'learner','lda'}}};
myapproach = {'Spectralmeans' 'SignalProcessing',{'FIRFilter',[8 12 16 32],'EpochExtraction',[0,1],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}},'Prediction', {'FeatureExtraction',{'FreqWindows',[2 6;8 12;28 32]}}};

%finally we train the model on the data, specifying the target markers
%[trainloss,mymodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'768','769'},'EvaluationScheme',{'chron',5,5},'NoPrechecks', true,'EvaluationMetric', 'mse'); 
[trainloss,mymodel,laststats] = bci_train('Data',mytraindata,'Approach',myapproach,'TargetMarkers',Stim1,'EvaluationMetric', 'mse','EvaluationScheme',0); 

%this will display the results of the cross-validation tests
%disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);


%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
[prediction,loss,teststats,targets] = bci_predict(mymodel,mytraindata);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);