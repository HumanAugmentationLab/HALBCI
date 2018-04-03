% Select screen for display of movie:
%%This script will play a movie with an overlayed checkboard.
AssertOpenGL;
PsychDefaultSetup(2);  
%Undo Warnings

addpath(genpath('/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/PsychToolbox'))

%
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);


moviename = [ '/home/gsteelman/Desktop/Summer Research/Media/OGgrass.mp4' ];
moviename2 = [ '/home/gsteelman/Desktop/Summer Research/Media/OGswim.mp4' ];
Hz = [1 15];  
time = 200;
transparencyChecker = 75;
checkernumSize = 2; 
lslBool = 1


if lslBool
    disp('Loading library...');
    lib = lsl_loadlib();

    disp('Creating a new marker stream info...');
    info = lsl_streaminfo(lib,'PsychMarkers','Markers',1,0,'cf_int32','myuniquesourceid23443');

    disp('Opening an outlet...');
    outlet = lsl_outlet(info);
end


  
Square1 = [255 0 0];
Square2 = [0 255 255];

Square1 = [255 0 255];
Square2 = [0 255 0  ];

Square1 = [0 255 0];
Square2 = [0 0 255];

Square1 = [255 255 255  ];
Square2 = [0 0 0];  

checkerboard = repmat(eye(2),checkernumSize , checkernumSize,4);
%checkerboard = checkerboard .* 255;

checkerboard2 = abs(1-checkerboard);
for i = 1:3
    for j = 1:checkernumSize*2
         for k = 1:checkernumSize*2
             if checkerboard(j,k,i) ==1
                 checkerboard(j,k,i) = Square1(i);
                 checkerboard2(j,k,i) = Square2(i);
             else
                 checkerboard2(j,k,i) = Square1(i);
                 checkerboard(j,k,i) = Square2(i); 
             end
         end
    end

end

   
checkerboard(:,:,4) = zeros(checkernumSize*2,checkernumSize*2) +transparencyChecker;  
checkerboard2(:,:,4) = zeros(checkernumSize*2,checkernumSize*2) +transparencyChecker; 




windowrect = [];


% Wait until user releases keys on keyboard:
KbReleaseWait;


screenid = max(Screen('Screens'));

try
    % Open 'windowrect' sized window on screen, with black [0] background color:
    [window, windowRect] = Screen('OpenWindow', screenid, 0 );
    


    % Make the checkerboard into a texure (4 x 4 pixels)
    checkerTexture(1) = Screen('MakeTexture', window, checkerboard);
    checkerTexture(2) = Screen('MakeTexture', window, checkerboard2);
    
    [xCenter, yCenter] = RectCenter(windowRect);
    [wW,wH] = Screen('WindowSize', window)
    [s1, s2] = size(checkerboard);
    dstRectOG = [0 0 wW/3 wH/2 ] ;
     
    dstRect1 = CenterRectOnPointd(dstRectOG, xCenter * .5, yCenter);
    dstRect2 = CenterRectOnPointd(dstRectOG, xCenter  * 1.5 , yCenter);
    dstRect = [dstRect1; dstRect2];
    
    % Open movie file:
    movie = Screen('OpenMovie', window, moviename,0,-1);
    movie2 = Screen('OpenMovie', window, moviename2,0,-1);
    
    % Start playback engine:
    
    
    
   
    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);
    slack = ifi/2;
    checkFlipTimeSecs = 1/Hz(1);
    checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
    checkFlipTimeSecs2 = 1/Hz(2);
    checkFlipTimeFrames2 = round(checkFlipTimeSecs2 / ifi);

    % Get the centre coordinate of the window

    

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
    textureCue = [1 2];
    textureCue2 = [1 2];
    frameCounter = 0;
    frameCounter2 = 0;  
    Screen('PlayMovie', movie, 1,1);
    Screen('PlayMovie', movie2, 1,1);
    tex2 = Screen('GetMovieImage', window, movie2,1,0); 
    tex = Screen('GetMovieImage', window, movie,1,0); 
    ltex = tex;
    ltex2 = tex2;
    texFlip = 0;
    numTimes = 1000  
    while p<numTimes && ~KbCheck
           tex = Screen('GetMovieImage', window, movie,0,0);     
           tex2 = Screen('GetMovieImage', window, movie2,0,0);        
  
           % Every 20 counts...
           if mod(p,20) == 0
               % increasing frequencies? [2 16] ...
               % Hz(1) = Hz(1) + 1;
               % Hz(2) = Hz(2) + 1;
               
               % number of seconds per flip (1/1/s)
               checkFlipTimeSecs = 1/Hz(1);
               % number of frames per flip (s/s/frame) 
               checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
               
               checkFlipTimeSecs2 = 1/Hz(2);
               checkFlipTimeFrames2 = round(checkFlipTimeSecs2 / ifi);
               
               p = p+1;
           end

           % MOVIE 1
           % If found, display next frame -- else display last frame found
           if tex>0
                Screen('DrawTexture', window, tex,[],dstRect(1,:) );
                ltex = tex;
           else 
                Screen('DrawTexture', window, ltex,[],dstRect(1,:) );
           end
                
           % MOVIE 2
           % If found, display next frame -- else display last frame found
           if tex2>0
                Screen('DrawTexture', window, tex2,[],dstRect(2,:) );
                ltex2 = tex2;
           else 
                Screen('DrawTexture', window, ltex2,[],dstRect(2,:) );
           end


            frameCounter = frameCounter + waitframes;
            frameCounter2 = frameCounter2 + waitframes;
            % Draw our texture to the screen
            Screen('DrawTexture', window, checkerTexture(textureCue(1)),[],dstRect(1,:), 0, filterMode);
            Screen('DrawTexture', window, checkerTexture(textureCue2(1)),[],dstRect(2,:), 0, filterMode);

            % Flip to the screen
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);


            % Reverse the texture cue to show the other polarity if the time is up
            if frameCounter >= checkFlipTimeFrames
                 p = p+1;
                 actualhz(mod(p,20)+1,Hz(1)) = toc(my1);
                 my1 = tic;
                 textureCue = fliplr(textureCue);
                 
                 frameCounter = 0;
                 texFlip= ~texFlip;
            end

            if frameCounter2 >= checkFlipTimeFrames2
                 toc(my2)
                 my2 = tic;
                 textureCue2 = fliplr(textureCue2);
                 frameCounter2 = 0;
            end
    end


     
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    Screen('PlayMovie', movie2, 0);
    
    % Close movie:
    Screen('CloseMovie', movie2);
    
    % Close Screen, we're done:
  
    
catch %#ok<CTCH>
    sca;
    psychrethrow(psychlasterror);
end
KbStrokeWait;
sca;


