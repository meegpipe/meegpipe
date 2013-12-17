function [status, MEh] = test_basic()
% TEST_BASIC - Tests basic node functionality

import mperl.file.spec.*;
import meegpipe.node.*;
import test.simple.*;
import pset.session;
import safefid.safefid;
import datahash.DataHash;
import misc.rmdir;
import oge.has_oge;
import physioset.event.value_selector;

MEh     = [];

initialize(7);

%% Create a new session
try
    
    name = 'create new session';
    warning('off', 'session:NewSession');
    session.instance;
    warning('on', 'session:NewSession');
    hashStr = DataHash(randn(1,100));
    session.subsession(hashStr(1:5));
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    status = finalize();
    return;
    
end


%% default constructor
try
    
    name = 'constructor';
    parallel_node_array.new;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    
    myNodeList = {...
        center.new, ...
        copy.new ...
        };
    
    myNode = parallel_node_array.new(...
        'NodeList',     myNodeList, ...
        'Aggregator',   @(varargin) prod(cell2mat(varargin)));
    
    myNodeList = get_config(myNode, 'NodeList');
    myAggr     = get_config(myNode', 'Aggregator');
    ok(...
        numel(myNodeList) == 2 & ...
        isa(myNodeList{1}, 'meegpipe.node.center.center') & ...
        isa(myAggr, 'function_handle') & ...
        myAggr(5,4) == 20, ...
        name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% using a regression filter as aggregator (real data)
try
    
    name = 'using a regression filter as aggregator (real data)';
    
    
    data = real_data;
    
    myFilter = filter.cca.bcg_enhance(...
        'MinCorr',      @(x) median(x), ...
        'SamplingRate', data.SamplingRate ...
        );
    
     myFilter = filter.pca(...
        'PCA',          spt.pca('RetainedVar', 99.99), ...
        'PCFilter',     myFilter);
    
    % This mini-pipeline takes care of extracting the signals that are
    % to be regressed out later on
    myRegrExtractor = pipeline.new(...
        copy.new, ...
        filter.new('Filter', myFilter), ...
        spt.new('SPT',    spt.pca('RetainedVar', 99)));
    
    % The regression filter is a sliding window multiple-lag regression
    % filter
    myFilter = filter.mlag_regr('Order', 10);
    myFilter = filter.sliding_window(...
        'Filter',         myFilter, ...
        'WindowLength',   data.SamplingRate*10, ...
        'WindowOverlap',  50);   
    
    % The second parallel node is just transparent, meaning: let the input
    % data pass through untouched (no copy is performed due to CopyInput
    % being set to false).
    myNode = parallel_node_array.new(...
        'NodeList',   {[], myRegrExtractor}, ...
        'Aggregator', @(nodesOut) filter(myFilter, nodesOut{1}, nodesOut{2}), ...
        'CopyInput',  false);
    
    dataO = data(1,:);    
    run(myNode, data);    
    
    ok(prctile(abs(dataO), 90) > 2*prctile(abs(data(1,:)), 90), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% two operator nodes and sum aggregator
try
    
    name = 'two operator nodes and minus aggregator';
    
    
    data = import(physioset.import.matrix, rand(5,1000));
    
    myNode1 = operator.new('Operator', @(x) x.^2);
    myNode2 = operator.new('Operator', @(x) x.^3);
    
    myNode = parallel_node_array.new(...
        'NodeList',  {myNode1, myNode2}, ...
        'Aggregator', @(varargin) varargin{1}-varargin{2});
    
    dataOut = run(myNode, data);
    
    ok(max(abs(data(:).^2-data(:).^3-dataOut(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% three copy nodes and sum aggregator
try
    
    name = 'two copy nodes and sum aggregator';
    
    
    data = import(physioset.import.matrix, rand(5,1000));
    
    myNode = parallel_node_array.new(...
        'NodeList', {copy.new, copy.new, copy.new}, ...
        'Aggregator', @(varargin) varargin{1}+varargin{2}+varargin{3});
    
    dataOut = run(myNode, data);
    
    ok(max(abs(3*data(:)-dataOut(:))) < 0.01, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end


%% Cleanup
try
    
    name = 'cleanup';
    clear data dataCopy;
    rmdir(session.instance.Folder, 's');
    session.clear_subsession();
    ok(true, name);
    
catch ME
    ok(ME, name);
end

%% Testing summary
status = finalize();

end


function dataCopy = real_data()

import pset.session;
import mperl.file.spec.catfile;
import mperl.file.spec.catdir;

if exist('bcg_sample.pseth', 'file') > 0,
    data = pset.load('bcg_sample.pseth');
else
    % Try downloading the file
    url = 'http://kasku.org/data/meegpipe/bcg_sample.zip';
    unzipDir = catdir(session.instance.Folder, 'bcg_sample');
    unzip(url, unzipDir);
    fileName = catfile(unzipDir, 'bcg_sample.pseth');
    data = pset.load(fileName);
end
dataCopy = copy(data);

end