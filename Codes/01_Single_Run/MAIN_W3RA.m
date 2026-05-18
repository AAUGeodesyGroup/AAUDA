function MAIN_W3RA(config)

%% Simulation time
ys = year(datetime(config.run.fromdate));
ms = month(datetime(config.run.fromdate));
ds = day(datetime(config.run.fromdate));
ye = year(datetime(config.run.todate));
me = month(datetime(config.run.todate));
de = day(datetime(config.run.todate));
start = [ys ms ds]; stop = [ye me de];
%% Run model
RUN_W3RA_EF(config, start, stop);

end

