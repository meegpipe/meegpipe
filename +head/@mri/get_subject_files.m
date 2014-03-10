function info = get_subject_files(subjectPath, nbVertices)

AmbiguousSensors = MException('head:mri:get_subject_files:AmbiguousSensors', ...
    'There are multiple sensor specification files in the subject folder');

AmbiguousSubject = MException('head:mri:get_subject_files:AmbiguousSubject', ...
    'Found multiple subjects in the same folder');

AmbiguousDensity = MException('head:mri:get_subject_files:AmbiguousDensity', ...
    'Ambiguous surface density');

AmbiguousSurface = MException('head:mri:get_subject_files:AmbiguousSurface', ...
    'Ambiguous surface file');

if subjectPath(end) == '/' || subjectPath(end) == '\',
    subjectPath = subjectPath(1:end-1);
end

if nargin < 2, nbVertices = []; end

files = dir(subjectPath);
info = struct('sensors', [], 'outerskin', [], 'outerskull', [], ...
    'innerskull', [], 'outerskindense', [], 'outerskulldense', [], ...
    'innerskulldense', [], 'subject', [], 'density', nbVertices);
for i = 1:numel(files)
    if files(i).bytes < 1, continue; end
    
    patSensors = '^\d+-sensors(.hpts|.sfp)$';
    patDense   = '^\d+-[^-]+-dense.tri$';
    patSparse  = '^\d+-[^-]+-\d+.tri$';
    
    if ~isempty(regexpi(files(i).name, patSensors)),
        % Sensors file
        if ~isempty(info.sensors),
            throw(AmbiguousSensors);
        else
            info.sensors = [subjectPath  filesep files(i).name];
        end
        pat = '^(?<subject>[^-]+)-';
        names = regexpi(files(i).name, pat, 'names');
        if ~isempty(info.subject),
            if ~strcmpi(names.subject, info.subject),
                throw(AmbiguousSubject);
            end
        else
            info.subject = names.subject;
        end
    elseif ~isempty(regexpi(files(i).name, patSparse)),
        % Sparse surface files
        pat = '^(?<subject>\d+)-(?<surface>[^-]+)-(?<density>\d+).tri$';
        names = regexpi(files(i).name, pat, 'names');
        if ~isempty(info.subject),
            if ~strcmpi(names.subject, info.subject),
                throw(AmbiguousSubject);
            end
        else
            info.subject = names.subject;
        end
        if ~isempty(info.density),
            if str2double(names.density) ~= info.density,
                throw(AmbiguousDensity);
            end
        else
            info.density = str2double(names.density);
        end
        surface = strrep(names.surface, '_', '');
        if ~isempty(info.(surface)),
            throw(AmbiguousSurface);
        else
            info.(surface) = [subjectPath  filesep files(i).name];
        end
    elseif ~isempty(regexpi(files(i).name, patDense)),
        % Sparse surface files
        pat = '^(?<subject>\d+)-(?<surface>[^-]+)-dense.tri$';
        names = regexpi(files(i).name, pat, 'names');
        if ~isempty(info.subject),
            if ~strcmpi(names.subject, info.subject),
                throw(AmbiguousSubject);
            end
        else
            info.subject = names.subject;
        end
        surface = strrep(names.surface, '_', '');
        if ~isempty(info.([surface 'dense'])),
            throw(AmbiguousSurface);
        else
            info.([surface 'dense']) = [subjectPath  filesep files(i).name];
        end
        
    else
        continue;
    end
    
    
end


end