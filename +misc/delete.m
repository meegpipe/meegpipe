function val = delete(file)

if isunix,
    val = system(['rm -f ' file]);
else
    val = delete(file);
end


end