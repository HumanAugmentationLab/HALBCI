%This Script calculates the difference between two sets of data recorded
%over lsl they are first loaded into matlab below
%next they are run through tryFindStart() in order to find the first event
%position for each in order to approximate the offset

%I now realize this could all be more easily accomplished with xcorr
traindata = reconfigSNAP('C:\Users\gsteelman\Desktop\longrecord.xdf');
%traindata = pop_loadxdf('C:\Users\gsteelman\Desktop\SummerResearch\bob6.xdf', 'streamtype', 'signal')
mytempdata = tryFindStart(traindata,4);

traindata2 = reconfigSNAP('C:\Users\gsteelman\Desktop\40mintest.xdf');
%traindata = pop_loadxdf('C:\Users\gsteelman\Desktop\SummerResearch\bob6.xdf', 'streamtype', 'signal')
mytempdata2 = tryFindStart(traindata2,4);

first = mytempdata.event(1).latency
first2 = mytempdata2.event(1).latency
%the first part will lop off the first part of the larger dataset in
%accordance with the precieved first event marker
if first > first2
    mytempdata.data = mytempdata.data(1:4,first-first2:end)
elseif first2>first
    mytempdata2.data = mytempdata2.data(1:4,first2-first:end)
end
%check each one's size
size(mytempdata2.data(4,:))
size(mytempdata.data(4,:))
%now check the length of each set and chop off the end of the larger one
if length(mytempdata.data(4,:)) > length(mytempdata2.data(4,:))
    mytempdata.data = mytempdata.data(1:4,1:length(mytempdata2.data(4,:)))
elseif length(mytempdata.data(4,:)) < length(mytempdata2.data(4,:))
    mytempdata2.data = mytempdata2.data(1:4,1:length(mytempdata.data(4,:)))
end
%and plot
figure
plot(mytempdata.data(4,:).')
hold on
plot(mytempdata2.data(4,:).')
figure
plot(mytempdata2.data(4,2:end).' - mytempdata.data(4,1:end -1).')


(mytempdata2.data(4,1:end-1).' - mytempdata.data(4,2:end).')