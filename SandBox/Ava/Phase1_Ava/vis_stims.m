figure
for i = 1 : length(markerinfo)
   type = markerinfo(1,i);
   lat = markerinfo(2,i);
   
   if type == 769
       line([lat lat], [0 1800], 'Color', 'g');
   else if type == 770
       line([lat lat], [0 1800], 'Color', 'r');
       end
   end
end

EEG = pop_loadxdf('C:\Users\alakmazaheri\Desktop\mytest.xdf', 'streamtype', 'signal');
hold on
plot(EEG.data(3,:).')