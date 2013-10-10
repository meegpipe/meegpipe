classdef stat < meegpipe.node.bad_epochs.criterion.rank.rank
    % STAT - Bad epochs rejection using simple statistics
    %
    % ## Usage synopsis:
    %
    % import meegpipe.node.bad_epochs.criterion.stat.stat;
    % import physioset.import.matrix;
    % import physioset.event.event;
    %
    % % Generate some random dataset and some periodic events
    % data = import(matrix, randn(10, 100000));
    % evArray = event(1:100:10000, 'Type', 'myevent', 'Duration', 1000);
    %
    % % Create a criterion to reject epochs with abnormally large (above
    % % the 95% percentile) or abnormally small (below 5% percentile) 
    % % maximum amplitude
    % myCrit = stat('Percentile', [5 90]);
    %
    % % Mark bad epochs (should mark as bad about 15% of the data
    % set_bad_epochs(myCrit, data, evArray);    
    % 
    % ## Accepted (optional) construction key/value pairs:
    %
    %   * All key/value pairs accepted by the corresponding configuration
    %     class meegpipe.node.bad_epochs.criterion.stat.config
    %
    %
    % See also: config
    
    % From criterion rank
    methods
        
        [idx, rankVal] = compute_rank(obj, data, ev);
        
    end
    
   % Constructor
    methods
        
        function obj = stat(varargin)
           
            obj = obj@meegpipe.node.bad_epochs.criterion.rank.rank(...
                varargin{:});         
           
        end
        
    end
    
    
    
end