
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Use an observer to record if a persons eyes are open, closed or if they
% blinked. This script sends triggers over LSL that indicate the condition.

% This begins with a photodiode calibration (that can be turned on or off
% below) to align the start trigger for LSL and the EEG.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the workspace and the screen and set the variables
sca;
close all;
clearvars;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Settings 
opts.photodiode = false;
opts.keyboardsetup = true; % Set up keyboard numbers
startdelaytime = 5;

%This next part will find the keyboard indexes of the desired kyes
KeyStart = 's';
KeyQuit = 'q';
KeyOpenEyes = 'j';
KeyClosedEyes = 'k';
KeyBlink = 'f';
mrkstart = 100;
mrkend = 200;
mrkOpenEyes = 149;
mrkClosedEyes = 151; 
mrkBlink = 12;

namelslstream = 'SamMarkers';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Call some default help settings for setting up Psychtoolbox
PsychDefaultSetup(2);
AssertOpenGL;
%Undo Warnings
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up keyboard
sprintf('Use the following keys:\n %s to start\n %s for eyes open \n %s for eyes closed \n %s for blinks \n %s to quit \n',KeyStart, KeyOpenEyes, KeyClosedEyes,KeyBlink, KeyQuit)
RestrictKeysForKbCheck([]);
if opts.keyboardsetup
    input('Begin keyboard setup');
    WaitSecs(0.4);
    sprintf('Press start key: %s \n',KeyStart)
    WaitSecs(0.1);
    [~, keyCode, ~] = KbWait();
    [~, KeyStartNum]=max(keyCode);
   
    sprintf('Press Open Eyes key: %s \n',KeyOpenEyes)
    WaitSecs(0.3);
    [~, keyCode, ~] = KbWait();
    [~, KeyOpenEyesNum]=max(keyCode);
    
    sprintf('Press Closed Eyes key: %s \n',KeyClosedEyes)
    WaitSecs(0.3);
    [~, keyCode, ~] = KbWait();
    [~, KeyClosedEyesNum]=max(keyCode);

    sprintf('Press Blink Eyes key: %s \n',KeyBlink)
    WaitSecs(0.3);
    [~, keyCode, ~] = KbWait();
    [~, KeyBlinkNum]=max(keyCode);
    
    
    sprintf('Press quit key: %s \n',KeyQuit)
    WaitSecs(0.3);
    [~, keyCode, ~] = KbWait();
    [~, KeyQuitNum]=max(keyCode);
    save('keyboardsetupforIntrinsicEyes.mat','KeyStartNum','KeyOpenEyesNum','KeyClosedEyesNum','KeyBlinkNum','KeyQuitNum');
else
    sprintf('Loading keyboardsetupforIntrinsicEyes.mat \n')
    load('keyboardsetupforIntrinsicEyes.mat');
end
   
% Restrict to just these keys for kbcheck/kbwait
RestrictKeysForKbCheck([KeyStartNum,KeyOpenEyesNum,KeyClosedEyesNum,KeyBlinkNum,KeyQuitNum]);

% If using photodiode, need to set up screen stuff
if opts.photodiode
    % Get the screen numbers. This gives us a number for each of the screens
    % attached to our computer.
    screens = Screen('Screens'); 

    % To draw we select the maximum of these numbers. So in a situation where we
    % have two screens attached to our monitor we will draw to the external
    % screen.
    screenNumber = max(screens);

    % Define black and white (white will be 1 and black 0). This is because
    % in general luminace values are defined between 0 and 1 with 255 steps in
    % between. All values in Psychtoolbox are defined between 0 and 
    white = [255 255 255];
    black = [0 0 0];

    % Do a simply calculation to calculate the luminance value for grey. This
    % will be half the luminace values for white
    grey = white / 2;
    
    % Put a square just in the bottom corner
    [wW, wH]=Screen('WindowSize', screenNumber);
    
    %wW = 1920;%for Nick's laptop
    %wH = 1080;
    rSize = 250;
    %myrect=[wW-rSize wH - rSize wW wH];
    myrect = [0 0 wW wH];
    myoval=[wW/2-rSize/2 wH/2-rSize/2 wW/2+rSize/2 wH/2 + rSize/2]; % center dRect on current mouseposition

    % Open an on screen window using PsychImaging and color it grey.
    [w, wRect] = Screen('OpenWindow', screenNumber, black);%, myrect);
    Screen('TextSize', w ,50);
    %define the slack in the system (will be helpful for more accurate event markers) 
    slack = Screen('GetFlipInterval', w)/2;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the lsl outlet so that it may send out markers
%as
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,namelslstream,'Markers',1,0,'cf_int32','myuniquesourceid23443');

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
    disp('Waiting for start... /n')
    
    if opts.photodiode
        Screen('FillRect',w, grey);
        clickedTime = Screen('Flip', w);
    end
    [~,~, keyCode] = KbCheck();
    % Wait for start button
    while keyCode(KeyStartNum) == 0
        [~, keyCode, ~] = KbWait();
        [~, KeyCurrentNum]=max(keyCode);
    end
    tic
   if opts.photodiode
       Screen('FillRect',w, black);
       clickedTime = Screen('Flip', w);
   end 

    
    %This will wait for startdelaytime seconds after the user clicks and then blink a white
    %square in the bottom right and send an event marker over lsl
    %The purpose of this is to enable syncing up the data when there is a
    %photodiode in place so that we can line up the event markers with their
    %proper timestamp in the data
    mrk = 100
    if opts.photodiode
        Screen('FillRect',w, white);
        toc
        
        rectTime = Screen('Flip', w,clickedTime + startdelaytime);
        outlet.push_sample(mrk);
        Screen('FillRect',w, white);
        rectTime = Screen('Flip', w);
        
        toc
    end
    outlet.push_sample(mrk);
    toc
    % Turn the screen back to black after 3 seconds
    if opts.photodiode
        Screen('FillRect',w, black);
        endtrial = Screen('Flip', w,rectTime + 3);
    end
    
    
    % Run loop until quit button is pressed and send out markers each time
    % one of the designated buttons are pressed
    % count the number of markers sent out in 'num' for troubleshooting
    num = 0;
    while keyCode(KeyQuitNum) == 0
        [~, keyCode, ~] = KbWait(); % May want to replace this w/ KbCheck, but will then need to change marker sending
        if keyCode(KeyOpenEyesNum) == 1
            mrk = mrkOpenEyes
        elseif keyCode(KeyClosedEyesNum) == 1
            mrk = mrkClosedEyes
        elseif keyCode(KeyBlinkNum) == 1
            mrk = mrkBlink
        end
        outlet.push_sample(mrk);
        num = num+1; % number of trials/markers
        toc
        mrk = 0; % Change marker back to zero for debugging
        pause(.3);     
    end
    
    mrk = mrkend; 
    outlet.push_sample(mrk);
    
    if opts.photodiode
        Screen('FillRect',w, grey);
        endtrial = Screen('Flip', w); % turn gray 
        
        %Wait 5 seconds and turn black
        pause(5)
        Screen('FillRect',w, black);
        clickedTime = Screen('Flip', w, endtrial+4-slack);
        
        % Wait another 10 seconds and turn white and send another marker
        % for the end
        Screen('FillRect',w, white);
        rectTime = Screen('Flip', w,clickedTime + 3);
        outlet.push_sample(mrk);
        
        Screen('FillRect',w, black);
        finishedTime = Screen('Flip', w, rectTime + 4);
    end
    toc
    sca;
    ShowCursor;
    Priority(0);
    RestrictKeysForKbCheck([]);
catch
    RestrictKeysForKbCheck([]);
    sca;
    ShowCursor;
    Priority(0);
    
    % Restore preferences
    %Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    %Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    psychrethrow(psychlasterror);
end

% Should shut down outlet here