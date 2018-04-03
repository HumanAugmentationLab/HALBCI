  Fs = 14100;
  time = (0:1/Fs:12*60);    % 12 minute audio
  t1 = time(1:Fs*2*60);     % Indices for the first 2 minutes
  xalpha = sin(2*pi*10*time(1:Fs*2*60)); % Wave at the alpha freq=10 Hz
  xpb =  sin(2*pi*50*time(1:Fs*2*60)); % sound of the sea
  xalphasea = xalpha.*xpb; %alpha as a carrier of the sea sound
  xrun(1:Fs*2*60) = xalpha;
  xrun(Fs*2*60+1,Fs*4*60)=xpb;
  xrun(Fs*4*60+1,Fs*8*60)=xpb;
  xrun(Fs*8*60+1,Fs*10*60-1)=xalpha;
  xrun(Fs*10*60+1,Fs*12*60-1)=xpb;
  % Can the amplitude be made about 30dB ?