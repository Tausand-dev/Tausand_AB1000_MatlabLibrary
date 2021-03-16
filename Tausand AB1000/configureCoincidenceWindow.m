function [ value_ns ] = configureCoincidenceWindow( abacus_object, value_ns )
%CONFIGURECOINCIDENCEWINDOW Writes the coincidence window in a Tausand Abacus.
%   Y = configureCoincidenceWindow(OBJ,X) changes the configuration of the
%   coincidence window to X nanoseconds on the Tausand Abacus device 
%   connected to serial port object OBJ. Returns Y as the actual new value 
%   of coincidence window, in nanoseconds, after coercing input value.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign coincidence window = 300ns:
%       configureCoincidenceWindow(abacus_obj,300);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also QUERYCOINCIDENCEWINDOW.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-07. Includes different resolutions, depending on each device.
%       Accepts AB1502, AB1504, AB1902, AB1904 as valid device types.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end
if ~isnumeric(value_ns)
    errorStruct.message = 'Input ''value_ns'' must be a number.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end


%% Get device type and resolution
[device_type,is32bitdevice]=getDeviceTypeFromName(abacus_object);
resolution_ns = getResolutionFromName(abacus_object); %new on v1.1 (2020-07-07)


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
value_ns = uint32(value_ns + value_us*1000);


end