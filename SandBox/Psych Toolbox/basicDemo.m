% Clear the workspace and the screen and set the variables
sca;
close all;
clearvars;
numTrials = 5;
Trialslength = 5;
timeBeforeOnset = 1;%time between trials
repetitions = 1;%This is how many times the audio file should repeat(No reason to be more than 1)
a_prob = .5;%Probability of each class

% Here we call some defaulhelpt settings for setting up Psychtoolbox
PsychDefaultSetup(2);
AssertOpenGL;
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

% Open an on screen window using PsychImaging and color it grey.
[w, wRect] = Screen('OpenWindow', 0, 0)
Screen('TextSize', w ,50);

%define the slack in the system (will be helpful for more accurate event markers)
slack = Screen('GetFlipInterval', w)/2

%define the image files and conver them to the appropriate format
myimgfile = ['/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/Media/openEyes.jpg'];
fprintf('Using image ''%s''\n', myimgfile);
imdata=imread(myimgfile);
imagetexOpen=Screen('MakeTexture', w, imdata);

myimgfile = ['/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/Media/closedEyes.jpg'];
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

%load the audio file and format it correctly
%InitializePsychSound;
%[pahandle,wavedata] = loadSound(['/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/Media/default_ding.wav']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this part loads the lsl outlet so that it may send out markers
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'PsychMarkers','Markers',1,0,'cf_int32','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This part is just a buffer screen to wait for the user to click when
%ready
try
    disp('click for stuff')
    %Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse to prep photodiode stimulation', wW/2-100, wH/2, black);
    clickedTime = Screen('Flip', w);
    while 1
       [mx, my, buttons]=GetMouse(screenNumber);
       if find(buttons)
            while any(buttons)
                [mx, my, buttons]=GetMouse(screenNumber);
            end
            Screen('FillRect',w, black);
            tic
            clickedTime = Screen('Flip', w);
            toc
            break
        end 

    end
    %This will wait for 30 seconds after the user clicks and then blink a white
    %square in the bottom right and send an event marker over lsl
    %The purpose of this is to enable syncing up the data when there is a
    %photodiode in place so that we can line up the event markers with their
    %proper timestamp in the data
    mrk = 100
    Screen('FillRect',w, white,myrect);
    toc
    rectTime = Screen('Flip', w,clickedTime + 30);
    toc
    outlet.push_sample(mrk);
    toc

    Screen('FillRect',w, black);
    endtrial = Screen('Flip', w,rectTime + 3);
    %We will then turn the screen grey and wait for a click before starting the
    %experiment in order to give time for the user to get the headband properly
    %situated
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse to start session', wW/2-100, wH/2, black);
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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Now we start the expriment
    for i = 1:numTrials
        %Put oval on Screen
        Screen('FillOval', w, white,myoval);
        disp('Tic')
        tic
        tfixation_onset = Screen('Flip', w,endtrial + 3);
        toc
        disp('Oval')
        %Select and load the correct image and event marker based on the
        %predefined probability of the first class. Each selection will
        %slightly change the probability in order to prevent a run with only 1
        %type of event
        if a_prob > rand()
            Screen('DrawTexture', w, imagetexOpen);
            Screen('FillRect',w, white,myrect);
            a_prob = a_prob - .05;
            mrk = 149
        else
            Screen('DrawTexture', w, imagetexClosed);
            Screen('FillRect',w, white,myrect);
            a_prob = a_prob + .05;
            mrk = 151
        end
        
        %Put Picture on Screen 3 seconds after oval (adjust for slack)
        %Imediately send the corresponding event marker afterwards
        toc
        stim_onset = Screen('Flip', w,tfixation_onset + timeBeforeOnset);
        toc
        outlet.push_sample(mrk);
        toc
        disp('Person')
        %Load the audio into the buffer for fast playing
        PsychPortAudio('FillBuffer', pahandle, wavedata);

        %End Picture and send Audio and event marker
        mrk = 170
        
        PsychPortAudio('Start', pahandle, repetitions, stim_onset + Trialslength, 1);
        Screen('FillRect',w, black);
        toc
        endtrial = Screen('Flip', w,stim_onset + Trialslength);
        toc
        disp('Sound')
        outlet.push_sample(mrk);
        toc
        disp('Black')

        %This is supposed to exit the loop if the user clicks, but it does not
        %work

    end
    %At the end of the experiment, this will turn the screen grey and wait for
    %the user click, then 10 seconds later it will flash another white square
    %for photodiode validation
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse when ready for end stimulation', wW/2, wH/2, black);
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

    mrk = 200
    Screen('FillRect',w, white,myrect);
    rectTime = Screen('Flip', w,clickedTime + 10);
    outlet.push_sample(mrk);


    % Now we have drawn to the screen we wait for a keyboard button press (any
    % key) to terminate the demo.
catch

    sca;
    ShowCursor;
    Priority(0);
    
    % Restore preferences
    %Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    %Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    psychrethrow(psychlasterror);
end


% Clear the screen.
PsychPortAudio('Close', pahandle);
%}
KbStrokeWait;
sca;