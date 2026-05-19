function [fn_list] = F02_ensemble_extract_state_results_W3RA(config)
% Extract results from W3RA states and average over ensemble.

%% Load previous files.
% Load necessary files
par_fname = strrep(config.input.pars,'%n',num2str(1));
load(par_fname); % Only the HRU parameter will be used, which is not perturbed.

% Empty list for saved file directory filenames
fn_list = string.empty();

% Dates to extract.
ys = year(datetime(config.run.fromdate));
ms = month(datetime(config.run.fromdate));
ds = day(datetime(config.run.fromdate));
ye = year(datetime(config.run.todate));
me = month(datetime(config.run.todate));
de = day(datetime(config.run.todate));
time = datetime(ys,ms,ds):datetime(ye,me,de);
nt = numel(time);

% Number of ensemble members
nE = config.ensembleOptions.nE;

% Get keyword for summary files
if isfield(config.summary,'nameKeyword')
    kw = char(config.summary.nameKeyword);
else
    kw = 'OL';
end

% Log_in and Horizontal averaging matrix (B)
if config.summary.ExtractEnsemble_Subbasin_Averaged==1
    l = load(config.DAOptions.OtherData.log_in); % Load log_in to go from whole grid to xMinus grid.
    log_in = l.log_in;
end

if isfield(config.DAOptions.OtherData,'DesignMatrix') % Unisensor DA
    B_fn = strrep(config.DAOptions.OtherData.DesignMatrix,'A_DAonly','B_DAonly');
    l2 = load(B_fn); B = l2.B; % Load matrix B (horizontal averaging from xMinus to observations).
else % Multisensor DA
    B = [];
    fln = fieldnames(config.DAOptions.OtherData);
    for i=1:length(fln)
        fl = fln{i};
        if contains(fl,'DesignMatrix')
            B_fn = strrep(config.DAOptions.OtherData.(fl),'A_DAonly','B_DAonly');
            l2 = load(B_fn); B = [B; l2.B]; % Load matrix B (horizontal averaging from xMinus to observations).
        end
    end
end

%% Initialize vectors.
% Folder containing the states.
dir_name_1 = strrep(config.states.directory,'%n',num2str(1));
% Retrieve state field names and Initialize vectors for memory allocation.
load(sprintf('%sstate_%04d%02d%02d.mat',dir_name_1,year(time(1)),month(time(1)),day(time(1))));
fields = fieldnames(state); % Retrieve filed names
fields(fields=="LAI") = []; fields(fields=="EVI") = []; % Omit variables that are not of interest.
% Initialize individual compartments:
for vv = 1:numel(fields)
    eval(sprintf("%s_ens = zeros(%d,%d);",fields{vv},size(state.S0,2),nt)); % Save variable in vector.
end
% Initialize TWS:
TWS_ens = zeros(size(state.S0,2),nt);

%% Retrieve variable time series.
for nn = 1:nE
    % Ensemble member directory name:
    dir_name = strrep(config.states.directory,'%n',num2str(nn));
    
    for tt=1:nt        
        % Load file.
        load(sprintf('%sstate_%04d%02d%02d.mat',dir_name,year(time(tt)),month(time(tt)),day(time(tt))));

        % Retrieve variables:
        for vv = 1:numel(fields)
            eval(sprintf("var = state.%s;",fields{vv})); % Retrieve variable
            if size(var,1)==2
                var = sum(var.*par.Fhru,1); % Combine HRUs
            end
            if fields(vv)=="Mleaf"
                var = var*4; % Multiply Mleaf by 4
            end
            eval(sprintf("%s_ens(:,tt) = %s_ens(:,tt) + var'/nE;",fields{vv},fields{vv})); % Save variable in vector.
            TWS_ens(:,tt) = TWS_ens(:,tt) + var'/nE; % Add variable to TWS.
        end
    end
end

%% Save.

% Save subbasin(tile)-average file.
dir_out = config.summary.directory;
if config.summary.ExtractEnsemble_Subbasin_Averaged==1
    if not(isfield(config, 'DAOptions'))
        warning('Without DA options, there is no log-in, and therefore there is no information to average over subbasin. Skipping this step. Please, add log_in directory to configuration to get subbasin averages.');
    else
        % Save TWS:
        TWS_subb_ens = B*TWS_ens(log_in,:);
        fname = sprintf('%s/COMP_%s_%d_%d_subb_ens.mat',dir_out,kw,ys,ye);
        save(fname,'time','TWS_subb_ens'); 
        % Append individual compartments:
        for vv = 1:numel(fields)
            eval(sprintf("%s_subb_ens = B*%s_ens(log_in,:);",fields{vv},fields{vv}));
            eval(sprintf("save('%s','%s_subb_ens','-append');",fname,fields{vv})); % Save individual variables.
        end
        fn_list(end+1) = string(fname);
    end
end

% Save whole grid file.
if config.summary.ExtractEnsemble_Averaged==1
    if not(isfield(config, 'DAOptions'))
        warning('Without DA options, there is no log-in, and therefore there is no information to average over subbasin. Skipping this step. Please, add log_in directory to configuration to get subbasin averages.');
    else
        % Save TWS
        TWS_ens_grid = TWS_ens; % Temporarily save variable with another name
        TWS_ens = TWS_ens_grid;
        fname = sprintf("%s/COMP_%s_%d_%d_ens.mat",dir_out,kw,ys,ye);
        save(fname,'time','TWS_ens');
        TWS_ens = TWS_ens_grid; % Recover variable name
        % Append individual compartments:
        for vv = 1:numel(fields)
            eval(sprintf("%s_ens_grid = %s_ens;",fields{vv},fields{vv})); % Temporarily save variable with another name
            eval(sprintf("%s_ens = %s_ens_grid;",fields{vv},fields{vv}));
            fname = sprintf('%s/COMP_%s_%d_%d_ens.mat',dir_out,kw,ys,ye);
            eval(sprintf("save('%s','%s_ens','-append');",fname,fields{vv}));
            eval(sprintf("%s_ens = %s_ens_grid;",fields{vv},fields{vv})); % Recover variable name
        end
        fn_list(end+1) = string(fname);
    end
end


% Grid-wise extraction.
if not(isempty(config.summary.ExtractEnsemble_Averaged_Grid_wise))
    % Load latitude and longitude of grid and landmask
    fn_landmask = config.input.landmask;
    l2 = load(fn_landmask);
    path = fileparts(fn_landmask);
    l3 = load(sprintf('%s/grid_latlon_10k.mat',path));
    % Retrieve grid information
    grid_pts = config.summary.ExtractEnsemble_Averaged_Grid_wise;
    grid_names = fieldnames(grid_pts);
    n_gridpt = length(grid_names);
    for i=1:n_gridpt
        % Find index for gridpoint
        id_lat = round(l3.LAT(logical(l2.landmask_10k)),1)==round(grid_pts.(grid_names{i})(1),1);
        id_lon = round(l3.LON(logical(l2.landmask_10k)),1)==round(grid_pts.(grid_names{i})(2),1);
        id(i) = find(and(id_lat,id_lon));
    end
    % Save TWS
    TWS_grid_ens = TWS_ens(id,:);
    fname = sprintf("%s/COMP_%s_%d_%d_grid_ens.mat",dir_out,kw,ys,ye);
    save(fname,'time','TWS_grid_ens','grid_pts'); 
    % Append individual compartments:
    for vv = 1:numel(fields)
        eval(sprintf("%s_grid_ens = %s_ens(id,:);",fields{vv},fields{vv}));
        fname = sprintf('%s/COMP_%s_%d_%d_grid_ens.mat',dir_out,kw,ys,ye);
        eval(sprintf("save('%s','%s_grid_ens','-append');",fname,fields{vv}));
    end
    fn_list(end+1) = string(fname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% REPEAT PROCEDURE FOR RIVER ROUTING, IF AVAILABLE                         %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars *ens *subb_ens -except TWS_ens

if config.run.RR

    %% Load previous files.
    % Load necessary files (additional to the ones previously loaded)
    landmask_fname = config.input.landmask;
    l = load(landmask_fname);
    landmask_10k = logical(l.landmask_10k);

    %% Initialize vectors.
    Sriv_ens = zeros(sum(landmask_10k,'all'),size(TWS_ens,2));
    Q_ens = zeros(sum(landmask_10k,'all'),size(TWS_ens,2));

    %% Retrieve variable time series.
    for nn = 1:nE
        % Ensemble member directory name:
        dir_name_Sriv = strrep(config.states.routing,'%n',num2str(nn));
        dir_name_Q = strrep(config.output.directory,'%n',num2str(nn));

        for tt=1:nt        
            % Load file.
            load(sprintf('%s/Rstate_%04d%02d%02d.mat',dir_name_Sriv,year(time(tt)),month(time(tt)),day(time(tt))));
            load(sprintf('%s/Routed/Qriv_%04d%02d%02d.mat',dir_name_Q,year(time(tt)),month(time(tt)),day(time(tt))));

            % Retrieve river storage:
            Sriv = state.Sriv; Sriv(isnan(Sriv)) = 0;
            Qriv(isnan(Qriv)) = 0;
            lat_rout = 90:-0.5:-89.5; lon_rout = [0:0.5:180 -179.5:0.5:-0.5];

            % Get indexes for Ganges-Brahmaputra basin
            lat1 = 31.1; lat2 = 21.9; lon1 = 73.6; lon2 = 97.6; % Basin boundaries.
            idx_lat = and(lat2<=lat_rout,lat_rout<=lat1);
            idx_lon = and(lon1<=lon_rout,lon_rout<=lon2);
            lat_GBMP = lat_rout(idx_lat); lon_GBMP = lon_rout(idx_lon);
            % Get Sriv values for basin
            [idx_LON,idx_LAT] = meshgrid(idx_lon,idx_lat);
            Sriv_GBMP = Sriv(and(idx_LON,idx_LAT));
            Qriv_GBMP = Qriv(and(idx_LON,idx_LAT));
            % Define new grid (similar to model.)
            lat_new = lat1:-0.1:lat2; lon_new = lon1:0.1:lon2;
            % Interpolate values for new grid.
            [LON_GBMP,LAT_GBMP] = meshgrid(lon_GBMP,lat_GBMP);
            Sriv_GBMP = reshape(Sriv_GBMP,size(LON_GBMP));
            Qriv_GBMP = reshape(Qriv_GBMP,size(LON_GBMP));
            [LON_new,LAT_new] = meshgrid(lon_new,lat_new);
            Sriv_new = interp2(LON_GBMP,LAT_GBMP,Sriv_GBMP,LON_new,LAT_new,'mean',0); % Put value 0 outside of 0.5 degree grid range.
            Qriv_new = interp2(LON_GBMP,LAT_GBMP,Qriv_GBMP,LON_new,LAT_new,'mean',0); % Put value 0 outside of 0.5 degree grid range.            
            
            Sriv_ens(:,tt) = Sriv_ens(:,tt) + Sriv_new(landmask_10k)/nE; % Add variable to vector.
            Q_ens(:,tt) = Q_ens(:,tt) + Qriv_new(landmask_10k)/nE; % Add variable to vector.
            
        end
    end

    %% Save.

    % Save subbasin(tile)-average file.
    dir_out = config.summary.directory;
    if config.summary.ExtractEnsemble_Subbasin_Averaged==1
        if not(isfield(config, 'DAOptions'))
        else
            Sriv_subb_ens = B*Sriv_ens(log_in,:);
            Q_subb_ens = B*Q_ens(log_in,:);
            load(sprintf("%s/COMP_%s_%d_%d_subb_ens.mat",dir_out,kw,ys,ye),'TWS_subb_ens');
            TWS_subb_ens = TWS_subb_ens + Sriv_subb_ens;
            save(sprintf("%s/COMP_%s_%d_%d_subb_ens.mat",dir_out,kw,ys,ye),'TWS_subb_ens','Sriv_subb_ens','Q_subb_ens','-append'); 
        end
    end
    
    % Save whole grid file.
    if config.summary.ExtractEnsemble_Averaged==1
        if not(isfield(config, 'DAOptions'))
        else
            Sriv_ens_grid = Sriv_ens; % Temporarily save variable with another name
            Q_ens_grid = Q_ens; % Temporarily save variable with another name
            Sriv_ens = Sriv_ens_grid;
            Q_ens = Q_ens_grid;
            % Append River Storage to previously created file
            load(sprintf("%s/COMP_%s_%d_%d_ens.mat",dir_out,kw,ys,ye),'TWS_ens');
            TWS_ens = TWS_ens + Sriv_ens;
            save(sprintf("%s/COMP_%s_%d_%d_ens.mat",dir_out,kw,ys,ye),'TWS_ens','Sriv_ens','Q_ens','-append'); 
            Sriv_ens = Sriv_ens_grid; % Recover variable name
            Q_ens = Q_ens_grid; % Recover variable name
        end
    end

    % Grid-wise extraction.
    if not(isempty(config.summary.ExtractEnsemble_Averaged_Grid_wise))
        % Load latitude and longitude of grid and landmask
        fn_landmask = config.input.landmask;
        l2 = load(fn_landmask);
        path = fileparts(fn_landmask);
        l3 = load(sprintf('%s/grid_latlon_10k.mat',path));
        % Retrieve grid information
        grid_pts = config.summary.ExtractEnsemble_Averaged_Grid_wise;
        grid_names = fieldnames(grid_pts);
        n_gridpt = length(grid_names);
        for i=1:n_gridpt
            % Find index for gridpoint
            id_lat = round(l3.LAT(logical(l2.landmask_10k)),1)==round(grid_pts.(grid_names{i})(1),1);
            id_lon = round(l3.LON(logical(l2.landmask_10k)),1)==round(grid_pts.(grid_names{i})(2),1);
            id(i) = find(and(id_lat,id_lon));
        end
        Sriv_grid_ens = Sriv_ens(id,:);
        Q_grid_ens = Q_ens(id,:);
        % Append River Storage to previously created file
        load(sprintf("%s/COMP_%s_%d_%d_grid_ens.mat",dir_out,kw,ys,ye),'TWS_grid_ens');
        TWS_grid_ens = TWS_grid_ens + Sriv_grid_ens;
        save(sprintf("%s/COMP_%s_%d_%d_grid_ens.mat",dir_out,kw,ys,ye),'TWS_grid_ens','Sriv_grid_ens','Q_grid_ens','-append'); 
        
    end
end
