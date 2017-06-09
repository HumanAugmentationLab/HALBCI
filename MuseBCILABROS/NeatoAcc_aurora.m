rosinit('10.0.75.2',11311, 'NodeHost','10.0.75.1')

% Subscribe and publish setup 
pub = rospublisher('/raw_vel');
sub_bump = rossubscriber('/bump');
msg = rosmessage(pub);

bci_stream_name = 'museacc';  
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

% Confirm that you are getting data
vis_stream('museacc');
% Close the vis_stream window
pause(1);
[tempdataacc,temptimestampacc] = inlet.pull_chunk();
mean(tempdataacc,2)

% Thresholds and dimensions
%  Left and Right spin
dim_leftright = 3; % Which accelerometer index
dim_updown = 2;
thresh_left = -200; % 
thresh_right = 200; %
thresh_down = -200;
robospeed = .05;
dataacc = [];
timestampacc = [];

while 1
    
    % get data from the inlet (timeout: 1 second)
    [tempdataacc,temptimestampacc] = inlet.pull_chunk();
    if ~isempty(temptimestampacc)
        %fprintf('%.2f\n',dataacc); 
        %bar([data-1,1-(data-1)]); ylim([0 1]); drawnow;
        lrmovingavg = mean(tempdataacc(dim_leftright,:))
        lrmovingavg2 = mean(tempdataacc(dim_updown,:))
        if lrmovingavg < thresh_left %Head tilted left, turn left
            msg.Data = [-robospeed, robospeed];
        elseif lrmovingavg > thresh_right %Head tilted right, turn right
            msg.Data = [robospeed, -robospeed];
        elseif lrmovingavg < thresh_down
            ms.Data = [0,0];
        else %Otherwise go forward
            msg.Data = [0.05, 0.05];
        end
% %         send(pub, msg); 
    end

    % wait for the next bump message
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