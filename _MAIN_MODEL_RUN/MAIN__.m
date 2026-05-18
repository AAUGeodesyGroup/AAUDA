% MAIN SCRIPT TO RUN MODEL.
% This script reads settings and runs the model according to them.

clc, clear all; dbstop if error;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% INPUT DATA %%%%%%%%%%%%%%%%%%%%%

 settings = '01_setting_single.json'; % Configuration file.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read JSON settings file.
fid = fopen(settings); 
if fid<0
    error('Caution! General configuration file %s cannot be found.',settings);
end
raw = fread(fid,inf); fclose(fid);

% Add all codes to path.
addpath(genpath('../Codes/'));

% Replace keywords in config file (if any)
raw_updated = F00_replace_keywords(raw);
config = jsondecode(char(raw_updated'));
config = F00_open_processing_receipt(raw_updated,config);

if config.run.DA == 1
    F03_DA_manager(config); % Perform DA.
elseif config.run.EnsRun == 1
    F02_ensemble_manager(config); % Perform n parallel model runs.
elseif config.run.EnsRun == 0
    F01_single_run_manager(config); % Perform a plain model run.        
end

F00_close_processing_receipt(config);
