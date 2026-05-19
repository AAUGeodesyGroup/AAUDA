function F02_ensemble_manager(config)

nE = config.ensembleOptions.nE; % Number of ensemble members.

% Perform model run.
parfor i=1:nE
    config_ens = config;
    % Assign proper directories to each ensemble member:
    config_ens.input.pars                   = strrep(config_ens.input.pars,'%n',num2str(i));
    config_ens.input.forcing.directory      = strrep(config_ens.input.forcing.directory,'%n',num2str(i));
    config_ens.input.forcing.prcp           = strrep(config_ens.input.forcing.prcp,'%n',num2str(i));
    config_ens.input.forcing.dswrf          = strrep(config_ens.input.forcing.dswrf,'%n',num2str(i));               % Might not be necessary.
    config_ens.input.forcing.tmin           = strrep(config_ens.input.forcing.tmin,'%n',num2str(i));                % Might not be necessary.
    config_ens.input.forcing.tmax           = strrep(config_ens.input.forcing.tmax,'%n',num2str(i));                % Might not be necessary.
    config_ens.states.directory             = strrep(config_ens.states.directory,'%n',num2str(i));                  % Might not be necessary.
    config_ens.states.routing               = strrep(config_ens.states.routing,'%n',num2str(i));                    % Might not be necessary.
    config_ens.output.directory             = strrep(config_ens.output.directory,'%n',num2str(i));          % Might not be necessary.
    % Avoid result extraction, as this will be performed at the end to save
    % memory:
    config_ens.summary.ExtractEnsemble_Averaged = 0;            
    config_ens.summary.ExtractEnsemble_Subbasin_Averaged = 0;   
    config_ens.summary.ExtractEnsemble_Averaged_Grid_wise = [];

    % Run ensemble member.
    if ~strcmp(config.run.RR,"afterDA") % If this is a posteriori river run, don't run land water balance.
        F01_single_run_manager(config_ens); % (includes extraction of result for each ensemble member).
    end
    
    % Run routing for ensemble member.
    if config.run.RR
        FUNC_rout_flow_50km_NM(config_ens);
    end 
end

% Final result extraction:
out1 = config.summary.ExtractEnsemble_Averaged;
out2 = config.summary.ExtractEnsemble_Subbasin_Averaged;
out3 = not(isempty(config.summary.ExtractEnsemble_Averaged_Grid_wise));
if out1+out2+out3~=0
    F02_result_extraction_manager(config);
end



