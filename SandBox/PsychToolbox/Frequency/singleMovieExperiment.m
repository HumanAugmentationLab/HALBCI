 %%This script will play a movie with an overlayed checkboard.
clear
AssertOpenGL;
PsychDefaultSetup(2);  
%Undo Warnings
%  
if isunix
    addpath(genpath('/home/gsteelman/Desktop/Summer Research/BCILAB/dependencies'))
end
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
 
moviename = cell(3,1);
moviename(1) = { '/home/gsteelman/Desktop/Summer Research/Resources/OGgrass.mp4'};

moviename(2) = { '/home/gsteelman/Desktop/Summer Research/Resources/OGswim.mp4'}; 
moviename(3) = { '/home/gsteelman/Desktop/Summer Research/Resources/OGsnow.mp4' }; 
Hz = [20  5];   
time = 200;
lslBool = 0; 
transparencyChecker = 100 ; 
numTrials = 7; 
TrialLength = 5; 
restTime = 5;
orderList =linspace(1,numTrials,numTrials);

checkernumSize = [1 4 8]  ; 

Square1 = [255 255 255];
Square2 = [0 0 0];


   
windowrect = [];


if lslBool
    disp('Loading library...');
    lib = lsl_loadlib();

    disp('Creating a new marker stream info...');
    info = lsl_streaminfo(lib,'PsychMarkers','Markers',1,0,'cf_int32','myuniquesourceid23443');

    disp('Opening an outlet...');
    outlet = lsl_outlet(info);
end
 

% Wait until user releases keys on keyboard:

% Select screen for display of movie:
screenid = max(Screen('Screens'));

try
    % Open 'windowrect' sized window on screen, with black [0] background color:
    [window, windowRect] = Screen('OpenWindow', screenid, 0 );
    
    
    
    
    for j = 1:length(checkernumSize)
        checkerboard = repmat(eye(2),checkernumSize(j) , checkernumSize(j),4);
            %checkerboard = checkerboard .* 255;

        checkerboard2 = abs(1-checkerboard);
        for i = 1:3
            for k = 1:checkernumSize(j)*2
                 for l = 1:checkernumSize(j)*2
                     if checkerboard(l,k,i) ==1
                         checkerboard(l,k,i) = Square1(i);
                         checkerboard2(l,k,i) = Square2(i);
                     else
                         checkerboard2(l,k,i) = Square1(i);
                         checkerboard(l ,k,i) = Square2(i);
                     end


                 end
            end

        end
        checkerboard(:,:,4) = zeros(checkernumSize(j)*2,checkernumSize(j)*2) +transparencyChecker;  
        checkerboard2(:,:,4) = zeros(checkernumSize(j)*2,checkernumSize(j)*2) +transparencyChecker; 
        checkerTexture(j,1) = Screen('MakeTexture', window, checkerboard);
        checkerTexture(j,2) = Screen('MakeTexture', window, checkerboard2 );
    end


       
    % Open movie file:
    movieIndex = 1;
    movie = Screen('OpenMovie', window, '/home/gsteelman/Desktop/Summer Research/Resources/OGgrass.mp4',0,-1);

    %movie2 = Screen('OpenMovie', window, moviename2,0,-1);
    % Start playback engine:
    
    
         % Make the checkerboard into a texure (4 x 4 pixels)


    % Query the frame duration
    ifi = Screen('GetFlipInterval', window);
    slack = ifi/2;
    checkFlipTimeSecs = 1./Hz;
    checkFlipTimeFrames = round(checkFlipTimeSecs ./ ifi);
 
    % Get the centre coordinate of the window
    [xCenter, yCenter] =  RectCenter(windowRect);
    [wW,wH] = Screen('WindowSize', window);

    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

    % Define a simple 4 by 4 checker boar

    % We will scale our texure up to 90 times its current size be defining a
    % larger screen destination rectangle
    dstRect = [0 0 wW*.75 wH*.75 ]; 
    dstRect = CenterRectOnPointd(dstRect, xCenter, yCenter);

    % Draw the checkerboard texture to the screen. By default bilinear
    % filtering is used. For this   example we don't want that, we want nearest
    % neighbour so we change the filter mode to zero
    filterMode = 0;

    % Time to wait in frames for a flip
    waitframes = 1; 

    % Texture cue that determines which texture we will show
    textureCue = [1 2];
    % Sync us to the vertical retrace
    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);
    vbl = Screen('Flip', window); 
    t = tic;
    numTimes = Hz * time;
    frameCounter = 0;
%     Screen('PlayMovie', movie, 1,0,0);
%     tex = Screen('GetMovieImage', window, movie,1,0);
%     ltex = tex;
    
    sizeList = randperm(3);
    sizeList = [sizeList fliplr(sizeList)];
    for i = 1:numTrials
        indexHz = mod(orderList(i),2)+1;
        Screen('PlayMovie', movie, 1);
        tex = Screen('GetMovieImage', window, movie,1,0);
        tex = Screen('GetMovieImage', window, movie,1,0);
        tex = Screen('GetMovieImage', window, movie,1,0);
        tex
        movie
        ltex = tex;
        numTimes = TrialLength * Hz(indexHz);
        p = 1;
        whichChecker = sizeList(mod(i-1,6)+1);
        if lslBool
            
            mrk = indexHz*100 + whichChecker*10;%left = 100 , right = 200,, arrow left = 10, arrow right = 20s
            outlet.push_sample(mrk);
            mrk
        end
        while p<numTimes && ~KbCheck
               
                % Increment the counter
               frameCounter = frameCounter + waitframes; 
                %
               tex = Screen('GetMovieImage', window, movie,0,0);

               if tex>0

                   Screen('DrawTexture', window, tex,[],dstRect, 0, filterMode );
                   ltex = tex;
               else 
                   Screen('DrawTexture', window, ltex,[],dstRect, 0, filterMode  );
               end
                %} 

                % Draw our texture to the screen
                Screen('DrawTexture', window, checkerTexture(whichChecker,textureCue(1)),[],dstRect, 0, filterMode);

                % Flip to the screen 
                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);


                % Reverse the texture cue to show the other polarity if the time is up
                if frameCounter >= checkFlipTimeFrames(indexHz)
                    p = p+1;
                    toc(t)
                    t = tic;
                    textureCue = fliplr(textureCue);
                    frameCounter = 0;
                end

        end
        Screen('PlayMovie', movie, 0);
        
        if mod(i,6) == 0
            Screen('CloseMovie', movie);
            movieIndex = movieIndex + 1;
            movie = Screen('OpenMovie', window, char(moviename(movieIndex)),0,-1);
            sizeList = randperm(3);
            sizeList = [sizeList fliplr(sizeList)];
            

            
        end
        Screen('FillRect',window, [0 0 0]);
        vbl = Screen('Flip', window);
        if lslBool
            
            mrk = 170;
            outlet.push_sample(mrk);
        end

         if KbCheck
            
            break;
        end
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi + restTime);
       
        
    end
     
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
     
    % Close Screen, we're done:
    sca;
     
catch %#ok<CTCH>
    sca;
    psychrethrow(psychlasterror);
end
KbStrokeWait;
sca;