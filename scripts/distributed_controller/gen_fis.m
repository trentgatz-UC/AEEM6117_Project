function [fis] = gen_fis(fis, vec)
    subset = sort(vec(1:3));
    fis.input(1).mf(1).params = [-1e9 subset(1) subset(2)];
    fis.input(1).mf(2).params = [subset];
    fis.input(1).mf(3).params = [subset(2) subset(3) 1e9];
    
	subset = sort(vec(4:6));
	fis.input(2).mf(1).params = [-1e9 subset(1) subset(2)];
    fis.input(2).mf(2).params = [subset];
    fis.input(2).mf(3).params = [subset(2) subset(3) 1e9];
	
	subset = sort(vec(7:9));
	fis.input(3).mf(1).params = [-1e9 subset(1) subset(2)];
    fis.input(3).mf(2).params = [subset];
    fis.input(3).mf(3).params = [subset(2) subset(3) 1e9];
	
	subset = sort(vec(10:12));
    fis.output(1).mf(1).params = [-1e9 subset(1) subset(2)];
    fis.output(1).mf(2).params = [subset];
    fis.output(1).mf(3).params = [subset(2) subset(3) 1e9];


    start_pos =36;
    for i = 1:size(fis.Rules, 2)
        fis.rule(i).consequent = vec(start_pos+i);
    end
end