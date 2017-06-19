%this is a very simple helper script that will take out anomalies in the
%jitter points so to better visualize the data. 150 is the threshold for
%the specific data we were working with
for i = 1:length(jitterPts)
    mymean = mean(jitterPts)
    if abs(jitterPts(i)) > 150
        jitterPts(i) = mymean
    end
end
figure
plot(jitterPts(1:250)*2)