rosinit('10.0.75.2',11311, 'NodeHost','10.0.75.1')

% Subscribe and publish setup 
pub = rospublisher('/raw_vel');
sub_bump = rossubscriber('/bump');
msg = rosmessage(pub);


disp('Now receiving data...');

% Confirm that you are getting data

% Thresholds and dimensions
%  Left and Right spin

dataacc = [];
timestampacc = [];
t = 0
while 1
    
    % get data from the inlet (timeout: 1 second)
    if t < 20
        fprintf('%.2f\n',t);
        msg.Data = [0.05, 0.05];
        send(pub, msg); 
        t = t + 1
    elseif t>=20 && t < 40
        fprintf('%.2f\n',t); 
        msg.Data = [0.0, 0.0];
        send(pub, msg);
        t = t + 1
    else
        t = 0
    end
    send(pub, msg); 

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