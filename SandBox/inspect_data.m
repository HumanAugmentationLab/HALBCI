figure; zoom xon
% View all channels
for i = 1:4
    subplot(4,1,i)
     plot(EEG.data(i,:)', 'k','DisplayName','EEG.data')
end

% Select cleanest channels to display with markers
figure; zoom xon
plot(EEG.data([1 4],:)','DisplayName','EEG.data')

count = 0;

eventlen = length(EEG.event);
for i = 1:eventlen
    t = EEG.event(i).latency;
    mark = sprintf('%d', str2double(EEG.event(i).type));

    if(strcmp(mark,'770') || strcmp(mark,'769'))
        count = count+1;
        l = line([t t], [0  1500]);
        label(l,mark,'location','top');
    end
end
% check that count equals 40 (20L/20R)