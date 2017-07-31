EEG = pop_loadxdf('C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\bobtestmarker2.xdf', 'streamtype', 'EEG');
figure
plot(EEG.data(3,:).'); hold on
 
len = length(EEG.event);
offset = EEG.event(1).latency;
mymark = zeros(len,2);
for i = 1: len
   typ = str2double(EEG.event(i).type);
   mymark(i,1) = typ;
   lat = EEG.event(i).latency - offset;
   mymark(i,2) = lat;
    
   if(typ == 770)
   line([lat lat], [0 1800], 'Color', 'g')
   else if (typ == 769)
    line([lat lat], [0 1800], 'Color', 'r')
       else if (typ == 768)
             line([lat lat], [0 1800], 'Color', 'b')
           end
       end
   end
end