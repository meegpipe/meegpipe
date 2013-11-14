classdef tfd < spt.criterion.rank.rank
    % TFD - Selects components with extreme Fractal dimensions
    %
    %
    % ## Usage synopsis:
    %
    % import spt.criterion.tfd.*;
    % data      = import(physioset.import.mff, 'file.mff');
    % objSpt    = learn(spt.jade, data);
    % ics       = project(objSpt, data);
    % critObj   = tfd('MinCard', 1, 'MaxCard', 1);
    % idx       = select(obj, objSpt, ics);
    %
    % Where
    %
    % CRITOBJ is a tsparse object that will select exactly one component
    % (the one with lowest fractal dimension). Note that high rank values
    % correspond to low fractal dimensions and viceversa. 
    %
    % OBJSPT is a spt.spt object.
    %
    % ICS are the temporal activations of the Independent Components
    % estimated by the JADE algorithm.
    %
    % IDX are the indices of the selected components.
    %
    % Public class properties and methods are summarized below.
    %
    % ## Accepted construction keys:
    %
    %   * All construction keys accepted by class spt.criterion.tfd.config
    %
    %   * All construction keys accepted by class spt.criterion.rank.rank
    %
    %   
    % See also: spt/criterion/tfd/config, spt/criterion/trank, spt/criterion

    
    
    % spt.criterion.criterion interface
    methods
        idx = compute_rank(obj, sptObj, tSeries, varargin);
    end
    
    % Static constructors
    methods (Static)
       
        obj = eog(varargin);
        
    end
  
    % Constructor
    methods
        
        function obj = tfd(varargin)
            
            obj = obj@spt.criterion.rank.rank(varargin{:});
       
        end
        
    end
    
    
end