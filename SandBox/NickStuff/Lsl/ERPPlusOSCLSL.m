%%This script will control a neato with 2 models one measuring ERP and one
%%measuring oscillations

closedCounter = 50;

bci_stream_name = 'Res'
bci_stream_name2 = 'Res2'
lib = lsl_loadlib();
disp('Resolving a BCI stream...');
result = {}
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name,1,1); end
inlet = lsl_inlet(result{1});
disp('Now receiving data...');

disp('Resolving a BCI stream 2...');
result = {}
while isempty(result)
    result = lsl_resolve_byprop(lib,'name',bci_stream_name2,1,1); end
inlet2 = lsl_inlet(result{1});
disp('Now receiving data 2...');






moving = 0;
OSCCounter = 0;
while 1
   if ~moving
       %pull sample from ERP
       %if sure there was a close eyes
       %set moving
       [data,timestamp] = inlet.pull_sample(0);
       if timestamp && data > 1.95
          disp('CLOSED ERP')
          moving = ~moving;
           
       end
       
       %else pull sample from OSC
       %if sure for an extended time
       %set moving
       
       [data,timestamp] = inlet2.pull_sample(0);
       if timestamp && data > 1.95
          OSCCounter = OSCCounter +1;
          if OSCCounter>closedCounter
              disp('CLOSED OSC')
              OSCCounter = 0;
              moving = ~moving;
          end
       else
           OSCCounter = 0;
           
       end
       
   else%is moving
       %pull sample from ERP
       %if slightly sure there was open eyes
       %stop moving
       [data,timestamp] = inlet.pull_sample(0);
       if timestamp && data < 1.05
          disp('OPEN ERP')
          moving = ~moving;
           
       end
       
       %else pull sample from OSC
       %if sure for an extended time
       %set moving
       
       [data,timestamp] = inlet2.pull_sample(0);
       if timestamp && data < 1.2
          OSCCounter = OSCCounter +1;
          if OSCCounter>closedCounter
              disp('OPEN OSC')
              OSCCounter = 0;
              moving = ~moving;
          end
       else
           OSCCounter = 0;
           
       end
       
   end
   
   %
    
    pause(.01)
end