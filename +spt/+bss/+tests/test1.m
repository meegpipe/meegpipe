function [status, MEh] = test1()
% TEST1 - Tests basic BSS functionality

import mperl.file.spec.*;
import spt.bss.atdsep.atdsep;
import spt.bss.tdsep.tdsep;
import spt.bss.jade.jade;
import spt.bss.fastica.fastica;
import spt.bss.runica.runica;
import spt.bss.multicombi.multicombi;
import spt.bss.efica.efica;
import spt.bss.ewasobi.ewasobi;
import spt.bss.amica.amica;
import spt.pca.pca;
import test.simple.*;
import misc.rmdir;
import spt.amari_index;

MEh     = [];

initialize(7);

%% default constructor
try
    
    name = 'default constructors';
    amica;
    atdsep;    
    jade;
    fastica;
    multicombi;
    runica;
    tdsep;
    efica;
    ewasobi;
    pca;
    ok(true, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% constructor with config options
try
    
    name = 'constructor with config options';
    myNode = pca('Var', .5);
    
    ok(all(get_config(myNode, 'Var') == [0 .5]), name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% process sample data
try
    
    name = 'process sample data';
    
    X = rand(3, 35000);
    
    obj = learn(jade, X);
    
    Wjade = projmat(obj);
    
    obj = learn(fastica, X);
    
    Wfica = projmat(obj);
    
    ok(amari_index(Wjade) < 0.05 & amari_index(Wfica) < 0.05 , name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of fastica
try
    
    name = 'reproducibility of fastica';
    
    X = rand(3, 35000);
    
    isCool = true;
    for i = 1:10,
        
        obj = fastica('InitGuess', @(x) rand(size(x,1)));
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2);
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of infomax (runica)
try
    
    name = 'reproducibility of infomax (runica)';
    
    X = rand(3, 3000);
    
    isCool = true;
    for i = 1:3,
        
        obj = runica;
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2);
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of infomax (amica)
try
    
    name = 'reproducibility of amica';
    
    X = rand(3, 3000);
    
    isCool = true;
    for i = 1:3,
        
        obj = amica;
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2);
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% reproducibility of infomax (runica)
try
    
    name = 'reproducibility of efica';
    
    X = rand(3, 3000);
    
    isCool = true;
    for i = 1:3,
        
        obj = efica;
        
        obj = learn(obj, X);
        
        W  = projmat(obj);
        
        A  = bprojmat(learn(obj, X));
        
        obj = clear_state(obj);
        
        A2  = bprojmat(learn(obj, X));
        
        isCool = isCool & rcond(W*A) > rcond(W*A2);
        
    end
    
    ok(isCool, name);
    
catch ME
    
    ok(ME, name);
    MEh = [MEh ME];
    
end

%% Testing summary
status = finalize();