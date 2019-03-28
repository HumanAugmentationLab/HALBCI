%% Dual Flashing Checkerboard & Movie
% PsychToolbox code for SSVEP attention experiment
% Display two square checkerboards flashing independently (with movies overlayed)


% Variable checkerboard transparencies, checkerboard size, inverting?

%% PsychToolbox Setup
clear;
AssertOpenGL;
PsychDefaultSetup(2);  
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 5);
% oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
addpath(genpath('/home/hal/Research/Matlab/BCILAB/dependencies/liblsl-Matlab'));
%ListenChar(2);                      % Disable key presses from showing up in MATLAB script (change with CTRL+C)

%% Experiment Parameters
experimentName = 'test.txt';      % Log file name


% Duration
trialLength = 3.1;                  % Trial length (s)  --- always add 100 ms for buffer
numTrials = 12;                      % Number of trials per run - must be divisible by # conditions

% Pauses
calibrationPause = 0;               % Pause before the whole experiment starts, for EEG settling (s)
startTrialPause = 1;                % Pause before trial (s)
fixationPause = 2;                  % Pause before fixation cross (s)
endTrialPause = 2;                  % Pause after survey, after trial ends (s)
endPause = 1;                       % Pause after run ends (s)

% Enable Parameters
lslBool = 1;                        % 1: Send markers over LSL
logBool = 1;                        % 1: Write trial data to text file
surveyBool = 1;                     % 0: Trials only | 1: Attention Survey
movieBool = 0;                      % 0: Checkerboard only | 1: checkerboard and movie

% Background Display
WindowCoords = [];                  % Size of display: [x1, y1, x2, y2] or [] for full screen
backgroundColor = 0;                % 0: black
scalingCoeff = 1;                   % Alter driving frequency of checkerboard flip

% Checkerboard Display
Hz = [6 15];                         % Frequencies to display - should go into 60 Hz
boardSizeBig = 6;                    % Number of BIG checkers per side (smaller number)
boardSizeSmall = 8;                 % Number of SMALL checkers per side (bigger number)
color1 = 0;                         % Checker color 1 (0: black)
color2 = 255;                       % Checker color 2 (255: white)
color1TranspWeak = 75;              % Transparency (0: transparent, 250: opaque)
color2TranspWeak = 20;              % Transparency (0: transparent, 250: opaque)
color1TranspStrong = 175;           % Transparency (0: transparent, 250: opaque)
color2TranspStrong = 50;            % Transparency (0: transparent, 250: opaque)
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
mEventOnset = 81;                   % Actual movie event
                                    
% BIG checks on checkerboard (e.g. 2x2) vs SMALL checks on checkerboard (e.g. 8x8)
% CHECK only, STRONG (high opacity) check on video, WEAK (transp) check on video

mCondition1 = 1;                    % Attend CHECK & BIG & LOW frequency
mCondition2 = 2;                    % Attend CHECK & BIG & HIGH frequency
mCondition3 = 3;                    % Attend STRONG VID & BIG & LOW frequency
mCondition4 = 4;                    % Attend STRONG VID & BIG & HIGH frequency
mCondition5 = 5;                    % Attend WEAK VID & BIG & LOW frequency
mCondition6 = 6;                    % Attend WEAK VID & BIG & HIGH frequency

mCondition7 = 7;                    % Attend CHECK & SMALL & LOW frequency
mCondition8 = 8;                    % Attend CHECK & SMALL & HIGH frequency
mCondition9 = 9;                    % Attend STRONG VID & SMALL & LOW frequency
mCondition10 = 10;                   % Attend STRONG VID & SMALL & HIGH frequency
mCondition11 = 11;                   % Attend WEAK VID & SMALL & LOW frequency
mCondition12 = 12;                   % Attend WEAK VID & SMALL & HIGH frequency

%% Movie Loading
load eventTimes
VideoRoot = '/home/hal/Research/HALBCI/SandBox/Ava/VideoAttention/';

ball1.name = [ VideoRoot 'FocusVideos/bball1.mp4' ] ;
ball1.eventTimes = ball1Times;

ball2.name = [ VideoRoot 'FocusVideos/bball2.mp4' ] ;
ball2.eventTimes = ball2Times ;

ball3.name = [ VideoRoot 'FocusVideos/bball3.mp4' ] ;
ball3.eventTimes = ball3Times;

ball4.name = [ VideoRoot 'FocusVideos/bball4.mp4' ] ;
ball4.eventTimes = ball4Times;

ball5.name = [ VideoRoot 'FocusVideos/bball5.mp4' ] ;
ball5.eventTimes = ball5Times;

ball6.name = [ VideoRoot 'FocusVideos/bball6.mp4' ] ;
ball6.eventTimes = ball6Times;
 
% Leave out - camera shifting and time jump
ball7.name = [ VideoRoot 'FocusVideos/bball7.mp4' ] ;
ball7.eventTimes = ball7Times;
 
ball8.name = [ VideoRoot 'FocusVideos/bball8.mp4' ] ;
ball8.eventTimes = ball8Times;
 
ball9.name = [ VideoRoot 'FocusVideos/bball9.mp4' ] ;
ball9.eventTimes = ball9Times;
 
ball10.name = [ VideoRoot 'FocusVideos/bball10.mp4' ] ;
ball10.eventTimes = ball10Times;

focusMovieList = { ball1 ball2 ball3 ball4 ball5 ball6 ball8 ball9 ball10 };

for i = 1:length(focusMovieList)
    focusMovieList{i}.duration = 60*5;
    focusMovieList{i}.delayMax = focusMovieList{i}.duration - trialLength;
end

%% Randomize Targets
numFocusVideos = length(focusMovieList);
sixthSize = floor(numTrials/6);


% For PilotV4+, always attend RIGHT
targetSides = ones(1, numTrials);
 
if mod(numTrials, 12) ~= 0
    error('Trial number must give even number of conditions')
end

orderedDisplay = [zeros(1, sixthSize) ones(1, sixthSize) repelem(2, sixthSize) ...
    repelem(3, sixthSize) repelem(4, sixthSize) repelem(5, sixthSize) ];                % Checker v. video trial
orderedFreqs = repmat([Hz(1) Hz(2)], 1, numTrials/2);                                                     % Attending frequency

targetIndices = randperm(numTrials);

targetFreqs = orderedFreqs(targetIndices);
targetDisplay = orderedDisplay(targetIndices);
   
leftVideos = cell(1, numTrials);
rightVideos = cell(1, numTrials);

for i = 1:numTrials
    leftVideos{i} = focusMovieList{round(rand*(numFocusVideos-1)+1)};
    rightVideos{i} = focusMovieList{round(rand*(numFocusVideos-1)+1)};
end

% To display the same video on both sides, set rightVideos = leftVideos

% %  Setup output: LSL and log
if lslBool == 1
    disp('Loading library...');
    lib = lsl_loadlib();

    disp('Creating new marker stream info')
    info = lsl_streaminfo(lib, 'PsychMarkers', 'Markers', 1, 0, 'cf_int32', 'mysourceid');

    disp('Opening an outlet...')
    outlet = lsl_outlet(info);
end

if logBool
    fileID = fopen( ['./LogFiles/' experimentName],'w');                         % Open general log file
    markerfileID = fopen(['./LogFiles/marker_' experimentName], 'w');       % Open marker log file
    fprintf(markerfileID, 'type,latency,latency_ms\n');
    fprintf(markerfileID, '%d,%.3f,%d \n', mStartRun, 0, 0);
end

%% Generate Checkerboard and Cross Display

% Populate matrices to represent checkerboard 
checkerWeakBigL = ones([boardSizeBig boardSizeBig 2]);
checkerWeakBigR = checkerWeakBigL;

checkerStrongBigL = checkerWeakBigL;
checkerStrongBigR = checkerWeakBigL;

checkerFullBigL = checkerWeakBigL;
checkerFullBigR = checkerWeakBigL;

checkerWeakSmallL = checkerWeakBigL;
checkerWeakSmallR = checkerWeakBigL;

checkerStrongSmallL = checkerWeakBigL;
checkerStrongSmallR = checkerWeakBigL;

checkerFullSmallL = checkerWeakBigL;
checkerFullSmallR= checkerWeakBigL;

% LAYER 1: Set checkerboard colors with opposite polarity | LAYER 2: Set transparency
for j = 1:boardSizeBig
     for k = 1:boardSizeBig
         if mod(j+k,2) == 1
             checkerWeakBigL(j,k,:) = color1;
             checkerWeakBigL(j,k,2) = color1TranspWeak;
             checkerWeakBigR(j,k,:) = color2;
             checkerWeakBigR(j,k,2) = color2TranspWeak;
             
             checkerStrongBigL(j,k,:) = color1;
             checkerStrongBigL(j,k,2) = color1TranspStrong;
             checkerStrongBigR(j,k,:) = color2;
             checkerStrongBigR(j,k,2) = color2TranspStrong;
             
             checkerFullBigL(j,k,:) = color1;
             checkerFullBigR(j,k,:) = color2;
         else
             checkerWeakBigL(j,k,:) = color2; 
             checkerWeakBigL(j,k,2) = color2TranspWeak;
             checkerWeakBigR(j,k,:) = color1;
             checkerWeakBigR(j,k,2) = color1TranspWeak;
             
             checkerStrongBigL(j,k,:) = color2;
             checkerStrongBigL(j,k,2) = color2TranspStrong;
             checkerStrongBigR(j,k,:) = color1;
             checkerStrongBigR(j,k,2) = color1TranspStrong;
             
             checkerFullBigL(j,k,:) = color2;
             checkerFullBigR(j,k,:) = color1;
         end
     end
end

for j = 1:boardSizeSmall
     for k = 1:boardSizeSmall
         if mod(j+k,2) == 1
             checkerWeakSmallL(j,k,:) = color1;
             checkerWeakSmallL(j,k,2) = color1TranspWeak;
             checkerWeakSmallR(j,k,:) = color2;
             checkerWeakSmallR(j,k,2) = color2TranspWeak;
             
             checkerStrongSmallL(j,k,:) = color1;
             checkerStrongSmallL(j,k,2) = color1TranspStrong;
             checkerStrongSmallR(j,k,:) = color2;
             checkerStrongSmallR(j,k,2) = color2TranspStrong;
             
             checkerFullSmallL(j,k,:) = color1;
             checkerFullSmallR(j,k,:) = color2;
         else
             checkerWeakSmallL(j,k,:) = color2; 
             checkerWeakSmallL(j,k,2) = color2TranspWeak;
             checkerWeakSmallR(j,k,:) = color1;
             checkerWeakSmallR(j,k,2) = color1TranspWeak;
             
             checkerStrongSmallL(j,k,:) = color2;
             checkerStrongSmallL(j,k,2) = color2TranspStrong;
             checkerStrongSmallR(j,k,:) = color1;
             checkerStrongSmallR(j,k,2) = color1TranspStrong;
             
             checkerFullSmallL(j,k,:) = color2;
             checkerFullSmallR(j,k,:) = color1;
         end
     end
end


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
    checkerWeakBigTexture(1) = Screen('MakeTexture', window, checkerWeakBigL);
    checkerWeakBigTexture(2) = Screen('MakeTexture', window, checkerWeakBigR);
    
    checkerStrongBigTexture(1) = Screen('MakeTexture', window, checkerStrongBigL);
    checkerStrongBigTexture(2) = Screen('MakeTexture', window, checkerStrongBigR);
    
    checkerFullBigTexture(1) = Screen('MakeTexture', window, checkerFullBigL);
    checkerFullBigTexture(2) = Screen('MakeTexture', window, checkerFullBigR);
    
    checkerWeakSmallTexture(1) = Screen('MakeTexture', window, checkerWeakSmallL);
    checkerWeakSmallTexture(2) = Screen('MakeTexture', window, checkerWeakSmallR);
    
    checkerStrongSmallTexture(1) = Screen('MakeTexture', window, checkerStrongSmallL);
    checkerStrongSmallTexture(2) = Screen('MakeTexture', window, checkerStrongSmallR);
    
    checkerFullSmallTexture(1) = Screen('MakeTexture', window, checkerFullSmallL);
    checkerFullSmallTexture(2) = Screen('MakeTexture', window, checkerFullSmallR);
                
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Black Screen
    blackCheckerboard = checkerWeakBigL;
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
        runStart = tic;
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

        % Video v. checkerboard display condition:
        displayType = targetDisplay(n);

        if displayType == 0         % Checkerboard - checkerboard display
            movieBool = 0;
            currentdelay = 0;
        else                        % Movie - movie display (for any transparency)
            movieBool = 1;
            movienameL = leftVideos{n}.name;
            moviedelayL = 0; % rand * leftVideos{n}.delayMax;
            currentdelay = moviedelayL;

            movienameR = rightVideos{n}.name;
            moviedelayR = 0; %rand * rightVideos{n}.delayMax;
        end
        
        % Frequency display condition:
        leftFreq = targetFreqs(n);
        rightFreq = Hz(Hz ~= targetFreqs(n));
        
        % Output ALL  conditions
        if displayType == 0
            if targetFreqs(n) == min(targetFreqs)
                % Condition 1: CHECK BIG LOW
                mCondition = mCondition1;
            else
                % Condition 2: CHECK BIG HIGH
                mCondition = mCondition2;
            end
        elseif displayType == 1
            if targetFreqs(n) == min(targetFreqs)
                % Condition 3: STRONG VIDEO BIG LOW
                mCondition = mCondition3;
            else
                % Condition 4: STRONG VIDEO BIG  HIGH
                mCondition = mCondition4;
            end
        elseif displayType == 2
            if targetFreqs(n) == min(targetFreqs)
                % Condition 5: WEAK VIDEO BIG LOW
                mCondition = mCondition5;
            else
                % Condition 6: WEAK VIDEO BIG HIGH
                mCondition = mCondition6;
            end
        elseif displayType == 3
            if targetFreqs(n) == min(targetFreqs)
                % Condition 7: CHECK SMALL LOW
                mCondition = mCondition7;
            else
                % Condition 8: CHECK SMALL HIGH
                mCondition = mCondition8;
            end
        elseif displayType == 4
            if targetFreqs(n) == min(targetFreqs)
                % Condition 9: STRONG VIDEO SMALL LOW
                mCondition = mCondition9;
            else
                % Condition 10: SUBTLE VIDEO HIGH
                mCondition = mCondition10;
            end
        elseif displayType == 5
           if targetFreqs(n) == min(targetFreqs)
               % Condition 11: WEAK VIDEO SMALL LOW
               mCondition = mCondition11;
           else
                % Condition 12: WEAK VIDEO SMALL HIGH
                mCondition = mCondition12;
           end 
        end
        
                
        % Event timing adjustment
        % Find first event after video start time ...
        choppedEvents = leftVideos{n}.eventTimes - currentdelay;
        % Round negative to zero for logical indexing
        choppedEvents(choppedEvents < 0) = 0;
        % Return index of first non-zero index (event time after start time)
        startIndex = find(choppedEvents, 1);
        if isempty(startIndex)      % if no events in trial duration, place counter at end of array
            eventCounter = length(leftVideos{n}.eventTimes);
        else
            eventCounter = startIndex;
        end
        
        %% Setup log file
        eventlogTimes = [];
        responseTimes = [];
        
        if logBool
            fprintf(fileID,'Trial Number: %d\n', n);
            fprintf(fileID,'Target Movie: %s\n', leftVideos{n}.name);
            fprintf(fileID,'Movie start time: %.3f\n', currentdelay);
            fprintf(fileID,'Condition: %d (Frequency: %d | Movie Display: %d)\n', mCondition, targetFreqs(n), targetDisplay(n));        
        end
        
        %% Buffer movie underneath blank initial display
        % Try to open multimedia file
        if movieBool
            % Preload one second by default
            movieL = Screen('OpenMovie', window, movienameL, 0, 30);
            movieR = Screen('OpenMovie', window, movienameR, 0, 30);

            % Set start time from file ( name, delay from start, 0: in seconds | 1: in frames)
            Screen('SetMovieTimeIndex', movieL, moviedelayL, 0);
            Screen('SetMovieTimeIndex', movieR, moviedelayR, 0); 
        end

        if lslBool
            outlet.push_sample(mStartTrial + mCondition)
            trialStart = toc(runStart);
            disp(mStartTrial + mCondition)
            disp(trialStart);
        end

        Screen('DrawTexture', window, blackTexture, [], dstRect(1,:));
        Screen('DrawTexture', window, blackTexture, [], dstRect(2,:));

        Screen('Flip', window);
        pause(startTrialPause)  
        
        %% Draw fixation cross
        Screen('DrawTexture', window, crossTexture, [], dstRect(targetSides(n) + 1,:));
        Screen('Flip', window);

        if lslBool
            outlet.push_sample(mCueOnset + mCondition)
            cueStart = toc(runStart);
            disp(mCueOnset + mCondition)
            disp(cueStart);
        end

        pause(fixationPause)
        
        %% Start movie, get first frame

        if movieBool
            % Queue playback at normal speed forward
            Screen('PlayMovie', movieL, 1, 1);
            Screen('PlayMovie', movieR, 1, 1);
            start = tic;

            texL = Screen('GetMovieImage', window, movieL, 0, 0);     
            texR = Screen('GetMovieImage', window, movieR, 0, 0);

            ltexL = texL;
            ltexR = texR;
        else
            start = tic;
        end
        timeElapsedL = toc(start);
        timeElapsedR = toc(start);
        
        if lslBool
            outlet.push_sample(mStimulusOnset + mCondition)
            stimStart = toc(runStart);
            myStim = tic;
            disp(mStimulusOnset + mCondition)
            disp(stimStart);
        end

       

        looptimes = zeros(1, 30000);
        allvbl = looptimes;
        allfliptime = looptimes;
        q = 1;
        
        prevSeconds = 0;
        startOffset = toc(start);
        checklefttime = tic;
        checkrighttime = tic;
        %% PLAY        
        while toc(start) - startOffset < trialLength
            looptimes(q) = toc(start) - startOffset;
            q = q + 1;
            %% Draw movie frame by frame
            if movieBool
                % Try to get next movie image
                 texL = Screen('GetMovieImage', window, movieL, 0, 0);     
                 texR = Screen('GetMovieImage', window, movieR, 0, 0);
                 
                 offset = 0; % 200 for testing checkerboard completely off video

                 % If found, display next frame, else display last found
                 if texL > 0
                     % Try to close last frame for memory (if not already closed)
                      if ltexL > 0
                        Screen('Close', ltexL);
                      end
                      Screen('DrawTexture', window, texL, [], dstRect(1,:)  + offset);
                      ltexL = texL;                          
                 else 
                      Screen('DrawTexture', window, ltexL, [], dstRect(1,:) + offset);
                 end

                if texR > 0
                    if ltexR > 0
                        Screen('Close', ltexR);
                    end
                    Screen('DrawTexture', window, texR, [], dstRect(2,:) + offset);
                    ltexR = texR;
                else 
                    Screen('DrawTexture', window, ltexR, [], dstRect(2,:) + offset);
                end
            end
            %% Draw checker texture at target frequency

            % Determine if checkerboard should flip
            % For the left side
            % if time has passed since last flip
            if toc(checklefttime) > ((1/leftFreq) - 0.015)
                %disp(toc(checklefttime))
                textureCueL = fliplr(textureCueL);
                checklefttime = tic; %start left timer over
            end
            if toc(checkrighttime) > ((1/rightFreq)- 0.015)
                textureCueR = fliplr(textureCueR);
                checkrighttime = tic; %start left timer over
            end

            
            % Draw texture on screen
            if displayType == 0
                Screen('DrawTexture', window, checkerFullBigTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
                Screen('DrawTexture', window, checkerFullBigTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            elseif displayType == 1
                Screen('DrawTexture', window, checkerStrongBigTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
                Screen('DrawTexture', window, checkerStrongBigTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            elseif displayType == 2
                Screen('DrawTexture', window, checkerWeakBigTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
                Screen('DrawTexture', window, checkerWeakBigTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            elseif displayType == 3
                Screen('DrawTexture', window, checkerFullSmallTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
                Screen('DrawTexture', window, checkerFullSmallTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            elseif displayType == 4
                Screen('DrawTexture', window, checkerStrongSmallTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
                Screen('DrawTexture', window, checkerStrongSmallTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            elseif displayType == 5
                Screen('DrawTexture', window, checkerWeakSmallTexture(textureCueL(1)), [], dstRect(1,:), [], filterMode);
                Screen('DrawTexture', window, checkerWeakSmallTexture(textureCueR(1)), [], dstRect(2,:), [], filterMode);
            end
            Screen('DrawTexture', window, crossTexture, [], dstRect(targetSides(n) + 1,:));
            
            % Flip to update display at set time (at waitframes multiple of screen refresh rate) - 1 is very important to not have flips
            % missed and times doubled -- timestamps invalid, look at flip
            % timestamps
            [vbl,~, FlipTimestamp]  = Screen('Flip', window, vbl + (waitframes-buffer) * ifi, 0, 1);
            
            allvbl(q) = vbl;
            allfliptime(q) = FlipTimestamp;
           
%             % Increment frame counter per flip
%             frameCounterL = frameCounterL + waitframes;
%             frameCounterR = frameCounterR + waitframes;
% 
%             
%             
%             % For each checkerboard, reverse texture cue/polarity at interval of frequency
%             if frameCounterL >= scalingCoeff/(ifi*leftFreq)
%                  % Manually check duration of each flash
%                  % leftTime = toc(start) - timeElapsedL;
%                  % disp({'leftTime', leftTime})
% 
%                  % Flip texture
%                  textureCueL = fliplr(textureCueL);
% 
%                  % Reset counter and time
%                  frameCounterL = 0;
%                  timeElapsedL = toc(start);
%             end
% 
%             if frameCounterR >= scalingCoeff/(ifi*rightFreq)
%                 rightTime = toc(start) - timeElapsedR;
%                 %disp({'rightTime', rightTime})
% 
%                 textureCueR = fliplr(textureCueR);
% 
%                 frameCounterR = 0;
%                 timeElapsedR = toc(start);
%             end

            %% Event listening
            
            videoTime = currentdelay + toc(start);

            % USER-REPORTED EVENTS
            [ keyIsDown, seconds, keyCode ] = KbCheck;
            
            if keyIsDown && (seconds-prevSeconds > 0.2)
                responseTimes = [responseTimes videoTime];

                if lslBool
                     responseTime = toc(runStart);
                    outlet.push_sample(mResponseOnset);                 % Send response onset marker
                    disp(mResponseOnset);
                end
                
                if logBool
                    fprintf(markerfileID, '%d,%.3f,%d \n', mResponseOnset, responseTime, responseTime * 1000);
                end

                FlushEvents('keyDown');                                 % Flush to reduce number of reported key presses
                prevSeconds = seconds;
            end

            % SYSTEM EVENTS
            % If experiment time matches with event times, send event marker
            if ( eventCounter <= length(leftVideos{n}.eventTimes) && ...
                videoTime > leftVideos{n}.eventTimes(eventCounter) - 0.1 && ...
                    videoTime < leftVideos{n}.eventTimes(eventCounter) + 0.1)

                eventlogTimes = [eventlogTimes videoTime];

                if lslBool
                    eventTime = toc(runStart);
                    outlet.push_sample(mEventOnset);                    % Send event onset marker
                    disp(mEventOnset)
                end
                
                if logBool
                    fprintf(markerfileID, '%d,%.3f,%d \n', mEventOnset, eventTime, eventTime * 1000);
                end

                eventCounter = eventCounter + 1;
            end
        end
%             disp(looptimes(1:q));
            
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
%                 outlet.push_sample(mCueOffset + mCondition)
%                 outlet.push_sample(mStimulusOffset + mCondition)
                outlet.push_sample(mEndTrial + mCondition)

                trialTime = toc(myStim);
                trialEnd = toc(runStart);
%                 disp(mCueOffset + mCondition)
%                 disp(mStimulusOffset + mCondition)
                disp(mEndTrial + mCondition)
                disp(trialTime)
            end
            
            %% Log all response and event times
            if logBool
                fprintf(fileID,'Event Times: ');
                for i = 1:length(eventlogTimes)
                    fprintf(fileID,'%.3f ', eventlogTimes(i));
                end
                fprintf(fileID, '\n');

                fprintf(fileID,'Response Times: ');
                for i = 1:length(responseTimes)
                    fprintf(fileID,'%.3f ', responseTimes(i));
                end
                fprintf(fileID, '\n');
                
                fprintf(fileID, 'trialStart: %.3f \n', trialStart); 
                fprintf(fileID, 'cueStart: %.3f \n', cueStart); 
                fprintf(fileID, 'stimStart: %.3f \n', stimStart); 
                fprintf(fileID, 'Trial Length: %.3f \n', trialTime);
                
                fprintf(markerfileID, '%d,%.3f,%d \n', mStartTrial + mCondition, trialStart, trialStart * 1000);
                fprintf(markerfileID, '%d,%.3f,%d \n', mCueOnset + mCondition, cueStart, cueStart * 1000);
                fprintf(markerfileID, '%d,%.3f,%d \n', mStimulusOnset + mCondition, stimStart, stimStart * 1000);
                fprintf(markerfileID, '%d,%.3f,%d \n', mEndTrial + mCondition, trialEnd, trialEnd * 1000);

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
                
                lastKey = '';

                while 1 % Wait until answer submitted
                    [keyIsDown, seconds, keyCode] = KbCheck;
                    keyCode = find(keyCode, 1);

                    % If key is pressed, display its code number or name.
                    if keyIsDown
                        if keyCode == endKey
                            keyName = KbName(lastKey);
                            fprintf(fileID, 'Survey Response: %s \n', keyName); 
                            
                            if lslBool
                                outlet.push_sample(str2double(keyName) + 85)
                                disp(str2double(keyName) + 85)
                            end
                            break;
                        end
                        
                        lastKey = keyCode;
                        KbReleaseWait;
                    end
                end
                
                 fprintf(fileID, '\n');
            end
            

        %% End of experiment
            if n ~= numTrials                                               % Allow for pause between trials
                pause(endTrialPause)
            else
                pause(endPause)
                
                if lslBool
                    outlet.push_sample(mEndRun)
                    totalTime = toc(runStart);
                    disp(totalTime)
                    disp(mEndRun)
                end

                if logBool
                    fprintf(fileID, 'Total Time: %.3f \n', totalTime); 
                    fprintf(fileID, '\n');
                    
                    fprintf(markerfileID, '%d,%.3f,%d \n', mEndRun, totalTime, totalTime * 1000);
                   
                    fclose(fileID);                                         % Close log file in last trial
                    fclose(markerfileID);
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