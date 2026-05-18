function F01_single_extract_state_results_W3RA(config)
% Extract results from W3RA states.

%% Load previous files.
% Load necessary files
load(config.input.pars);

% Folder containing the states.
dir_name = [config.states.directory '/'];

% Dates to extract.
ys = year(datetime(config.run.fromdate));
ms = month(datetime(config.run.fromdate));
ds = day(datetime(config.run.fromdate));
ye = year(datetime(config.run.todate));
me = month(datetime(config.run.todate));
de = day(datetime(config.run.todate));
time = datetime(ys,ms,ds):datetime(ye,me,de);
nt = numel(time);

%% Initialize vectors.
% Retrieve state field names and Initialize vectors for memory allocation.
load(sprintf('%sstate_%04d%02d%02d.mat',dir_name,year(time(1)),month(time(1)),day(time(1))));
fields = fieldnames(state); % Retrieve filed names
fields(fields=="LAI") = []; fields(fields=="EVI") = []; % Omit variables that are not of interest.
% Initialize individual compartments:
for vv = 1:numel(fields)
    eval(sprintf("%s = zeros(%d,%d);",fields{vv},size(state.S0,2),nt)); % Save variable in vector.
end
% Initialize TWS:
TWS = zeros(size(state.S0,2),nt);

%% Retrieve variable time series.
for i=1:nt
    % Load file.
    load(sprintf('%sstate_%04d%02d%02d.mat',dir_name,year(time(i)),month(time(i)),day(time(i))));
    
    % Retrieve variables:
    for vv = 1:numel(fields)
        eval(sprintf("var = state.%s;",fields{vv})); % Retrieve variable
        if size(var,1)==2
            var = sum(var.*par.Fhru,1); % Combine HRUs
        end
        if fields(vv)=="Mleaf"
            var = var*4; % Multiply Mleaf by 4
        end
        eval(sprintf("%s(:,i) = var;",fields{vv})); % Save variable in vector.
        TWS(:,i) = TWS(:,i) + var'; % Add variable to TWS.
    end
end

%% Save.

% Save whole grid file.
dir_out = config.summary.directory;
if config.summary.ExtractEnsemble_Averaged==1
    disp('CAUTION! The file extraction for single runs extract whole-area 2D maps! (And should be perfected in general...)');
    % Save TWS
    save(sprintf("%s/COMP_Single_%d_%d.mat",dir_out,ys,ye),'time','TWS'); 
    % Append individual compartments:
    for vv = 1:numel(fields)
        fname = sprintf('%s/COMP_Single_%d_%d.mat',dir_out,ys,ye);
        eval(sprintf("save('%s','%s','-append');",fname,fields{vv}));
    end
end

% Save subbasin-average file.
if config.summary.ExtractEnsemble_Subbasin_Averaged==1
    if not(isfield(config, 'DAOptions'))
        warning('Without DA options, there is no log-in, and therefore there is no information to average over subbasin. Skipping this step. Please, add log_in directory to configuration to get subbasin averages.');
    else
        l = load(config.DAOptions.OtherData.log_in); % Load log_in-s for subbasin averaging.
        fields_log_in = fieldnames(l); fields_log_in(fields_log_in=="log_in") = [];
        % Save TWS:
        for bb = 1:numel(fields_log_in)
            eval(sprintf("TWS_subb(bb,:) = mean(TWS(l.log_in_%d,:),1,'omitnan');",bb));
        end
        save(sprintf("%s/COMP_Single_%d_%d_subb.mat",dir_out,ys,ye),'time','TWS_subb'); 
        % Append individual compartments:
        for vv = 1:numel(fields)
            for bb = 1:numel(fields_log_in)
                eval(sprintf("%s_subb(bb,:) = mean(%s(l.log_in_%d,:),1,'omitnan');",fields{vv},fields{vv},bb));
            end
            fname = sprintf('%s/COMP_Single_%d_%d_subb.mat',dir_out,ys,ye);
            eval(sprintf("save('%s','%s_subb','-append');",fname,fields{vv})); % Save individual variables.
        end
    end
end

% Grid-wise extraction.
if not(isempty(config.summary.ExtractEnsemble_Averaged_Grid_wise))
    warning('Grid-wise result extraction is not yet automatically implemented.')
end

end
