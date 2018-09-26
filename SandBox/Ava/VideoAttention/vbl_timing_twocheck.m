%% Dual Flashing Checkerboard & Movie
% PsychToolbox code for SSVEP attention experiment
% Display two square checkerboards flashing independently (with movies overlayed)
% CONTROL: 1 keyboard press to pause experiment | 2 to stop experiment and close window

%% PsychToolbox Setup

AssertOpenGL;
PsychDefaultSetup(2);  
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
addpath(genpath('/home/hal/Documents/BCILAB/dependencies/liblsl-Matlab'));
ListenChar(2); % Disable key presses from showing up in MATLAB script (change with CTRL+C)
%% Experiment Parameters
% Duration
trialLength = 15;                    % Trial length (s) -- includes pauses defined below!
numTrials = 2;                      % Number of trials per run

% Pauses
calibrationPause = 0;               % Pause before the whole experiment starts, for EEG settling (s)
runPause = 1;                       % Pause before run (s)
startTrialPause = 1;                % Pause before trial (s)
fixationPause = 1;                  % Pause before fixation cross (s)
videoPause = 1;                     % Pause before video starts (s)
endTrialPause = 1;                  % Pause after trial ends (s)
endPause = 2;                       % Pause after run ends (s)

% Enable Parameters
movieBool = 0;                      % 0: Checkerboards only | 1: Overlay movies  -- FIX
lslBool = 1;                        % 0: Trials only | 1: Send markers over LSL
surveyBool = 1;                     % 0: Trials only | 1: Attention Survey

% Background Display
%WindowCoords = [];                 % Size of display: [x1, y1, x2, y2] or [] for full screen
WindowCoords = [200 200 1000 600];       % Size of display: [x1, y1, x2, y2] or [] for full screen
backgroundColor = 0;                % 0: black
scalingCoeff = 0.325;               % Fix bug of speed dependening on display size

% Checkerboard Display
Hz = [6 1];                        % Frequencies to display [L R]
transparencyChecker = 50;           % Transparency (0: none, 250: opaque)
boardSize = 4;                     % Number of checkers per side 
color1 = 255;                       % Checker color 1 (255: black) %I am not sure if this is true
color2 = 0;                         % Checker color 2 (0: white)
filterMode = 0;                     % Color blending (0: nearest neighbour)
waitframes = 1;                     % Flip rate in reference to monitor refresh
buffer = 0.1;                       % Time buffer to prevent lag

checkerboardSize = 100;            % Checkerboard size relative to display screen (0 to 100, 100:full size)
videoSize = 1;                     % Size of the Video (0-1, 1: largest without overlap)

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

VideoRoot = '/home/hal/Documents/HALBCI/SandBox/Ava/VideoAttention/Videos/';
train.name = [ VideoRoot 'v1.mp4' ];
train.duration = 96;                                % Seconds
train.delayMax = train.duration - trialLength;
train.eventTimes = trainTimes;

discs.name = [ VideoRoot 'DualDiscs.mov' ] ;
discs.duration = 2;
discs.delayMax = 0;

ball1.name = [ VideoRoot 'bball1.mov' ] ;
ball1.duration = (360*1) + (60*16) + 28;
ball1.delayMax = ball1.duration - trialLength;
bball1.fps = 30;                                            % Check multimedia properties for each video
ball1.eventTimes = ball1Times;                              % Event times (s)
                                                            % Make sure eventTimes mat file loaded and naming consistent
ball1.eventFrames = floor(ball1.eventTimes/bball1.fps);     % Event times (frames)

dog.name = [ VideoRoot 'doglickingscreen.mp4' ] ;
dog.duration = 66;
dog.delayMax = dog.duration - trialLength;

% focusMovieList = { train , ball1 };
focusMovieList = { ball1 };

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

%% Load LSL
if lslBool == 1
    disp('Loading library...');
    lib = lsl_loadlib();

    disp('Creating new marker stream info')
    info = lsl_streaminfo(lib, 'PsychMarkers', 'Markers', 1, 0, 'cf_int32', 'mysourceid');

    disp('Opening an outlet...')
    outlet = lsl_outlet(info);
end

%% Generate Initial Checkerboards
new_boardSize = round(boardSize/checkerboardSize*100);
removeCH = (new_boardSize-boardSize)/2;
actual_checkerboardSize = boardSize/new_boardSize*100; % Actual checkerboard size
boardSize = new_boardSize;

% Populate matrices to represent checkerboard display
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

for i = 1:removeCH
    checkerboardL(i,:,2) = 0;
    checkerboardL(:,i,2) = 0;
    checkerboardL(boardSize-i+1,:,2) = 0;
    checkerboardL(:,boardSize-i+1,2) = 0; 
    
    checkerboardR(i,:,2) = 0;
    checkerboardR(:,i,2) = 0;
    checkerboardR(boardSize-i+1,:,2) = 0;
    checkerboardR(:,boardSize-i+1,2) = 0;
end
%% Cross
[crossImage, ~, alpha] = imread('cross_sm.png');
crossImage(:,:,4) = alpha;
crossImage = imresize(crossImage, 0.5);
cross_window = 1;
%% Display
try
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

    pause(runPause)

%     % Start timing for trial length and to manually check frequencies
%     start = tic;
%     timeElapsedL = toc(start);
%     timeElapsedR = toc(start);

%% Trial level
    for n = 1:(numTrials*2)

        if mod(n, 2) == 1
            %% Randomized selection (target side, video, frequency, start)       
            m = (n+1)/2;

            % LEFT/RIGHT display condition:
            currentSide = targetSides(m);
            
            % Associate target movie with target side
            if currentSide == 0
                movienameL = targetVideos{m}.name;
                moviedelayL = rand * targetVideos{m}.delayMax;
                currentdelay = moviedelayL;
                
                movienameR = dog.name;   % Change distracting video
                moviedelayR = rand * dog.delayMax;
            else
                movienameR = targetVideos{m}.name;
                moviedelayR = rand * targetVideos{m}.delayMax;
                currentdelay = moviedelayR;
                
                movienameL = dog.name;   % Change distracting video
                moviedelayL = rand * dog.delayMax;
            end
            
            disp("Video starting at...");
            disp(currentdelay);
            
            % Event timing adjustment
            % Find first event after video start time ...
            choppedEvents = targetVideos{m}.eventTimes - currentdelay;
            % Round negative to zero for logical indexing
            choppedEvents(choppedEvents < 0) = 0;
            % Return index of first non-zero index (event time after start time)
            startIndex = find(choppedEvents, 1);
            eventCounter = startIndex;
            
            % HIGH/LOW freq condition:
            if currentSide == 0
                leftFreq = targetFreqs(m);
                rightFreq = Hz(Hz ~= targetFreqs(m));

                if lslBool
                    if targetFreqs(m) == min(targetFreqs)
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
                rightFreq = targetFreqs(m);
                leftFreq = Hz(Hz ~= targetFreqs(m));

                if lslBool
                    if targetFreqs(m) == min(targetFreqs)
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

            %% Buffer movie and initial display
            % Try to open multimedia file
            movieL = Screen('OpenMovie', window, movienameL, 0, -1);
            movieR = Screen('OpenMovie', window, movienameR, 0, -1);
            
            % Set start time from file ( name, delay from start, 0: in seconds | 1: in frames)
            Screen('SetMovieTimeIndex', movieL, moviedelayL, 0);
            Screen('SetMovieTimeIndex', movieR, moviedelayR, 0); 
    
             % Queue playback at normal speed forward
            Screen('PlayMovie', movieL, 1, 1);
            Screen('PlayMovie', movieR, 1, 1);

            texL = Screen('GetMovieImage', window, movieL,1,0); 
            ltexL = texL;

            texR = Screen('GetMovieImage', window, movieR,1,0); 
            ltexR = texR;

            if lslBool
                outlet.push_sample(mStartTrial + m)
                disp(mStartTrial + m)
            end

            Screen('DrawTexture', window, blackTexture, [], dstRect(1,:));
            Screen('DrawTexture', window, blackTexture, [], dstRect(2,:));

            Screen('Flip', window);
            pause(startTrialPause)  
            
            %% Fixation display
            % Draw texture on screen
            Screen('DrawTexture', window, crossTexture, [], dstRect(currentSide + 1,:));
            Screen('Flip', window);

            if lslBool
                outlet.push_sample(mCueOnset + m)
                disp(mCueOnset + m)
            end

            pause(fixationPause)
            %% Initial movie display
            start = tic;
            timeElapsedL = toc(start);
            timeElapsedR = toc(start);

            texL = Screen('GetMovieImage', window, movieL, 0, 0);     
            texR = Screen('GetMovieImage', window, movieR, 0, 0);

            Screen('DrawTexture', window, texL, [], dstRect(1,:) );
            Screen('DrawTexture', window, texR, [], dstRect(2,:) );

            % Uncomment to display first frame of video before playing
%               Screen('Flip', window);
%               pause(videoPause)

            if lslBool
                outlet.push_sample(mStimulusOnset + m)
                disp(mStimulusOnset + m)
            end

            %% Play movie
            while toc(start) < trialLength
                % Display movies if included
                texL = Screen('GetMovieImage', window, movieL, 0, 0);     
                texR = Screen('GetMovieImage', window, movieR, 0, 0);    

                % If found, display next frame, else display last found
                if texL > 0
                     Screen('DrawTexture', window, texL, [], dstRect(1,:) );
                     ltexL = texL;
                else 
                     Screen('DrawTexture', window, ltexL, [], dstRect(1,:) );
                end

                if texR > 0
                    Screen('DrawTexture', window, texR, [], dstRect(2,:) );
                    ltexR = texR;
                else 
                    Screen('DrawTexture', window, ltexR, [], dstRect(2,:) );
                end

                % Increment frame counter per flip
                frameCounterL = frameCounterL + waitframes;
                frameCounterR = frameCounterR + waitframes;

                % Draw texture on screen
                Screen('DrawTexture', window, checkerTexture(textureCueL(1)), [], dstRect(1,:), 0, filterMode);
                Screen('DrawTexture', window, checkerTexture(textureCueR(1)), [], dstRect(2,:), 0, filterMode);
                Screen('DrawTexture', window, crossTexture, [], dstRect(currentSide + 1,:));

                % Flip to update display at set time (at waitframes multiple of screen refresh rate)
                vbl = Screen('Flip', window, vbl + (waitframes-buffer) * ifi);

                % For each checkerboard, reverse texture cue/polarity at interval of frequency
                if frameCounterL >= scalingCoeff/(ifi*leftFreq)
                     % Manually check duration of each flash
                     leftTime = toc(start) - timeElapsedL;
                     %disp({'leftTime', leftTime})

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

                % ADD -reading events from file, waiting for key press, and sending markers!
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                
                
                if keyIsDown && lslBool
                    outlet.push_sample(mResponseOnset);
                    disp(mResponseOnset);
                    FlushEvents('keyDown');
                    
                    disp(videoTime)
                    % KbReleaseWait;
                end

                videoTime = currentdelay + timeElapsedL;

                % Event matrix does not match video
%                  disp("Next event")
%                  disp(targetVideos{m}.eventTimes(eventCounter));
%                  disp("Time")
%                  disp(videoTime)
                
                % If time matches with event times, send event marker
                if ( eventCounter <= length(targetVideos{m}.eventTimes) && ...
                    videoTime > targetVideos{m}.eventTimes(eventCounter) - 0.05 && ...
                        videoTime < targetVideos{m}.eventTimes(eventCounter) + 0.05)
                    if lslBool
                        disp("Event at")
                        disp(targetVideos{m}.eventTimes(eventCounter))
                        
                        outlet.push_sample(mEventOnset);
                        disp(mEventOnset)
                    end
                    eventCounter = eventCounter + 1;
                end

            end
            
            start = tic;
        elseif  mod(n, 2) == 0
            %% Close movie
%           disp('Closing movie...')
            Screen('CloseMovie', movieL);
            Screen('CloseMovie', movieR);

            Screen('DrawTexture', window, blackTexture, [], dstRect(1,:));
            Screen('DrawTexture', window, blackTexture, [], dstRect(2,:));
            Screen('Flip', window);

            if lslBool
                outlet.push_sample(mCueOffset + m)
                disp(mCueOffset + m)

                outlet.push_sample(mStimulusOffset + m)
                disp(mStimulusOffset + m)

                outlet.push_sample(mEndTrial + m)
                disp(mEndTrial + m)
            end

            if surveyBool
                textX = wW/6;
                textY = wH/5;
                space = 20;
                Screen('TextSize', window, 12);
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
                        % Note that we use find(keyCode) because keyCode is an array.
                        % fprintf('You pressed key %i which is %s\n', keyCode, KbName(keyCode));
                        % fprintf('You pressed key %s\n', KbName(keyCode));

                        if keyCode == endKey
                            break;
                        end

                        % If the user holds down a key, KbCheck will report multiple events.
                        % To condense multiple 'keyDown' events into a single event, we wait until all
                        % keys have been released.
                        KbReleaseWait;
                    end
                end
            end

            if n ~= numTrials*2
%                     disp('Pausing...')
%                     while toc(start) < endTrialPause
%                     end
                pause(endTrialPause)
                start = tic;
            end
        else
            disp("error")
        end
    end

    pause(endPause)
    
    if lslBool
        outlet.push_sample(mEndRun)
        disp(mEndRun)
    end
catch SE
    sca; 
    psychrethrow(psychlasterror);
end

% Closes screen with keyboard press
sca;
ListenChar(0);
