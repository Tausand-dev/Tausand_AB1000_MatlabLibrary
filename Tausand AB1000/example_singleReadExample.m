%% Tausand AB1000 Matlab library example: Single Read Example
% Reads once the measurements from a Tausand Abacus device.
%
% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2021-03. Last revision: 2021-03-24. Version: 1.1.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%%
% Change this port to the adequate one:
my_port = 'COM3'; 

%%
% Then open, read, and close device.
my_tausand = openAbacus(my_port);
[data,labels] = readMeasurement(my_tausand);
closeAbacus(my_tausand);