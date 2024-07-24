function [fis] = FIS_setup_centralized(nMFs)
% FIS_setup - Create initial FIS for training
% [fis] = FIS_setup(nMFs);
%   - if nMFs is not provided, 3 is assumed
arguments
    nMFs = 3;
end

fis = mamfis('Name', 'RobotController',...
    'NumInputs', 3,...
    'NumInputMFs', nMFs,...
    'NumOutputs', 2,...
    'NumOutputMFs', nMFs,...
    'MFType', "trimf",...
    'AddRules', "allcombinations");

vel_range = [-20 20]; % Starting Assumption

fis.Inputs(1).Name = "Distance to Target";
fis.Inputs(1).Range = [0 0.866]; % Valid distances between object and target

fis.Inputs(2).Name = "Object X Velocity";
fis.Inputs(2).Range = vel_range;

fis.Inputs(3).Name = "Object Y Velocity";
fis.Inputs(3).Range = vel_range;

fis.Outputs(1).Name = "X Velocity Input";
fis.Outputs(1).Range = vel_range;

fis.Outputs(2).Name = "Y Velocity Input";
fis.Outputs(2).Range = vel_range;
end