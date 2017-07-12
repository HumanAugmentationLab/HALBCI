function [ mydata ] = refactorFunc( mydata, minoff,maxoff,epoch)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%For different training purposes this function will take and event marker
%and turn it into many event markers at the desired offset and rate.
%I believe it makes the markers the wrong type so additional processesing
%is required
    srate = 500
    rate = srate * epoch
    answer = cell(3)
    t = 1
    Stim1 = '101'
    Stim2 = '201'
    for i = 1:length(mydata.event)
        if strcmp(mydata.event(i).type,Stim1) 
            for j = minoff * srate:rate:maxoff*srate
                answer{1,t} = Stim1;
                answer{2,t} = j+mydata.event(i).latency;
                answer{3,t} = t;
                t = t+1;
            end

        elseif strcmp(mydata.event(i).type,Stim2)

            for j = minoff * srate:rate:maxoff*srate
                answer{1,t} = Stim2;
                answer{2,t} = j+mydata.event(i).latency;
                answer{3,t} = t;
                t = t+1
            end

        end
    end
    %I copied this code from another so am not 100% sure it works in
    %context. it is supposed to convert the data into the right format
    %because it is orignally a cell but supposed to be a character array to
    %work in bcilab
    answer = answer.';
    for i = 1:length(answer(:,1))
        if length(answer(:,1))>i
            mydata.event(i).type = char(answer(i,1));
            mydata.event(i).latency = cell2mat(answer(i,2));
            mydata.event(i).urevent = cell2mat(answer(i,3));
            mydata.urevent(i).type = char(answer(i,1));
            mydata.urevent(i).latency = cell2mat(answer(i,2));
        else
            break
        end
    end
end

