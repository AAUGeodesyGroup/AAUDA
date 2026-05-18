function RUN_W3RA_EF(config_general, start, stop)

% (1) Configure run
[config, par]=configure_run(config_general,start,stop);

% (2) Initialise: retrieve warmed up model state
%%% be careful to use a correct initial value
%%% if you start assimilation from 2003, start few years before to have
%%% initial values
stated=datevec(datenum(config.run.start)-1); % The state of the day previous to the start day will be retrieved.
stateroot=num2str(stated(1)*1e4+stated(2)*1e2+stated(3)); % Generate datetime string.
 
load([config.dirs.states 'state_' stateroot '.mat']);

% (3) Run the model
dates=datevec(datenum(config.run.start):datenum(config.run.stop));
Ndays=size(dates,1);
%fprintf('\n About to run %0.0f days.',Ndays);

month_mem = 0; % For monthly forcing data loading.
tic
for di=1:Ndays
    date.yy=dates(di,1);
    date.mm=dates(di,2);
    date.dd=dates(di,3);
    date.doy=datenum([dates(di,:)])-datenum([date.yy-1 12 31]);
%    fprintf('\n Run for %i / %i / %i',date.dd,date.mm,date.yy);

    %Efficient (monthly) forcing data loading
    if month_mem~=date.mm %If we change month, load new data
        [PRECIP_m, RAD_m, TMIN_m, TMAX_m, WINDSPEED, ALBEDO, AIRPRESS]=load_forcing_EF(date,config);
        month_mem = date.mm;
    end
    PRECIP = PRECIP_m(date.dd,:); RAD = RAD_m(date.dd,:); TMIN = TMIN_m(date.dd,:); TMAX = TMAX_m(date.dd,:);
    
    % transform forcing data to the format required by the model
    [in]=input_adapter(PRECIP,RAD,TMIN,TMAX,AIRPRESS,WINDSPEED,ALBEDO,date,par);
    % run the model for this time step
    [state,out_tmp]=W3RA_timestep_model(in,state,par);
    % Save outputs of interest.
    out =[];
    for i = 1:length(config_general.output.vars)
        varname = config_general.output.vars{i};
        out.(varname)=out_tmp.(varname);
    end
    clear out1
    % save the updated state 
    fnroot=num2str(date.yy*1e4+date.mm*1e2+date.dd);
    save([config.dirs.states '/state_' fnroot '.mat'],'state')
%     [config.dirs.states 'state_' fnroot '.mat']
%% save the compressed outputs
    outdir=[config.dirs.output 'compressed/' num2str(date.yy) '/'];
    if exist(outdir,'dir')==7
    else mkdir(outdir)
    end
    save([outdir 'out_' fnroot '.mat'],'out');
%%
    %%%%
    % provide screen feedback
    sofar=toc;
    EstimTime=((Ndays-di).*(sofar./di)./(24*60*60));
    ETA=datevec(now+EstimTime);
%    fprintf('\n Day saved; estimated completion time: %s',datestr(ETA))
     
%% Routing
    %    rout_flow_EFv4(config,dates(di,:));
    %    rout_flow_50km_EF(config,dates(di,:));
end
tt=toc;
%fprintf('Run completed, total run time %4.0f minutes \n',tt./60);
