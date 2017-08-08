figure
hold on

if ~exist('allData','var')
   makesuperMatrix; 
end

freq = 7.5;
freq2 = 12;
freq3 = 15;
freq4 = 20
one = 0;
list1 = []
list2 = []
list3 = []
list4 = []
for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq
      list1 = [list1;squeeze(mean(allData.DataTCF(i,:,1:50))).'];
      one = one +1;
   end
    
end
one

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq2
      list2 = [list2;squeeze(mean(allData.DataTCF(i,:,1:50))).'];
   end
    
end

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq3
      list3 = [list3;squeeze(mean(allData.DataTCF(i,:,1:50))).'];
   end
    
end

for i = 1:length(allData.attIndex)
   if allData.attIndex(i) == freq4
      list4 = [list4;squeeze(mean(allData.DataTCF(i,:,1:50))).'];
   end
    
end

plot(linspace(1,25,50),mean(list1(:,:)),'b')
hold on
plot(linspace(1,25,50),mean(list2(:,:)),'g')
plot(linspace(1,25,50),mean(list3(:,:)),'r')
plot(linspace(1,25,50),mean(list4(:,:)),'k')
legend('7.5','12','15','20')