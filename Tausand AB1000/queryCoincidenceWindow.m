function [ value_ns ] = queryCoincidenceWindow( abacus_object )
%QUERYCOINCIDENCEWINDOW Reads the coincidence window, in ns, from a Tausand Abacus.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 31-Aug-2020
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.


%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);
%is32bitdevice = ~ismember(device_type,[1002,1502,1902]);%new on v1.1 (2020-08-31)

%% Read addresses for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 81;
    value_ns=readSingleRegister(abacus_object,address);
    [value_ns,value_us]=convertSciToEng(value_ns);
else%if device_type == 1002, 1502 or 1902
    address = 20;
    value_ns=readSingleRegister(abacus_object,address);
    address = 21;
    value_us=readSingleRegister(abacus_object,address);
end

%% Calculate value in ns
value_ns = value_ns + value_us*1000;

end

