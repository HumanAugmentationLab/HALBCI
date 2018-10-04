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
addpath(genpath('/home/hal/Research/Matlab/BCILAB/dependencies/liblsl-Matlab'));
ListenChar(2);                      % Disable key presses from showing up in MATLAB script (change with CTRL+C)

%% Experiment Parameters
experimentName = 'experiment_log.txt';      % Log file name

% Duration
trialLength = 10;                   % Trial length (s)
numTrials = 2;                      % Number of trials per run

% Pauses
calibrationPause = 0;               % Pause before the whole experiment starts, for EEG settling (s)
runPause = 0;                       % Pause before run (s)
startTrialPause = 1;                % Pause before trial (s)
fixationPause = 5;                  % Pause before fixation cross (s)
videoPause = 1;                     % Pause before video starts (s) -- NOT USED
endTrialPause = 1;                  % Pause after trial ends (s)
endPause = 2;                       % Pause after run ends (s)

% Enable Parameters
lslBool = 1;                        % 1: Send markers over LSL
logBool = 1;                        % 1: Write trial data to text file
surveyBool = 1;                     % 0: Trials only | 1: Attention Survey

% Background Display
WindowCoords = [];                  % Size of display: [x1, y1, x2, y2] or [] for full screen
%WindowCoords = [200 200 1000 600];       % Size of display: [x1, y1, x2, y2] or [] for full screen
backgroundColor = 0;                % 0: black
scalingCoeff = 0.325;               % Fix bug of speed dependening on display size

% Checkerboard Display
Hz = [6 15];                        % Frequencies to display [L R]
transparencyChecker = 50;           % Transparency (0: none, 250: opaque)
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

% focusVideoNames = [VideoRoot 'FocusVideos/*.mp4'];
% focusVideos = {dir(targetVideoNames).name};

ball0.name = [ VideoRoot 'FocusVideos/bball0.mp4' ] ;
ball0.duration = (60*5);
ball0.delayMax = ball0.duration - trialLength;
ball0.eventTimes = ball0Times;                              % Event times (s)

ball5.name = [ VideoRoot 'FocusVideos/bball5.mp4' ] ;
ball5.duration = (60*5);
ball5.delayMax = ball5.duration - trialLength;
ball5.eventTimes = ball5Times - ball0.duration;                              % Offset 5 mins (start 0)

ball10.name = [ VideoRoot 'FocusVideos/bball10.mp4' ] ;
ball10.duration = (60*10);
ball10.delayMax = ball10.duration - trialLength;
ball10.eventTimes = ball10Times - ball0.duration - ball5.duration;           % Offset 10 mins (start 0)

dog.name = [ VideoRoot 'DistractVideos/doglickingscreen.mp4' ] ;
dog.duration = 66;
dog.delayMax = 0; % dog.duration - trialLength;

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
actual_checkerboardSize = boardSize/new_boardSize*100;                  % Actual checkerboard size
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
crossImage(:,:,4) = alpha * 1000;
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

beginyay = tic;

if logBool
    fileID = fopen(experimentName,'w'); % Open log file
end

%% Trial level
    for n = 1:(numTrials*2)
        disp(strcat('Trial number: ',num2str(n)))

        if mod(n, 2) == 1
            eventlogTimes = [];
            responseTimes = [];
        
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
            
%             disp("Video starting at...");
%             disp(currentdelay);

            % Print to log file
            if logBool
                fprintf(fileID,'Trial Number: %d\n', m);
                fprintf(fileID,'Target Movie: %s\n', targetVideos{m}.name);
                fprintf(fileID,'Start time: %f\n', currentdelay);
            end
            
            % Event timing adjustment
            % Find first event after video start time ...
            choppedEvents = targetVideos{m}.eventTimes - currentdelay;
            % Round negative to zero for logical indexing
            choppedEvents(choppedEvents < 0) = 0;
            % Return index of first non-zero index (event time after start time)
            startIndex = find(choppedEvents, 1);
            if isempty(startIndex)      % if no events in trial duration, place counter at end of array
                eventCounter = length(targetVideos{m}.eventTimes);
            else
                eventCounter = startIndex;
            end
            
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
                    % disp(num2str(toc(beginyay)));
                end
            end

            %% Buffer movie and initial display
            % Try to open multimedia file
            movieL = Screen('OpenMovie', window, movienameL, 0, -1);
            movieR = Screen('OpenMovie', window, movienameR, 0, -1);
            
            % Set start time from file ( name, delay from start, 0: in seconds | 1: in frames)
            Screen('SetMovieTimeIndex', movieL, moviedelayL, 0);
            Screen('SetMovieTimeIndex', movieR, moviedelayR, 0); 
   

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

            pause(fixationPause) % movie playing in background during this pause
            
            %% Initial movie display
            start = tic;
            timeElapsedL = toc(start);
            timeElapsedR = toc(start);
            
             % Queue playback at normal speed forward
            Screen('PlayMovie', movieL, 1, 1);
            Screen('PlayMovie', movieR, 1, 1);

            texL = Screen('GetMovieImage', window, movieL, 0, 0);     
            texR = Screen('GetMovieImage', window, movieR, 0, 0);

            Screen('DrawTexture', window, texL, [], dstRect(1,:) );
            Screen('DrawTexture', window, texR, [], dstRect(2,:) );
            ltexL = texL;
            ltexR = texR;
            
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

                % disp('Got image')
                % If found, display next frame, else display last found
                if texL > 0
                     Screen('DrawTexture', window, texL, [], dstRect(1,:));
                     ltexL = texL;
                     % disp(strcat('texl: ',num2str(texL)))
                else 
                     Screen('DrawTexture', window, ltexL, [], dstRect(1,:));
                     % disp(strcat('ltexl: ',num2str(ltexL)))
                end

                if texR > 0
                    Screen('DrawTexture', window, texR, [], dstRect(2,:));
                    ltexR = texR;
                    % disp(strcat('texR: ',num2str(texR)))
                else 
                    Screen('DrawTexture', window, ltexR, [], dstRect(2,:));
                    % disp(strcat('ltexR: ',num2str(ltexR)))
                end

                % Increment frame counter per flip
                frameCounterL = frameCounterL + waitframes;
                frameCounterR = frameCounterR + waitframes;

                % Draw texture on screen
                Screen('DrawTexture', window, checkerTexture(textureCueL(1)), [], dstRect(1,:), 0, filterMode, 0.1);
                Screen('DrawTexture', window, checkerTexture(textureCueR(1)), [], dstRect(2,:), 0, filterMode, 0.1);
                Screen('DrawTexture', window, crossTexture, [], dstRect(currentSide + 1,:));
                % disp('Drew')
                
                % Flip to update display at set time (at waitframes multiple of screen refresh rate)
                vbl = Screen('Flip', window, vbl + (waitframes-buffer) * ifi);
                % disp('Flipped')

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
                     % disp('Left polarity')
                end

                if frameCounterR >= scalingCoeff/(ifi*rightFreq)
                    rightTime = toc(start) - timeElapsedR;
                    %disp({'rightTime', rightTime})

                    textureCueR = fliplr(textureCueR);

                    frameCounterR = 0;
                    timeElapsedR = toc(start);
                    % disp('Right polarity')
                end

                % ADD -reading events from file, waiting for key press, and sending markers!
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                
                
                if keyIsDown 
                    disp(mResponseOnset);
                    disp(videoTime)
                    responseTimes = [responseTimes videoTime];

                    if lslBool
                        outlet.push_sample(mResponseOnset);
                    end
                    
                    FlushEvents('keyDown');
                end

                videoTime = currentdelay + toc(start);
                % disp(videoTime)

                % Event matrix does not match video
%                  disp("Next event")
%                  disp(targetVideos{m}.eventTimes(eventCounter));
%                  disp("Time")
%                  disp(videoTime)
%                  disp("Next event at")
%                  disp(targetVideos{m}.eventTimes(eventCounter))
                
                % If time matches with event times, send event marker
                if ( eventCounter <= length(targetVideos{m}.eventTimes) && ...
                    videoTime > targetVideos{m}.eventTimes(eventCounter) - 0.5 && ...
                        videoTime < targetVideos{m}.eventTimes(eventCounter) + 0.5)
                     % disp('Event match')
                     
                    eventlogTimes = [eventlogTimes videoTime];
                    if lslBool
                        outlet.push_sample(mEventOnset);
                        disp(mEventOnset)
                        disp(videoTime)
                    end
                   
                    eventCounter = eventCounter + 1;
                end
               % disp('end loop')
            end
            
            start = tic;
            % disp('Re tic')
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
            
            if logBool
                fprintf(fileID,'Response Times:');
                for i = 1:length(responseTimes)
                    fprintf(fileID,'%7.2f', responseTimes(i));
                end
                fprintf(fileID, '\n');

                fprintf(fileID,'Event Times:');
                for i = 1:length(eventlogTimes)
                    fprintf(fileID,'%7.2f', eventlogTimes(i));
                end
                fprintf(fileID, '\n');
                fprintf(fileID, '\n'); 
            end

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
                
                
%                 Screen('CloseMovie', movieL);
%                 Screen('CloseMovie', movieR);

            
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
    
    if logBool
        fclose(fileID); % close log file in last trial
    end
catch SE
    sca; 
    psychrethrow(psychlasterror);
end

% Closes screen with keyboard press
sca;
ListenChar(0);
