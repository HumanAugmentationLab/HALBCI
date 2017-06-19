traindata = reconfigSNAP('C:\Users\gsteelman\Desktop\longrecord.xdf');
%traindata = pop_loadxdf('C:\Users\gsteelman\Desktop\SummerResearch\bob6.xdf', 'streamtype', 'signal')
mytempdata = tryFindStart(traindata,4);
%mytempdata = traindata;
thres = 1000;
absjit = 0
nummarker = 0
srate = 500
sizeWindow = 500
jitterPts = []
deviations = 5
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
realDat = mytempdata.data(4,:).';
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
    if(strcmp(mytempdata.event(i).type, '700'))
        color = 'b';
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
            a = round(mytempdata.event(i).latency)
            if round(a + j-sizeWindow) > 0 && round(a + j) < mytempdata.pnts
                window = realDat(a + j-sizeWindow:a + j);
                if(realDat(round(a+j+1))-mean(window))/std(window) > 5 && (realDat(round(a+j))-mean(window))/std(window) < 5
                   jitterPts = [jitterPts;j];
                   vline(a+j+1,'black');
                   absjit = absjit + j;
                   nummarker = nummarker + 1;
                   break
                end
            end
            
            if round(a - j-sizeWindow) > 0 && round(a - j) < mytempdata.pnts
                window = realDat(a - j-sizeWindow:a - j);
                if(realDat(a-j+1)-mean(window))/std(window) > 5 && (realDat(a-j)-mean(window))/std(window) < 5
                   jitterPts = [jitterPts;-j];
                   vline(a-j+1,'black');
                   absjit = absjit + j;
                   nummarker = nummarker + 1;
                   break
                end
            end
            
            %{
            if round(mytempdata.event(i).latency + j) < mytempdata.pnts && (round(mytempdata.event(i).latency + j)) > thres
                
            elseif round(mytempdata.event(i).latency - j) > 0 && round(mytempdata.event(i).latency + j) < mytempdata.pnts && realDat(round(mytempdata.event(i).latency - j)) > thres
                
            end
            %}
            j = j +1;
            
        end
    end
    i = i +1;
end
averagejit = (absjit / nummarker)/srate
figure
plot(jitterPts*2)
xlabel('trials')
ylabel('jitter (ms)')
nickdat = realDat