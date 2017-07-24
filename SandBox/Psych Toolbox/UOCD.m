% Clear the workspace and the screen and set the variables
sca;
close all;
clearvars;
%This is code specific to my computer because my ubuntu won't add a path on
%startup
addpath(genpath('/home/gsteelman/Desktop/Summer Research/labstreaminglayer/LSL/liblsl-Matlab'));
numTimes = 5;

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
white = [255 255 255]
black = [0 0 0]

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;
wW = 1920%for my laptop;
wH = 1080;
rSize = 250;
myrect=[wW-rSize wH - rSize wW wH];
myoval=[wW/2-rSize/2 wH/2-rSize/2 wW/2+rSize/2 wH/2 + rSize/2]; % center dRect on current mouseposition

% Open an on screen window using PsychImaging and color it grey.
[w, wRect] = Screen('OpenWindow', screenNumber, black,myrect)
Screen('TextSize', w ,50);

%define the slack in the system (will be helpful for more accurate event
%markers) 
slack = Screen('GetFlipInterval', w)/2;
%This next part will find the keyboard indexes of the desired kyes
Key1 = 'a';
Key2 = 's';
Key3 = 'd';
disp('Press the Following Button')
disp(Key1)
while 1
       
       if KbCheck
           [keyIsDown,secs,keyCode]=PsychHID('KbCheck');
           [Y, I]=max(keyCode);
           Key1Num = I;
           break
        end 

end
pause(.5)
disp('Press the Following Button')
disp(Key2)
while 1

       if KbCheck
           [keyIsDown,secs,keyCode]=PsychHID('KbCheck');
           [Y, I]=max(keyCode);
           Key2Num = I
           break
        end 

end
pause(.5)
disp('Press the Following Button')
disp(Key3)
while 1 

       if KbCheck
           [keyIsDown,secs,keyCode]=PsychHID('KbCheck');
           [Y, I]=max(keyCode);
           Key3Num = I
           break
        end 

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this part loads the lsl outlet so that it may send out markers
%as
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'PsychMarkers','Markers',1,0,'cf_int32','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This part is just a buffer screen to wait for the user to click when
%ready
%This code will essentially turn the screen grey, wait for a mouse click
%and when it does register one. turn it black and then white 10 seconds
%late to register a photodiode This can be adjusted to send a marker at the
%same time
try
    disp('click for stuff')
    Screen('FillRect',w, grey);
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
    Screen('FillRect',w, white);
    toc
    rectTime = Screen('Flip', w,clickedTime + 10);
    toc
    outlet.push_sample(mrk);
    toc

    Screen('FillRect',w, black);
    endtrial = Screen('Flip', w,rectTime + 3);
    %Next it will call KbCheck and send a marker if any of the
    %predetermined buttons had been pressed
    
    num = 0
    while 1
       
       if KbCheck
            [keyIsDown,secs,keyCode]=PsychHID('KbCheck')
            num = num+1;
            if keyCode(Key1) ==1
                mrk = 10
                outlet.push_sample(mrk);
                
            elseif keyCode(Key2) ==1
                mrk = 11
                outlet.push_sample(mrk);
                
                
                
            elseif keyCode(Key3) ==1
                mrk = 12
                outlet.push_sample(mrk);
                
                
                
            end
            disp('clic')
            if num > numTimes
                Screen('FillRect',w, black);
                clickedTime = Screen('Flip', w);
                break
            end
            pause(.2)
        end 

    end
    
    
    
    Screen('FillRect',w, grey);
    endtrial = Screen('Flip', w,endtrial + 3);

    %At the end of the experiment, this will turn the screen grey and wait
    %for 
    %the user click, then 10 seconds later it will flash another white square
    %for photodiode validation
    Screen('FillRect',w, grey);
    %Screen('DrawText', w, 'Click mouse when ready for end stimulation', wW/2, wH/2, black);
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
    Screen('FillRect',w, white);
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
%}
KbStrokeWait;
sca;