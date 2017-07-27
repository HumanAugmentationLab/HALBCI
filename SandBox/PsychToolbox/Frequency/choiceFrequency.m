%%This Script will display two flashing checkerboards of different
%%frequencies and point an arrow to one or the other. the order of the
%%checkerboards (i.e. whether the faster/slower one is on the left or right
%%will change so the data should not be skewed by eye movements.
sca;
close all;
clearvars;
numTrials = 6;
Trialslength = 5;
timeBeforeOnset = .8;%time between trials
extraTime = 4;
arrowBuffer = .2;
%repetitions = 1;%This is how many times the audio file should repeat(No reason to be more than 1)
Hz = [1 15];
orderList = linspace(1,numTrials,numTrials);%randperm(numTrials);
lrList = randperm(numTrials);
choices = [1 2];
images = ['left.png' 'right.png'];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here we call some defaulhelpt settings for setting up Psychtoolbox
PsychDefaultSetup(2);
AssertOpenGL;
%Undo Warnings
%
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
oldSkipSyncTests = Screen('Preference', 'SkipSyncTests', 2);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[w, wRect] = PsychImaging('OpenWindow', screenNumber, grey  );
Screen('TextSize', w ,50);
rSize = 250;
[wW, wH]=WindowSize(w);
myrect=[wW-rSize wH - rSize wW wH];   
myoval=[wW/2-rSize/2 wH/2-rSize/2 wW/2+rSize/2 wH/2 + rSize/2]; % center dRect on current mouseposition


myimgfile = ['/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/Media/left.png'];
fprintf('Using image ''%s''\n', myimgfile);
imdata=imread(myimgfile);
imagetexLeft=Screen('MakeTexture', w, imdata);

myimgfile = ['/home/gsteelman/Desktop/Summer Research/HALBCI/SandBox/Media/right.png'];
fprintf('Using image ''%s''\n', myimgfile);
imdata=imread(myimgfile);
imagetexRight=Screen('MakeTexture', w, imdata);

imagetexs = [imagetexLeft imagetexRight];

slack = Screen('GetFlipInterval', w)/2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this part loads the lsl outlet so that it may send out markers
%
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
info = lsl_streaminfo(lib,'PsychMarkers','Markers',1,0,'cf_int32','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);
%}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    %{
    disp('click for stuff')
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse to prep photodiode stimulation', wW/2-100, wH/2, black);
    clickedTime = Screen('Flip', w);
    while 1
       [mx, my, buttons]=GetMouse(screenNumber);
       if find(buttons)
            while any(buttons)
                [mx, my, buttons]=GetMouse(screenNumber);
            end
            Screen('FillRect',w, black);
            tic
            clickedTime = Screen('Flip', w);
            toc
            break
        end 

    end
    %This will wait for 30 seconds after the user clicks and then blink a white
    %square in the bottom right and send an event marker over lsl
    %The purpose of this is to enable syncing up the data when there is a
    %photodiode in place so that we can line up the event markers with their
    %proper timestamp in the data
    mrk = 100
    Screen('FillRect',w, white,myrect);
    toc
    rectTime = Screen('Flip', w,clickedTime + 30);
    toc
    outlet.push_sample(mrk);
    toc
    %}
    %
    %We will then turn the screen grey and wait for a click before starting the
    %experiment in order to give time for the user to get the headband properly
    %situated
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse to start session', wW/2-100, wH/2, black);
    endtrial = Screen('Flip', w);

    while 1
       [mx, my, buttons]=GetMouse(screenNumber);
       if find(buttons)
            while any(buttons)
                [mx, my, buttons]=GetMouse(screenNumber);
            end
            Screen('FillRect',w, grey);
            mrk = 99;
            endtrial = Screen('Flip', w);
            outlet.push_sample(mrk);
            break
        end 

    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Now we start the expriment
    for i = 1:numTrials
        %Put oval on Screen
        indexHz = mod(orderList(i),2)+1
        indexlr = mod(lrList(i),2)+1
        Screen('DrawTexture', w, imagetexs(indexHz));
        mrk = indexHz*100 + indexlr*10;%left = 100 , right = 200,
        tfixation_onset = Screen('Flip', w,endtrial -slack + timeBeforeOnset);
        outlet.push_sample(mrk);
        %Select and load the correct image and event marker based on the
        %predefined probability of the first class. Each selection will
        %slightly change the probability in order to prevent a run with only 1
        %type of event
        %{
        num = mod(orderList(i),4) + 1;
        Hz = choices(num);
        mrk = Hz;
        %}
        if indexHz == indexlr
            lr = [1 2];
        else
            lr = [2 1];
        end
        tfixation_onset = Screen('Flip', w,tfixation_onset - slack + arrowBuffer);
        mrk = mrk + 1;%left = 101 right = 201
        efficientChoice(w,wRect,Hz,Trialslength,imagetexs(indexHz),outlet,mrk,lr);
        %Put Picture on Screen 3 seconds after oval (adjust for slack)
        %Imediately send the corresponding event marker afterwards
        
        
        Screen('FillRect',w, grey);
        endtrial = Screen('Flip', w);
        %This is supposed to exit the loop if the user clicks, but it does not
        %work
        if(mod(i,3) == 0)
            Screen('FillRect',w, grey);
            endtrial = Screen('Flip', w, endtrial + 4);
            
        end

    end
    %At the end of the experiment, this will turn the screen grey and wait for
    %the user click, then 10 seconds later it will flash another white square
    %for photodiode validation
    Screen('FillRect',w, grey);
    Screen('DrawText', w, 'Click mouse when ready for end stimulation', wW/2, wH/2, black);
    mrk = 299;
    endtrial = Screen('Flip', w,endtrial + 5);
    outlet.push_sample(mrk);

    while 1
       [mx, my, buttons]=GetMouse(screenNumber);
       if find(buttons)
            while any(buttons)
                [mx, my, buttons]=GetMouse(screenNumber);
            end
            Screen('FillRect',w, black);
            clickedTime = Screen('Flip', w);
            break
        end 

    end





    % Now we have drawn to the screen we wait for a keyboard button press (any
    % key) to terminate the demo.
catch

    sca;
    ShowCursor;
    Priority(0);
    
    % Restore preferences
    %Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
    %Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
    
    psychrethrow(psychlasterror);
end


% Clear the screen.
%}
KbStrokeWait;
sca;







