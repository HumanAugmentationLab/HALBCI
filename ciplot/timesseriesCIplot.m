% This will generate confidence interval plot for time series data
% get this from the grd file?

close all
figure

time = -200:10:800; %Time in ms
signals = repmat(sin(time*pi),30,1);
signals = signals + rand(size(signals)); 

num_conditions = 2;
colors{1} = [.1 .3 .7];
colors{2} = [.7 .1 .2];
alphaval = .2;
leglabels = {'Duck', 'Goose'};

x= time;

for i = 1:num_conditions
    
    signals = repmat(3*sin(i* time*pi)+ .1*i,30,1);
    signals = signals + rand(size(signals)); 
    
    % set y to values
    y = signals;

    % Calcuate the confidence interval
    N = size(y,1);                                      % Number of ‘Experiments’ In Data Set
    yMean(i,:) = mean(y);                                    % Mean Of All Experiments At Each Value Of ‘x’
    ySEM = std(y)/sqrt(N);                              % Compute ‘Standard Error Of The Mean’ Of All Experiments At Each Value Of ‘x’
    CI95 = tinv([0.025 0.975], N-1);                    % Calculate 95% Probability Intervals Of t-Distribution
    yCI95 = bsxfun(@times, ySEM, CI95(:));              % Calculate 95% Confidence Intervals Of All Experiments At Each Value Of ‘x’

    % Plot these both first.
    % Plot the confidence interval and mean
    ciplot(yCI95(1,:)+yMean(i,:),yCI95(2,:)+yMean(i,:),x,colors{i},alphaval);
    hold on   
end
xline(0,'k--','LineWidth',2)

for i = 1:num_conditions
    plot(x,yMean(i,:),'Color',colors{i},'LineWidth',2);
end

set(gca,'FontSize',14)
legend(leglabels)
xlabel('Time (ms)');
ylabel('Signal (uV)');





