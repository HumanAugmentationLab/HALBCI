function [ 	inputdata ] = tryFindStart( inputdata,channelnum )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%MAKE SURE THE LATENCIES START AT 0 AND ARE IN SCOPE
    realDat = inputdata.data(channelnum,:).';
    sizeWindow = 500
    for i = sizeWindow+1:length(realDat)
        window = realDat(i-sizeWindow:i);
        if(realDat(i+1)-mean(window))/std(window) > 3
            offset = i
            break
        end
    end
    for i = 1:length(inputdata.event)
        inputdata.event(i).latency = inputdata.event(i).latency + offset;
    end

end

