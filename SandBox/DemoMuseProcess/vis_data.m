function vis_data(inputdata,channelnum,linelim,timerange,text)

    figure; 
    plot(inputdata.data(channelnum,:)');
    xlim(timerange)
    title(text);
    zoom xon;
    hold on;
    for i = 1: length(inputdata.event)
        e = inputdata.event(i);
        if(strcmp(e.type,'149'))
            line([e.latency e.latency], [linelim(1) linelim(2)], 'Color', 'r')
        else if (strcmp(e.type,'151'))
            line([e.latency e.latency], [linelim(1) linelim(2)], 'Color', 'g')
            end
        end
    end

end

