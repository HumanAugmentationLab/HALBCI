function [cleanevents] = onsetmark(inputdata)
e0 = '123456789';
cleanevents = inputdata.event;

for i = 1: length(inputdata.event)-1
   e = inputdata.event(i);
   
   disp(i)
   if(strcmp(e.type,e0))
       cleanevents.event(i) = [];
       i = i-1;
   end
   
   e0 = e.type;

end

