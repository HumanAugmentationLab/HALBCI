%%This script will run through BCI_train over multiple parameters and plot
%%the relationship between a parameter and the accuracy of the model (
%%either cross validated or self validated
traindata = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727114720_PatientW1-8v15_Record.easy')
mytempdata = exp_eval(traindata)
resultdataSpec = []
resultdataSpoc = []
xaxis = linspace(40,150,12)
mytempdataTest = refactorFunc(mytempdata,2,9,1)
mytempdataEdit = refactorFunc(mytempdata,2, 9,1)
for i = 40:10:150
    
    mytempdataEdit = decreaseTrialsFunc(mytempdataEdit,i,{'101', '201'},1)
    
    myapproach = {'Spectralmeans' 'SignalProcessing',{'EpochExtraction',[0 1]},'Prediction', {'FeatureExtraction',{'FreqWindows',[4 8;8 12;12 16;16 20]}}};

    [trainloss,mymodel,laststats] = bci_train('Data',mytempdataEdit,'Approach',myapproach,'TargetMarkers',{'101','201'},'EvaluationMetric', 'mse','EvaluationScheme',0); 
    [prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdataTest);
    resultdataSpec = [resultdataSpec; loss];
    
    myapproach = {'SPoC' 'SignalProcessing',{'EpochExtraction',[0 1],'FIRFilter',[8 10 14 16]}, 'Prediction',{'FeatureExtraction',{'PatternPairs',4}}};
    [trainloss,mymodel,laststats] = bci_train('Data',mytempdataEdit,'Approach',myapproach,'TargetMarkers',{'101','201'},'EvaluationMetric', 'mse','EvaluationScheme',0); 
    [prediction,loss,teststats,targets] = bci_predict(mymodel,mytempdataTest);
    t = 0
    for j = 1:length(prediction)
        if round(prediction(j)) ~= round(targets(j))
            t = t+1;
        end
    end
    
    
    resultdataSpoc = [resultdataSpoc; t/length(prediction)];
    
end
figure
plot(xaxis,resultdataSpec.')
hold on
plot(xaxis,resultdataSpoc.')
xlabel('Seconds in Epoch')
ylabel('Misclassification Rate')
legend('Spectral Means', 'Spoc')