classdef config < spt.criterion.rank.config
    % CONFIG - Configuration for xcorr criterion
    %
    % ## Usage synopsis:
    %
    % import spt.criterion.xcorr.*;
    % myConfig = config('key', value, ...);
    % myXcorrCrit = xcorr(myConfig);
    %
    % ## Accepted key/value pairs:
    %
    %       * All key/value pairs accepted by class
    %         spt.criterion.rank.config
    %
    %       Selector : A pset.selector.selector object. Default: []
    %           This data selector will be used to select the set of data
    %           against which every spatial component's activation will be
    %           cross-correlated. If the data selector results in a
    %           multi-channel data selection, multiple cross correlation
    %           coefficients will be sumarized according to the SummaryFunc
    %           property, as described below.
    %
    %       SummaryFunc : A function_handle. Default: @(x) median(x)
    %           If Selector produces a multiple-channel data selection, the
    %           cross-correlation values for all channels will be
    %           summarized by means of this function handle. 
    %
    % See also: xcorr
    
    % Documentation: pkg_xcorr.txt
    % Description: Configuration for xcorr criterion
  
    properties
       
        Selector;
        SummaryFunc = @(x) median(x);        
        
    end
    
    
   
    
    % Constructor
    methods
        
        function obj = config(varargin)
            
            obj = obj@spt.criterion.rank.config(varargin{:});
            
        end
        
    end
    
    
    
end