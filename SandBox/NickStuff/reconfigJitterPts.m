
for i = 1:length(jitterPts)
    mymean = mean(jitterPts)
    if abs(jitterPts(i)) > 150
        jitterPts(i) = mymean
    end
end
figure
plot(jitterPts(1:250)*2)