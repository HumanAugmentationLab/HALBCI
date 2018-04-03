%% Sample Stimulus Script
% Authored By Yoonyoung Cho @ 2017
% Contact yoonyoung.cho@students.olin.edu

% Description :
% This script performs a variant of the Stroop task,
% where a combination of two stimuli from [audio|text|color] are used.

% Resources :
% TTS script available from
% https://www.mathworks.com/matlabcentral/fileexchange/18091-text-to-speech

% Instructions :
% Run, and click on the figure to begin.
% When the stimuli are consistent, press space.
% Otherwise, click on the figure.


%% Define Parameters Here
n_trials = 25;
p_match = 0.5;

%% Initialization

% initialize random number generator
% replace 0 with something else for a different result
rng(0, 'twister');

% stimulus type
% 0 = TEXT | COLOR
% 1 = TEXT | AUDIO
% 2 = COLOR | AUDIO
s_idx = randi([1, 3], 1, n_trials);

% color type
colors_t=["RED", "ORANGE", "YELLOW", "GREEN", "BLUE", "PURPLE"]; % text
% color values
colors_v = [
    255 0 0; 
    255 128 0;
    255 255 0;
    0 255 0;
    0 0 255;
    128 0 255;
    ];
colors_v = colors_v / 255.0;

% collect sounds, .wav
colors_s = {};
for i = 1:length(colors_t)
    s = tts(char(colors_t(i)));
    colors_s{i} = audioplayer(s, 16000);
    %assume default 16kHz sampling rate
end
    
%% Set Matching Events
% the number of non-contradictory events
% are defined according to p_match.

n_match = floor(p_match * n_trials);
m_mask = zeros(n_trials, 1);
m_idx = randperm(n_trials, n_match);
m_mask(m_idx) = 1;
c_idx = zeros(2, n_trials);

for i = 1:n_trials
    if m_mask(i) == 1
        c_idx(:,i) = randi([1,6]);
    else
        c_idx(:,i) = randperm(6,2);
    end
end

%% Prepare Display
fig = figure;
% Display String
tx = text(0.5, 0.5, 'START');
tx.HorizontalAlignment = 'center';
tx.VerticalAlignment = 'middle';
tx.FontSize = 32;
tx.FontWeight = 'bold';
%% Run 
%p = gcp(); % get the current parallel pool
k = waitforbuttonpress; % start
% response, click (unmatch) | space (match)
resp = zeros(n_trials, 1);

for i=1:n_trials
    ca_i = c_idx(1, i);
    cb_i = c_idx(2, i);
    
    c_a = char(colors_t(ca_i));
    c_b = char(colors_t(cb_i));
    
    fprintf('Type : %d | Match : %d\n', s_idx(i), m_mask(i));
    
    switch s_idx(i)
        case 1 %T/C
            whitebg(fig, 'white');
            tx.String = c_a;
            tx.Color = colors_v(cb_i, :);
            drawnow
        case 2 %T/A
            whitebg(fig, 'white');
            tx.String = c_a;
            tx.Color = [0 0 0];
            drawnow
            play(colors_s{cb_i});
        case 3 %C/A 
            whitebg(fig, colors_v(ca_i, :));
            tx.String = '';
            tx.Color = [0 0 0];
            drawnow
            play(colors_s{cb_i});
    end
    % some logic for sending markers
    % send_marker()
    resp(i) = waitforbuttonpress();
end