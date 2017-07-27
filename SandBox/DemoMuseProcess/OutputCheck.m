bci_stream_name = 'Res666';  
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

while 1
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0);
    if timestamp
        fprintf('%.2f\n',data); 
        %figure; bar([data-1,1-(data-1)]); ylim([0 1]); drawnow;
    end
    pause(0.01);
end