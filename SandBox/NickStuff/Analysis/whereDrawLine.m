t = 0
drawline = []
for j = -.5:.05:.5
    t = 0
    for i = 1:length(prediction)
        if round(prediction(i)+j) ~= round(targets(i))
            t = t+1;
        end
    end
    drawline = [drawline; t/length(prediction)];
end