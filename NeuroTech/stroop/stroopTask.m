  %% Sample Stimulus Script
% Authored By Yoonyoung Cho @ 2017
% Contact yoonyoung.cho@students.olin.edu

% Description :
% This script performs a variant of the Stroop task,
% where a combination of two stimuli from [audio|text|color] are used.

% Resources :
% TTS script available from
% https://www.mathworks.com/matlabcentral/fileexchange/18091-text-to-speech

% Instructions :
% Run, and click on the figure to begin.
% When the stimuli are consistent, press space.
% Otherwise, click on the figure.


%% Initialize
sca;
close all;
clearvars;
PsychDefaultSetup(2);
AssertOpenGL;
%Undo Warnings
%
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
%}
Fs = 21000;

[P,Q] = rat(44.1e3/Fs);

%% Get spacebar
RestrictKeysForKbCheck([]);
sprintf('Press Match key:')
    WaitSecs(0.1);
    [~, keyCode, ~] = KbWait();
    [~, matchNum]=max(keyCode);
    
sprintf('Press UnMatch key:')
WaitSecs(0.3);
[~, keyCode, ~] = KbWait();
[~, unmatchNum]=max(keyCode);

  
%% Define Parameters He  re
n_trials = 5;
p_match = 0.5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Lsl
%this part loads the lsl outlet so that it may send out markers
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'PsychMarkers','Markers',1,0,'cf_int32','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);  

%% Initialization
try
   


    % initialize random number generator
    % replace 0 with something else for a different result
    rng(0, 'twister');

    % stimulus type
    % 0 = TEXT | COLOR
    % 1 = TEXT | AUDIO
    % 2 = COLOR | AUDIO
    s_idx = randi([1, 3], 1, n_trials);

    % color type

    colors_t={'RED', 'ORANGE', 'YELLOW', 'GREEN', 'BLUE', 'PURPLE'};
    % color values
    colors_v = [
        255 0 0; 
        255 128 0;
        255 255 0;
        0 255 0;
        0 0 255;
        128 0 255;
        ];
    colors_v = colors_v;

    InitializePsychSound;  
    % collect sounds, .wav
    loadhandle = 1
    colors_s = {};
    for i = 1:length(colors_t)
        soundFile = [char(lower(colors_t(i))) '.wav']
        [handle,wavedata] = loadSound(soundFile,loadhandle);
        if loadhandle
            pahandle = handle;  
        end  
        wavedata = resample(wavedata.',P,Q).';
        colors_s{i} = wavedata;
        loadhandle = 0;
        %assume default 16kHz sampling rate
    end
%     colors_s = {};
%     for i = 1:length(colors_t)
%         s = tts(char(colors_t(i)));
%         colors_s{i} = audioplayer(s, 16000);
%         %assume default 16kHz sampling rate
%     end

    
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
    if isunix
        white = [255 255 255]
        black = [0 0 0]
    end

    % Do a simply calculation to calculate the luminance value for grey. This
    % will be half the luminace values for white
    grey = white ./ 2;

   
    % Open an on screen window using PsychImaging and color it grey.
    [w, wRect] = Screen('OpenWindow', 0, 0)
    Screen('TextSize', w ,50);
    rSize = 250
    [wW, wH]=WindowSize(w);
    myrect=[wW-rSize wH -   rSize wW wH];
    myoval=[wW/2-rSize/2 wH/2-rSize/2 wW/2+rSize/2 wH/2 + rSize/2]; % center dRect on current mouseposition
    fixCrossDimPix = 40;
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    lineWidthPix = 4;
    [xCenter, yCenter] = RectCenter(wRect);



    %define the slack in the system (will be helpful for more accurate event markers)
    slack = Screen('GetFlipInterval', w)/2  
    %% Set Matching E  vents
    % the number of non-contradictory events
    % are defined according to p_match.

    n_match = floor(p_match * n_trials);
    m_mask = zeros(n_trials, 1);
    m_idx = randperm(n_trials, n_match);
    m_mask(m_idx) = 1;
    c_idx = zeros(2, n_trials);

    for i = 1:n_trials
        if m_mask(i) == 1
            c_idx(:,i) = randi([1,6]);
        else
            c_idx(:,i) = randperm(6,2);
        end
    end
    
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse to prep photodiode stimulation', wW/2-100, wH/2, black);
    clickedTime = Screen('Flip', w);
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

    %This will wait for 30 seconds after the user clicks and then blink a white
    %square in the bottom right and send an event marker over lsl
    %The purpose of this is to enable syncing up the data when there is a
    %photodiode in place so that we can line up the event markers with their
    %proper timestamp in the data
    mrk = 100
    Screen('FillRect',w, white,myrect);
    disp('Wait for photodiode')
    disp(clickedTime) 
    pause(20)
    rectTime = Screen('Flip', w,clickedTime + 30);
    outlet.push_sample(mrk);
    Screen('FillRect',w, black);
    endtrial = Screen('Flip', w,rectTime + 3);

    
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
    %% Run 
    %p = gcp(); % get the current parallel pool
    % response, click (unmatch) | space (match)
    resp = zeros(n_trials, 1);

    for i=1:n_trials
        ca_i = c_idx(1, i);
        cb_i = c_idx(2, i);

        c_a = char(colors_t(ca_i));
        c_b = char(colors_t(cb_i));

        fprintf('Type : %d | Match : %d\n', s_idx(i), m_mask(i));
        Screen('FillRect',w, grey);
        Screen('DrawLines', w, allCoords,...
            lineWidthPix, black, [xCenter yCenter], 0  );
        mrk = 109;
        fixation = Screen('Flip', w);
        outlet.push_sample(mrk);
        Screen('FillRect',w, grey);
        mrk = 100 + s_idx(i) * 10 + m_mask(i); 
          
        switch s_idx(i)
            case 1 %T/C
                Screen('DrawText', w, c_a, wW/2-100, wH/2,  colors_v(cb_i, :));
                startTrial = Screen('Flip', w,fixation + 0.5);
                outlet.push_sample(mrk);
                
            case 2 %T/A
                wavedata = colors_s{cb_i};
                PsychPortAudio('FillBuffer', pahandle, wavedata);
                Screen('DrawText', w, c_a, wW/2-100, wH/2,  black);
                startTrial = Screen('Flip', w,fixation + 0.5);
                outlet.push_sample(mrk);
                PsychPortAudio('Start', pahandle);
            case 3 %C/A 
                Screen('FillOval', w, colors_v(ca_i, :),myoval);
                wavedata = colors_s{cb_i}; 
                PsychPortAudio('FillBuffer', pahandle, wavedata);
                startTrial = Screen('Flip', w,fixation + 0.5);
                outlet.push_sample(mrk);
                PsychPortAudio('Start', pahandle);

        end
        Screen('FillRect',w, grey);
        mrk = 200 + s_idx(i) * 10 + m_mask(i);  
        [~,~, keyCode] = KbCheck();
        % Wait for start button
        while keyCode(matchNum) == 0 && keyCode(unmatchNum) == 0
            [~, keyCode, ~] = KbWait();  
            [~, KeyCurrentNum]=max(keyCode);
        end
        outlet.push_sample(mrk);
        endTrial = Screen('Flip', w);
        % some logic for sending markers
        % send_marker()
        resp(i) = endTrial - startTrial;
        pause(1)
    end
catch
    sca;
    ShowCursor;
    Priority(0);
    
    
    % Restore preferences
    %Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    %Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    psychrethrow(psychlasterror);
    PsychPortAudio('Close', pahandle);
end
PsychPortAudio('Close', pahandle);  
KbStrokeWait;
sca;