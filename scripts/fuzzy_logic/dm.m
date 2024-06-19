function [X] = dm(var,MF)
%determineMembership Find membership of var given MF

    nMFs = size(MF,1);
    nCses = length(var);
    X = nan(nCses, nMFs);


    


    for jj = 1:nCses
        for ii = 1:nMFs
            if ii == 1
                X(jj, ii) = lshlder(var(jj), MF(ii,2), MF(ii,3), MF(ii,1) ); 
            elseif ii == nMFs
                X(jj, ii) = rshlder(var(jj), MF(ii,2), MF(ii,3), MF(ii,1) );
            else
                X(jj, ii) = triangle(var(jj), MF(ii,2), MF(ii,3), MF(ii,1) );
                
            end
        end
    end
end