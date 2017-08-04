ntraindata = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\longrecord.xdf');
%traindata = pop_loadxdf('C:\Users\gsteelman\Desktop\SummerResearch\bob6.xdf', 'streamtype', 'signal')
nmytempdata = tryFindStart(ntraindata,4);

atraindata = reconfigSNAP('C:\Users\alakmazaheri\Documents\BCI\MuseData\40mintest.xdf');
%traindata = pop_loadxdf('C:\Users\gsteelman\Desktop\SummerResearch\bob6.xdf', 'streamtype', 'signal')
amytempdata = tryFindStart(atraindata,4);

first = mytempdata.event(1).latency
first2 = mytempdata2.event(1).latency
if first > first2
    mytempdata.data = mytempdata.data(1:4,first-first2:end)
elseif first2>first
    mytempdata2.data = mytempdata2.data(1:4,first2-first:end)
end
size(mytempdata2.data(4,:))
size(mytempdata.data(4,:))

if length(mytempdata.data(4,:)) > length(mytempdata2.data(4,:))
    mytempdata.data = mytempdata.data(1:4,1:length(mytempdata2.data(4,:)))
elseif length(mytempdata.data(4,:)) < length(mytempdata2.data(4,:))
    mytempdata2.data = mytempdata2.data(1:4,1:length(mytempdata.data(4,:)))
end
figure
plot(mytempdata.data(4,:).')
hold on
plot(mytempdata2.data(4,:).')
figure
plot(mytempdata2.data(4,2:end).' - mytempdata.data(4,1:end -1).')