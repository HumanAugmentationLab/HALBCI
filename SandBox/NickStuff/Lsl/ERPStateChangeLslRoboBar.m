

%% Read in data stream and apply model, write out new predictor stream
% !C:\"Program Files (x86)"\Muse\muse-io.exe --lsl-eeg MuseEEG --no-dsp --preset ab &
% or run it from the command terminal

run_readlsl('MatlabStream','dopeStream','DataStreamQuery','type=''EEG''', 'MarkerStreamQuery','');
bci_stream_name = 'dopeStream';
%%
run_writelsl('Model',mymodel,'SourceStream',bci_stream_name,'LabStreamName','Res5','OutputForm','expectation','ChannelNames',{'open','closed'})

pause(3);

%%
bci_stream_name = 'Res5'
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');
%% If robots
rosinit('10.0.75.2',11311, 'NodeHost','10.0.75.1')
pause(1)
%teleopAndVisualizer()

% Subscribe and publish setup 
pub = rospublisher('/raw_vel');
sub_bump = rossubscriber('/bump');
msg = rosmessage(pub);

%% Actual demo
figure;
set(0,'DefaultAxesFontSize',18)
%ocstate = {'Closed','Open'};
ocstate = {'Open','Closed'};

robot = true;
robospeed = .05;

bar([1 1])
threshopen = 1.25;   
threshclosed = 1.75;
t = 0;
t2 = 0;
closed = false;
tic;
while true
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0);
    % and display it
    if timestamp
        if closed && data < threshopen % If actually open and state is closed
            closed = 0; %change to not closed
            fprintf(strcat(ocstate{mod(closed+1,2)+1},' : %3.1f\n'),toc)
            %pause(.2)
        elseif ~closed && data > threshclosed % if actually closed but state is not closed
            closed = 1; % set as closed
            fprintf(strcat(ocstate{mod(closed+1,2)+1},' : %3.1f\n'),toc)
            %pause(.2)
        end
        
        if closed
            t2 = t2 +1; %increment times in closed
        else
            t = t+1; %increment times in open
        end
            
        
        fprintf('%.2f\n',data);
        %disp(['Open ' num2str(t)])
        %disp(['Closed ' num2str(t2)])
        if t + t2 > 200
            t = 0;
            t2 = 0;
        end
        
        %Plot
        bar([data-1,1-(data-1)]); ylim([0 1]); xticklabels(ocstate);
        %bar([1-(data-1),data-1]); ylim([0 1]); xticklabels(ocstate);

        if ~closed
            title('CLOSED (predition)')
            if robot; msg.Data = [-robospeed, robospeed]; end
        else
            title('OPEN (predition)')
            if robot; msg.Data = [0, 0]; end
        end
        drawnow;
        if robot;  send(pub, msg); end
        %disp('pulled data')
    else
        pause(0.01);
    end
end

