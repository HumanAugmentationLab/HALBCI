%%This script will visualize the data directly around the event markers and
%%plot all the data of one class the same color
%First we load the data set in
addpath(genpath('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/NickStuff'))
Stim1 = '151';
Stim2 = '149';
pathToData = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/N3MuseIntrinsic.xdf';
pathToData2 = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/W3IntrinsicSelf.xdf';
pathToData3 = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/W4-Intrinsic.xdf';
pathToData4 = '/media/HumanAugmentationLab/EEGdata/Muse_EyesOpenClosed/NickTest2.xdf';
traindata = reconfigSNAP(pathToData4);
mytempdata = tryFindStart(traindata,3,0);

figure
hold on
realDat = mytempdata.data(5,:).';
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,2) = realDat(:,2) - mean(realDat(:,2))
%realDat(:,3) = realDat(:,3) - mean(realDat(:,3))
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,5) = realDat(:,5) - mean(realDat(:,5))
%realDat(:,6) = realDat(:,6) - mean(realDat(:,6))
time = 1
%myX = linspace(0,length(realDat)/1000,length(realDat));
%plot(realDat)
i = 1
%legend(mytempdata.chanlocs([1:4]).labels)
color = 'N'
currentWindow = []
currentWindow2 = []
while i <= length(mytempdata.event)
    %{
    if mytempdata.event(i).latency > 100000
        disp('got out')
        break
    end
    %}

    if(strcmp(mytempdata.event(i).type, Stim1))
        currentTime = mytempdata.event(i).latency;
        currentWindow = [currentWindow;realDat(currentTime-mytempdata.srate:currentTime+mytempdata.srate).'];
%         plot(currentWindow ,'b')
    elseif(strcmp(mytempdata.event(i).type, Stim2))
        currentTime = mytempdata.event(i).latency;
        currentWindow2 = [currentWindow2;realDat(currentTime-mytempdata.srate:currentTime+mytempdata.srate).'];
%         plot(currentWindow2 ,'g')  
    end
    %}
    
   
    i = i +1;
end

plot(mean(currentWindow),'b','linewidth',3)
plot(mean(currentWindow2),'g','linewidth',3)
legend('Open Eyes', 'Closed Eyes')
xlabel('Time After Stimulation (ms)')
ylabel('Voltage (uV)')
ylim([600 1050])
