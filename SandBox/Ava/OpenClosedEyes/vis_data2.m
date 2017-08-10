function vis_data2(inputdata,channelnum)%, datrange)

    sr = inputdata.srate;
    figure;
    %xlim(datrange/sr*1000)
    hold on; 
    plot(inputdata.times, inputdata.data(channelnum,:)');
    n = ''; 
    for i = 1: length(inputdata.event)
        e = inputdata.event(i);
        col = 'k';
        n =  e.type;
        if strcmp(n,'221')
                col = 'r'; end
        if strcmp(n,'111')
                col = 'g'; end
        if strcmp(n,'211')
                col = 'b'; end
        if strcmp(n,'121')
                col = 'y'; end
            line([e.latency/sr*1000 e.latency/sr*1000], [-400 400], 'Color', col)
    end

end

