function [  ] = efficientChoice(  window,windowRect,Hz,time,extraImage,outlet,mrk,lr)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    slack = Screen('GetFlipInterval', window)/2;
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
    dstRectOG = [0 0 s1 s2] .* 90;
    
    dstRect1 = CenterRectOnPointd(dstRectOG, xCenter * .5, yCenter);
    dstRect2 = CenterRectOnPointd(dstRectOG, xCenter  * 1.5 , yCenter);
    dstRect = [dstRect1; dstRect2]


    % Draw the checkerboard texture to the screen. By default bilinear
    % filtering is used. For this example we don't want that, we want nearest
    % neighbour so we change the filter mode to zero
    filterMode = 0;

    % Time to wait in frames for a flip
    waitframes = 1;

    % Texture cue that determines which texture we will show
    textureCue = [1 2];
    textureCue2 = [1 2];
    frameCounter = 0;
    frameCounter2 = 0;
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);
    Screen('DrawTexture', window, extraImage);
    vbl = Screen('Flip', window);
    my1 = tic;
    my2 = tic;
    numTimes = Hz(1) * time;
    p = 0;
    checkFlipTimeSecs = 1/Hz(1);
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    checkFlipTimeSecs2 = 1/Hz(2);
    checkFlipTimeFrames2 = round(checkFlipTimeSecs2 / ifi);
    outlet.push_sample(mrk);
    while p<numTimes && ~KbCheck

        % Increment the counter
        %frameCounter = frameCounter + waitframes;

        % Draw our texture to the screen
        
        % Increment the counter
        frameCounter = frameCounter + waitframes;
        frameCounter2 = frameCounter2 + waitframes;
        % Draw our texture to the screen
        Screen('DrawTexture', window, checkerTexture(textureCue(1)),[],dstRect(lr(1),:), 0, filterMode);
        Screen('DrawTexture', window, checkerTexture(textureCue2(1)),[],dstRect(lr(2),:), 0, filterMode);
        Screen('DrawTexture', window, extraImage);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);


        % Reverse the texture cue to show the other polarity if the time is up
        if frameCounter >= checkFlipTimeFrames
             p = p+1;
             %toc(my1)
             my1 = tic;
             textureCue = fliplr(textureCue);
             frameCounter = 0;
        end
        
        if frameCounter2 >= checkFlipTimeFrames2
             %toc(my2)
             my2 = tic;
             textureCue2 = fliplr(textureCue2);
             frameCounter2 = 0;
        end




        % Reverse the texture cue to show the other polarity if the time is up

    end

end

