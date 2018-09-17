numRuns = 2;
numTrials = 5;
numTotal = numRuns*numTrials;

videos = ['a', 'b', 'c', 'd', 'e'];
frequencies = [10 15];

numVideos = length(videos);
half_size = floor(numTotal/2);

if mod(numTotal, 2) == 0
    ordered_sides = [zeros(1, half_size) ones(1, half_size)];
else
    extra_side = round(rand);
    ordered_sides = [extra_side zeros(1, half_size) ones(1, half_size)];    
end
random_sides = ordered_sides(randperm(length(ordered_sides)));
display_sides = random_sides;

freq_sides = zeros(1, numTotal);
for i = 1:numTotal
    freq_sides(i) = frequencies(random_sides(i) + 1);
end
   
video_target = zeros(1, numTotal);
for i = 1:numTotal
    video_target(i) = videos(round(rand*(numVideos-1)+1));
end

for i = 1:numTotal
    disp(['Playing video ', video_target(i), ' on side ', num2str(display_sides(i)), ' with frequency ', num2str(freq_sides(i))])
end