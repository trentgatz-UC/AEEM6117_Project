function [y_fuz] = M_FIS(x1, x2, MF)
%M_FIS Mamdani Fuzzy Inference System

    %determine percent membership in each of the membership functions
    X1 = Triangle_MF.determine_membership(x1 ,MF.X1);
    X2 = Triangle_MF.determine_membership(x2, MF.X2);

    %% Rules
    % Every combimation of X & Y Input Membership Functions
    % only using AND rules, AND == min

    mu = zeros(size(X1));%1,length(X1)); %initialize mu
    for n = 1:size(MF.Rules,1)
        for m = 1:size(MF.Rules,2)
            outputMF = MF.Rules(n,m); % determine rule
            if outputMF == 0
                % implies that the combination of input and output does
                % not need a rule
                continue 
            end
            % take the maximum of the input membership functions assigned
            % to the rule
            mu(:,outputMF) = max(mu(:,outputMF), min(X1(:,n), X2(:,m)));
        end
    end

    %% Defuzzification
    % Solve for area of each output membership function.
    % Find center of area for the entirety of the output

    A = 0.5 * mu .* (MF.Y(:,3)' - MF.Y(:,1)');
    unison_area = sum(A,2);
    y_fuz = sum(A .* MF.Y(:,2)',2)/unison_area;
    y_fuz = y_fuz(:,1);
end