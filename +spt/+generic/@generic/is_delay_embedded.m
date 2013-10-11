function bool = is_delay_embedded(obj)


embedDim = get_config(obj, 'EmbedDim');
bool =  ~isempty(embedDim) & embedDim > 1;


end