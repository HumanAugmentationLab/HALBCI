% Draw fixation spot to backbuffer:
winRect = Screen('Rect', win); slack = Screen('GetFlipInterval', win)/2;
Screen('FillOval', win, 255, CenterRectInRect([0 0 20 20], winRect));
% Show fixation spot on next retrace, take onset timestamp:
tfixation_onset = Screen('Flip', win);
% Draw prime stimulus image to backbuffer:
Screen('DrawTexture', win, primeImage);
% Show prime exactly 500 msecs after onset of fixation spot:
tprime_onset = Screen('Flip', win, tfixation_onset + 0.500 - slack);
% Draw target stimulus image to backbuffer:
Screen('DrawTexture', win, targetImage);
% Show target exactly 100 msecs after onset of prime image:
ttarget_onset = Screen('Flip', win, tprime_onset + 0.100 - slack);
% Show target exactly for 200 msecs, then blank screen.
ttarget_offset = Screen('Flip', win, ttarget_onset + 0.200 - slack);
??Choose your presentation times as a multiple of the video refresh
duration! 100 Hz is a good refresh setting for 10 ms timing granularity.
