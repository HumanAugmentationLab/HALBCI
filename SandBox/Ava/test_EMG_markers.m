%% Write to LSL
addpath(genpath('/home/hal/Research/Matlab/BCILAB/dependencies/liblsl-Matlab'));

disp('Loading library...');
lib = lsl_loadlib();

disp('Creating new marker stream info')
info = lsl_streaminfo(lib, 'PsychMarkers', 'Markers', 1, 0, 'cf_int32', 'mysourceid');

disp('Opening an outlet...')
outlet = lsl_outlet(info);

for gestureMarker = 1:10
    outlet.push_sample(gestureMarker);
    disp(gestureMarker);
    pause(2);
end


%% Read from LSL

% streams = load_xdf('C:/Users/alakmazaheri/Desktop/dummy.xdf')

% instantiate the library
disp('Loading the library...');
lib = lsl_loadlib();

% resolve a stream...
disp('Resolving a Markers stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','Markers'); end

% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});

disp('Now receiving data...');
while true
    % get data from the inlet
    [mrks,ts] = inlet.pull_sample();
    % and display it
    fprintf('got %s at time %.5f\n',mrks{1},ts);
end