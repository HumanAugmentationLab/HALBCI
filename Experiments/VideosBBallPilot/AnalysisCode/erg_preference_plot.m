% Load Responses:
% Conds x [MD BN LO FE OP IF CV RM GR    JR AI QP LT HL DC VM]

full_pref = [1 1 1 1 2 1 1 1 1    2 1 1 1.2 1 1 1];
strong_pref = [1 1 2.5 3.6 2 1 2.5 1.5 1    3 3 2 2.5 3 3 2];
med_pref = [1 1 3.2 4.2 3 5 3.5 2 2    4 4 4 3.2 4 4 3];
weak_pref = [3 2 4.5 4.7 5 5 5 2.5 3   5 4 5 4.2 5 5 4];
opac = [full_pref; strong_pref; med_pref; weak_pref];

% missing GR all
big_strong_pref = [1 2 3.2 3.9 3 4 2 1 1    4 2 2 4.4 5 2 3];
med_strong_pref = [1 1 1 1.4 1 1 1 1.5 1    1 1 1 1 1 3 1];
small_strong_pref = [2 2 3.8 4.6 5 4 4 4 2    3 3.5 4 3 3 4.5 5];
strong = [big_strong_pref; med_strong_pref; small_strong_pref];

% missing IF ... DC med copy DC strong
big_med_pref = [2 2 3 3.5 3       3     3 4 1     4 5 2 4.3 3 2 4];
med_med_pref = [1 1 1 2 1         1    1 1 1      1 1 1 1.7 1 3 1.5];
small_med_pref = [2 1 4.2 4.6 5   5    4.5 3 3    3 3 4 3 5 4.5 5];
med = [big_med_pref; med_med_pref; small_med_pref];

checksize = (strong + med)/2;


% 3 cond x 9 subj

opac_mean = mean(opac, 2);
opac_stderror = 1.96* std(opac, 0, 2) / sqrt( length(opac) );

checksize_mean = mean(checksize, 2);
checksize_stderror = 1.96* std(checksize, 0, 2) / sqrt( length(strong) + length(med) );
 
%% Plot bar for each experiment
fs = 16; lw = 2;

figure; bar( opac_mean ); hold on;
er = errorbar(1:length(opac_mean), opac_mean, opac_stderror, 'LineWidth', lw);
er.Color = [0 0 0]; er.LineStyle = 'none'; er.LineWidth = lw;
title("Opacity Preferences");  ylim([0 5])
xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
xticklabels( ["Fully Opaque", "Strong Opacity", "Medium Opacity", "Weak Opacity"])
set(gca,'FontSize',fs)

figure; bar( checksize_mean ); hold on
er = errorbar(1:length(checksize_mean), checksize_mean, checksize_stderror, 'LineWidth', lw);
er.Color = [0 0 0]; er.LineStyle = 'none';  er.LineWidth = lw;
title("Check Size Preferences");  ylim([0 5])
xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
xticklabels( ["Big Checker", "Medium Checker", "Small Checker"])
set(gca,'FontSize',fs)


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

[h_bm, p_bm, ci_bm, stats_bm] = ttest(checksize(1,:), checksize(2,:));
[h_bs, p_bs, ci_bs, stats_bs]  = ttest(checksize(1,:), checksize(3,:));
[h_ms, p_ms, ci_ms, stats_ms]  = ttest(checksize(2,:), checksize(3,:));

[~,~,~,padj] = fdr_bh([p_bm p_bs p_ms])

%% Run ANOVA and t tests on opacity
% [p,tbl,stats] = anova1(opac');
[h_fs, p_fs, ci_fs, stats_fs]  = ttest(opac(1,:), opac(2,:));
[h_fm, p_fm, ci_fm, stats_fm]  = ttest(opac(1,:), opac(3,:));
[h_fw, p_fw, ci_fw, stats_fw]  = ttest(opac(1,:), opac(4,:));
[h_sm, p_sm, ci_sm, stats_sm]  = ttest(opac(2,:), opac(3,:));
[h_sw, p_sw, ci_sw, stats_sw]  = ttest(opac(2,:), opac(4,:));
[h_mw, p_mw, ci_mw, stats_mw]  = ttest(opac(3,:), opac(4,:));

[~,~,~,padj] = fdr_bh([p_fs p_fm p_fw p_sm p_sw p_mw])