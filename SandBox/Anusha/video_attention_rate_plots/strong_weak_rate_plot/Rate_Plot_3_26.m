load('rates.mat')
% Create plots of classification rates based on pilot data for 
% Only checkerboard, strong checkerboard, weak checkerboards...

% Uses a matrix of data classification rates where each
% approach is a column vector and each video stimulus configuration 
% is a row vector. 
load('rates.mat');
training = subplot(2, 1,1);

plot([1, 2, 3], training_rates(:, 1), '*','Color', 'r');
hold on;
plot([1, 2, 3], training_rates(:, 2), '*', 'Color', 'b');
plot([1, 2, 3], training_rates(:, 3), '*', 'Color', 'c');
plot([1, 2, 3], training_rates(:, 4), '*', 'Color', 'm');
plot([1, 2, 3], training_rates(:, 5), '*', 'Color', 'k');

line([1,2,3], training_rates(:, 1), 'Color', 'r')
line([1,2,3], training_rates(:, 2), 'Color', 'b');
line([1,2,3], training_rates(:, 3), 'Color', 'c');
line([1,2,3], training_rates(:, 4), 'Color', 'm');
line([1,2,3], training_rates(:, 5), 'Color', 'k');

xlim([0.5, 3.5]);
ylim([50, 100]);
xticks(training,[1 2 3])
xticklabels(training,{'Checkerboard','Strong Video','Weak Video'})

title("Test Data Classification Rate");
legend("6 Hz Bandpower", "15 Hz Bandpower", "Spectral CSP", "Spectral Means - lda", "Spectral Means - logreg");
legend('Location', 'southeast');
legend('boxoff');


testing = subplot(2, 1, 2);
plot([1, 2, 3], testing_rates(:, 1), '*','Color', 'r');
hold on;
plot([1, 2, 3], testing_rates(:, 2), '*', 'Color', 'b');
plot([1, 2, 3], testing_rates(:, 3), '*', 'Color', 'c');
plot([1, 2, 3], testing_rates(:, 4), '*', 'Color', 'm');
plot([1, 2, 3], testing_rates(:, 5), '*', 'Color', 'k');

line([1,2,3], testing_rates(:, 1), 'Color', 'r')
line([1,2,3], testing_rates(:, 2), 'Color', 'b');
line([1,2,3], testing_rates(:, 3), 'Color', 'c');
line([1,2,3], testing_rates(:, 4), 'Color', 'm');
line([1,2,3], testing_rates(:, 5), 'Color', 'k');

xlim([0.5, 3.5]);
ylim([50, 100]);
xticks(testing,[1 2 3])
xticklabels(testing,{'Checkerboard','Strong Video','Weak Video'})

title("Test Data Classification Rate");
legend("6 Hz Bandpower", "15 Hz Bandpower", "Spectral CSP", "Spectral Means - lda", "Spectral Means - logreg");
legend('Location', 'southeast');
legend('boxoff');
