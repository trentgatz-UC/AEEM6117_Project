%% Inputs

% vectorized code about 3 times faster. need to update FIS script to use
% this instead
clc

MF = [0 1 2; 1 2 3; 2 3 4];
cses = linspace(1,4,100);
T1 = nan(1,100);
T2 = nan(1,100);

%% Loooped
for j = 1:10000
    tic
    X1 = nan(length(cses),3);
    for i = 1:length(cses)
        X1(i,:) = determine_membership(cses(i), MF);
    end
    T1(j) = toc;
end
fprintf('Looped Time %.05f\n', sum(T1))

%% vectorized
for j = 1:10000
    tic
    X2 = Triangle_MF.determine_membership(cses,MF);
    T2(j) = toc;
end
fprintf('Vectorized Time %.05f\n', sum(T2))