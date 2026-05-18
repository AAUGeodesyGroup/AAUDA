function F00_close_processing_receipt(config)
    %% Save a summary of processing configuration and some extra information.
    if isstring(config.summary.PrintProcessingReceipt)
        % Retrieve data
        currentTime = strrep(string(datetime),' ','_');
        currentTime = strrep(currentTime,':','-');
        % Open File
        fn = config.summary.PrintProcessingReceipt;
        fid = fopen(fn,'a');
        % Write in file:
        fprintf(fid,"\nEnding of processing:          %s",currentTime);
        fprintf(fid,'\n-------------------------------------------------');
        fprintf(fid,'\n     PROCESSING SUCCESFULLY COMPLETED! :)        ');
        fprintf(fid,'\n-------------------------------------------------');
        fprintf(fid,'\n\n\n');
        % Close file
        fclose(fid);
    end
end
