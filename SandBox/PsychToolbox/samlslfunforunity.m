
namelslstream = 'SamTwo';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set up the lsl outlet so that it may send out markers
%as
disp('Loading library...');
lib = lsl_loadlib();

disp('Creating a new marker stream info...');
%info = lsl_streaminfo(lib,namelslstream,'3DCoord',1,0,'cf_int32','myuniquesourceid23443');
info = lsl_streaminfo(lib,namelslstream,'3DCoord',3,0,'cf_int32','myuniquesourceid23443');

disp('Opening an outlet...');
outlet = lsl_outlet(info);
%}


for i = 1:10
    outlet.push_sample([.2 i 5]);
    input('test')
end
