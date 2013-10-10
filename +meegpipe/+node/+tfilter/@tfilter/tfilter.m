classdef tfilter < meegpipe.node.abstract_node
    % TFILTER - Constructor for time-domain filtering nodes
    %
    % ## Usage synosis:
    %
    % % Load some data
    % myData = import(physioset.import.mff, 'myfile.mff');
    %
    % % Filter the data using a LASIP filter with polynomials of order 2,
    % % Gamma parameter equal to 3
    %
    % import meegpipe.node.tfilter;
    % myNode = tfilter('Filter', filter.lasip('Order', 2, 'Gamma', 3));
    % process(myNode, myData);
    %
    %
    % ## Accepted key/value pairs:
    %
    %   * All keys accepted by meegpipe.node.tfilter.config
    %
    % See also: config

    methods (Static, Access = private)
       
        gal = generate_filt_plot(rep, idx, data1, data2, samplTime, ...
            gal, showDiff);
        
    end   

    % meegpipe.node.node interface
    methods
        [data, dataNew] = process(obj, data, varargin)
    end
    
    % Constructor
    methods
        function obj = tfilter(varargin)
            
            obj = obj@meegpipe.node.abstract_node(varargin{:});
            
            if nargin > 0 && ~ischar(varargin{1}),
                % copy construction: keep everything like it is
                return;
            end
       
            if isempty(get_data_selector(obj));               
                set_data_selector(obj, pset.selector.good_data);
            end
            
            if isempty(get_name(obj)),
                filtObj = get_config(obj, 'Filter');
                if isempty(filtObj),
                     obj = set_name(obj, 'tfilter');
                elseif isa(filtObj, 'filter.dfilt') && ...
                        ~isempty(get_name(filtObj)),
                     obj = set_name(obj, ['tfilter-' get_name(filtObj)]);
                elseif isa(filtObj, 'function_handle'),
                    % A function_handle of the input data sampling rate
                    tmpObj = filtObj(500);
                    set_name(obj, ['tfilter-' get_name(tmpObj)]);
                end
            end
            
        end
    end
    
    
end