function [list]  = interval_sort(list, subset,end_point)
    %interval_sort sort nums in each subset of the list in ascending order
    %intentionaly skips last ones in Rules
    
    for pos = 1:subset:(end_point-subset+1)       % length(list)-subset+1
        last_idx = pos + subset - 1;
        for ii = pos:last_idx
            min_idx = ii;
            for j = ii+1:last_idx
                if list(min_idx) > list(j)
                    min_idx = j;
                end
            end
            list([min_idx ii]) = list([ii min_idx]);
        end
    end
end