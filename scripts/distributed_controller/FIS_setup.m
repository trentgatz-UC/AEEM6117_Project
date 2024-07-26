function [fis] = FIS_setup(nMFs)
% FIS_setup - Create initial FIS for training
% [fis] = FIS_setup(nMFs);
%   - if nMFs is not provided, 3 is assumed
arguments
    nMFs = 3;
end

fis = mamfis('Name', 'RobotController',...
    'NumInputs', 1,...
    'NumInputMFs', nMFs,...
    'NumOutputs', 1,...
    'NumOutputMFs', nMFs,...
    'MFType', "trimf",...
    'AddRules', "allcombinations");
voltage_range = [-10 10]; % Starting Assumption

fis.Inputs(1).Name = "Distance to Target";
fis.Inputs(1).Range = [-.866 0.866]; % Valid distances between object and target

fis.Outputs(1).Name = "Voltage";
fis.Outputs(1).Range = voltage_range;
end


