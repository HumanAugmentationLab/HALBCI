figure
hold on

if ~exist('allData','var')
   makesuperMatrix; 
end
plotSize = 50;

freq = 7.5;
freq2 = 12;
freq3 = 15;
freq4 = 20;
one = 0;
list1 = [];
list2 = [];
list3 = [];
list4 = [];
for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq
      list1 = [list1;squeeze(mean(allData.DataTCF(i,:,6:plotSize))).'];
      one = one +1;
   end
    
end
one

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq2
      list2 = [list2;squeeze(mean(allData.DataTCF(i,:,6:plotSize))).'];
   end
    
end

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq3
      list3 = [list3;squeeze(mean(allData.DataTCF(i,:,6:plotSize))).'];
   end
    
end

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq4
      list4 = [list4;squeeze(mean(allData.DataTCF(i,:,6:plotSize))).'];
   end
    
end

plot(allData.freq(6:plotSize),mean(list1(:,:)),'b')
hold on
plot(allData.freq(6:plotSize),mean(list2(:,:)),'g')
plot(allData.freq(6:plotSize),mean(list3(:,:)),'r')
plot(allData.freq(6:plotSize),mean(list4(:,:)),'k')
xlim()
legend('7.5 Hz','12 Hz','15 Hz','20 Hz')
xlabel('Frequency (Hz)')
ylabel('Power')