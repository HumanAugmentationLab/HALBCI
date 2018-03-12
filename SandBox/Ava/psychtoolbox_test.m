% Setup and Error Prevention
AssertOpenGL;
PsychDefaultSetup(2);  
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);


% Experiment Parameters
movieBool = 0;                  % Ignore movie files for testing
trialLength = 30;               % Trial length (s)

% Checkerboard display
Hz = [1 2];                   % [L R] frequencies (actual = 1/2 input?)
transparencyChecker = 200;       % Set transparency (0: none, 250: opaque)
board_size = 2;                 % Half of board width/height (2: 4x4)
color1 = 255;                   % Checker color 1 (black)
color2 = 0;                     % Checker color 2 (white)
WindowCoords = [100 100 600 600];              % For full screen, []
filterMode = 0;                 % Nearest neighbour


% Create mirrored checkerboards
checkerboardL = repmat(eye(2), board_size, board_size, 4);
checkerboardR = checkerboardL;

% Checkerboard layers 1-3: set colors
% such that checkerboard 1 and 2 will have opposite polarities
for j = 1 : board_size*2
     for k = 1 : board_size*2
         if checkerboardL(j,k,:) == 1
             checkerboardL(j,k,:) = color1;
             checkerboardR(j,k,:) = color2;
         else
             checkerboardL(j,k,:) = color2; 
             checkerboardR(j,k,:) = color1;
         end
     end
end

% Checkerboard layer 4: set transparency
checkerboardL(:,:,4) = zeros(board_size*2, board_size*2) + transparencyChecker;  
checkerboardR(:,:,4) = zeros(board_size*2, board_size*2) + transparencyChecker; 
    
try
    % --------------------- DISPLAY ------------------------- %
    % Find screen
    screenid = max(Screen('Screens'));

    % Open 'windowrect' sized window on screen, with black [0] background color:
    [window, windowRect] = Screen('OpenWindow', screenid, 0, WindowCoords);
    
    [xCenter, yCenter] = RectCenter(windowRect);
    [wW,wH] = Screen('WindowSize', window);
    
    % Set portion of window for displaying checkerboards (with margins)
    % Space checkerboards evenly for display
    dispRect = [0 0 wW/3 wH/2];
    dispRectL = CenterRectOnPointd(dispRect, xCenter*.5, yCenter);
    dispRectR = CenterRectOnPointd(dispRect, xCenter*1.5, yCenter);
    dstRect = [dispRectL; dispRectR];

    % Make the checkerboard into a texure
    checkerTexture(1) = Screen('MakeTexture', window, checkerboardL);
    checkerTexture(2) = Screen('MakeTexture', window, checkerboardR);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Setup movies if included
    if movieBool == 1
        movienameL = '/.mp4';
        movienameR = '/.mp4';

        movieL = Screen('OpenMovie', window, movienameL, 0, -1);
        movieR = Screen('OpenMovie', window, movienameR, 0, -1);
    
        Screen('PlayMovie', movieL, 1, 1);
        Screen('PlayMovie', movieR, 1, 1);
        
        texL = Screen('GetMovieImage', window, movieL,1,0); 
        ltexL = texL;
        
        texR = Screen('GetMovieImage', window, movieR,1,0); 
        ltexR = texR;
    end
    
    % --------------------- TIMING ------------------------- %
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);            % s/frame
    framesPerFlipL = (1 / (ifi * Hz(1)))
    framesPerFlipR = (1 / (ifi * Hz(2)))

    textureCueL = [1 2];
    textureCueR = [1 2];

    frameCounterL = 0;
    frameCounterR = 0;  
    
    % Sync to vertical retrace
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);
    vbl = Screen('Flip', window);
    
    % Time to wait in frames for a flip
    waitframes = 1;
    
    % Start timing to manually check frequency
    start = tic;
    
    % Stop script if trial ends or keyboard pressed
    while toc(start) < trialLength && ~KbCheck
        % Display movies if included
        if movieBool == 1
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
        end

        % Draw texture on screen
        Screen('DrawTexture', window, checkerTexture(textureCueL(1)), [], dstRect(1,:), 0, filterMode);
        Screen('DrawTexture', window, checkerTexture(textureCueR(1)), [], dstRect(2,:), 0, filterMode);
        Screen('Flip', window)

        % For each checkerboard, reverse texture cue to flash opposite at t
        if mod(toc(start), 1/Hz(1)) < 0.05
             textureCueL = fliplr(textureCueL);
             actualhzL = frameCounterL/toc(start);
        end
        
        if mod(toc(start), 1/Hz(2)) < 0.05
             textureCueR = fliplr(textureCueR);
             actualhzR = frameCounterR/toc(startR);
        end
    end
    
catch
    sca;
    psychrethrow(psychlasterror);
end
disp('frameCounterL')
disp(frameCounterL)
disp('toc')
disp(toc(start))

KbStrokeWait;
sca;