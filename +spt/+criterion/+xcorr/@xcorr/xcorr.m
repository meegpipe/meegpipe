classdef xcorr < spt.criterion.rank.rank
    % XCORR - Select components by cross-correlating them with a ref.
    %
    % ## Usage synopsis:
    %
    % % This example will select those components whose cross-correlation 
    % % coefficient with the ECG channel exceeds the fixed threshold 0.2
    % import spt.criterion.xcorr.*;
    % import pset.selector.*;
    % dataSel = sensor_class('Type', 'ECG');
    % critObj = xcorr('Selector', dataSel, 'Min', 0.20);
    % 
    % % Assume X are the spatial components time-series (a numeric matrix
    % % or a pset.pset object), and data is the raw EEG data (a physioset
    % % object). Then, 
    % [selected, rIndex] = select(critObj, [], X, data);
    % 
    % % So that selected is a logical array with true values on the
    % % positions of the selected components.
    %
    % See also: config
    
    % Documentation: class_xcorr.txt
    % Description: Ccross-correlation with reference signal
    
    methods
        
        idx = compute_rank(obj, sptO, tSeries, sr, ev, rep, raw, varargin);
        
    end
    
    % Static constructors
    methods (Static)
        
        obj = bcg(varargin);
        
    end
    
    % Constructor
    methods
        
        function obj = xcorr(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
            
        end
        
    end
    
    
end