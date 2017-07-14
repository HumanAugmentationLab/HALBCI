
% Clear the workspace and the screen
sca;
close all;
%clearvars;


% Here we call so me default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
AssertOpenGL;
%Undo Warnings
%
%oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
%oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For example, when I call this I get the vector
% [0 1]. The first number is the native display for my laptop and the
% second referes to my secondary external monitor. By native display I mean
% the display the is physically part of my laptop. With a non-laptop
% computer look at your screen preferences to see which is the primary
% monitor.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. If I were to select the minimum of these numbers then I would be
% displaying on the physical screen of my laptop.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% luminace values are genrally defined between 0 and 1.
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace value for white
grey = white / 2;
inc = white - grey;


% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,[0 0 800 500])

slack = Screen('GetFlipInterval', window)/2
% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window); 

% Query the frame duration
ifi = Screen('GetFlipInterval', window)
hertz=Screen('NominalFrameRate', window)

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Define a simple 4 by 4 checker board
checkerboard = repmat(eye(2), 3, 3,4);
%checkerboard = checkerboard .* 255;
checkerboard(:,:,4) = zeros(6,6) +225/2; 

% Make the checkerboard into a texure (4 x 4 pixels)
checkerTexture(1) = Screen('MakeTexture', window, checkerboard);
checkerTexture(2) = Screen('MakeTexture', window, abs(1-checkerboard));

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

% Flip to the screen
Screen('Flip', window);



frameCounter = 0;

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

% Sync us to the vertical retrace
topPriorityLevel = MaxPriority(window);
Priority(topPriorityLevel);
vbl = Screen('Flip', window);
tic
t = toc
actualhz = zeros(30,20)

for i=1:50
    Hz = i
    checkFlipTimeSecs = 1/Hz
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    p = 1
    while p<20

        % Increment the counter
        frameCounter = frameCounter + waitframes;

        % Draw our texture to the screen
        Screen('DrawTexture', window, checkerTexture(textureCue(1)),[],dstRect, 0, filterMode);

        % Flip to the screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi); 


        % Reverse the texture cue to show the other polarity if the time is up
        if frameCounter >= checkFlipTimeFrames
            actualhz(i,p) = (toc - t)
            p = p+1;
            t = toc;
            
            textureCue = fliplr(textureCue);
            frameCounter = 0;
        end

    end
end
slack
% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them.
KbStrokeWait;
sca;