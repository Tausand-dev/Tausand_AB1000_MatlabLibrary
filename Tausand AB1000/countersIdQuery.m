function [ id ] = countersIdQuery( abacus_object )
%COUNTERSIDQUERY Reads ID of last measurement. Integer consecutive number.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 7-Jul-2020
% v1.1 July 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);
is32bitdevice = ~ismember(device_type,[1002,1502,1902]);%new on v1.1 (2020-07-07)

%% Assign address for specific device type
if is32bitdevice %device_type == 1004, 1504 or 1904
    address = 83;
else%if device_type == 1002, 1502 or 1902
    address = 30;
end

%% Read single register
id=readSingleRegister(abacus_object,address);

end

