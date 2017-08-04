og_temp = io_loadset('C:\Users\alakmazaheri\Documents\BCI\BCI Competition IV Data\1AD Matlab\BCICIV_calib_ds1b.mat','channels',1:4);
og = exp_eval(og_temp);

streams = load_xdf('C:\Users\alakmazaheri\Desktop\avacado.xdf');
markers = streams{2};
markertimes = markers.time_stamps;
markervals = markers.time_series;

datastream = streams{3};
data = datastream.time_series;

x2 = x;
x2.data = data;
x2.event(:,1) = markervals';
x2.event.latency = markertimes;

x = pop_loadxdf('C:\Users\alakmazaheri\Desktop\test_long.xdf');
%x = exp_eval(x_temp);
x2.nbchan = 4;
x2.data = x2.data(1:4,:);
x2.chanlocs(5:6) = [];
for i = 1:length(x2.event)
    %disp(curr)
    curr = x2.event(i).type;
    if abs(curr - 770) < 2
       disp(i)
    else
    end
    
end
   x2.event(i).type = num2str(x2.event(i).type);
end
% lat1 = x.event(1).latency;
% for i = 1:length(x.event)
%     x.event(i).latency = x.event(i).latency - lat1;
% end

% for i = 1:length(x.event)
%     x.event(i).urevent = i;
% end
% x.urevent = x.event;

%myapproach = {'CSP' 'SignalProcessing',{'EpochExtraction',[0.5 1.5],'FIRFilter',[7 8 26 28]}};

