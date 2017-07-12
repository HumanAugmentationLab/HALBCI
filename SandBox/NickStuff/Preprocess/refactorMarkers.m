%Does the same thing as refactor Func
traindata = io_loadset('C:\Users\gsteelman\Desktop\bob1.gdf','channels',1:4);
srate = 220
minoff = 5
maxoff = 15
rate = srate * .1
mydata = exp_eval(traindata)
answer = cell(3)
t = 1
for i = 1:length(mydata.event)
    if strcmp(mydata.event(i).type,'68') 
        for j = minoff * srate:rate:maxoff*srate
            answer{1,t} = '68';
            answer{2,t} = j+mydata.event(i).latency;
            answer{3,t} = t;
            t = t+1
        end
        
    elseif strcmp(mydata.event(i).type,'69')
        
        for j = minoff * srate:rate:maxoff*srate
            answer{1,t} = '69';
            answer{2,t} = j+mydata.event(i).latency;
            answer{3,t} = t;
            t = t+1
        end
        
    end
end
answer = answer.'