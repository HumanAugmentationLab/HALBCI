function [ pahandle, wavedata ] = loadSound( wavfilename)
    %%This simple function will simply load a sound into the computer and
    %%return the required variables for psychotoolbox. This is mainly to
    %%increase modularoty and readability

    [y, freq] = psychwavread(wavfilename);
    wavedata = y';
    nrchannels = size(wavedata,1); % Number of rows == number of channels.

    if nrchannels < 2
        wavedata = [wavedata ; wavedata];
        nrchannels = 2;
    end


    try
        % Try with the 'freq'uency we wanted:
        pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
    catch
        % Failed. Retry with default frequency as suggested by device:
        fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', freq);
        fprintf('Sound may sound a bit out of tune, ...\n\n');

        psychlasterror('reset');
        pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
    end



end

