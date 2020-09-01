function [ value_ns ] = configureCoincidenceWindow( abacus_object, value_ns )
%CONFIGURECOINCIDENCEWINDOW Writes the coincidence window in a Tausand Abacus.
%   Value in nanoseconds.
%   Applies data validation before writting by coercing values if required.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 7-Jul-2020
% v1.1 July 2020. Includes different resolutions, depending on each device.
% Accepts AB1502, AB1504, AB1902, AB1904 as valid device types.

%% Get device type and resolution
[device_type,is32bitdevice]=getDeviceTypeFromName(abacus_object);
resolution_ns = getResolutionFromName(abacus_object); %new on v1.1 (2020-07-07)
%is32bitdevice = ~ismember(device_type,[1002,1502,1902]);%new on v1.1 (2020-07-07)

%% Data validation: coerce
if value_ns < resolution_ns %updated on v1.1 (2020-07-07)
    value_ns = resolution_ns;   %set minimum to resolution
elseif (value_ns > 50000) && (device_type == 1002)
    value_ns = 50000; %maximum 50us for AB1002
elseif value_ns > 10000 
    value_ns = 10000; %maximum 10us for any other device
elseif (value_ns > 100) && (device_type ~= 1002) %new on v1.1 (2020-07-07)
    resolution_ns = 10; %set resolution to 10ns when coinWind>100ns
end

value_ns = value_ns+resolution_ns/2-rem(value_ns+resolution_ns/2,resolution_ns); %round to multiple of resolution_ns

num=value_ns;
value_ns = rem(num,1000);
num=floor(num/1000);
value_us = num;

%% Write addresses for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 81;
    value_nsToAbacus=convertEngToSci(value_ns,value_us,0,0);
    writeSerial32(abacus_object,"write",address,value_nsToAbacus);
    [value_ns,value_us]=convertSciToEng(value_nsToAbacus);    
else %if device_type == 1002, 1502 or 1902
    address = 20;
    writeSerial(abacus_object,"write",address,value_ns);
    address = 21;
    writeSerial(abacus_object,"write",address,value_us);
end

%% Calculate value in ns
value_ns = value_ns + value_us*1000;


end