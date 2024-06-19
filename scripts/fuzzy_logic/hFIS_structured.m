function [out] = hFIS_structured(input_table, gene, nMFs)
    %hFIS - hierarchical FIS structuring for multi-input systems

    cses =  size(input_table,1);
    len_gene = GeneDefinition.calc_gene_length(nMFs);
    nInpts = length(gene) / len_gene;

    %#TODO fix issue with length of gene
    %   - due to first set having 1 ruleset
    %   - reduced inputs but should not have?
    %   - how to bound membership functions for abstract combinations?
    %create array of MF structures
    for i = 1:nInpts
        [MF(i).X1, MF(i).X2, MF(i).Y, MF(i).Rules] = GeneDefinition.array_to_MF(gene(1+len_gene*(i-1):len_gene*i), nMFs);
        MF(i).Rules = round(MF(i).Rules);
    end
    


    % Incremental Fuzzy Tree Implementation
    % - output of previous FIS and next input variable fed into next FIS
    % - final output is treated as the crisp output of the full system
    % Run first FIS (only FIS with 2 inputs from input data)  
    x1 = input_table.(1);
    x2 = input_table.(2);
    out1 = M_FIS(x1, x2, MF(1));
    
    x1 = input_table.(3);
    x2 = input_table.(4);
    out2 = M_FIS(x1,x2,MF(2));

    out = M_FIS(out1, out2, MF(3));
    % for i = 3:(nInpts)
    %     x1 = out;
    %     x2 = input_table.(i);
    %     out = M_FIS(x1, x2, MF(i));
    % end

    % % for i = 1:cses %for each case
    % %     x1 = input_table.(1)(i);
    % %     x2 = input_table.(2)(i);
    % %     out(i) = M_FIS(x1, x2, MF(1)); 
    % % 
    % %     for j = 2:(nInpts) %for each FIS
    % %         %x1 = out(i) / max(out(i)) * nMFs ;%/ max(out); %normalize x1 such that bounds of input membership function will be [0 1]
    % %         x1 = out(i);
    % %         x2 = input_table.(j)(i);
    % %         out(i) = M_FIS(x1, x2, MF(j));
    % %     end
    % % end
end
