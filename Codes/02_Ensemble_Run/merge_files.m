dir_list = dir("COMP_OL*");
% Initialize
load(dir_list(1).name);
% Iterate
for i=2:length(dir_list)
    l = load(dir_list(i).name);
    TWS_subb_ens = [TWS_subb_ens l.TWS_subb_ens];
    S0_subb_ens = [S0_subb_ens l.S0_subb_ens];
    Sr_subb_ens = [Sr_subb_ens l.Sr_subb_ens];
    Ss_subb_ens = [Ss_subb_ens l.Ss_subb_ens];
    Sd_subb_ens = [Sd_subb_ens l.Sd_subb_ens];
    Sg_subb_ens = [Sg_subb_ens l.Sg_subb_ens];
    Mleaf_subb_ens = [Mleaf_subb_ens l.Mleaf_subb_ens];
    DrySnow_subb_ens = [DrySnow_subb_ens l.DrySnow_subb_ens];
    FreeWater_subb_ens = [FreeWater_subb_ens l.FreeWater_subb_ens];
    time = [time l.time];
end
% Double check that time is continuous and increasing
if not(all((time(2:end)-time(1:end-1))==days(1)))
    disp('Error. Time vector is not continuous. Re-check files please.')
else
% Save
    save('COMP_OL_2003_2015_subb_ens.mat','time','TWS_subb_ens','Sr_subb_ens','S0_subb_ens','Ss_subb_ens','Sd_subb_ens','Sg_subb_ens','Mleaf_subb_ens','DrySnow_subb_ens','FreeWater_subb_ens');
end