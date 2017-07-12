function [ mydata ] = decreaseTrialsFunc( mydata, numTrials, TrialNames,random )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%For different training purposes this function will take and event marker
%and turn it into many event markers at the desired offset and rate.
%I believe it makes the markers the wrong type so additional processesing
%is required
    srate = 500
    rate = srate * 1
    answer = cell(2)
    t = 1
    Stim1 = char(TrialNames(1))
    Stim2 = char(TrialNames(2))
    minoff = 0
    maxoff = 0
    if random
       orderlist = randperm(length(mydata.event))
    end
        
    for i = 1:length(mydata.event)
        if random
            c = orderlist(i);
        else
            c = i;
        end
        if strcmp(mydata.event(c).type,Stim1) 
            for j = minoff * srate:rate:maxoff*srate
                answer{1,t} = Stim1;
                answer{2,t} = j+mydata.event(c).latency;
                t = t+1
            end

        elseif strcmp(mydata.event(c).type,Stim2)

            for j = minoff * srate:rate:maxoff*srate
                answer{1,t} = Stim2;
                answer{2,t} = j+mydata.event(c).latency;
                t = t+1
            end

        end
        if t > numTrials
            break;
        end
    end
    %I copied this code from another so am not 100% sure it works in
    %context. it is supposed to convert the data into the right format
    %because it is orignally a cell but supposed to be a character array to
    %work in bcilab
    answer = answer.';
    for i = 1:length(mydata.event)
        if length(answer(:,1))>i
            mydata.event(i).type = char(answer(i,1));
            mydata.event(i).latency = cell2mat(answer(i,2));
            %mydata.event(i).urevent = i;
            %mydata.urevent(i).type = char(answer(i,1));
            %mydata.urevent(i).latency = cell2mat(answer(i,2));
        else
            mydata.event(i).type = 'DUMMYMARKER';
            %mydata.urevent(i).type = 'DUMMYMARKER';
        end
    end

end

