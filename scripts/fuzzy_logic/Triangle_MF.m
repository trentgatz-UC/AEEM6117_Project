classdef Triangle_MF
    properties
        MFs

    end


    methods(Static)
        function mul = lshld(x,cel,rel,lel)   %left shoulder membership function
            mul = (rel-x)/ (rel-cel);
            mul(x<cel) = 1;
            mul(x>rel) = 0;
            mul = mul';
        end
    
        function mur = rshld(x,cer,rer,ler)   %right shoulder membership function
            mur = (x-ler)/(cer-ler);
            mur(x>cer) = 1;
            mur(x<ler) = 0;
            mur = mur';
        end
    
        function mu = triangle(x,ce,re,le)    %TRIANGLE MEMBERSHIP FUNCTION
            left_side = x>=le & x<=ce;
            right_side = x>ce & x<=re;
            mu = zeros(1, length(x));        
            mu(left_side) = (x(left_side)-le)/(ce-le);
            mu(right_side) = (re-x(right_side))/(re-ce);
            mu = mu';
        end
    
        function [X] = determine_membership(var,MF)
        %determineMembership Find membership of var given MF
        
            nMFs = size(MF,1);
            cses = length(var);
            X = nan(cses,nMFs);
            for ii = 1:nMFs
                if ii == 1
                    X(:,ii) = Triangle_MF.lshld(var, MF(ii,2), MF(ii,3), MF(ii,1) ); 
                elseif ii == nMFs
                    X(:,ii) = Triangle_MF.rshld(var, MF(ii,2), MF(ii,3), MF(ii,1) );
                else
                    X(:,ii) = Triangle_MF.triangle(var, MF(ii,2), MF(ii,3), MF(ii,1) );
                    
                end
            end
        end
    end


end