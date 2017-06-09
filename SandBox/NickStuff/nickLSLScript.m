%this first statement is telling bcilab to look for an lsl stream of type
%"EEG"
%It will then visualize the data with vis_stream
%
traindata = io_loadset('C:\Users\gsteelman\Desktop\bob1.gdf','channels',1:4);
mydata = exp_eval(traindata);
answer = refactorFunc(mydata);
for i = 1:length(mydata.event)
    if length(answer(:,1))>i
        mydata.event(i).type = char(answer(i,1));
        mydata.event(i).latency = cell2mat(answer(i,2));
        mydata.event(i).urevent = cell2mat(answer(i,3));
        mydata.urevent(i).type = char(answer(i,1));
        mydata.urevent(i).latency = cell2mat(answer(i,2));
    else
        break
    end
end
%run_readdataset('Dataset',mydata);
%bci_annotate('Model',lastmodel, laststream)
%'Markers',{'68','69'}
[predictions,latencies] = onl_simulate(mydata, mymodel,'SamplingRate',1,'Shift',1,'Interval',[0 1]);
[prediction,loss,teststats,targets] = bci_predict(mymodel,mydata);
%this simply displays the information gotten from bci_predict
disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);
%}
disp('Done')
%plot(latencies, predictions); 
% process data in real time using lastmodel, and visualize outputs
%run_writevisualization('Model',lastmodel, 'VisFunction','bar(y);ylim([0 1])');

%{
run_readlsl('MatlabStream','dopeStream','DataStreamQuery','type=''EEG''', 'MarkerStreamQuery','');
bci_stream_name = 'dopeStream';
%
onl_newpredictor('mypredictor',mymodel,bci_stream_name)
t = 0
t2 = 0
%
while true
   output = onl_predict('mypredictor','expectation') 
   disp(output)
   if output > 1.5
       t = t+1;
   else
       t2 = t2 + 1;
   end
   t
   t2
   
   pause(.1)
end
%run_writevisualization('Model',lastmodel,'VisFunction','bar(y);ylim([0 1])');
%}

%{
disp('Opening the library...');
if isempty(lib)
    lib = lsl_loadlib(env_translatepath('dependencies:/liblsl-Matlab/bin')); end
% describe the stream
disp('Creating a new streaminfo...');
info = lsl_streaminfo(lib,opts.out_stream,'BackOut',length(opts.channel_names),'220','cf_float32',uid);
% ... including some meta-data
desc = info.desc();
channels = desc.append_child('channels');


% create an outlet
outlet = lsl_outlet(info);

% start background writer job
onl_write_background( ...
    'ResultWriter',@(y)send_samples(outlet,y),...
    'MatlabStream',opts.in_stream, ...
    'Model',opts.pred_model, ...
    'OutputFormat',opts.out_form, ...
    'UpdateFrequency',opts.update_freq, ...
    'PredictorName',opts.pred_name, ...
    'PredictAt',opts.predict_at, ...
    'Verbose',opts.verbose, ...
    'StartDelay',0,...
    'EmptyResultValue',[]);

disp('Now writing...');


function send_samples(outlet,y)
if ~isempty(y)
    outlet.push_chunk(y'); end

run_writelsl('SourceStream','dopeStream','LabStreamName','BCI-Continuous');
%vis_stream()
%}
%in order to save the information to a file we must first grab the
%socket(or inlet) of the stream
%{
f=figure;
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {}
%this while loop will wait until a stream of the given name is retrieved
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');
newstream = flt_pipeline(bci_stream_name,'Rereferencing',{{'TP9','TP10'}})
%}
%{
%this variable will catch each variable and append it onto itself
recorded = [0 0 0 0 0 0]
while true
    % get data from the inlet (timeout: 1 second)
    [data,timestamp] = inlet.pull_sample(0);
    % and display it
    if timestamp
        fprintf('%.2f\n',data); 
        recorded = [recorded; data];
        %bar([data-1,1-(data-1)]); ylim([0 1]); drawnow;
        disp('pulled data')
    else
        pause(0.01);
    end
end
%}
%{
run_writevisualization('VisFunction','bar(y);ylim([0 1])');
disp('Click into the figure to stop online processing.'); 
waitforbuttonpress; onl_clear; close(gcf);
%}