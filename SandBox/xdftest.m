[EEG] = pop_loadxdf('C:\Users\alakmazaheri\Desktop\untitled.xdf')
mydata = EEG.data;
plot(mydata(1:4, :)')