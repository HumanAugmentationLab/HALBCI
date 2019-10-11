function [EEGout] = makeContinuousWithExtraMarkers(lastEEG,markersofinterest)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% markersofinterest is a cell with all markers of interest?

        % Check if data are epoched, if not, don't run this, because you've
        % already run it
    if length(size(EEG.data)) == 3 


        disp('Adding EEG markers...')

        k = 1; % New event index
        for i = 1:length(lastEEG.event) 
            if any(contains(markersofinterest,lastEEG.event(i).type))
                markerstring = EEG.event(i).type;

                for j = 0:(adetails.markers.numeventsperwindow) %For how many markers we are doing per window     
                    EEG.event(k).type = lastEEG.event(i).type;
                    EEG.event(k).latency = lastEEG.event(i).latency + (j*lastEEG.srate*adetails.markers.epochsize); 
                    EEG.event(k).latency_ms = lastEEG.event(i).latency_ms + (j*adetails.markers.epochsize*1000); 
                    EEG.event(k).duration = 0; %adetails.markers.epochsize; % seconds for continuous data
                    k = k+1; 
                end        
            else
                EEG.event(k).type = lastEEG.event(i).type;
                EEG.event(k).latency = lastEEG.event(i).latency; 
                EEG.event(k).latency_ms = lastEEG.event(i).latency_ms; 
                EEG.event(k).duration = 0;
                k = k+1;
            end
        end


    else
        display('Data are already continuous, skipping this function')
    end
    
end

