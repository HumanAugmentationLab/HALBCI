%Run model on live data
run_readlsl('MatlabStream','dopeStream','DataStreamQuery','type=''EEG''', 'MarkerStreamQuery','');
bci_stream_name = 'dopeStream';

run_writelsl('Model',mymodel,'SourceStream',bci_stream_name,'LabStreamName','Res3','OutputForm','expectation','ChannelNames',{'open','closed'})

%% output model results
bci_stream_name = 'Res3';  
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

% Confirm that you are getting data

% Thresholds and dimensions
%  Left and Right spin

dataacc = [];
timestampacc = [];
figure

while 1
    try
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0);
    if timestamp
        fprintf('%.2f\n',data); 
        bar([1-(data-1),data-1]); ylim([0 1]); drawnow;
          
    end
    
    %pause(0.05);
    catch 
        break
    end
end
disp('done')
onl_clear(); % Shutdown connection to lsl (Clear all online streams and predictors.)
