function [fis] = gen_fis_centralized(fis, vec)
    fis.input(1).mf(1).params = sort(vec(1:3));
    fis.input(1).mf(2).params = sort(vec(4:6));
    fis.input(1).mf(3).params = sort(vec(7:9));
    
    fis.input(2).mf(1).params = sort(vec(10:12));
    fis.input(2).mf(2).params = sort(vec(13:15));
    fis.input(2).mf(3).params = sort(vec(16:18));
    
    fis.input(3).mf(1).params = sort(vec(19:21));
    fis.input(3).mf(2).params = sort(vec(22:24));
    fis.input(3).mf(3).params = sort(vec(25:27));

    fis.output(1).mf(1).params = sort(vec(28:30));
    fis.output(1).mf(2).params = sort(vec(31:33));
    fis.output(1).mf(3).params = sort(vec(34:36));
    
    fis.output(2).mf(1).params = sort(vec(37:39));
    fis.output(2).mf(2).params = sort(vec(40:42));
    fis.output(2).mf(3).params = sort(vec(43:45));
    
    start_pos =46;
    for i = 1:size(fis.Rules, 2)
        fis.rule(i).consequent = vec(start_pos:start_pos+1);
        start_pos = start_pos + 2;
    end
end