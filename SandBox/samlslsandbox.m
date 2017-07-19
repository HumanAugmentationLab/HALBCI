bci_stream_name = 'museData';  
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG',1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');



%% Read mouse data
run_readlsl('DataStreamQuery','type=''Position''', 'MarkerQuery','','SamplingRateOverride',0.2);
vis_stream()

%% Read Mouse through inlet
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','Position',1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

%%
run_writedataset('laststream','./lastdata2.set',.05)

%%
instr=textread('yourfile.txt','%s\n');
for i=1:length(instr)
temp=sscanf(instr,formatstr);
end;
%%

%% Read EEG through inlet
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {};
while isempty(result)
    result = lsl_resolve_byprop(lib,'type','EEG',1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test Enobio to understand stream mnames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lib = lsl_loadlib();
alllsl = lsl_resolve_all(lib);
for i = 1:size(alllsl,2)
alllsl{1}.as_xml %Prints info on each stream
end

