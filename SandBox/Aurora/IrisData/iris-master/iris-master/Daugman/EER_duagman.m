
% calculation of fnmr and fmr
% same represents same subject distance result£¬diff represents different subject distance result
% Author: Qingbao Guo
% Gjovik University College, GUC, Norway

clear all;
load 'HD_same.mat';
load 'HD_diff.mat';

x = 0:0.01:1;
fmr = zeros(size(x));
fnmr = zeros(size(x));

for k=1:length(x)
    a1 = HD_diff(1,:) <= x(k); %takes each number in HD_diff and sees if it 
    %is less or equal to the value of x, puts a 0 if not, puts a 1 if yes
    a2 = sum(a1); %adds up all the times that a1 was a 'yes'
    fmr(k) =  a2 / size(HD_diff,2); % divides the number of times it was
    %a 'yes' by the total number of times in HD_diff
    b1 = HD_same(1,:) > x(k); %takes each number in HD_same and sees if it 
    % is greater than the value of x, if yes puts a 1, if no puts a 0
    b2 = sum(b1); %sums up the times b1 was 'yes'
    fnmr(k) = b2 / size(HD_same,2); %divides the number of 'yes's by the 
    % totall number in HD_same
end

%%% EER %%%
EER = 1;
for i = 1:length(x)-1
        if fmr(i) == fnmr(i)
            EER = fmr(i);
        elseif sign(fmr(i)-fnmr(i))*sign(fmr(i+1)-fnmr(i+1)) == -1
            EER = (fmr(i)+fmr(i+1)+fnmr(i)+fnmr(i+1))/4;
            break;
        else
            EER = 1;            
        end
end
% fmr
% fnmr
figure
plot(fmr,fnmr,'.-b')
EER