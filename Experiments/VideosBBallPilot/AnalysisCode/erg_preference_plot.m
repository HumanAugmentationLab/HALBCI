% Responses:
% Conds x [MD BN LO FE OP IF CV RM GR]
full_pref = [1 1 1 1 2 1 1 1 1];
strong_pref = [1 1 2.5 3.6 2 1 2.5 1.5 1];
med_pref = [1 1 3.2 4.2 3 5 3.5 2 2];
weak_pref = [3 2 4.5 4.7 5 5 5 2.5 3];
opac = [full_pref; strong_pref; med_pref; weak_pref];

% missing GR all
big_strong_pref = [1 2 3.2 3.9 3 4 2 1 1];
med_strong_pref = [1 1 1 1.4 1 1 1 1.5 1];
small_strong_pref = [2 2 3.8 4.6 5 4 4 4 2];
strong = [big_strong_pref; med_strong_pref; small_strong_pref];

% missing IF
big_med_pref = [2 2 3 3.5 3       3     3 4 1];
med_med_pref = [1 1 1 2 1         1    1 1 1];
small_med_pref = [2 1 4.2 4.6 5   5    4.5 3 3];
med = [big_med_pref; med_med_pref; small_med_pref];

checksize = (strong + med)/2;


% 3 cond x 9 subj

opac_mean = mean(opac, 2);
opac_stderror = std(opac, 0, 2) / sqrt( length(opac) );

checksize_mean = mean(checksize, 2);
checksize_stderror = std(checksize, 0, 2) / sqrt( length(strong) + length(med) );
 
%% Plot bar for each experiment
figure; bar( opac_mean ); hold on;
er = errorbar(1:length(opac_mean), opac_mean, opac_stderror, 'LineWidth', 2);
er.Color = [0 0 0]; er.LineStyle = 'none'; er.LineWidth = 1;
title("Opacity Preferences");  ylim([0 5])
xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
xticklabels( ["Fully Opaque", "Strong Opacity", "Medium Opacity", "Weak Opacity"])

figure; bar( checksize_mean ); hold on
er = errorbar(1:length(checksize_mean), checksize_mean, checksize_stderror, 'LineWidth', 2);
er.Color = [0 0 0]; er.LineStyle = 'none';  er.LineWidth = 1;
title("Check Size Preferences");  ylim([0 5])
xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
xticklabels( ["Big Check", "Medium Check", "Small Check"])

%% Run linear regression on opacity
alpha_values = [255 125 85 50]';
p = polyfit(alpha_values, opac_mean, 1);
f = polyval(p, alpha_values);
[r2, rmse] = rsquare(opac_mean,f);

figure; plot(alpha_values,opac_mean,'k*');
hold on; plot(alpha_values,f,'r-');
title(strcat(['R2 = ' num2str(r2) '; RMSE = ' num2str(rmse)]))
legend({'Average Ergonomics Rating', 'Linear Regression'})

%% Run ANOVA and t tests on check size
[p,tbl,stats] = anova1(checksize');

[h_bm, p_bm, ci_bm, stats_bm] = ttest2(checksize(1,:), checksize(2,:));
[h_bs, p_bs, ci_bs, stats_bs]  = ttest2(checksize(1,:), checksize(3,:));
[h_ms, p_ms, ci_ms, stats_ms]  = ttest2(checksize(2,:), checksize(3,:));