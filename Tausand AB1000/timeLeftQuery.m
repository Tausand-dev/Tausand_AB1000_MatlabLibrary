function [ time_left_ms ] = timeLeftQuery( abacus_object )
%TIMELEFTQUERY Reads time left for next measurement, in ms.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if device_type == 1002
    address = 31;
else%if device_type == 1004
    address = 84;
end

%% Read single register
time_left_ms=readSingleRegister(abacus_object,address);

%time_left_ms=data_out(1);
if device_type == 1002
    %if first bit is '1', indicates the remaining bits have the value in seconds
    if time_left_ms >= 32768
        time_left_ms = (time_left_ms-32768)*1000;
    end
end

end

