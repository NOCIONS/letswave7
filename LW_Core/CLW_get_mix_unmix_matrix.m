function [unmix_matrix,mix_matrix]=CLW_get_mix_unmix_matrix(header)
unmix_matrix=[];
mix_matrix=[];
for k=length(header.history):-1:1
    option=header.history(k).option;
    if isfield(option,'unmix_matrix') && isfield(option,'mix_matrix')
        unmix_matrix=option.unmix_matrix;
        mix_matrix=option.mix_matrix;
        return;
    end
end
end
