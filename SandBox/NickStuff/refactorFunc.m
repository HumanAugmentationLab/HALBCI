function [ answer ] = refactorFunc( mydata )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%For different training purposes this function will take and event marker
%and turn it into many event markers at the desired offset and rate.
%I believe it makes the markers the wrong type so additional processesing
%is required
    srate = 220
    minoff = 1.5
    maxoff = 3.5
    rate = srate
    answer = cell(3)
    t = 1
    for i = 1:length(mydata.event)
        if strcmp(mydata.event(i).type,'68') 
            for j = minoff * srate:rate:maxoff*srate
                answer{1,t} = '68';
                answer{2,t} = j+mydata.event(i).latency;
                answer{3,t} = t;
                t = t+1;
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
    answer = answer.';
end

