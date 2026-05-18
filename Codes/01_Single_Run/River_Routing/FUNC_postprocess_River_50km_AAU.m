function FUNC_postprocess_River_50km_AAU(config_ens)

%clc, clear all; dbstop if error;
%addpath(genpath('./'))
rootdir = './'; %% Main code
datadir = './init/states/';

%% Simulation time
start = [2002 01 01]; stop = [2007 12 31];

%% Routing
rout_flow_50km_NM(config_ens, start, stop)

end
