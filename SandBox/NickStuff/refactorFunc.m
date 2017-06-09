function [ answer ] = refactorFunc( mydata )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    srate = 220
    minoff = 5
    maxoff = 15
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

