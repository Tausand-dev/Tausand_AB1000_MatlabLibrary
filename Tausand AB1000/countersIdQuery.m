function [ id ] = countersIdQuery( abacus_object )
%COUNTERSIDQUERY Reads ID of last measurement. Integer consecutive number.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 10-Mar-2021
% v1.1 July 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)     
end

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if is32bitdevice %device_type == 1004, 1504 or 1904
    address = 83;
else%if device_type == 1002, 1502 or 1902
    address = 30;
end

%% Read single register
id=readSingleRegister(abacus_object,address);

end

