classdef config < spt.generic.config
    % CONFIG - Configuration for class atdsep
    %
    % ## Usage synopsis:
    %
    % import spt.bss.atdsep.*;
    % cfg = config;
    % cfg = config('key', value, ...);
    % bssObj = atdsep(cfg);
    %
    % ## Accepted (optional) construction arguments (as key/value pairs):
    %
    %       Lag : Eigher an array of natural numbers or a function_handle
    %           that can be used to determine the lags from the input to
    %           method learn_basis. Default: [0 1]
    %           List of lags to use with TDSEP
    %
    %       Lambda : A scalar in the range (0 1]. Default: 0.999
    %           The Lambda property determines the speed of adaptation to
    %           changes in the covariance structure of the input data.
    %
    %       WindowShift : A natural scalar. Default: 50
    %           The shift, in data samples, between correlative adaptation
    %           steps. 
    %
    %       JacobiTh: A (very small) scalar. Default: 0.00001
    %         
    %
    %
    % See also: +spt, +spt/abstract_spt, +spt/+bss/+atdsep/qrs_lag
    
    % Documentation: pkg_tdsep.txt
    % Description: Configuration for class tdsep
    
    %% PUBLIC INTERFACE ...................................................
    
    properties
        
        Lag = 1;
        Lambda = 0.999;
        WindowShift = 5;
        JacobiTh = 0.0001;
      
    end

    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.generic.config(varargin{:});
            
        end
        
    end
    
    
    
end