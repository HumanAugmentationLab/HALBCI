function checkerboard(sidelength,frequency)
% texture based

maxduration = 20;

if nargin < 2
    frequency = 1;
end
    

try
    myScreen = max(Screen('Screens'));
    [win,winRect] = Screen(myScreen,'OpenWindow');
    
    [width, height] = RectSize(winRect);
    
    numCheckers =  ceil([width; height] ./ sidelength);

    % Background color dark green, just to make sure
    Screen('FillRect',win,[0 127 0]);
    
    % make an atomic checkerboard
    miniboard = eye(2,'uint8') .* 255;
    
    % repeat it in half of x,y, since it's 2x2
    checkerboard_heads = repmat(miniboard, ceil(0.5 .* numCheckers))';
    
    % invert for the other cycle
    checkerboard_tails = 255 - checkerboard_heads;

    % scale the images up
    checkerboard_heads = imresize(checkerboard_heads,sidelength,'box');
    checkerboard_tails = imresize(checkerboard_tails,sidelength,'box');
    
    % make textures clipped to screen size
    texture(1) = Screen('MakeTexture', win, checkerboard_heads(1:height,1:width));
    texture(2) = Screen('MakeTexture', win, checkerboard_tails(1:height,1:width));
    
    % don't need those anymore
    clear checkerboard_*; 


    
    % Define refresh rate.
    ifi = Screen('GetFlipInterval', win);
    
    % set to 'ifi/2' for maximum refresh rate
    % ifi/2 represents the next possible retrace
    % 1/frequency < ifi is impossible
    swapinterval = 1 / frequency;
    deadline = GetSecs + maxduration;
        
    % Preview texture briefly before flickering
    % n.b. here we draw to back buffer
    Screen('DrawTexture',win,texture(1));
    Screen('Flip',win);
    WaitSecs(2);
    % n.b. here we draw to the other buffer,
    % while the other one acts as the front buffer
    Screen('DrawTexture',win,texture(2));
          
    % First flip to get the time code we use in the loop
    % n.b. first real swap
    VBLTimestamp = Screen('Flip', win, 0, 2);

    % loop swapping buffers, checking keyboard, and checking time
    % param 2 denotes "dont clear buffer on flip", i.e., we alternate
    % our buffers cum textures
    while (~KbCheck) && (GetSecs < deadline)
        [VBLTimestamp StimulusOnseTime] = Screen('Flip', win, VBLTimestamp + swapinterval,2);
    end
    
    Screen('CloseAll');


catch

    Screen('CloseAll');
    psychrethrow(psychlasterror);

end