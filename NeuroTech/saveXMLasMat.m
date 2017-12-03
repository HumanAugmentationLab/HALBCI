filename = 'testduck1';
Stim1 = {'149' '151'};
Stim2 = {'151' '149'};
StimArr = {'149','151','12','0','200'}
StimArr2 = {'151','149','12','0','200'}
PhotodiodeStimulationChannel = 3;
OffsetforPhotodiodeStimulation = 0;

pathToData = strcat('/home/gsteelman/Pictures/',filename, '.xdf');

traindata = reconfigSNAP(pathToData);
mytraindata = tryFindStart(traindata,PhotodiodeStimulationChannel,OffsetforPhotodiodeStimulation);

save(strcat(filename,'.mat'),'mytraindata')
vizData(mytraindata, PhotodiodeStimulationChannel,Stim1, Stim2)