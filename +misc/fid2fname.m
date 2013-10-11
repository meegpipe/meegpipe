function fname = fid2fname(fid)


if isa(fid, 'io.safefid'),
    fname = fid.FileName;
else
    fname = fopen(fid);
end


end