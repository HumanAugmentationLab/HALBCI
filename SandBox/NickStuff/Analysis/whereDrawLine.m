%%This script will give the accuarcy of a set of predictions between 1 and
%%2 ompared to an actual state depending on where the cutoff point between
%%1 and 2 is (e.g. should 1.4 be considered 1 or 2). This script should be
%%expanded to plot a False negative vs False Positive Curve. 
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