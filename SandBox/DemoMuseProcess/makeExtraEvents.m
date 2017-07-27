function [ outdata ] = makeExtraEvents( mydata, minoff,maxoff,epoch)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%For different training purposes this function will take and event marker
%and turn it into many event markers at the desired offset and rate.
%I believe it makes the markers the wrong type so additional processesing
%is required
    outdata = mydata;
    srate = mydata.srate;
    rate = srate * epoch;
    t = 1; % new event counter
    Stim1 = '149'
    Stim2 = '151'
    for i = 1:length(mydata.event)
        
        if strcmp(mydata.event(i).type,Stim1) || strcmp(mydata.event(i).type,Stim2)
            for j = minoff * srate:rate:maxoff*srate
                outdata.event(t).type = mydata.event(i).type;
                outdata.event(t).latency = j+mydata.event(i).latency;
                outdata.event(t).duration = epoch;
                t = t+1;
            end
        else %If you're not refactoring, just copy the same info in with a new index number t
            outdata.event(t).type = mydata.event(i).type;
            outdata.event(t).latency = mydata.event(i).latency;
            outdata.event(t).duration = mydata.event(i).duration;
            t = t +1;
        end    
    end
end

