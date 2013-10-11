function obj = embed_pca(obj, pcaObj)
% EMBED_PCA - Embeds a PCA transformation into another spatial transform
%
% newObj = embed_pca(obj, pcaObj)
%
% Where
%
% PCAOBJ is spt.pca object
%
% NEWOBJ is the result of embedding the provided PCA transformation into
% OBJ. 
%
% 
% See also: spt.generic.generic, spt.spt, spt


obj.W = obj.W*projmat(pcaObj);
obj.A = bprojmat(pcaObj)*obj.A;



end