function EEG = preprocess(filename)
    % Load EEG and Marker data from XDF
    EEG = pop_loadxdf(filename, 'streamtype', 'signal');
    %{
    % Sync marker latencies
    x = EEG;
    eventlen = length(x.event);
    latencies = zeros(eventlen, 1);
    for i = 1:eventlen
        curr = x.event(i).latency + x.xmin*x.srate; % Add data offset in samples
        EEG.event(i).latency = curr;
    end

    % Remove accelerometer channels
    EEG.nbchan = 4;
    EEG.data = EEG.data(1:4,:);
    EEG.chanlocs(5:6) = [];
    %}
end