classdef acf < spt.criterion.rank.rank
    % ACF - Autocorrelation Function criterion 
    %
    % See also: config
  
   
    
    methods
       
        idx = compute_rank(obj, sptObj, tSeries, sr, ev, rep, varargin);
        
    end    
 
    % Static factory methods
    methods (Static)
        
        obj = ecg(varargin); 
        obj = bcg(varargin); 
        
    end  
    
    % Constructor
    methods
        
        function obj = acf(varargin)
         
           obj = obj@spt.criterion.rank.rank(varargin{:});           
          
        end
        
    end
    
end