%this first statement is telling bcilab to look for an lsl stream of type
%"EEG"
%It will then visualize the data with vis_stream
run_readlsl('DataStreamQuery','type=''EEG''', 'MarkerQuery','');
vis_stream()
%{
run_writevisualization('VisFunction','bar(y);ylim([0 1])');
disp('Click into the figure to stop online processing.'); 
waitforbuttonpress; onl_clear; close(gcf);
%}