function [ value_ns ] = queryCoincidenceWindow( abacus_object )
%QUERYCOINCIDENCEWINDOW Reads the coincidence window, in ns, from a Tausand Abacus.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Read addresses for specific device type
if device_type == 1002
    address = 20;
    value_ns=readSingleRegister(abacus_object,address);
    address = 21;
    value_us=readSingleRegister(abacus_object,address);
else%if device_type == 1004
    address = 81;
    value_ns=readSingleRegister(abacus_object,address);
    [value_ns,value_us]=convertSciToEng(value_ns);
end

%% Calculate value in ns
value_ns = value_ns + value_us*1000;

end

