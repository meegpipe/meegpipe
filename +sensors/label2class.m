function sensorClass = label2class(labelArray, className, classRegex)
% LABEL2CLASS - Map sensor labels to valid sensor classes
%
%   sensorClass = label2class(labelArray, className, classRegex)
%
% Where
%
% LABELARRAY is a cell array of sensor labels (strings).
%
% CLASSNAME is a cell array of sensor classes (strings).
%
% CLASSREGEX is a cell array of regular expressions matching the various
% sensor classes.
%
% SENSORCLASS is a cell array of class names (strings).
%
%
% See also: sensors


if nargin < 3 || isempty(classRegex) || isempty(className),
    className = {'eeg', 'meg', 'trigger', 'physiology'};
    classRegex = {...
        '(EEG|EOG|E|eeg|eog|e)\s?', ...
        '(MEG|meg)(\d+)', ...
        '(STI|sti)101', ...
        '([^\s]+)\s*([^\s]*)' ...
        };
end

verbose = goo.globals.get.Verbose;
verboseLabel = goo.globals.get.VerboseLabel;

isMatched = false(size(labelArray));
sensorClass = cell(size(labelArray));
isAmbiguous = false(size(labelArray));

for classItr = 1:numel(className),
    isThisClass = ...
        cellfun(@(x) ~isempty(x), regexp(labelArray, classRegex{classItr}));    
    isAmbiguous = isAmbiguous | (isThisClass & isMatched);
    % The first listed classes take preference
    isThisClass(isMatched) = false;
    nbThisClass = numel(find(isThisClass));
    sensorClass(isThisClass) = repmat(className(classItr), nbThisClass, 1);
    if verbose && any(isThisClass),
        fprintf([verboseLabel 'Found %d %s sensor(s): %s\n'], ...
            nbThisClass, ...
            className{classItr}, ...
            misc.any2str(labelArray(isThisClass)));
    end
    isMatched = isMatched | isThisClass;
end

if any(isAmbiguous),
    warning('label2classes:AmbiguousLabel', ...
        'The following sensor labels are ambiguous: %s', ...
        misc.any2str(labelArray(isAmbiguous)));
end

if ~all(isMatched)
   warning('label2class:UnknownSensorClass', ...
       'Using default %s class for sensor(s): %s', className{end}, ...
       misc.any2str(labelArray(~isMatched))); 
end

end