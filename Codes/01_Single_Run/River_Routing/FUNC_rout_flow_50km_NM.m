function FUNC_rout_flow_50km_NM(config)
% LRS 11-09-2023: Implemented changes to integrate in DA.
%% 50 km

% This script was originally set up by Nooshin Mehrnegar.

%% Set routing parameter
RoutCoeff=0.8;
% Configure
load('rout_50km.mat');
k=min(1,RoutCoeff./rout.relarea);
dates=datevec(datenum(config.run.fromdate):datenum(config.run.todate));
Ndays=size(dates,1);

%% Initialise: retrieve warmed up model state
stated=datevec(datenum(config.run.fromdate)-1);  % Load file from previous day.
stateroot=num2str(stated(1)*1e4+stated(2)*1e2+stated(3));
load([config.states.routing '/Rstate_' stateroot '.mat']);

clear stated stateroot
%fprintf('\n About to run %0.0f days.',Ndays);
%tic

%%
% Qtest=[]; % ADD.1 for testing purposes only
MonthNow=0;
 for di=1:Ndays
    date.yy=dates(di,1);
    date.mm=dates(di,2);
    date.dd=dates(di,3);
   date.doy=datenum([dates(di,:)])-datenum([date.yy-1 12 31]);
%     fprintf('\n Run for %i / %i / %i',date.dd,date.mm,date.yy);
    % load landscape model output
    fnroot=num2str(date.yy*1e4+date.mm*1e2+date.dd);
    outdir=[config.output.directory '/compressed/' num2str(date.yy) '/'];
%     load([outdir 'out_Global_' fnroot '.mat']);
%     Qtot_temp=zeros(1801,3600);
%     Qtot_temp(config.selecti)=out.Qtot;
    % >>>>>>>>>>>>>>>>>>>>>>>>>> LRS modified.
    % Load output file of the OL model run.
    load([outdir 'out_' fnroot '.mat']);
    % Initialize Qtot
    Qtot_temp=zeros(1801,3600); 
    % Generate primary landmask. Lat: 21.9 - 31.1; Lon: 73.6 - 97.6.
    lat = 90:-0.1:-90; lon = [0:0.1:180 -180:0.1:-0.1];
    [LON,LAT] = meshgrid(lon,lat);
    idx_lon = and(LON>=73.6, LON<=97.6); idx_lat = and(LAT>=21.85,LAT<=31.1);
    idx_landmask_prim = find(and(idx_lon,idx_lat));
    % Load secondary landmask
    load(config.input.landmask);
    idx_landmask_sec = idx_landmask_prim(logical(landmask_10k(:)));
    Qtot_temp(idx_landmask_sec) = out.Qtot;
    % <<<<<<<<<<<<<<<<<<<<<<<<<< end LRS modified.
    % oversample model output
    Qtot_temp(1801,:)=[];
    Qtot=imresize(Qtot_temp,0.2,'nearest'); Qtot(isnan(Qtot)==1)=0;
    clear Qtot_temp
    % Rout flow
    S=state.Sriv;S(isnan(S)==1)=0;
    loss=rout.mask.*0;
    gain=Qtot;
    jro=find(rout.mask==1);
    for ij=1:numel(jro)
        jid=jro(ij);
        gain(rout.goto(jid))=gain(rout.goto(jid))+k(jid).*S(jid).*rout.scaling(jid);
        loss(jid)=loss(jid)+k(jid).*S(jid);
    end
    S=S+gain-loss;
    Qout=Qtot+loss;
    S(rout.dir==9 | rout.dir==12)=0;  % remove S from outflow points
    Qout(rout.dir==9 | rout.dir==12)=0;
    Qriv=1000.*rout.area.*Qout/(24.*3600); % result is in m3/s
    %% save the updated state
    state.Sriv=S;
    state.Qriv=Qriv;
    fnroot=num2str(date.yy*1e4+date.mm*1e2+date.dd);
    outdir_Rstate=[config.states.routing '/'];
    save([outdir_Rstate 'Rstate_' fnroot '.mat'],'state')
    %% save routed flows
    outdir=[config.output.directory '/Routed/'];
    if exist(outdir,'dir')==7
    else mkdir(outdir)
    end
    save([outdir 'Qriv_' fnroot '.mat'],'Qriv');
    %
 end


