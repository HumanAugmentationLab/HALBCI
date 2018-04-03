function [ ] = vizData( mytempdata,PhotodiodeStimulationChannel,Stim1, Stim2 )

    figure
    realDat = mytempdata.data(PhotodiodeStimulationChannel,:).';
    myX = linspace(0,length(realDat)/1000,length(realDat));
    plot(realDat)
    i = 1
    %legend(mytempdata.chanlocs([1:4]).labels)
    color = 'N'
    while i <= length(mytempdata.event)
        %{
        if mytempdata.event(i).latency > 100000
            disp('got out')
            break
        end
        %}
        %
        if(strcmp(mytempdata.event(i).type, '100') || strcmp(mytempdata.event(i).type, '200'))
            color = 'magenta';
        elseif(max(strcmp(mytempdata.event(i).type, Stim1(1))))
            color = 'g';
        elseif(max(strcmp(mytempdata.event(i).type, Stim2(1))))
            color = 'r';    
        else
            color = 'N';  
        end
        %}



        if(~strcmp(color, 'N'))
            vline(mytempdata.event(i).latency,color)
        end
        i = i +1;
    end

end

