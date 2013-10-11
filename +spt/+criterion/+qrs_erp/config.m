classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for qrs_erp criterion
    %
    %
    % See also: qrs_erp
    
    
    properties
        
        FirstLevelCrit = spt.criterion.acf.acf.ecg;
        Offset         = 0.08;      % In seconds
        Duration       = 0.4;       % In seconds
        SamplingRate   = [];        % If [], to be inferred from input dataset
        
    end

    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            if nargin ~= 1,
                % not a copy constructor             
                varargin= [varargin {'Max', 0.6}];
            end
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end