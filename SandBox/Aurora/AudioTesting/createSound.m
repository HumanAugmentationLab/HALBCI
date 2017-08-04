clc;
clear;

%creating file
folder = pwd;
baseFileName = '20000Hz.wav';
fileName = fullfile(folder, baseFileName);
fprintf('Full File Name = %s\n', fileName);

T = .25; %how long in seconds  
Fs = 44100; % sampling rate: how many data points per second
dp = Fs*T; %data points for whole time
tp = 1:dp; %vector of data points
t = 0:(1/Fs):(T-1/Fs);

% humans can hear between 20 Hz and 20,000 Hz
f = 20000; % frequency 
%T = linspace(30, 4, length(t)); %pitch changes

a = 0.6; %maximum amplitude %32767
%a = a .* exp(-0.0003*t); %adding exponential decay to amplitude

%a = a .* rand(1, length(x)); %adds a shushing/roaring sound
%a = a .* sin(2.*pi.*t./2000); %adds a decaying pulsing sound

y = a .* sin(2.*pi.*t.*f); %constructing the waveform

%plotting the waveform
% plot(t, y, 'b-');
% title('Sound Wave');
% xlabel('Time (Sec)');
% ylabel('Amplitude');
% axis([0 1 -1 1])
% grid on;

y_silence = zeros(1,dp); %one second of silence

y_long = [y y_silence y y_silence y y_silence y y_silence];
T2 = length(y_long)/Fs;
t_long = 0:(1/Fs):(T2-1/Fs);
sound(y_long, Fs);
plot(t_long, y_long, 'b-');
axis([0 T2 -1 1])

audiowrite(fileName, y_long, Fs) %write wave to .wav file



% sample from online
% load handel.mat
% 
% filename = 'handel.wav';
% audiowrite(filename,y,Fs);
% clear y Fs
% 
% [y,Fs] = audioread('handel.wav');
% 
% t = 1:73113;
% sec = length(y)/Fs;
% t2 = 0:(1/Fs):(sec-1/Fs);
% %sound(y,Fs);
% plot(t2, y);
