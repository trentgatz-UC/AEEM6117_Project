function [out] = hFIS(input_table, gene, nMFs)
    %hFIS - hierarchical FIS structuring for multi-input systems
    cses =  size(input_table,1);
    len_gene = GeneDefinition.calc_gene_length(nMFs);
    nFISs = length(gene) / len_gene;
    %create array of MF structures
    for i = 1:(nFISs)
        [MF(i).X1, MF(i).X2, MF(i).Y, MF(i).Rules] = GeneDefinition.array_to_MF(gene(1+len_gene*(i-1):len_gene*i), nMFs);
        MF(i).Rules = round(MF(i).Rules);

        % GeneDefinition.plotMF(gene(1+len_gene*(i-1):len_gene*i), nMFs);
        % xlim([0 nMFs])
        % plotbrowser on
    end

    for i = 1:cses %for each case
        x1 = input_table.(1)(i);
        x2 = input_table.(2)(i);
        out(i) = M_FIS(x1, x2, MF(1)); 
        for j = 2:(nFISs) %for each FIS            
            x1 = out(i);
            x2 = input_table.(j)(i);
            out(i) = M_FIS(x1, x2, MF(j));
        end
    end
end
