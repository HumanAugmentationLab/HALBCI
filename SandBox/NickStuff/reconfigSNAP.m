function [ returndata ] = reconfigSNAP( filepath )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    returndata = pop_loadxdf(filepath)
    min = returndata.event(1).latency
    for i = 1:length(returndata.event)
        returndata.event(i).latency = returndata.event(i).latency - min
    end
end

