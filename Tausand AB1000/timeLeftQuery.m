function [ time_left_ms ] = timeLeftQuery( abacus_object )
%TIMELEFTQUERY Reads time left for next measurement, in ms.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 10-Mar-2021
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.
%      March 2021. Returns unsigned integer.

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)    
end

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 84;
else%if device_type == 1002, 1502 or 1902
    address = 31;
end

%% Read single register
time_left_ms=readSingleRegister(abacus_object,address);

%time_left_ms=data_out(1);
%if device_type == 1002
if ~is32bitdevice %if device_type == 1002, 1502 or 1902
    %if first bit is '1', indicates the remaining bits have the value in seconds
    if time_left_ms >= 32768
        time_left_ms = (time_left_ms-32768)*1000;
    end
end

time_left_ms = uint32(time_left_ms);

end

