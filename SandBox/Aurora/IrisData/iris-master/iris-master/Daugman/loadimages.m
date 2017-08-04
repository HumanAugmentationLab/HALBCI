% Loading images and create iris templates
% Author: Qingbao Guo
% Gjovik University College, GUC, Norway


clear all;
%load('data');

tic %CPU time begainning

path='C:\Users\abunten\Documents\Summer Research\CASIA Iris Image Database (version 1.0)\'; %please update to your directory
subpath='00'; %please update to your directory

folders = 108; %the # of people
subfolders = 2; %the # of sub-folders within the people
pics1 = 3; %the # of pictures in sub-folder 1
pics2 = 4; %the # of pictures in sub-folder 2

for i=1:folders
    
            if i>=10
                %path='CASIA Iris Image Database (version 1.0)\0';
                subpath='0';
            end
            
            if i>=100
                 %path='CASIA Iris Image Database (version 1.0)\';
                 subpath='';
            end
    
    for j=1:subfolders
        
        if j==1
        for k=1:pics1
            
        filesrcpath1 = strcat(path,subpath,num2str(i),'_',num2str(j),'_',num2str(k),'.jpg');     
        im = filesrcpath1;  
        [t,m] = createiristemplate(im);
        template(:,7*(i-1)+k)  = reshape(t,1,480*20);
        mask(:,7*(i-1)+k)  = reshape(m,1,480*20);
        save template.mat template;
        save mask.mat mask;
        end
        end
        
        if j==2
        for h=1:pics2
        filesrcpath2 = strcat(path,subpath,num2str(i),'_',num2str(j),'_',num2str(h),'.jpg');
        im = filesrcpath2;  
        [t,m] = createiristemplate(im);
        template(:,7*i-4+h)  = reshape(t,1,480*20);
        mask(:,7*i-4+h)  = reshape(m,1,480*20);
        save template.mat template;
        save mask.mat mask;
        end
        end
        
    end
end

toc %CPU time ending





 