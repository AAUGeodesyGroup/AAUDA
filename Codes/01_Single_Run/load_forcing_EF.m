function [prcp, dswrf, tmin, tmax, WINDSPEED, ALBEDO, AIRPRESS]=load_forcing_EF(date,config)

% loads in the dynamic forcing data required.

%% Get inputs from climatologies
% ALBEDO
% load(config.clims.albedo);
load([config.dirs.clims config.clims.albedo]);
alb=albedo_clim(:,:,date.mm);
ALBEDO=alb(config.selecti)';
clear alb albedo albedo_clim
% WINDSPEED
load([config.dirs.clims config.clims.wind]);
wind=Windspeed50m_clim(:,:,date.mm);
WINDSPEED=wind(config.selecti)';
clear wind datatmp

% AIRPRESS
clim=[];
load([config.dirs.clims config.clims.airpress]);
press=clim(:,:,date.mm);
AIRPRESS=press(config.selecti)';
clear press clim

%% load dynamic forcing data.

varn={'dswrf';'prcp';'tmax';'tmin';};
for vari=1:numel(varn)
    [folder,fn_] = setFileName(config.dirs.data.(varn{vari})); % Account for the possibility of the user defining a different filename structure.
    fname = sprintf(['%s%s/' fn_],config.dirs.data.directory,folder,varn{vari},date.yy,date.mm);
    load(fname);
    tmpdat = reshape(datatmp,size(datatmp,1)*size(datatmp,2),size(datatmp,3)); % Squeeze spatial dimensions from 2 to 1
    eval(sprintf("%s = tmpdat(config.selecti,:)';",varn{vari}))
end
end
%=========EoF=========

function [folder,fn_] = setFileName(fn)
    dir_name = fn;
    if numel(dir_name)>4
        if string(dir_name(end-3:end))==".mat" % If the filename is already set, retrieve
            [folder,fn,ext] = fileparts(dir_name);
            fn_ = [fn ext];
        else
            fn_ = 'ERA5_%s_daily_%d-%02d.mat';
            folder = dir_name;
        end
    else % Otherwise set default
        fn_ = 'ERA5_%s_daily_%d-%02d.mat';
        folder = dir_name;
    end
end
