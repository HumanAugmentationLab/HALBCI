% Responses:
% Conds x [MD BN LO FE OP IF CV RM GR]
full_pref = [1 1 1 1 2 1 1 1 1];
strong_pref = [1 1 2.5 3.6 2 1 2.5 1.5 1];
med_pref = [1 1 3.2 4.2 3 5 3.5 2 2];
weak_pref = [3 2 4.5 4.7 5 5 5 2.5 3];
opac = [full_pref; strong_pref; med_pref; weak_pref];

% missing GR all
big_strong_pref = [1 2 3.2 3.9 3 4 2 1];
med_strong_pref = [1 1 1 1.4 1 1 1 1.5];
small_strong_pref = [2 2 3.8 4.6 5 4 4 4];
strong = [big_strong_pref; med_strong_pref; small_strong_pref];

% missing IF
big_med_pref = [2 2 3 3.5 3    3 4 1];
med_med_pref = [1 1 1 2 1      1 1 1];
small_med_pref = [2 1 4.2 4.6 5  4.5 3 3];
med = [big_med_pref; med_med_pref; small_med_pref];

% Plot bar for each experiment
figure; bar( mean(opac, 2) )
title("Opacity Preferences");  ylim([0 5])
xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
xticklabels( ["Fully Opaque", "Strong Opacity", "Medium Opacity", "Weak Opacity"])

figure; bar( mean([strong med], 2) )
title("Check Size Preferences");  ylim([0 5])
xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
xticklabels( ["Big Check", "Medium Check", "Small Check"])

% figure; bar( mean(strong, 2) )
% title("Check Size Preferences: Strong Opacity");  ylim([0 5])
% xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
% xticklabels( ["Big Check", "Medium Check", "Small Check"])
% 
% figure; bar( mean(med, 2) )
% title("Check Size Preferences: Medium Opacity");  ylim([0 5])
% xlabel("Conditions"), ylabel("Preference: 1 - hate, 5 - do not mind")
% xticklabels( ["Big Check", "Medium Check", "Small Check"])