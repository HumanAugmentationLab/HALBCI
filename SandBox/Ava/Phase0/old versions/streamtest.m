bci_stream_name = 'BCI-Continuous';  

f=figure;
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name'q,bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');
while true
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0); % Timeout default: 60s
    % and display it
    if timestamp
        fprintf('%.2f\n',data); 
        bar([data-1,1-(data-1)]); ylim([0 1]); drawnow;
    else
        pause(0.01); % Receive Data: no pause
    end
end