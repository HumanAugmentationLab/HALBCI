traindata = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\psychOpen.xdf');
mytempdata = tryFindStart(traindata,3,8000);
traindata2 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\psychOpen2.xdf');
mytempdata2 = tryFindStart(traindata2,3,0);
traindata3 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\psychOpen3.xdf');
mytempdata3 = tryFindStart(traindata3,3,0);

%
traindata4 = reconfigSNAP('C:\Users\gsteelman\Desktop\SummerResearch\TestData\Psych Toolbox\psychOpenLong.xdf');
mytempdata4 = tryFindStart(traindata4,3,0);

mytempdata = refactorFunc(mytempdata,.75, 3.75,.5)
mytempdata2 = refactorFunc(mytempdata2,.75, 3.75,.5)
mytempdata3 = refactorFunc(mytempdata3,.75, 3.75,.5)
mytempdata4 = refactorFunc(mytempdata4,2, 18,.5)
%}
maxTrials = 300
minTrials = 18
step = 24

myapproach = {'SpecCSP' 'SignalProcessing',{'EpochExtraction',[0 .5],'FIRFilter',[6 12 16 32],'ChannelSelection',{{'TP9' 'FP1' 'FP2' 'TP10'}}}, 'Prediction',{'FeatureExtraction',{'PatternPairs',2},'MachineLearning',{'learner','lda'}}};
trials = []
data = []

for i = minTrials:step:maxTrials
    reducedData = decreaseTrialsFunc(mytempdata,i,{'Open' 'Closed'},0)
    %reducedData2 = decreaseTrialsFunc(mytempdata2,i,{'Open' 'Closed'},0)
    %reducedData3 = decreaseTrialsFunc(mytempdata3,i,{'Open' 'Closed'},0)

    [trainloss,mymodel,laststats] = bci_train('Data',{reducedData},'Approach',myapproach,'TargetMarkers',{'Closed','Open'},'EvaluationMetric', 'mse','EvaluationScheme',0); 

    %[prediction,loss1,teststats,targets] = bci_predict(mymodel,mytempdata4);
    [prediction,loss2,teststats,targets] = bci_predict(mymodel,mytempdata2);
    %this simply displays the information gotten from bci_predict
    [prediction,loss3,teststats,targets] = bci_predict(mymodel,mytempdata3);
    trials = [trials; i]
    data = [data;loss2 loss3]
    
    
end
dataM = []
for i = 1:length(data)
    dataM(i) = mean(data(i,:)) 
end
figure
plot(trials, data)
%legend('Accuracy On Data1','Accuracy On Data2','Accuracy On Data3')
xlabel('Number Trials Trained On')
ylabel('Accuracy on Whole Set')
title('RANDOM Accuracy vs Number of Trials Trained on (Model Trained on X Number from each Set)')