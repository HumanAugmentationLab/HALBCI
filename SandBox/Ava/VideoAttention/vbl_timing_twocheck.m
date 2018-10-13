%% Dual Flashing Checkerboard & Movie
% PsychToolbox code for SSVEP attention experiment
% Display two square checkerboards flashing independently (with movies overlayed)

%% PsychToolbox Setup

AssertOpenGL;
PsychDefaultSetup(2);  
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 5);
% oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
addpath(genpath('/home/hal/Research/Matlab/BCILAB/dependencies/liblsl-Matlab'));
ListenChar(2);                      % Disable key presses from showing up in MATLAB script (change with CTRL+C)

%% Experiment Parameters
experimentName = 'experiment_log.txt';      % Log file name

% Duration
trialLength = 10;                   % Trial length (s)
numTrials = 3;                      % Number of trials per run

% Pauses
calibrationPause = 0;               % Pause before the whole experiment starts, for EEG settling (s)
startTrialPause = 1;                % Pause before trial (s)
fixationPause = 2;                  % Pause before fixation cross (s)
endTrialPause = 0;                  % Pause after survey, after trial ends (s)
endPause = 2;                       % Pause after run ends (s)

% Enable Parameters
lslBool = 1;                        % 1: Send markers over LSL
logBool = 1;                        % 1: Write trial data to text file
surveyBool = 1;                     % 0: Trials only | 1: Attention Survey
movieBool = 1;

% Background Display
WindowCoords = [];                  % Size of display: [x1, y1, x2, y2] or [] for full screen
%WindowCoords = [200 200 1000 600];       % Size of display: [x1, y1, x2, y2] or [] for full screen
backgroundColor = 0;                % 0: black
scalingCoeff = 0.325;               % Fix bug of speed dependening on display size

% Checkerboard Display
Hz = [6 15];                        % Frequencies to display [L R]
transparencyChecker = 25;           % Transparency (0: none, 250: opaque)
boardSize = 4;                      % Number of checkers per side 
color1 = 255;                       % Checker color 1 (255: black) %I am not sure if this is true
color2 = 0;                         % Checker color 2 (0: white)
filterMode = 0;                     % Color blending (0: nearest neighbour)
waitframes = 1;                     % Flip rate in reference to monitor refresh
buffer = 0.1;                       % Time buffer to prevent lag

checkerboardSize = 100;             % Checkerboard size relative to display screen (0 to 100, 100:full size)
videoSize = 1;                      % Size of the Video (0-1, 1: largest without overlap)

% Marker Options
mStartRun = 10;
mEndRun = 100;

mStartTrial = 20;                   % Increments with trial number
mEndTrial = 90;                     % Increments with trial number

mCueOnset = 30;                     % Fixation cross appears - one's place increments with trial
mCueOffset = 40;                    % Fixation cross removed - one's place increments with trial

mStimulusOnset = 50;                % Video appears - one's place increments with trial
mStimulusOffset = 60;               % Video removed - one's place increments with trial

mResponsePeriodOnset = 70;          % Task reporting period  - do not use if report during trial
mResponseOnset = 80;             
mEventOnset = 81;             
                                    
mConditionA = 1;                    % Attend LEFT & LOW frequency
mConditionB = 2;                    % Attend LEFT & HIGH frequency
mConditionC = 3;                    % Attend RIGHT & LOW frequency
mConditionD = 4;                    % Attend RIGHT & HIGH frequency

%% Movie Options
load eventTimes
VideoRoot = '/home/hal/Research/HALBCI/SandBox/Ava/VideoAttention/';

ball0.name = [ VideoRoot 'FocusVideos/bball0.mp4' ] ;
ball0.duration = (60*5);
ball0.delayMax = ball0.duration - trialLength;
ball0.eventTimes = ball0Times;                                              % Event times (s)

ball5.name = [ VideoRoot 'FocusVideos/bball5.mp4' ] ;
ball5.duration = (60*5);
ball5.delayMax = ball5.duration - trialLength;
ball5.eventTimes = ball5Times - ball0.duration;                              % Offset 5 mins (start 0)

ball10.name = [ VideoRoot 'FocusVideos/bball10.mp4' ] ;
ball10.duration = (60*5);
ball10.delayMax = ball10.duration - trialLength;
ball10.eventTimes = ball10Times - ball0.duration - ball5.duration;           % Offset 10 mins (start 0)

dog.name = [ VideoRoot 'DistractVideos/doglickingscreen.mp4' ] ;
dog.duration = 66;
dog.delayMax = dog.duration;

focusMovieList = { ball0 ball5 ball10 };

%% Randomize Targets
numVideos = length(focusMovieList);
halfSize = floor(numTrials/2);

if mod(numTrials, 2) == 0
    orderedSides = [zeros(1, halfSize) ones(1, halfSize)];
else
    extraSide = round(rand);
    orderedSides = [extraSide zeros(1, halfSize) ones(1, halfSize)];    
end
randomSides = orderedSides(randperm(length(orderedSides)));
targetSides = randomSides;

targetFreqs = zeros(1, numTrials);
for i = 1:numTrials
    targetFreqs(i) = Hz(randomSides(i) + 1);
end
   
targetVideos = cell(1, numTrials);
for i = 1:numTrials
    targetVideos{i} = focusMovieList{round(rand*(numVideos-1)+1)};
end

%% Setup output: LSL and log
if lslBool == 1
    disp('Loading library...');
    lib = lsl_loadlib();

    disp('Creating new marker stream info')
    info = lsl_streaminfo(lib, 'PsychMarkers', 'Markers', 1, 0, 'cf_int32', 'mysourceid');

    disp('Opening an outlet...')
    outlet = lsl_outlet(info);
end

if logBool
    fileID = fopen(experimentName,'w'); % Open log file
end

%% Generate Checkerboard and Cross Display

% Populate matrices to represent checkerboard 
checkerboardL = ones([boardSize boardSize 2]);
checkerboardR = checkerboardL;

% LAYER 1: Set checkerboard colors with opposite polarity
for j = 1:boardSize
     for k = 1:boardSize
         if mod(j+k,2) == 1
             checkerboardL(j,k,:) = color1;
             checkerboardR(j,k,:) = color2;
         else
             checkerboardL(j,k,:) = color2; 
             checkerboardR(j,k,:) = color1;
         end
     end
end

% LAYER 2: Set transparency
checkerboardL(:,:,2) = zeros(boardSize, boardSize) + transparencyChecker;  
checkerboardR(:,:,2) = zeros(boardSize, boardSize) + transparencyChecker; 

% FIXATION CROSS
[crossImage, ~, alpha] = imread('fixation-cross-white.png');
crossImage(:,:,4) = alpha;

%% Display
try
    % Set up 
    
    % Find screen
    screenid = max(Screen('Screens'));

    % Open window on specified screen | return [window ID, window size]
    [window, windowRect] = Screen('OpenWindow', screenid, backgroundColor, WindowCoords);
    
    % Find center of display window
    [xCenter, yCenter] = RectCenter(windowRect);
    
    % Return width and height of display window
    [wW,wH] = Screen('WindowSize', window);
    
    % Set portion of window for displaying checkerboards (with margins)
    % Space checkerboards evenly for display
    dispRect = [0 0 videoSize*wW/3 videoSize*wH/2];
    dispRectL = CenterRectOnPointd(dispRect, xCenter*.5, yCenter);
    dispRectR = CenterRectOnPointd(dispRect, xCenter*1.5, yCenter);
    dstRect = [dispRectL; dispRectR];

    % Make the checkerboard into a texure
    checkerTexture(1) = Screen('MakeTexture', window, checkerboardL);
    checkerTexture(2) = Screen('MakeTexture', window, checkerboardR);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Black Screen
    blackCheckerboard = checkerboardL;
    blackCheckerboard(:,:,1) = 0;
    blackCheckerboard(:,:,2) = 0;
    blackTexture = Screen('MakeTexture', window, blackCheckerboard);
    
    crossTexture = Screen('MakeTexture', window, crossImage);
    
    % Flip Timing
    % Query refresh rate of monitor (s)
    ifi = Screen('GetFlipInterval', window);
    
    % Set initial checkerboard polarities
    textureCueL = [1 2];
    textureCueR = [1 2];

    % Initialize frame counters
    frameCounterL = 0;
    frameCounterR = 0;  
    
    % Sync to vertical retrace
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);
    
    % Return time of initial flip
    vbl = Screen('Flip', window);

    if lslBool
        outlet.push_sample(mStartRun)
        disp(mStartRun)
    end

    % Wait on black screen
    Screen('DrawTexture', window, blackTexture, [], dstRect(1,:));
    Screen('DrawTexture', window, blackTexture, [], dstRect(2,:));
    Screen('Flip', window);

    pause(calibrationPause)

    %% Trials
    for n = 1:numTrials
        disp(strcat('Trial number: ',num2str(n)))
        
        %% Randomized selection (target side, video, frequency, start)       

        % LEFT/RIGHT display condition:
        currentSide = targetSides(n);

        % Associate target movie with target side
        if currentSide == 0
            movienameL = targetVideos{n}.name;
            moviedelayL = rand * targetVideos{n}.delayMax;
            currentdelay = moviedelayL;

            movienameR = dog.name;
            moviedelayR = rand * dog.delayMax;
        else
            movienameR = targetVideos{n}.name;
            moviedelayR = rand * targetVideos{n}.delayMax;
            currentdelay = moviedelayR;

            movienameL = dog.name;
            moviedelayL = rand * dog.delayMax;
        end

        % HIGH/LOW freq condition:
        if currentSide == 0
            leftFreq = targetFreqs(n);
            rightFreq = Hz(Hz ~= targetFreqs(n));

            if lslBool
                if targetFreqs(n) == min(targetFreqs)
                    % Condition A: LEFT LOW
                    outlet.push_sample(mConditionA)
                    disp(mConditionA)
                else
                    % Condition B: LEFT HIGH
                    outlet.push_sample(mConditionB)
                    disp(mConditionB)
                end

            end
        else
            rightFreq = targetFreqs(n);
            leftFreq = Hz(Hz ~= targetFreqs(n));

            if lslBool
                if targetFreqs(n) == min(targetFreqs)
                    % Condition C: RIGHT LOW
                    outlet.push_sample(mConditionC)
                    disp(mConditionC)
                else
                    % Condition D: RIGHT HIGH
                    outlet.push_sample(mConditionD)
                    disp(mConditionD)
                end
            end
        end
        
        % Event timing adjustment
        % Find first event after video start time ...
        choppedEvents = targetVideos{n}.eventTimes - currentdelay;
        % Round negative to zero for logical indexing
        choppedEvents(choppedEvents < 0) = 0;
        % Return index of first non-zero index (event time after start time)
        startIndex = find(choppedEvents, 1);
        if isempty(startIndex)      % if no events in trial duration, place counter at end of array
            eventCounter = length(targetVideos{n}.eventTimes);
        else
            eventCounter = startIndex;
        end
        
        %% Setup log file
        eventlogTimes = [];
        responseTimes = [];
        
        if logBool
            fprintf(fileID,'Trial Number: %d\n', n);
            fprintf(fileID,'Target Movie: %s\n', targetVideos{n}.name);
            fprintf(fileID,'Start time: %.2f\n', currentdelay);
        end
        
        %% Buffer movie underneath blank initial display
        % Try to open multimedia file
        if movieBool
            % Preload one second by default
            movieL = Screen('OpenMovie', window, movienameL, 0);
            movieR = Screen('OpenMovie', window, movienameR, 0);

            % Set start time from file ( name, delay from start, 0: in seconds | 1: in frames)
            Screen('SetMovieTimeIndex', movieL, moviedelayL, 0);
            Screen('SetMovieTimeIndex', movieR, moviedelayR, 0); 
        end

        if lslBool
            outlet.push_sample(mStartTrial + n)
            disp(mStartTrial + n)
        end

        Screen('DrawTexture', window, blackTexture, [], dstRect(1,:));
        Screen('DrawTexture', window, blackTexture, [], dstRect(2,:));

        Screen('Flip', window);
        pause(startTrialPause)  
        
        %% Draw fixation cross
        Screen('DrawTexture', window, crossTexture, [], dstRect(currentSide + 1,:));
        Screen('Flip', window);

        if lslBool
            outlet.push_sample(mCueOnset + n)
            disp(mCueOnset + n)
        end

        pause(fixationPause)
        
        %% Start movie, get first frame
        start = tic;
        timeElapsedL = toc(start);
        timeElapsedR = toc(start);

        if movieBool
            % Queue playback at normal speed forward
            Screen('PlayMovie', movieL, 1, 1);
            Screen('PlayMovie', movieR, 1, 1);

            texL = Screen('GetMovieImage', window, movieL, 0, 0);     
            texR = Screen('GetMovieImage', window, movieR, 0, 0);

            ltexL = texL;
            ltexR = texR;
        end

        if lslBool
            outlet.push_sample(mStimulusOnset + n)
            disp(mStimulusOnset + n)
        end
        
        %% PLAY
        while toc(start) < trialLength
            %% Draw movie frame by frame
            if movieBool
                % Try to get next movie image
                 texL = Screen('GetMovieImage', window, movieL, 0, 0);     
                 texR = Screen('GetMovieImage', window, movieR, 0, 0);

                 % If found, display next frame, else display last found
                 if texL > 0
                     % Try to close last frame for memory (if not already closed)
                      if ltexL > 0
                        Screen('Close', ltexL);
                      end
                      Screen('DrawTexture', window, texL, [], dstRect(1,:));
                      ltexL = texL;                          
                 else 
                      Screen('DrawTexture', window, ltexL, [], dstRect(1,:));
                 end

                if texR > 0
                    if ltexR > 0
                        Screen('Close', ltexR);
                    end
                    Screen('DrawTexture', window, texR, [], dstRect(2,:));
                    ltexR = texR;
                else 
                    Screen('DrawTexture', window, ltexR, [], dstRect(2,:));
                end
            end
            %% Draw checker texture at target frequency

            % Increment frame counter per flip
            frameCounterL = frameCounterL + waitframes;
            frameCounterR = frameCounterR + waitframes;

            % Draw texture on screen
            Screen('DrawTexture', window, checkerTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
            Screen('DrawTexture', window, checkerTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            Screen('DrawTexture', window, crossTexture, [], dstRect(currentSide + 1,:));

            % Flip to update display at set time (at waitframes multiple of screen refresh rate)
            vbl = Screen('Flip', window, vbl + (waitframes-buffer) * ifi);

            % For each checkerboard, reverse texture cue/polarity at interval of frequency
            if frameCounterL >= scalingCoeff/(ifi*leftFreq)
                 % Manually check duration of each flash
                 % leftTime = toc(start) - timeElapsedL;
                 % disp({'leftTime', leftTime})

                 % Flip texture
                 textureCueL = fliplr(textureCueL);

                 % Reset counter and time
                 frameCounterL = 0;
                 timeElapsedL = toc(start);
            end

            if frameCounterR >= scalingCoeff/(ifi*rightFreq)
                rightTime = toc(start) - timeElapsedR;
                %disp({'rightTime', rightTime})

                textureCueR = fliplr(textureCueR);

                frameCounterR = 0;
                timeElapsedR = toc(start);
            end
            %% Event listening

            % USER-REPORTED EVENTS
            [ keyIsDown, seconds, keyCode ] = KbCheck;
            if keyIsDown 
                responseTimes = [responseTimes videoTime];

                if lslBool
                    outlet.push_sample(mResponseOnset);                 % Send response onset marker
                    disp(mResponseOnset);
                end

                FlushEvents('keyDown');                                 % Flush to reduce number of reported key presses
            end

            videoTime = currentdelay + toc(start);

            % SYSTEM EVENTS
            % If experiment time matches with event times, send event marker
            if ( eventCounter <= length(targetVideos{n}.eventTimes) && ...
                videoTime > targetVideos{n}.eventTimes(eventCounter) - 0.5 && ...
                    videoTime < targetVideos{n}.eventTimes(eventCounter) + 0.5)

                eventlogTimes = [eventlogTimes videoTime];

                if lslBool
                    outlet.push_sample(mEventOnset);                    % Send event onset marker
                    disp(mEventOnset)
                end

                eventCounter = eventCounter + 1;
            end
        end
            
        %% End of trial
        
            %% Stop movie and end display
            if movieBool
                % Stop movie
                Screen('PlayMovie', movieL, 0);
                Screen('PlayMovie', movieR, 0);
                
                % Close movie
                Screen('CloseMovie', movieL);
                Screen('CloseMovie', movieR);
            end
            
            % Flip to blank display
            Screen('DrawTexture', window, blackTexture, [], dstRect(1,:));
            Screen('DrawTexture', window, blackTexture, [], dstRect(2,:));
            Screen('Flip', window);

            %% Send end of trial markers
            if lslBool
                outlet.push_sample(mCueOffset + n)
                disp(mCueOffset + n)

                outlet.push_sample(mStimulusOffset + n)
                disp(mStimulusOffset + n)

                outlet.push_sample(mEndTrial + n)
                disp(mEndTrial + n)
            end
            
            %% Log all response and event times
            if logBool
                fprintf(fileID,'Response Times: ');
                for i = 1:length(responseTimes)
                    fprintf(fileID,'%.2f ', responseTimes(i));
                end
                fprintf(fileID, '\n');

                fprintf(fileID,'Event Times: ');
                for i = 1:length(eventlogTimes)
                    fprintf(fileID,'%.2f ', eventlogTimes(i));
                end
                fprintf(fileID, '\n');
            end
                        
            %% Survey
            if surveyBool
                textX = wW/6;
                textY = wH/5;
                space = 40;
                Screen('TextSize', window, 24);
                Screen('DrawText', window, 'Rate your focus during this past session by keying in the number of the most accurate statement:', textX, textY, [255, 255, 255]);
                Screen('DrawText', window, '1: I did not pay attention in this session', textX, textY+space*2, [255, 255, 255]);
                Screen('DrawText', window, '2: I was focused, lost attention, and then caught myself multiple times', textX, textY+space*3, [255, 255, 255]);
                Screen('DrawText', window, '3: I did well at the beginning, but my attention faded near the end', textX, textY+space*4, [255, 255, 255]);
                Screen('DrawText', window, '4: I was able to maintain my attention the entire time', textX, textY+space*5, [255, 255, 255]);

                Screen('DrawText', window, 'Press the right arrow key to continue.', textX, textY+space*7, [255, 255, 255]);
                Screen('Flip', window);

                endKey = KbName('RightArrow'); % Pressing right arrow leaves survey
                
                while KbCheck; end % Wait until all keys are released.

                while 1 % Wait until answer submitted
                    [keyIsDown, seconds, keyCode] = KbCheck;
                    keyCode = find(keyCode, 1);

                    % If key is pressed, display its code number or name.
                    if keyIsDown
                        if keyCode == endKey
                            fprintf(fileID, 'Survey Response: %s \n', KbName(lastKey)); 
                            break;
                        end
                        
                        lastKey = keyCode;
                        KbReleaseWait;
                    end
                end
                
                fprintf(fileID, '\n');
            end
            

        %% End of experiment
            if n ~= numTrials                           % Allow for pause between trials
                pause(endTrialPause)
            else
                if lslBool
                    outlet.push_sample(mEndRun)
                    disp(mEndRun)
                end

                if logBool
                    fclose(fileID);                     % Close log file in last trial
                end
            end
    end
catch SE
    sca; 
    psychrethrow(psychlasterror);
end

% Close screen and enable MATLAB key press
sca;
ListenChar(0);