classdef GeneValidation    
    methods(Static)
        function [gene] = validate(gene, nMFs)
            %month will be the 3rd col, day the 4th
            len_gene = GeneDefinition.calc_gene_length(nMFs);
            
            % day_range = [1+len_gene*(4-1) len_gene*4];
            % month_range = [1+len_gene*(3-1) len_gene*3];
            rules_range = [len_gene-nMFs+1  len_gene]; 
            % day= gene(day_range);
            % month = gene(month_range);
            rules = gene(rules_range);

            % day = GeneValidation.validate_day(day); %day segment
            % month = GeneValidation.validate_month(month); %month segment
            rules = GeneValidation.validate_rules(rules, nMFs);

            % gene(day_range) = day;
            % gene(month_range) = month; %input related segments
            gene(rules_range) = rules;
        end

        function [gene] = validate_day(gene)
            gene = round(gene);
            gene(gene<1) = 1;
            gene(gene>7)= 7;
        end
        
        function [gene] = validate_month(gene)
            gene = round(gene);
            gene(gene<1) = 1;
            gene(gene>12)=12;
        end
        
        function [rules] = validate_rules(gene, nMFs)
            rules = round(gene);
            rules(rules<0) = 0;
            rules(rules>nMFs) = nMFs;
        end

        function [mon_num] = convert_month(mon)
            switch mon
                case 'jan'
                    mon_num = 1;
                case 'feb'
                    mon_num = 2;
                case 'mar'
                    mon_num = 3;
                case 'apr'
                    mon_num = 4;
                case 'may'
                    mon_num = 5;
                case 'jun'
                    mon_num = 6;
                case 'jul'
                    mon_num = 7;
                case 'aug'
                    mon_num = 8;
                case 'sep'
                    mon_num = 9;
                case 'oct'
                    mon_num = 10;
                case 'nov'
                    mon_num = 11;
                case 'dec'
                    mon_num = 12;
            end
        end

        function [day_num] = convert_day(day)
            switch day
                case 'mon'
                    day_num = 1;
                case 'tue'
                    day_num = 2;
                case 'wed'
                    day_num = 3;
                case 'thu'
                    day_num = 4;
                case 'fri'
                    day_num = 5;
                case 'sat'
                    day_num = 6;
                case 'sun'
                    day_num = 7;
            end
        end

    
    end
end
