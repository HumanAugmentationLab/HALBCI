% Classification analysis code for FA19

direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\icafiles\FA19';
fnamebase = 'VideoCheckOpacity';
subjs = {'BN','CV','FE','GR','IF','LO','MD','OP','RM'};
approaches = {'Spectral Means logreg'};%{'SpecCSP', 'BP 6Hz', 'BP 15Hz', 'Spectral Means LDA', 'Spectral Means logreg'};
%adetails.markers.types = {'51','52','53','54','55','56'};
TargetMarkersA = { '53', '55','57'};
TargetMarkersB = { '54', '56','58'};
adetails.markers.epochwindow = [0 2.996];

for s = 1:1;%length(subjs)
    
    % Load the .easy file version of the data
    ioeasy = io_loadset(fullfile(direeg,strcat(subjs{s},'-',fnamebase,'.set'))); %requires .info file
    EEG = exp_eval(ioeasy); % Force bcilab to evaluate the expression and load the data
    
    
    
    for ap = 1:length(approaches)
    
        

        
        
        
    end
end


% %%
% switch approaches{ap}
%         case 'Spectral Means logreg'
%                     disp('running spectral means logreg')
%                     myapproach = {'Spectralmeans' ...
%                         'SignalProcessing', { ...
%                             'EpochExtraction', {'TimeWindow',[0 epochsizes(es)-0.002] } ...
%                          }, ...
%                          'Prediction', { ...
%                             'FeatureExtraction',{ 'FreqWindows', [5 7; 14 16] }, ...
%                             'MachineLearning', {'Learner', 'logreg'} ...
%                             }...
%                     };
%         end
% 
%         
%         [trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
%         'TargetMarkers',{TargetMarkersA, TargetMarkersB},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 
%         
%         disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
% 
%         [prediction,testloss,teststats,targets] = bci_predict(mymodel,EEGtest);
%         disp(['test mis-classification rate: ' num2str(testloss*100,3) '%']);
%         
%         trainlossresults(s,ap) = trainloss;
%         testlossresults(s, ap) = testloss;
%         laststatsresults(s, ap).laststats = laststats;

