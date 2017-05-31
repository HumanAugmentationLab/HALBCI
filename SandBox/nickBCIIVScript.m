%First we load the data set into matlab with io_loadset()
traindata = io_loadset('C:\Users\gsteelman\Desktop\Summer Research\BCIIV\BCICIV_calib_ds1a.mat','channels',1:59);
mydata = exp_eval(traindata)
%here we specifiy the approach to detangle the data
%this one is Filter Banked CSP with epochs from .5 to 3.5. 8 different
%frequency bands were also selected to be processed

myapproach = {'FBCSP' 'SignalProcessing',{'EpochExtraction',[0.5 3.5]}, ...
           'Prediction', {'FeatureExtraction',{'FreqWindows',[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5],'TimeWindows',[]}, ...
                          'MachineLearning',{'Learner','lda'}}}
%finally we train the model on the data, specifying the target markers
[trainloss,lastmodel,laststats] = bci_train('Data',traindata,'Approach',myapproach,'TargetMarkers',{'1','-1'}); 
%this will display the results of the cross-validation tests
disp(['training mis-classification rate: ' num2str(trainloss*100,3) '%']);
%this will visualize the results of the csp for this case
bci_visualize(lastmodel)
%this will go through any given data, predict the result, and return the
%classification accuracy. You may also use bci_annotate to find probaility
%values of each
[prediction,loss,teststats,targets] = bci_predict(lastmodel,traindata);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
%[7.5 8.5;9.25 10.25;11.39 12.39;14 15;17.17 18.17;21 22;25.75 26.75;31.5 32.5];