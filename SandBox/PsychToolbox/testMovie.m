
sca;
close all;
numTrials = 10;
Trialslength = 5;
timeBeforeOnset = 1;%time between trials
repetitions = 1;%This is how many times the audio file should repeat(No reason to be more than 1)
a_prob = .5;%Probability of each class

% Here we call some defaulhelpt settings for setting up Psychtoolbox
PsychDefaultSetup(2);
AssertOpenGL;
%Undo Warnings
%
%oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
%oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
%}
SimpleMovieDemo()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{

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
[w, wRect] = PsychImaging('OpenWindow', screenNumber, grey);
Screen('TextSize', w ,50);

%define the slack in the system (will be helpful for more accurate event markers)
slack = Screen('GetFlipInterval', w)/2


%Define boundries for the rectangle in the bottom right and oval in the
%center
rSize = 250
[wW, wH]=WindowSize(w);
myrect=[wW-rSize wH - rSize wW wH];
myoval=[wW/2-rSize/2 wH/2-rSize/2 wW/2+rSize/2 wH/2 + rSize/2]; % center dRect on current mouseposition

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this part loads the lsl outlet so that it may send out markers
%{
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
try
    disp('click for stuff')
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse to Start', wW/2-100, wH/2, black);
    clickedTime = Screen('Flip', w);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Now we start the expriment
    moviename = [ PsychtoolboxRoot 'PsychDemos/MovieDemos/DualDiscs.mov' ];
    
    
        % Start playback engine:

    
    movie = Screen('OpenMovie', w, moviename);
    
    Screen('PlayMovie', movie, 1);
    
    % Playback loop: Runs until end of movie or keypress:
    while ~KbCheck
        % Wait for next movie frame, retrieve texture handle to it
        tex = Screen('GetMovieImage', win, movie);
        
        % Valid texture returned? A negative value means end of movie reached:
        if tex<=0
            % We're done, break out of loop:
            break;
        end
        
        % Draw the new texture immediately to screen:
        Screen('DrawTexture', win, tex);
        
        % Update display:
        Screen('Flip', win);
        
        % Release texture:
        Screen('Close', tex);
    end
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    
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
sca