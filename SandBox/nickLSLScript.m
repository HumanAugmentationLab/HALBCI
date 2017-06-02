%this first statement is telling bcilab to look for an lsl stream of type
%"EEG"
%It will then visualize the data with vis_stream
run_readlsl('DataStreamQuery','type=''EEG''', 'MarkerQuery','')
bci_stream_name = 'museData'
vis_stream(bci_stream_name)
run_writedataset('laststream','NickMuseWaves7.set')
 
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