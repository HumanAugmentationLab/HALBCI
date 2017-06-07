figure
zoom xon
%ylim([0 6])
plot(EEG.data','DisplayName','EEG.data')

eventlen = length(EEG.event);

for i = 1:eventlen
    t = EEG.event(i).latency;
    mark = sprintf('%d', str2double(EEG.event(i).type));
    disp(mark)

    if(strcmp(mark,'770') || strcmp(mark,'769'))
        l = line([t t], [0  1500]);
        label(l,mark,'location','top');
    end
end