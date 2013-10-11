classdef qrs_erp < spt.criterion.rank.rank
    % QRS_ERP - Pick components that contain QRS-like periodic waveforms
    %
    % See also: config
  
    
    methods
       
        idx = compute_rank(obj, sptObj, tSeries, sr, ev, rep, varargin);
        
    end    
 
 
    % Constructor
    methods
        
        function obj = qrs_erp(varargin)
         
           if nargin < 1 || isempty(varargin{1}) || ischar(varargin{1}),
               varargin = [{NaN}, varargin];
           end
           
           if nargin == 1 && isa(varargin{1}, 'spt.criterion.qrs_erp.qrs_erp'), 
               % copy constructor, do nothing
           else
               sr = varargin{1};
               varargin = varargin(2:end);
               if isnan(sr),
                   % sr can be nan if the sr is to be learnt at runtime
                   filtObj = @(sr) filter.bpfilt('fp', [5 45]/(sr/2));
               else
                   filtObj = filter.bpfilt('fp', [5 45]/(sr/2));
               end
               varargin = [{'Filter', filtObj} varargin];
           end

           obj = obj@spt.criterion.rank.rank(varargin{:});           
          
        end
        
    end
    
end