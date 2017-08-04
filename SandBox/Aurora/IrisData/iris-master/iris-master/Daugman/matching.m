% Getting Hamming Distance for Intra-class and Inter-class
% Author: Qingbao Guo
% Gjovik University College, GUC, Norway

clear all;
load 'template.mat';
load 'mask.mat';

tic
same_index = 1;
diff_index = 1;

folders = 108; %the # of people
subfolders = 2; %the # of sub-folders within the people
pics1 = 3; %the # of pictures in sub-folder 1
pics2 = 4; %the # of pictures in sub-folder 2

%intra-class
for i=1:folders %iterating through # of people

but1 = (pics1 + pics2) - 1;
all = (pics1 + pics2);
for j=1:but1 %iterating through every picture but 1
    
   for k=1:but1 %
       
    if (j+k)>all;       
        break;
    end
    
    template1 = reshape(template(:,all*(i-1)+j),20,480);
    mask1 = reshape(mask(:,all*(i-1)+j),20,480);

    template2 = reshape(template(:,all*(i-1)+k+j),20,480);
    mask2= reshape(mask(:,all*(i-1)+k+j),20,480);
    
    HD_same(1,same_index) = gethammingdistance(template1, mask1, template2, mask2, 1);
   
    same_index= same_index +1;
    
   end
end
end


% inter-class
allim = (pics1 + pics2) * folders;
minus1 = folders - 1;
 for i=1:(folders - 1)

    for j=1:all
    
        for k=1:((pics1 + pics2) * minus1)
        
        if (all*(i-1)+k+all)>allim
            break;
        end
            
        template1 = reshape(template(:,all*(i-1)+j),20,480);
        mask1 = reshape(mask(:,all*(i-1)+j),20,480);

        template2 = reshape(template(:,all*(i-1)+k+all),20,480);
        mask2= reshape(mask(:,all*(i-1)+k+all),20,480);

        HD_diff(1,diff_index) = gethammingdistance(template1, mask1, template2, mask2, 1);

        diff_index= diff_index +1;
                
        end
    end
end








save HD_diff.mat HD_diff;
HD_diff

save HD_same.mat HD_same
HD_same
toc