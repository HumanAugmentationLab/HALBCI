run_readlsl('MatlabStream','dopeStream','DataStreamQuery','type=''EEG''', 'MarkerStreamQuery','');
bci_stream_name = 'dopeStream';

run_writelsl('Model',mymodel,'SourceStream',bci_stream_name,'LabStreamName','Res666','OutputForm','expectation','ChannelNames',{'open','closed'})