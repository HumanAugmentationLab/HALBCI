%the data given for evaluation has not markers included so we have to make
%our own markers in order to check the accuracy of the developed model.
%this piece of code will take the "true y" data which has every time point
%and whether or not there is a marker at the point in time, and converts it
%into markers with the stimulation code and time point where it occurs by
%detecting differences between the last value and the current in a for loop
%over the time points.
timepoints = [0 0]
last = 2

for m = 1:length(true_y)
    if last ~= true_y(m) && ~isnan(true_y(m)) && true_y(m) ~= 0
        timepoints = [timepoints; true_y(m) m]
        disp('thing')
    end
    last = true_y(m);
end
timpoints(2) = timepoints(2) / 10