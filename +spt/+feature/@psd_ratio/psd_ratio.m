classdef psd_ratio < spt.feature.feature & goo.verbose
    % PSD_RATIO - Spectral power ratio
    
    properties
        Band1;
        Band2;
        % IMPORTANT: this default estimator should match the default
        % estimator in physioset.plotter.psd.config. Otherwise the spectra
        % plotted in the report will not match the actual spectra used when
        % extracting the spectral power ratio features.
        Estimator  = @(x, sr) pwelch(x,  min(ceil(numel(x)/5),sr*3), ...
            [], [], sr);
        Band1Stat = @(power) prctile(power, 75);
        Band2Stat = @(power) prctile(power, 25);
    end
    
    % Static constructors
    methods (Static)
        
        function obj = emg(varargin)
           obj = spt.feature.psd_ratio(...
               'Band1', [40 100], 'Band2', [2 30]); 
        end
        
        function obj = eog(varargin)
           obj = spt.feature.psd_ratio(...
               'Band1', [0.25 6], 'Band2', [6 13;20 40]); 
        end
        
        function obj = pwl(varargin)
            obj = spt.feature.psd_ratio(...
                'Band1', [49 51], 'Band2', [3 11]); 
        end
        
    end
    
    methods
        
        % spt.feature.feature interface
        idx = extract_feature(obj, sptObj, tSeries, raw, varargin)
        
        % Constructor
        
        function obj = psd_ratio(varargin)
            import misc.set_properties;
            
            if nargin < 1, return; end
            
            opt.Band1 = [];
            opt.Band2 = [];
            opt.Estimator  = ...
                @(x, sr) pwelch(x,  min(ceil(numel(x)/5),sr*3), [], [], sr);
            opt.Band1Stat = @(power) prctile(power, 75);
            opt.Band2Stat = @(power) prctile(power, 25);
            obj = set_properties(obj, opt, varargin);      
        end
        
    end
    
end