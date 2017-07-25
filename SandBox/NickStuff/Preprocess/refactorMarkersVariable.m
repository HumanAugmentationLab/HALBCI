function [ mydata ] = refactorMarkersVariable( mydata, minoff,epoch, Stim1, Stim2 )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%%This script will input markers at a given interval after one stimulation
%%until another stimulation for 2 cognitive states.
%%Stim1 and Stim2 should both be arrays with the first value as the start
%%stimulation and all further values the stop stimulation
%%Sorry for the spaghetti code but I could not think of
%%a much better option for this situation
    srate = 500;
    rate = srate * epoch;
    answer = cell(3);
    t = 1;

    for i = 1:length(mydata.event)-1
        if strcmp(mydata.event(i).type,Stim1(1)) 
            for j = i+1:length(mydata.event)
                maxoff = mydata.event(j).latency;
                if max(strcmp(Stim1,mydata.event(j).type))
                    break
                end
                
            end
            for j = minoff * srate + mydata.event(i).latency:rate:maxoff-rate
                answer{1,t} = char(Stim1(1));
                answer{2,t} = j;
                answer{3,t} = t;
                t = t+1;
            end

        elseif strcmp(mydata.event(i).type,Stim2(1))

            for j = i+1:length(mydata.event)
                maxoff = mydata.event(j).latency;
                if max(strcmp(Stim2,mydata.event(j).type))
                    break
                end
                
            end
            for j = minoff * srate + mydata.event(i).latency:rate:maxoff-rate
                answer{1,t} = char(Stim2(1));
                answer{2,t} = j;
                answer{3,t} = t;
                t = t+1;
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

