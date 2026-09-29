function d = struct2dict(s)
    % STRUCT2DICT Converts a MATLAB structure or an existing dictionary into a dictionary.
    %
    %   d = STRUCT2DICT(s)
    %       - If 's' is already a dictionary, returns 's' unchanged.
    %       - If 's' is a structure, converts its fields into keys (String) and corresponding values.
    %       - For empty inputs or any other data type, throws an error.

    if isempty(s)
        error('struct2dict:EmptyInput', ...
            'Input must be a non-empty structure or dictionary (received type: %s).', class(s));
    end

    if isa(s, 'dictionary')
        d = s;
        
    else if isa( s, 'struct' )
        keys = string(fieldnames(s));
        values = struct2cell(s);
        
        d = dictionary(keys, values);
    else
        error('struct2dict:InvalidInput', ...
            'The input structure must be a structure or a dictionary.');
    end
end