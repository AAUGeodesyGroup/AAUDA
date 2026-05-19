function F02_result_extraction_manager(config)
%F02_RESULT_EXTRACTION_MANAGER manages result extraction
%   For processings of more thatn 5 years, each year will be extracted
%   independently (parallel extraction), saved in a different file, and
%   merged at the end.
%   LRS 1-12-2024

% Separate result extraction in 1-year slots if the time period is
% longer than 5 years.
todate = datetime(config.run.todate);
fromdate = datetime(config.run.fromdate);
if (todate - fromdate)<years(5)
    F02_ensemble_extract_state_results_W3RA(config);
else
    y_list = year(fromdate):year(todate);
    %% Extract results for each year
    fn_list = string.empty();
    parfor i=1:length(y_list)
        y = y_list(i);
        config_y = config;
        config_y.run.fromdate = sprintf("%s",max(datetime(y,1,1),fromdate));
        config_y.run.todate = sprintf("%s",min(datetime(y,12,31),todate));
        fn = F02_ensemble_extract_state_results_W3RA(config_y);
        fn_list(i,:) = fn;
    end

    %% Merge extracted results
    
    for j = 1:size(fn_list,2) % Iterate over summary-file type
        l = load(fn_list(1,j));
        t = struct2cell(l);
        % Iterate
        for i=2:size(fn_list,1)
            l = load(fn_list(i,j));
            t2 = struct2cell(l);
            t = cellfun(@(x,y) cat(2,x,y),t,t2,'UniformOutput',false);
        end
        % Double check that time is continuous and increasing
        time = t{1};
        if not(all((time(2:end)-time(1:end-1))==days(1)))
            disp('Error. Time vector is not continuous. Re-check files please.')
        else
            % Generate filename for new file
            fn_year_min = string(strsplit(string(fn_list(1,j)),'_'));
            fn_year_max = string(strsplit(string(fn_list(end,j)),'_'));
            [year_max,id_year_max] = max(str2double(flip(fn_year_max))); % Find where maxyear should be located
            id_year_max = length(fn_year_max) +1 -id_year_max;
            fn_complete = fn_year_min;
            fn_complete(id_year_max) = string(year_max);
            fn = strjoin(fn_complete,'_');
    
            % Save
            save(fn,'time');
    
            var_list = fieldnames(l);
            for i=2:length(var_list)
                eval(sprintf("%s = t{i};",var_list{i}));
                eval(sprintf("save(fn,'%s','-append');",var_list{i}));
            end
        end
    end
end


