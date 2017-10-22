filename = 'OCtraining';%Dictates which file to load
Stim1 = {'149' '151'};
load(strcat(filename,'.mat'))%loads the file
run_readdataset('mystream',mytraindata)%runs the dataset in real time
%then visualize the models predictions
run_writevisualization('Model',mymodel,'SourceStream','mystream','VisFunction','bar(y);ylim([0 1])');
while true%quick for loop to display the actual values for self validation
    if strcmp(mystream_marker_chunk.type,Stim1(1))
        
        disp(1)
        
    elseif strcmp(mystream_marker_chunk.type,Stim1(2))
        disp(2)
        
    end
            
            
end
%[Predictions,Latencies] = onl_simulate(mytraindata, mymodel, 'SamplingRate',1)