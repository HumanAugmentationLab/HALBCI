%% Outlet (REMEMBER TO DELETE ETHERNET CONNECTION IN WIRELESS & NETWORKING OPTION

% instantiate the library
disp('Loading library...');
lib = lsl_loadlib();

% make a new stream outlet
% the name (here MyMarkerStream) is visible to the experimenter and should be chosen so that 
% it is clearly recognizable as your MATLAB software's marker stream
% The content-type should be Markers by convention, and the next three arguments indicate the 
% data format (1 channel, irregular rate, string-formatted).
% The so-called source id is an optional string that allows for uniquely identifying your 
% marker stream across re-starts (or crashes) of your script (i.e., after a crash of your script 
% other programs could continue to record from the stream with only a minor interruption).
disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'Will_Markers_string','Markers',1,0,'cf_string','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);

% send markers into the outlet
disp('Now transmitting data...');
%string markers
%markers = ['Test', 'Blah', 'Marker', 'XXX', 'Testtest', 'Test-1-2-3'];

%int markers
%markers = [1, 2, 3, 4, 5, 6, 7, 8];
disp(markers)
i = 0;
while i < 2000
    pause(rand()*.5);
    %mrk = randi([1, 6]);
    %mrk = markers{min(length(markers), 1+floor(rand()*(length(markers))))};
    %disp(num2str(mrk));
    outlet.push_sample("Test");   % note that the string is wrapped into a cell-array
    i = i + 1;
end


