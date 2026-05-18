function config = F00_open_processing_receipt(raw,config)
    %% Save a summary of processing configuration and some extra information.
    if config.summary.PrintProcessingReceipt
        % Make summary directory if this is not done.
        if ~isfolder(config.summary.directory)
            mkdir(config.summary.directory);
        end
        % Retrieve data
        txt = char(raw');
        currentTime = strrep(string(datetime),' ','_');
        currentTime = strrep(currentTime,':','-');
        % Open File
        fn = sprintf("%s/ProcessingReceipt_%s.txt",config.summary.directory,currentTime);
        fid = fopen(fn,'w');
        config.summary.PrintProcessingReceipt = fn; % Save filename in config to close receipt later.
        % Write in file:
        fprintf(fid,'\n-------------------------------------------------');
        fprintf(fid,'\n       Configuration:                            ');
        fprintf(fid,'\n-------------------------------------------------\n');
        fprintf(fid,strrep(txt,'%','%%'));
        fprintf(fid,'\n-------------------------------------------------');
        fprintf(fid,'\n-------------------------------------------------');
        fprintf(fid,'\n       Processing details:                       ');
        fprintf(fid,'\n-------------------------------------------------');
        fprintf(fid,"\nBeginning of processing:       %s",currentTime);
        fprintf(fid,'\n\n\n');
        % Close file
        fclose(fid);
    end
end
