AssertOpenGL;
PsychDefaultSetup(2);  
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);

Hz = [1 15];  
time = 200;
transparencyChecker = 75;
board_size = 2; 

color1 = 255;
color2 = 0;  

checkerboard = repmat(eye(2),board_size,board_size,4);
checkerboard2 = abs(1-checkerboard);
for j = 1:board_size*2
     for k = 1:board_size*2
         if checkerboard(j,k,:) == 1
             checkerboard(j,k,:) = color1;
             checkerboard2(j,k,:) = color2;
         else
             checkerboard(j,k,:) = color2; 
             checkerboard2(j,k,:) = color1;
         end
     end
end

checkerboard(:,:,4) = zeros(board_size*2, board_size*2) + transparencyChecker;  
checkerboard2(:,:,4) = zeros(board_size*2, board_size*2) + transparencyChecker; 

windowrect = [];
display_rect_full = [0 0 wW/3 wH/2];
screenid = max(Screen('Screens'));
    
try
    % Open 'windowrect' sized window on screen, with black [0] background color:
    [window, windowRect] = Screen('OpenWindow', screenid, 0, [100 100 600 600] );

    % Make the checkerboard into a texure (4 x 4 pixels)
    checkerTexture(1) = Screen('MakeTexture', window, checkerboard);
    checkerTexture(2) = Screen('MakeTexture', window, checkerboard2);
    
    [xCenter, yCenter] = RectCenter(windowRect);
    [wW,wH] = Screen('WindowSize', window);
    [s1, s2] = size(checkerboard);
    
    % Display rectangle in part of screen
    display_rect_full = [0 0 wW/3 wH/2];
    % Position checkerboards with respect to display rect
    display_rect_left = CenterRectOnPointd(display_rect_full, xCenter*.5, yCenter)
    display_rect_right = CenterRectOnPointd(display_rect_full, xCenter*1.5, yCenter);
    dstRect = [display_rect_left; display_rect_right];
    
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window)
    slack = ifi/2;
    checkFlipTimeSecs = 1/Hz(1);
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    checkFlipTimeSecs2 = 1/Hz(2);
    checkFlipTimeFrames2 = round(checkFlipTimeSecs2 / ifi);

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Draw the checkerboard texture to the screen. By default bilinear
    % filtering is used. For this example we don't want that, we want nearest
    % neighbour so we change the filter mode to zero
    filterMode = 0;

    % Time to wait in frames for a flip
    waitframes = 1;

    % Texture cue that determines which texture we will show

    % Sync us to the vertical retrace
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);
    vbl = Screen('Flip', window);
    my1 = tic;
    my2 = tic;
    numTimes = Hz(1) * time;
    p = 1;
    frameCounter = 0;
    waitframes = 1;
    numTimes = 1000;
    textureCue = [1 2];
    
    while p < numTimes && ~KbCheck
        frameCounter = frameCounter + waitframes;
        
        % Draw our texture to the screen
        Screen('DrawTexture', window, checkerTexture(textureCue(1)), [], dstRect(1,:), 0, filterMode);
        Screen('DrawTexture', window, checkerTexture(textureCue(1)), [], dstRect(2,:), 0, filterMode);
        Screen('Flip',window)

        % Reverse the texture cue to show the other polarity if the time is up
        if frameCounter >= checkFlipTimeFrames
             p = p+1;
             frameCounter = 0;
             textureCue = fliplr(textureCue);
        end

    end
catch %#ok<CTCH>
    sca;
    psychrethrow(psychlasterror);
end

KbStrokeWait;
sca;


