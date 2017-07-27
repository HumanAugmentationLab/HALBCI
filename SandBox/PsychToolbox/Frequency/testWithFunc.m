% Clear the workspace and the screen
sca;
close all;
clearvars;


% Here we call so me default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
AssertOpenGL;
%Undo Warnings
%
oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey,[0 0 800 500]);

inefficientBoardFuncc(window,windowRect,30  ,100); 

KbStrokeWait;
sca;