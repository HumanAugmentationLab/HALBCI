
addpath('C:\Users\alakmazaheri\Documents\BCI\labstreaminglayer\Apps\MATLAB Viewer')


%% Write to LSL
addpath(genpath('/home/hal/Research/Matlab/BCILAB/dependencies/liblsl-Matlab'));

disp('Loading library...');
lib = lsl_loadlib();

disp('Creating new marker stream info')
info = lsl_streaminfo(lib, 'EMGMarkers', 'Markers', 1, 0, 'cf_int32', 'mysourceid');

disp('Opening an outlet...')
outlet = lsl_outlet(info);

pause(5);
disp('Starting')
pause(1);

a = 2; b = 3;
n = 25;
% markers = [zeros(n, 1); ones(n, 1)];
markers = repmat([0 1], 1, n);
% markers_shuffle = markers(randperm(length(markers)));

for i = 1:n*2
    gestureMarker = markers(i);
    outlet.push_sample(gestureMarker);
    disp(gestureMarker);
    pause_dur = (b-a).*rand(1,1) + a;
    pause(pause_dur);
end

disp('Done')
%% Read from LSL


% instantiate the library
disp('Loading the library...');
lib = lsl_loadlib();

% resolve a stream...
disp('Resolving a Markers stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG'); end

% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});

disp('Now receiving data...');
while true
    % get data from the inlet
    [mrks,ts] = inlet.pull_sample();
    % and display it
    fprintf('got %s at time %.5f\n',mrks,ts);
end

%% Read from XDF
streams = load_xdf('C:/Users/alakmazaheri/Desktop/test.xdf')
streams = exp_eval(io_loadset('C:/Users/alakmazaheri/Desktop/test.xdf'))

n = 2;
plot(streams{1,n}.time_stamps, streams{1,n}.time_series');
hold on
% for i = 1:length(streams{1,1}.time_stamps)
%    vline(streams{1,1}.time_stamps(i))
% end