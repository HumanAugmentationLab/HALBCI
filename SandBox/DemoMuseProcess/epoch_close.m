function [ start_times_close ] = epoch_close( inputdata,channelnum,offset )
% Visual analysis of EEG data suggests that closing eyes is represented by
% a negative spike in channels TP9 and TP10, opening eyes a positive spike,
% and blinking a negative spike -> positive spike. 

% This function will try and find all isolated negative spikes in the data,
% essentially epoching closed eye periods, by sliding a window from the 
% start of the EEG session and marking each time the data is outside the 
% standard deviation of the window.
    realDat = inputdata.data(channelnum,:).';
    sizeWindow = 2000
    for i = sizeWindow+1+offset:length(realDat)-1
        window = realDat(i-sizeWindow:i);
        if(realDat(i+1)-mean(window))/std(window) > 5 && (realDat(round(i))-mean(window))/std(window) < 5
            start_times_close = [start_times_close; i]
            break
        end
    end
    for i = 1:length(inputdata.event)
        inputdata.event(i).latency = inputdata.event(i).latency + offset;
    end

end

