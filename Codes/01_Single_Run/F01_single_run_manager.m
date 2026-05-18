function F01_single_run_manager(config)
% Manage single run and result extraction.

% Model run:
MAIN_W3RA(config);

% Final result extraction:
out1 = config.summary.ExtractEnsemble_Averaged;
out2 = config.summary.ExtractEnsemble_Subbasin_Averaged;
out3 = not(isempty(config.summary.ExtractEnsemble_Averaged_Grid_wise));
if out1+out2+out3~=0
    F01_single_extract_state_results_W3RA(config);
end
