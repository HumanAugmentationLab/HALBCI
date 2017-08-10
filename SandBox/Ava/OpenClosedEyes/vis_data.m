function vis_data(inputdata,channelnum)

    figure; plot(inputdata.data(channelnum,:)', 'LineWidth', 2);
    zoom xon;
    hold on;
    for i = 1: length(inputdata.event)
        e = inputdata.event(i);
        if(strcmp(e.type,'149'))
            line([e.latency e.latency], [-500 500], 'Color', 'r', 'LineWidth', 2)
        else if (strcmp(e.type,'151'))
            line([e.latency e.latency], [-500 500], 'Color', 'g', 'LineWidth', 2)
            end
        end
    end

end

