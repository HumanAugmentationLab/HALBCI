cd C:\Users\Public\Research\BCILAB
bcilab

direeg = 'K:\HumanAugmentationLab\EEGdata\EnobioTests\VideoSSVEP\Preprocessed\combineddata\';

EEGtrainOG = pop_loadset('filename', 'PK20190330_EEGtrain.set', 'filepath', direeg);
EEGtestOG = pop_loadset('filename', 'PK20190330_EEGtest.set', 'filepath', direeg);

%%
epochsizes = 1:10;

approaches = {'SpecCSP', 'BP 6Hz', 'BP 15Hz', 'Spectral Means LDA', 'Spectral Means logreg'};

trainlossresults = 200*ones(length(epochsizes), length(approaches));
testlossresults = trainlossresults;

for es = 1:length(epochsizes)

    for tt = 1:2
        if tt == 1
            lastEEG = EEGtrainOG;
        else
            lastEEG = EEGtestOG;
        end

        clear EEG
        EEG = lastEEG;
        % Markers for sustained attention
        adetails.markers.types = {'51','52','53','54','55','56'};
        % adetails.markers.names = {'LEFT & LOW','LEFT & HIGH','RIGHT & LOW','RIGHT & HIGH'};
        evtype = [];

        adetails.markers.epochwindow = [0 9.998]; % window after standard markers to look at
        adetails.markers.epochsize = epochsizes(es); % size of miniepochs to chop regular markered epoch up into
        adetails.markers.numeventsperwindow = floor((adetails.markers.epochwindow(2)-adetails.markers.epochwindow(1))/adetails.markers.epochsize);

        disp('Adding EEG markers...')

        k = 1; % New event index
        for i = 1:length(lastEEG.event) 
            if any(contains(adetails.markers.types,lastEEG.event(i).type))
                markerstring = EEG.event(i).type;

                for j = 0:(adetails.markers.numeventsperwindow) %For how many markers we are doing per window     
                    EEG.event(k).type = lastEEG.event(i).type;
                    EEG.event(k).latency = lastEEG.event(i).latency + (j*lastEEG.srate*adetails.markers.epochsize); 
                    EEG.event(k).latency_ms = lastEEG.event(i).latency_ms + (j*adetails.markers.epochsize*1000); 
                    EEG.event(k).duration = 0; %adetails.markers.epochsize; % seconds for continuous data
                    k = k+1; 
                end        
            else
                EEG.event(k).type = lastEEG.event(i).type;
                EEG.event(k).latency = lastEEG.event(i).latency; 
                EEG.event(k).latency_ms = lastEEG.event(i).latency_ms; 
                EEG.event(k).duration = 0;
                k = k+1;
            end
        end
        
        if tt == 1
            EEGtrain = EEG;
        else
            EEGtest = EEG;
        end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % loop through all approaches
    
    for ap = 1:length(approaches)
        switch approaches{ap}
            case 'SpecCSP'
                disp('running SpecCSP')
                myapproach = {'SpecCSP', ...
                    'SignalProcessing', { ...
                        'EpochExtraction', [0 epochsizes(es)-0.002] , ...
                        'FIRFilter', {'Frequencies', [1 2 48 49], 'Type','linear-phase'}...
                        } , ... 
                    'Prediction', {'FeatureExtraction',{...
                        'PatternPairs',4, ...
                        'prior','@(f) f>=2 & f<=20' ...
                        }...
                    } ...
                };
            case 'BP 6Hz'
                disp('running bp 6Hz')
                myapproach = {'Bandpower' ...
                    'SignalProcessing', { ...
                        'FIRFilter',[4 5 7 8], ...
                        'EpochExtraction', {'TimeWindow',[0 epochsizes(es)-0.002] } ...
                     }, ...
                };
            case 'BP 15Hz'
                disp('running bp 15hz')
                myapproach = {'Bandpower' ...
                    'SignalProcessing', { ...
                        'FIRFilter',[13 14 16 17], ...
                        'EpochExtraction', {'TimeWindow',[0 epochsizes(es)-0.002] } ...
                     }, ...
                };
            case 'Spectral Means LDA'
                disp('running spectral means LDA')
                myapproach = {'Spectralmeans' ...
                    'SignalProcessing', { ...
                        'EpochExtraction', {'TimeWindow',[0 epochsizes(es)-0.002] } ...
                     }, ...
                     'Prediction', { ...
                        'FeatureExtraction',{ 'FreqWindows', [5 7; 14 16] }, ...
                        'MachineLearning', {'Learner', 'lda'} ...
                        }...
                };
            case 'Spectral Means logreg'
                disp('running spectral means logreg')
                myapproach = {'Spectralmeans' ...
                    'SignalProcessing', { ...
                        'EpochExtraction', {'TimeWindow',[0 epochsizes(es)-0.002] } ...
                     }, ...
                     'Prediction', { ...
                        'FeatureExtraction',{ 'FreqWindows', [5 7; 14 16] }, ...
                        'MachineLearning', {'Learner', 'logreg'} ...
                        }...
                };
        end
        
        [trainloss,mymodel,laststats] = bci_train('Data',EEGtrain, 'Approach', myapproach,...
        'TargetMarkers',{{'51', '53', '55'}, {'52', '54', '56'}},'EvaluationMetric', 'mse','EvaluationScheme',{'chron',5,0}); 
        disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);

        [prediction,testloss,teststats,targets] = bci_predict(mymodel,EEGtest);
        disp(['test mis-classification rate: ' num2str(testloss*100,3) '%']);
        
        trainlossresults(es,ap) = trainloss;
        testlossresults(es, ap) = testloss;
        laststatsresults(es, ap).laststats = laststats;
    end
end

%%
save(strcat(direeg,'PK20190330-ClassificationResultsByEpochSize.mat'),...
    'trainlossresults','testlossresults','laststatsresults','approaches','epochsizes');

%% Plotting
trainclassrate = (1-trainlossresults)*100;
testclassrate = (1-testlossresults)*100;

figure;
subplot(1,2,1)
plot(trainclassrate);
%xticklabels({'0.5', '1', '2', '5', '10'})
xlabel('Epoch Size (s)')
ylabel('Classification Rate (%)')
ylim([50 100])
legend(approaches)
title('Training')

subplot(1,2,2)
plot(testclassrate)
%xticklabels({'0.5', '1', '2', '5', '10'})
xlabel('Epoch Size (s)')
ylabel('Classification Rate (%)')
ylim([50 100])
legend(approaches)
title('Testing')



%%
%figure;
hold on
subplot(1,2,1)
plot(mean(trainclassrate,2),'*');
%xticklabels({'0.5', '1', '2', '5', '10'})
xlabel('Epoch Size (s)')
ylabel('Classification Rate (%)')
ylim([50 100])
title('Training')

hold on
subplot(1,2,2)
plot(mean(testclassrate,2),'*')
%xticklabels({'0.5', '1', '2', '5', '10'})
xlabel('Epoch Size (s)')
ylabel('Classification Rate (%)')
ylim([50 100])
title('Testing')
