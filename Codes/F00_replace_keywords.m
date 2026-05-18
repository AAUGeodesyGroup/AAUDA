function raw_upd = F00_replace_keywords(raw)
%% This function replaces the keyword markers with the keywords themselves.
% The replacement is done in the order as the keywords are introduced,
% in such a way that a keyword can depend on another keyword that was
% previously defined.

    % Initialize new config file.
    raw_char = char(raw');
    
    % Retrieve initial config file
    config = jsondecode(raw_char);
    
    if isfield(config,'keywords')
        % Retrieve keyword markers
        fields = fieldnames(config.keywords);
        for i=1:numel(fields)
            kn = ['%' fields{i}(3:end)];
            raw_char_ = strrep(raw_char,kn,config.keywords.(fields{i}));
            raw_char = raw_char_;
        end
    end
    
    raw_upd = uint8(raw_char)';
end