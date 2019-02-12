% Import data from text file

filename = '/home/hal/Research/HALBCI/Experiments/VideosBBallPilot/marker_test-log1.txt';
delimiter = ',';
startRow = 2;

formatSpec = '%s%f%f%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'char', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

% Close the text file.
fclose(fileID);

% Create output variable
new_marker_table = table(dataArray{1:end-1}, 'VariableNames', {'type','latency','latency_ms'});
new_marker_struct = table2struct(new_marker_table);

% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;
