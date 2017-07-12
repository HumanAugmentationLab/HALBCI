%traindata = pop_loadxdf('K:\HumanAugmentationLab\EEGdata\EnobioTests\PhotodiodeScreen\block_nenobio.xdf')
%mytempdata = exp_eval(traindata)
%mytempdata = decreaseTrialsFunc(mytempdata,20,{'Open' 'Closed'})
traindata = io_loadset('C:\Users\gsteelman\Desktop\SummerResearch\6v15Hz_Flashing.edf')
mytempdata = exp_eval(traindata)
%mytempdata = refactorFunc(mytempdata);
%answer = refactorFunc(traindata);
%{
    open1 = 8000



%}
%{
for i = 1:length(traindata.event)
    if length(answer(:,1))>i
        traindata.event(i).type = answer(i,1);
        traindata.event(i).latency = cell2mat(answer(i,2));
        traindata.event(i).urevent = cell2mat(answer(i,3));
        traindata.urevent(i).type = answer(i,1);
        traindata.urevent(i).latency = cell2mat(answer(i,2));
    else
        break
    end
    
    
    
end
%}
figure
realDat = mytempdata.data(3,:).';
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,2) = realDat(:,2) - mean(realDat(:,2))
%realDat(:,3) = realDat(:,3) - mean(realDat(:,3))
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,5) = realDat(:,5) - mean(realDat(:,5))
%realDat(:,6) = realDat(:,6) - mean(realDat(:,6))
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
    if(strcmp(mytempdata.event(i).type, '1') || strcmp(mytempdata.event(i).type, '5'))
        color = 'magenta';
    elseif(strcmp(mytempdata.event(i).type, '2'))
        color = 'g';
    elseif(strcmp(mytempdata.event(i).type, '4'))
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

%{
plot(latencies, predictions(:,1)*100000,'black',...
    'LineWidth',2,...
    'MarkerSize',5,...
    'MarkerEdgeColor','black',...
    'MarkerFaceColor',[0.5,0.5,0.5])
%}