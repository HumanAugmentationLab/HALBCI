function [  ] = efficientBoardFunc( window,windowRect,Hz,time )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
    slack = Screen('GetFlipInterval', window)/2
    % Get the size of the on screen window


    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);

    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(windowRect);

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Define a simple 4 by 4 checker board
    checkerboard = repmat(eye(2), 3, 3);

    % Make the checkerboard into a texure (4 x 4 pixels)
    checkerTexture(1) = Screen('MakeTexture', window, checkerboard);
    checkerTexture(2) = Screen('MakeTexture', window, 1-checkerboard);

    % We will scale our texure up to 90 times its current size be defining a
    % larger screen destination rectangle
    [s1, s2] = size(checkerboard);
    dstRect = [0 0 s1 s2] .* 120;
    dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

    % Draw the checkerboard texture to the screen. By default bilinear
    % filtering is used. For this example we don't want that, we want nearest
    % neighbour so we change the filter mode to zero
    filterMode = 0;
    Screen('DrawTextures', window, checkerTexture(1), [],...
        dstRect, 0, filterMode);


    % Texture cue that determines which texture we will show
    textureCue = [1 2];

    % Sync us to the vertical retrace
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);
    vbl = Screen('Flip', window);
    tic
    numTimes = Hz * time;
    p = 0
    checkFlipTimeSecs = 1/Hz
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    while p<numTimes && ~KbCheck

        % Increment the counter
        %frameCounter = frameCounter + waitframes;

        % Draw our texture to the screen



        % Reverse the texture cue to show the other polarity if the time is up
        if toc >= checkFlipTimeSecs-.02
            
            p = p+1;
            
            textureCue = fliplr(textureCue);
            Screen('DrawTexture', window, checkerTexture(textureCue(1)),[],dstRect, 0, filterMode);
            vbl = Screen('Flip', window,vbl + (checkFlipTimeFrames - 1.5) * ifi);
            toc
            tic

        % Flip to the screen
        
            
        end
    end
end

