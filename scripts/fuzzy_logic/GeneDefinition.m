classdef GeneDefinition
    methods(Static) 
        function [X1, X2, Y, Rules] = array_to_MF(arr, nMFs)
            X1 = complete_MF(sort(arr(1:nMFs)));
            X2 = complete_MF(sort(arr(1+nMFs:nMFs*2)));
            Y = complete_MF(sort(arr(1+2*nMFs:3*nMFs)));
            Rules = reshape(arr(1+3*nMFs:end), [nMFs, nMFs])'; 
            
            % Validation of Rules (Whole Nubmer & Validate selection
            Rules = round(Rules);
            Rules(Rules<1) = 1;
            Rules(Rules>nMFs) = nMFs;
            function [MFs] = complete_MF(arr) 
                for i = 1:nMFs
                    if i == 1
                        MFs(i,:) = [0 arr(i) arr(i+1)];
                    elseif i == nMFs
                        MFs(i,:) = [arr(i-1) arr(i) 1e9];
                    else
                        MFs(i,:) = [arr(i-1) arr(i) arr(i+1)];
                    end
                end                                          
            end
        end

        function [gene_length] = calc_gene_length(nMFs)
            outputs = 1;
            inputs = 2;                                   
            gene_length = (inputs+outputs) * nMFs + nMFs^2;
        end
        
        function [] = plotMF(gene, nMFs)
            %plotMF show all membership functions
            [X1, X2, Y, ~] = GeneDefinition.array_to_MF(gene, nMFs);
            MF.X1 = X1;
            MF.X2 = X2;
            MF.Y = Y;
            figure;
            subplot(3,1,1)
            hold on
            for i = 1:nMFs
                end_middle_logic(MF.X1)
            end
            title('X1 Membership Functions')
            xlim([0 nMFs])
            subplot(3,1,2)
            hold on
            for i = 1:nMFs
                end_middle_logic(MF.X2)
                % plot(MF.X2(i,:), points)
            end
            title('X2 Membership Functions')
            xlim([0 nMFs])
            subplot(3,1,3)
            hold on
            for i = 1:nMFs
                plot(MF.Y(i,:), [0 1 0])
            end
            title('Output Membership Functions')
            xlim([0 nMFs])
            function [] = end_middle_logic(mfs)
                %handle plotting of should vs triangular membership functions
                if i == nMFs
                    plot(mfs(i,:), [0 1 1])
                elseif i == 1
                    plot(mfs(i,:), [1 1 0])
                else
                    plot(mfs(i,:), [0 1 0])
                end
            end
        end
    end
end
