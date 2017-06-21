function [ 	inputdata ] = tryFindStart( inputdata,channelnum )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%MAKE SURE THE LATENCIES START AT 0 AND ARE IN SCOPE
%This function will try and find the first spike in some eeg data, marking
%the first photodiode trigger. Like calculateJitter, it will essentially
%slide a window from the start of the data that will stop and mark down the
%firs time that the next piece of data is outside the standard deviation of
%the window.
    realDat = inputdata.data(channelnum,:).';
    sizeWindow = 1000
    for i = sizeWindow+1:length(realDat)
        window = realDat(i-sizeWindow:i);
        if(realDat(i+1)-mean(window))/std(window) > 5 && (realDat(round(i-50))-mean(window))/std(window) < 5
            
            offset = i
            break
        end
    end
    for i = 1:length(inputdata.event)
        inputdata.event(i).latency = inputdata.event(i).latency + offset;
    end

end

