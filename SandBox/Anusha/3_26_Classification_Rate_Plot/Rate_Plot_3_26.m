% Create plots of classification rates based on pilot data for 
% Only checkerboard, strong checkerboard, weak checkerboards...

% Uses a matrix of data classification rates where each
% approach is a column vector and each video stimulus configuration 
% (checkerboard, strong, weak) is a row vector. 

training = subplot(2, 1,1);
plot (1, training_rates(1, :), '*')
hold on;
plot (2, training_rates(2, :), '*')
plot (3, training_rates(3, :), '*')
% For loop was being problematic, so here's the next best thing.
plot([1, 2, 3], training_rates(:, 1));
plot([1, 2, 3], training_rates(:, 2));
plot([1, 2, 3], training_rates(:, 3));
plot([1, 2, 3], training_rates(:, 4));
plot([1, 2, 3], training_rates(:, 5));

xlim([0.5, 3.5]);
ylim([0, 100]);
xticks(training,[1 2 3])
xticklabels(training,{'Checkerboard','Strong Checkerboard','Weak Checkerboard'})

title("Training Data Classification Rate");
legend("Bandpower (6 Hz)", "Bandpower (15 Hz", "Spectral CSP", "Spectral Means (lda)", "Spectral Means (logreg)");
legend('Location', 'southeast');
legend('boxoff');

testing = subplot(2, 1, 2);
plot (1, testing_rates(1, :), '*')
hold on;

plot (2, testing_rates(2, :), '*')
plot (3, testing_rates(3, :), '*')

plot([1, 2, 3], testing_rates(:, 1));
plot([1, 2, 3], testing_rates(:, 2));
plot([1, 2, 3], testing_rates(:, 3));
plot([1, 2, 3], testing_rates(:, 4));
plot([1, 2, 3], testing_rates(:, 5));


xlim([0.5, 3.5]);
ylim([0, 100]);
xticks(testing,[1 2 3])
xticklabels(testing,{'Checkerboard','Strong Video','Weak Video'})

title("Test Data Classification Rate");
legend("6 Hz Bandpower", "15 Hz Bandpower", "Spectral CSP", "Spectral Means - lda", "Spectral Means - logreg");
legend('Location', 'southeast');
legend('boxoff');