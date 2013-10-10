function obj = clear_runtime(obj)
% CLEAR_RUNTIME - Clear all runtime parameters
%
% obj = clear_runtime(obj)
%
% This method is to be called during node initialization, if the runtime
% parameters of a previous node run have been invalidated. The latter will
% happen if:
%
% (1) The configuration of the node has changed, i.e. the runtime
% parameters that refer to the previous configuration are now invalid.
%
% (2) The configuration OR the runtime parameters of any previous node have
% changed. In such scenario, the input to the current node is likely to
% change, therefore invalidating the existing runtime parameters.
%
% See also: get_runtime, set_runtime

if ~has_runtime_config(obj),
    return;
end

if isempty(obj.RunTime_),
    obj.RunTime_ = get_runtime_config(obj);
end

cfg = obj.RunTime_;

rtSections = sections(cfg);


for sectItr = 1:numel(rtSections)
   
    
    rtParams = parameters(cfg, rtSections{sectItr});
   
    for paramItr = 1:numel(rtParams)
        
        setval(cfg, rtSections{sectItr}, rtParams{paramItr}, '');        
        
    end
    
end


end