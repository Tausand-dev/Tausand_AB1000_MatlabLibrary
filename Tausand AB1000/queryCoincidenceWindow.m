function [ value_ns ] = queryCoincidenceWindow( abacus_object )
%QUERYCOINCIDENCEWINDOW Reads the coincidence window, in ns, from a Tausand Abacus.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 11-Mar-2021
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);


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
value_ns = uint32(value_ns + value_us*1000);

end

