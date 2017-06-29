% Clear the workspace and the screen and set the variables
sca;
close all;
clearvars;
numTrials = 16;
Trialslength = 20;
timeBeforeOnset = 1;
repetitions = 1;
a_prob = .5;

% Here we call some defaulhelpt settings for setting up Psychtoolbox
PsychDefaultSetup(2);

%Undo Warnings
%
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;

% Open an on screen window using PsychImaging and color it black.
[w, wRect] = PsychImaging('OpenWindow', screenNumber, grey);

%define the slack in the system
slack = Screen('GetFlipInterval', w)/2

%define the image files
myimgfile = ['C:\Users\gsteelman\Desktop\SummerResearch\HALBCI\SandBox\Media\openEyes.jpg'];
fprintf('Using image ''%s''\n', myimgfile);
imdata=imread(myimgfile);
imagetexOpen=Screen('MakeTexture', w, imdata);

myimgfile = ['C:\Users\gsteelman\Desktop\SummerResearch\HALBCI\SandBox\Media\closedEyes.jpg'];
fprintf('Using image ''%s''\n', myimgfile);
imdata=imread(myimgfile);
imagetexClosed=Screen('MakeTexture', w, imdata);


%Define boundries for the rectangle in the bottom right and oval in the
%center
rSize = 250
[wW, wH]=WindowSize(w);
myrect=[wW-rSize wH - rSize wW wH];
myoval=[wW/2-rSize/2 wH/2-rSize/2 wW/2+rSize/2 wH/2 + rSize/2]; % center dRect on current mouseposition

%This code is for adjusting picture sizes
%{
[iy, ix, iz]=size(imdata); %#ok<NASGU>
%dRect = ClipRect(myrect,ctRect);
%sRect=OffsetRect(dRect, -dx, -dy);
tRect=Screen('Rect', imagetex);
[ctRect, dx, dy]=CenterRect(tRect, wRect);
if ix>wW || iy>wH
	fprintf('Image size exceeds screen size\n');
	fprintf('Image will be cropped\n');
end
if ix>wW
	cl=round((ix-wW)/2);
	cr=(ix-wW)-cl;
else
	cl=0;
	cr=0;
end
if iy>wH
	ct=round((iy-wH)/2);
	cb=(iy-wH)-ct;
else
	ct=0;
	cb=0;
end
%}
% Set up texture and rects

%load the audio file and format it correctly
InitializePsychSound;
[pahandle,wavedata] = loadSound(['C:\Users\gsteelman\Desktop\SummerResearch\HALBCI\SandBox\Media\default_ding.wav']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this part loads the lsl outlet so that it may send out markers
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'MyMarkerStreamPsych','Markers',1,0,'cf_string','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('click for stuff')
while 1
   [mx, my, buttons]=GetMouse(screenNumber);
   if find(buttons)
        while any(buttons)
            [mx, my, buttons]=GetMouse(screenNumber);
        end
        Screen('FillRect',w, black);
        clickedTime = Screen('Flip', w);
        break
    end 
    
end
mrk = 'StartSession'
Screen('FillRect',w, white,myrect);
rectTime = Screen('Flip', w,clickedTime + 30);
outlet.push_sample({mrk});
disp(['now sending ' mrk]);

Screen('FillRect',w, black);
endtrial = Screen('Flip', w,rectTime + 3);

Screen('FillRect',w, grey);
endtrial = Screen('Flip', w,endtrial + 3);

while 1
   [mx, my, buttons]=GetMouse(screenNumber);
   if find(buttons)
        while any(buttons)
            [mx, my, buttons]=GetMouse(screenNumber);
        end
        Screen('FillRect',w, black);
        endtrial = Screen('Flip', w);
        break
    end 
    
end


for i = 1:numTrials
    %Put oval on Screen
    Screen('FillOval', w, white,myoval);
	tfixation_onset = Screen('Flip', w,endtrial + 3);
    disp('Oval')
    if a_prob > rand()
        Screen('DrawTexture', w, imagetexOpen);
        Screen('FillRect',w, white,myrect);
        a_prob = a_prob - .05;
        mrk = 'Open'
    else
        Screen('DrawTexture', w, imagetexClosed);
        Screen('FillRect',w, white,myrect);
        a_prob = a_prob + .05;
        mrk = 'Closed'
    end
    %Put Picture on Screen 3 seconds after oval
    stim_onset = Screen('Flip', w,tfixation_onset + timeBeforeOnset - slack);
    outlet.push_sample({mrk});
    disp(['now sending ' mrk]);
    disp('Person')
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    
    %End Picture and send Audio
    mrk = 'EndTrial'
    PsychPortAudio('Start', pahandle, repetitions, stim_onset + Trialslength, 1);
    disp(['now sending ' mrk]);
    Screen('FillRect',w, black);
    endtrial = Screen('Flip', w,stim_onset + Trialslength);
    disp('Sound')
    outlet.push_sample({mrk});
    disp('Black')
    
    
    [mx, my, buttons]=GetMouse(screenNumber);
    if find(buttons)
        while any(buttons)
            [mx, my, buttons]=GetMouse(screenNumber);
        end

        mode = mode + 1;

        if mode == 1
            break;
        end
    end
end

Screen('FillRect',w, grey);
endtrial = Screen('Flip', w);

while 1
   [mx, my, buttons]=GetMouse(screenNumber);
   if find(buttons)
        while any(buttons)
            [mx, my, buttons]=GetMouse(screenNumber);
        end
        Screen('FillRect',w, black);
        clickedTime = Screen('Flip', w);
        break
    end 
    
end

mrk = 'EndSession'
Screen('FillRect',w, white,myrect);
rectTime = Screen('Flip', w,clickedTime + 10);
outlet.push_sample({mrk});
disp(['now sending ' mrk]);


% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo.


% Clear the screen.
PsychPortAudio('Close', pahandle);
%}
KbStrokeWait;
sca;