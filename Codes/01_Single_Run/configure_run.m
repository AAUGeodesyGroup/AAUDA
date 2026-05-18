function [config, par]=configure_run(config_general,start,stop)
% sets the environment etc

%% directory settings
dirs.routing =      config_general.states.routing;
dirs.states =       config_general.states.directory;
dirs.parameters =   config_general.input.pars;
dirs.clims =        config_general.input.clim.directory;
dirs.data =         config_general.input.forcing;
dirs.output =       config_general.output.directory;
%%

config.dirs = dirs;

config.clims.albedo =       config_general.input.clim.albedo;
config.clims.airpress =     config_general.input.clim.pres;
config.clims.wind =         config_general.input.clim.windspeed;

%% load parameter fields
load(config_general.input.pars); 

%% create landmask
load(config_general.input.landmask); 
config.selecti=find(landmask_10k==1); % cell IDs for land mask

%% start and end dates
config.run.start = start;
config.run.stop = stop;
end

