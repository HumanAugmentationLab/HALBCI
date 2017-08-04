function vis_data(inputdata,channelnum)

    figure; plot(inputdata.data(channelnum,:)');
    zoom xon;
    hold on;
    for i = 1: length(inputdata.event)
        e = inputdata.event(i);
        if(strcmp(e.type,'149'))
            line([e.latency e.latency], [0 1800], 'Color', 'r')
        else if (strcmp(e.type,'151'))
            line([e.latency e.latency], [0 1800], 'Color', 'g')
            end
        end
    end

end

