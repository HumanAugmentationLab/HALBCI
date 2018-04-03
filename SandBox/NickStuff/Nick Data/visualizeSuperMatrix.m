%This code will cut out the desired trials from the supermatrix and display
%them for analysis
load('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/NickStuff/Nick Data/superMatrix.mat')
set(0,'DefaultAxesFontSize',12)
hold on

if ~exist('allData','var')
   makesuperMatrix; 
end
plotSize = 60;
channels = {'CP6','O2','O1','PO3','PO4'};
selectedChannels = []
for i = 1: length(channels)
    index = find(strcmp(allData.channels,char(channels(i))))
    selectedChannels = [selectedChannels index];
end
natural = 1;
freq = 7.5;
unfreq = 12;
freq2 = 12;
unfreq2 = 7.5;
freq3 = 7.5;
unfreq3 = 12;
freq4 = 12;
unfreq4 = 7.5;
one = 0;
list1 = [];
list2 = [];
list3 = [];
list4 = [];
for i = 1:length(allData.attIndex) 
   if allData.attIndex(i) == freq && allData.unattIndex(i) == unfreq && allData.sizeIndex(i)== 20
      if length(channels) > 1 temp = squeeze(mean(allData.DataTCF(i,selectedChannels,6:plotSize)));
      else  temp =  squeeze(allData.DataTCF(i,selectedChannels,6:plotSize));end
      list1 = [list1;temp.'];
      one = one +1;
   end
    
end
one

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq2 && allData.unattIndex(i) == unfreq2 && allData.sizeIndex(i)== 20
      if length(channels) > 1 temp = squeeze(mean(allData.DataTCF(i,selectedChannels,6:plotSize)));
      else  temp =  squeeze(allData.DataTCF(i,selectedChannels,6:plotSize));end
      list2 = [list2;temp.'];   
   end
    
end

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq3 && allData.unattIndex(i) == unfreq3 && allData.sizeIndex(i)== 2
      if length(channels) > 1 temp = squeeze(mean(allData.DataTCF(i,selectedChannels,6:plotSize)));
      else  temp =  squeeze(allData.DataTCF(i,selectedChannels,6:plotSize)); end
      list3 = [list3;temp.'];  
   end
    
end

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq4 && allData.unattIndex(i) == unfreq4 && allData.sizeIndex(i)== 2
      if length(channels) > 1 temp = squeeze(mean(allData.DataTCF(i,selectedChannels,6:plotSize)));
      else  temp =  squeeze(allData.DataTCF(i,selectedChannels,6:plotSize)); end
      list4 = [list4;temp.'];  
   end
    
end
figure
meanAll = mean([mean(list1(:,:));mean(list2(:,:));mean(list3(:,:));mean(list4(:,:))]);
if natural 
    plotOne = mean(list1(:,:));
else
    plotOne = mean(list1(:,:))-meanAll;
    plotOne(plotOne<0) = 0
end
if natural 
    plotTwo = mean(list2(:,:));
else
    plotTwo = mean(list2(:,:))-meanAll;
    plotTwo(plotTwo<0) = 0
end
if natural 
    plotThree = mean(list3(:,:));
else
    plotThree = mean(list3(:,:))-meanAll;
    plotThree(plotThree<0) = 0
end
if natural
    plotFour = mean(list4(:,:));
else
    plotFour = mean(list4(:,:))-meanAll;
    plotFour(plotFour<0) = 0
end

plot(allData.freq(6:plotSize),plotOne,'b','LineWidth',1)
hold on
plot(allData.freq(6:plotSize),plotTwo,'g','LineWidth',1)
plot(allData.freq(6:plotSize),plotThree,'b','LineWidth',2)
plot(allData.freq(6:plotSize),plotFour,'g','LineWidth',2)
legend('15 Hz','20 Hz','15 Hz B','20 Hz B')
title('P7 and P8')
xlabel('Frequency (Hz)')
ylabel('Power')