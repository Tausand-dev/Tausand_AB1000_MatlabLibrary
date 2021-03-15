function [ time_left_ms ] = timeLeftQuery( abacus_object )
%TIMELEFTQUERY Reads time left for next measurement, in ms.
%   Y = timeLeftQuery(OBJ) returns Y the remaining time, in milliseconds, 
%   for the next set of data to be available on the Tausand Abacus device 
%   connected to serial port object OBJ. Output Y is an unsigned integer.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To read time left for next data set:
%       my_time_ms = timeLeftQuery(abacus_obj);
%
%     % Wait to a new data set to be avaiable to read:
%       pause(double(my_time_ms)/1000);
%
%     % Read a full set of current data in the device:
%       [data,labels] = readMeasurement(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also COUNTERSIDQUERY.

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

