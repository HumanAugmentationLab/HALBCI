%%This was just used to test importing enobio data into matlab
traindata = io_loadset('C:\Users\gsteelman\Desktop\SummerResearch\testMark2.edf')
mytempdata = exp_eval(traindata)
traindata = pop_loadxdf('K:\HumanAugmentationLab\EEGdata\EnobioTests\PhotodiodeScreen\block_nenobio.xdf')
mytempdata2 = exp_eval(traindata)
plot(diff(mytempdata.event(2:end).latency))