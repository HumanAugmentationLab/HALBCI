[y1, Fs1] = audioread('20Hz.wav');
[y2, Fs2] = audioread('100Hz.wav');
[y3, Fs3] = audioread('300Hz.wav');
[y4, Fs4] = audioread('1500Hz.wav');
[y5, Fs5] = audioread('7000Hz.wav');
[y6, Fs6] = audioread('14500Hz.wav');
[y7, Fs7] = audioread('20000Hz.wav');

folder = pwd;
name = 'Test_Final.wav';
fileName = fullfile(folder, name);
all = [y1; y2; y3; y4; y5; y6; y7;];
audiowrite(fileName, all, Fs1)

plot(all)