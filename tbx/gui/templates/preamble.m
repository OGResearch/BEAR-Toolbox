%% Automatically generated BEAR Toolbox script 
%
% This script was generated based on the user input from the BEAR Toolbox
% Graphical User Interface. Feel free to edit and adapt it furthere to your
% needs.
%
% Generated ?TIMESTAMP?
%


%% Clear workspace 

% Clear all variables
clear

% Close all figures
close all

% Rehash Matlab search path
rehash path

% Import the correct module
import ?MODULE?.*


%% Define convenience functions for future use 

% User choice of percentiles
percentiles = ?PERCENTILES?;

% Aggregation functions used to summarize distributions
prctilesFunc = @(x) prctile(x, percentiles, 2);
medianFunc = @(x) median(x, 2);
extremesFunc = @(x) [min(x, [], 2), max(x, [], 2)];


%% Prepare output folder 

outputFolder = fullfile(".", ?OUTPUT_FOLDER?);
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end


%% Set up print functions

printInfo = ?PRINT_INFO?;
printTable = ?PRINT_TABLE?;
printObject = ?PRINT_OBJECT?;

