%% Confusion Matrix

%Of the values that ARE true

temp_true = area.est(area.true>0); % values that SHOULD be true
temp_false = area.est(area.true<=0);

positive.true = 0; %should be true and is true
positive.false = 0; % should be true and is false
negative.true = 0; %should be false and is true
negative.false = 0;% should be false and is false

for i = 1:length(temp_true)
    if temp_true(i) == min(temp_true)
        positive.false = positive.false+1;
    else
        positive.true = positive.true + 1;
    end
end

for i = 1:length(temp_false)
    if temp_false(i) == min(temp_false)
        negative.true = negative.true+1;
    else
        negative.false = negative.false+1;
    end
end

arr = {'True', positive.true,  positive.false;
        'False', negative.false, negative.true};
conf_matrix = splitvars(table(arr));
conf_matrix.Properties.VariableNames = {'Condition', 'True', 'False'};
disp(conf_matrix)





