function [X] = determine_membership(var,MF)
%determineMembership Find membership of var given MF

    nMFs = size(MF,1);
    X = nan(1,nMFs);
    for ii = 1:nMFs
        if ii == 1
            X(ii) = lshlder(var, MF(ii,2), MF(ii,3), MF(ii,1) ); 
        elseif ii == nMFs
            X(ii) = rshlder(var, MF(ii,2), MF(ii,3), MF(ii,1) );
        else
            X(ii) = triangle(var, MF(ii,2), MF(ii,3), MF(ii,1) );
            
        end
    end
end
