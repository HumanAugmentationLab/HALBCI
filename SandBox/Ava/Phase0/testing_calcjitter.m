traindata = preprocess('C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Phase0_Ava\bobtestmark.xdf');
mytempdata = traindata;
thres = 1000;
totaljit = 0
nummarker = 0
srate = 500
%answer = refactorFunc(traindata);
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
realDat = traindata.data(4,:).';
%realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,2) = realDat(:,2) - mean(realDat(:,2))
%realDat(:,3) = realDat(:,3) - mean(realDat(:,3))
realDat(:,1) = realDat(:,1) - mean(realDat(:,1))
%realDat(:,5) = realDat(:,5) - mean(realDat(:,5))
%realDat(:,6) = realDat(:,6) - mean(realDat(:,6))
myX = linspace(0,length(realDat)/1000,length(realDat));
plot(realDat)
i = 1
legend(mytempdata.chanlocs([1:4]).labels)
color = 'N'
while i < length(mytempdata.event)
    if(strcmp(mytempdata.event(i).type, '768'))
        color = 'N';
    elseif(strcmp(mytempdata.event(i).type, '769'))
        color = 'g';
    elseif(strcmp(mytempdata.event(i).type, '770'))
        color = 'r';    
    else
        color = 'N';  
    end
    if(~strcmp(color, 'N'))
        vline(mytempdata.event(i).latency,color);
        j = 0;
        while 1
            j = j +1;
            if realDat(round(mytempdata.event(i).latency + j)) > thres
                totaljit = totaljit + j
                nummarker = nummarker + 1;
                break
            elseif realDat(round(mytempdata.event(i).latency - j)) > thres
                totaljit = totaljit - j
                nummarker = nummarker + 1;
                break
            end
            
        end
    end
    i = i +1;
end
averagejit = (totaljit / nummarker)/srate

