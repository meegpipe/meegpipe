function obj = destroy_mmemmapfile(obj)
% DESTROY_MMEMMAPFILE Destroys the memory map(s) associated with a pset
% object
%
% destroy_mmemmapfile(obj)
%
%
% (c) German Gomez-Herrero
% Contact: german.gomezherrero@ieee.org
%
% See also: pset.

obj.MemoryMap = [];
obj.MapIndices = [];
