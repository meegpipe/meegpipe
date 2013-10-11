function dataSel = data4learning(obj, data, varargin)
% DATA4LEARNING - Returns the data that will be actually used for learning
%
% data = data4learning(obj)
%
% Where
%
% OBJ is a spt.generic.generic object
%
% DATA is a numeric data matrix with the data that will be used for
% learning the spatial transform basis functions.
%
%
% ## Notes:
%
% Typically, the data for learning will be identical to the data that is
% provided to method learn(). However, only a subset of the latter may be
% used for learning if the EventSpecs or EventLatRange properties are
% defined.
%
%
% See also: spt.generic.generic

% Documentation: class_spt_abstract_spt
% Description: Returns the data used for learning

import misc.epoch_get;

verbose      = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

if verbose,
    fprintf([verboseLabel ...
        'Picking relevant data epochs for learning...\n\n']);
end

events = select(obj.EventSelector, data.Event);

[dataSel, ~, sampleIdx] = epoch_get(data, events);

% Remove bad channels and bad samples
if isa(data, 'pset.physioset'),
    badChan = is_bad_channel(data, 1:nb_dim(data));
    dataSel = dataSel(~badChan, :, :);    
end
badSample = is_bad_sample(data, sampleIdx);

nSamples = numel(find(~badSample));

if verbose,   
    fprintf([verboseLabel ...
        'Picked %d epochs. Total number of samples = %d (%d%%)\n\n'], ...
        size(dataSel,3), nSamples, round(100*nSamples/size(data,2)));
end

dataSel = reshape(dataSel, ...
    size(dataSel,1), size(dataSel,2)*size(dataSel,3));

% Remove bad samples

if any(badSample),
    dataSel(:, badSample) = [];
end

end