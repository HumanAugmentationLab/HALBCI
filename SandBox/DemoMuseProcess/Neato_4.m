rosinit('10.0.75.2',11311, 'NodeHost','10.0.75.1')

% Subscribe and publish setup 
pub = rospublisher('/raw_vel');
sub_bump = rossubscriber('/bump');
msg = rosmessage(pub);

bci_stream_name = 'Res';
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

while 1
    
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0);
    if timestamp
        fprintf('%.2f\n',data); 
        %bar([data-1,1-(data-1)]); ylim([0 1]); drawnow;
        
        if data > 1.75
            msg.Data = [0.1, 0.1];
            disp('go')
        else 
            msg.Data = [0.0, 0.0];
        end
        send(pub, msg); 
    end
        
    bumpMessage = receive(sub_bump);
    % check if any of the bump sensors are set to 1 (meaning triggered)
    if any(bumpMessage.Data)
        msg.Data = [0.0, 0.0];
        send(pub, msg);
        break;
    end
    
    pause(0.01);
end

onl_clear(); % Shutdown connection to lsl (Clear all online streams and predictors.)
rosshutdown(); % Shutdown ROS