function ev = from_eeglab(str)
% FROM_EEGLAB - Construction from EEGLAB structure
%
% evArray = from_eeglab(str)
%
% Where
%
% STR is an array of EEGLAB event structures, i.e. the array stored in
% field 'event' of an EEGLAB's dataset (EEG) structure. 
%
% EVARRAY is an equivalent array of event objects
%
% See also: from_fieldtrip, from_struct

% Description: Construction from EEGLAB structure
% Documentation: class_event.txt

import physioset.event.event;

ev = event.from_struct(str);


end
