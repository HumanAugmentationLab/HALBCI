%%This script is used as a first pass to visualize the data and make sure
%%everything looks right before diving into analysis. it will plot the data
%%and the markers according to the specified parameters


%traindata = pop_loadxdf('K:\HumanAugmentationLab\EEGdata\EnobioTests\PhotodiodeScreen\block_nenobio.xdf')
%mytempdata = exp_eval(traindata)
%mytempdata = decreaseTrialsFunc(mytempdata,20,{'Open' 'Closed'})
%traindata = io_loadset('/home/gsteelman/Desktop/Summer Research/Data/20170718152739_W1.easy')
%mytempdata = exp_eval(traindata)

%traindata = io_loadset('/media/HumanAugmentationLab/EEGdata/EnobioTests/EyesOpenClosed/20170718154026_W2.easy')
%mytempdata = exp_eval(traindata)
addpath(genpath('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/NickStuff'))

Stim1 = {'149' '151'};
Stim2 = {'151' '149'};
StimArr = {'149','151','12','0','200'}
StimArr2 = {'151','149','12','0','200'}
PhotodiodeStimulationChannel = 2;
OffsetforPhotodiodeStimulation = 0;
%pathToData = '/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727114720_PatientW1-8v15_Record.easy';
pathToData = 'C:\Users\gsteelman\Desktop\Neurotech\OCtrainingtest.xdf';
%pathToData = '/media/HumanAugmentationLab/EEGdata/EnobioTests/Testing SSVEP/20170727112030_PatientW1-15v20_Record.easy';
%pathToData4 = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/NickTest.xdf';
%traindata = io_loadset(pathToData)
%mytempdata= exp_eval(traindata)
%mytempdata = refactorFunc(mytempdata,2, 9,3)
traindata = reconfigSNAP(pathToData);
mytempdata = tryFindStart(traindata,PhotodiodeStimulationChannel,OffsetforPhotodiodeStimulation);
mytempdata = refactorMarkersVariable(mytempdata,0,1,StimArr,StimArr2);



%mytempdata = refactorFunc(mytempdata);
%answer = refactorFunc(traindata);
%{
    open1 = 8000



%}
%{
for i = 1:length(traindata.event)
    if length(answer(:,1))>i
        traindata.event(i).type = answer(i,1);
        traindata.event(i).latency = cell2mat(answer(i,2));
        traindata.event(i).urevent = cell2mat(answer(i,3));
        traindata.urevent(i).type = answer(i,1);
        traindata.urevent(i).latency = cell2mat(answer(i,2));
    else
        break
    end
    
    
    
end
%}
figure
realDat = mytempdata.data(PhotodiodeStimulationChannel,:).';
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,2) = realDat(:,2) - mean(realDat(:,2))
%realDat(:,3) = realDat(:,3) - mean(realDat(:,3))
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,5) = realDat(:,5) - mean(realDat(:,5))
%realDat(:,6) = realDat(:,6) - mean(realDat(:,6))
myX = linspace(0,length(realDat)/1000,length(realDat));
plot(realDat)
i = 1
%legend(mytempdata.chanlocs([1:4]).labels)
color = 'N'
while i <= length(mytempdata.event)
    %{
    if mytempdata.event(i).latency > 100000
        disp('got out')
        break
    end
    %}
    %
    if(strcmp(mytempdata.event(i).type, '100') || strcmp(mytempdata.event(i).type, '200'))
        color = 'magenta';
    elseif(max(strcmp(mytempdata.event(i).type, Stim1(1))))
        color = 'g';
    elseif(max(strcmp(mytempdata.event(i).type, Stim2(1))))
        color = 'r';    
    else
        color = 'N';  
    end
    %}
    
   
    
    if(~strcmp(color, 'N'))
        vline(mytempdata.event(i).latency,color)
    end
    i = i +1;
end

%{
plot(latencies, predictions(:,1)*100000,'black',...
    'LineWidth',2,...
    'MarkerSize',5,...
    'MarkerEdgeColor','black',...
    'MarkerFaceColor',[0.5,0.5,0.5])
%}