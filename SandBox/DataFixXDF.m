EEG = pop_loadxdf('C:\Users\alakmazaheri\Desktop\markertest1.xdf', 'streamtype', 'signal');

x = EEG;

eventlen = length(x.event);
latencies = zeros(eventlen, 1);
for i = 1:eventlen
    curr = x.event(i).latency + x.xmin*x.srate;
    EEG.event(i).latency = curr; % ms
end