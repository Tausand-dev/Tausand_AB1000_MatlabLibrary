function [ value_ms ] = querySamplingTime( abacus_object )
%QUERYSAMPLINGTIME Reads the sampling time, in ms, from a Tausand Abacus.
%   Y = querySamplingTime(OBJ) reads the current configuration of the
%   sampling time on the Tausand Abacus device connected to serial port 
%   object OBJ. Returns Y as the actual value of sampling time, in 
%   milliseconds.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign sampling time = 2s = 2000ms:
%       configureSamplingTime(abacus_obj,2000);
%
%     % To read current sampling time:
%       my_sampling_ms = querySamplingTime(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also CONFIGURESAMPLINGTIME.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-08. Includes new devices AB1502, AB1504, AB1902 and AB1904.
%       2021-03. Returns unsigned integer.
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

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
    address = 80;
    value_ms=readSingleRegister(abacus_object,address);
    [~,~,value_ms,value_s]=convertSciToEng(value_ms);
else%if device_type == 1002, 1502 or 1902
    address = 18;
    value_ms=readSingleRegister(abacus_object,address);
    address = 19;
    value_s=readSingleRegister(abacus_object,address);
end


%% Calculate value in ms
value_ms = uint32(value_ms + value_s*1000);

end
