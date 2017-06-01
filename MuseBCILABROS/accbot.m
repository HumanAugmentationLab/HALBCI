% BCILAB LSL on accel data to control Neato over ROS

%% Initialize ROS and connect to robot
% 1) Make sure docker is running 
% 2) Press Win+R and run: 
%  cmd /c docker run --net=host -e HOST=192.168.16.93 -it paulruvolo/neato_docker:qea 
%  with the IP address that matches you robot.
% 3) Run the code below to intialize and test the robot connection. When
% you're done, close the visualizer window to stop driving the Neato
% around.

rosinit('10.0.75.2',11311, 'NodeHost','10.0.75.1')
pause(1)
teleopAndVisualizer()

% Subscribe and publish setup 
pub = rospublisher('/raw_vel');
sub_bump = rossubscriber('/bump');
msg = rosmessage(pub);

%% Initialize Muse to read in accelerometer data
% 1) Connect to Muse via bluetooth
% 2) Use muse-io to connect over lsl
%       a) cd C:\Program Files (x86)\Muse
%       b) muse-io.exe --lsl-acc museacc
% 3) Run code below to read in acc data from Muse


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
input();
pause(1);
[tempdataacc,temptimestampacc] = inlet.pull_chunk();
mean(tempdataacc,2)

%% Super basic threshold model for controlling the Neato

% Thresholds and dimensions
%  Left and Right spin
dim_leftright = 3; % Which accelerometer index
thresh_left = -200; % 
thresh_right = 200; %
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
        if lrmovingavg < thresh_left %Head tilted left, turn left
            msg.Data = [-robospeed, robospeed];
        elseif lrmovingavg > thresh_right %Head tilted right, turn right
            msg.Data = [robospeed, -robospeed];
        else %Otherwise stop
            msg.Data = [0.0, 0.0];
        end
        send(pub, msg); 
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

%% Shutdown connections 

onl_clear(); % Shutdown connection to lsl (Clear all online streams and predictors.)
rosshutdown(); % Shutdown ROS





