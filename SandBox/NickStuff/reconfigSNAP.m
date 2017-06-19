
function [ returndata ] = reconfigSNAP( filepath )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%haha sure
%Not sure how detailed I can go with this simple function
%Will subtract the entire latencies of a eeg dataset by the first value
% I used a for loop because matlab does not like indexing with structures
% and cells
    returndata = pop_loadxdf(filepath)
    min = returndata.event(1).latency
    for i = 1:length(returndata.event)
        returndata.event(i).latency = returndata.event(i).latency - min
    end
end

