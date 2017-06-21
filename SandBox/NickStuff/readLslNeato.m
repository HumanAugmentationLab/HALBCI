%This script will read in a stream called 'Res' over lsl and display the 
%result
%The purpose of the first while loop is to make sure that the first loop is
%found
bci_stream_name = 'Res'
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {}
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

while true
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0);
    % and display it
    if timestamp
        fprintf('%.2f\n',data);
        %bar([data-1,1-(data-1)]); ylim([0 1]); drawnow;
        disp('pulled data')
    else
        pause(0.01);
    end
end

