%% Predict on pre-recorded data
evaldataset = preprocess('C:\Users\alakmazaheri\Documents\BCI\HALBCI\SandBox\Phase0_Ava\markertest1.xdf');
[prediction,loss,teststats,targets] = bci_predict(lastmodel,evaldataset);

disp(['test mis-classification rate: ' num2str(loss*100,3) '%']);
disp(['  predicted classes: ',num2str(round(prediction{2}*prediction{3})')]);  % class probabilities * class values
disp(['  true classes     : ',num2str(round(targets)')]);

%% Predict live by markers
% stream EEG and markers over LSL
run_readlsl('DataStreamQuery','name=''EEG''', 'MarkerQuery','name=''Markers''');

% evaluate stream at markers
onl_newpredictor('mypredictor',lastmodel,'laststream', {'769','770'})

% query predictive model
run_writevisualization('Model',lastmodel, 'VisFunction','bar(y);ylim([0 1])');

while(true)
    output = onl_predict('mypredictor', 'mode');
    if ~isnan(output)
         disp(output)
    end
end

%% Predict live continuous, mark stimulus times
% stream EEG and markers over LSL
run_readlsl('DataStreamQuery','name=''EEG''', 'MarkerQuery','name=''Markers''');

% evaluate stream at each sample
onl_newpredictor('mypredictor',lastmodel,'laststream')

markerinfo = [];

while(true)
    output = onl_predict('mypredictor', 'mode');
    currmarker = laststream_marker_chunk.type;
    
    for i = 1: length(laststream_marker_chunk)
        if (currmarker == 770 || currmarker == 769)
            add = [currmarker; laststream.smax];
            markerinfo = [markerinfo add]
             disp(currmarker)
        end
    end
end