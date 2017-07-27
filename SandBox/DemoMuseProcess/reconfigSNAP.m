
function [ returndata ] = reconfigSNAP( filepath )
%reconfigSNAP For xdfs using muse, subtract latency of first event from all
%events since the time scale coming from the muse are in a different clock
%system

%Will subtract the entire latencies of a eeg dataset by the first value
% I used a for loop because matlab does not like indexing with structures
% and cells
    returndata = pop_loadxdf(filepath);
    min = returndata.event(1).latency;
    for i = 1 : length(returndata.event)
        if strcmp(returndata.event(i).type, '99')
            min = returndata.event(i).latency;
        end
    end
    for i = 1:length(returndata.event)
        returndata.event(i).latency = (returndata.event(i).latency - min);%/500; %Fixed this; was converting to time instead of tps
    end
end

