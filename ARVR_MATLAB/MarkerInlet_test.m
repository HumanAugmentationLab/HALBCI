% instantiate the library
addpath(genpath('./../../dependencies/liblsl-Matlab/'))
disp('Loading the library...');
lib = lsl_loadlib();

% resolve a stream...
disp('Resolving a Markers stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type', 'Markers'); end

% create a new inlet
disp('Opening an inlet...');
inlet = lsl_inlet(result{1});

disp('Now receiving data...');
mrks1 = []; ts1 = [];

lookback = 30;

figure();
i = 1;
[mrks,ts] = inlet.pull_sample();
zerots = ts;
mrks1(i)=mrks; ts1(i)=ts-zerots;
i = i + 1;

while i < 10000
    % get data from the inlet
    [mrks,ts] = inlet.pull_sample();
    ts = ts - zerots; % make time relative to first time step
    mrks1(i)=mrks; ts1(i)=ts;
    % and display it
    fprintf('got %d at time %.5f\n',mrks,ts);
    plot(ts1(max(i-lookback, 1):i),mrks1(max(i-lookback, 1):i),'r-');
    drawnow;
    pause(.01);
    i = i + 1;
end