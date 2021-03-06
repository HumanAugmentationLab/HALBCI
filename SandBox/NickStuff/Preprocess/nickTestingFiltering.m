%this was just an incomplete sandbox to understand for filtering and the
%pipline works
mydata = io_loadset(recorded)
run_readlsl('DataStreamQuery','type=''EEG''', 'MarkerQuery','')
bci_stream_name = 'Muse-3FE0'
vis_stream(bci_stream_name)
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {}
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');
%newstream = flt_pipeline(bci_stream_name,'Rereferencing',{{'TP9','TP10'}})
% load calibration set
raw = io_loadset('calib.set')

% apply a ser'ies of filter to it (the processed set now has a filter expression and initial state)
processed = exp_eval(flt_iir(flt_resample(raw,128),[0.5 1],'highpass'));

% start streaming some data
run_readdataset('mystream','action.set');
% and put a pipeline on top of it that replicates the processing applied to processed and continues it on new data
pip = onl_newpipeline(processed,{'mystream'});

   while 1
      % generate a 200-sample view into the processed stream
      [EEG,pip] = onl_filtered(pip,200);
   end
flt_pipeline(mydata, '')