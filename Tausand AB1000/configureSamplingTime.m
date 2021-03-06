function [ value_ms ] = configureSamplingTime( abacus_object , value_ms )
%CONFIGURESAMPLINGTIME Writes the sampling time in a Tausand Abacus.
%   Y = configureSamplingTime(OBJ,X) changes the configuration of the
%   sampling time to X milliseconds on the Tausand Abacus device connected 
%   to serial port object OBJ. Returns Y as the actual new value of 
%   sampling time, in milliseconds, after coercing input value.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign sampling time = 2s = 2000ms:
%       configureSamplingTime(abacus_obj,2000);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also QUERYSAMPLINGTIME.

% Author: David Guzm�n.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-07. Includes new devices AB1502, AB1504, AB1902 and AB1904.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)   
end
if ~isnumeric(value_ms)
    errorStruct.message = 'Input ''value_ms'' must be a number.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)       
end

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Data validation: coerce
if value_ms < 1
    value_ms = 1;   %minimum 1ms
elseif value_ms > 1000000 
    value_ms = 1000000; %maximum 1000s for any device
end

if ~is32bitdevice %if device_type == 1002, 1502 or 1902
    valid_values = [1,2,5,10,20,50,100,200,500,1000,2000,5000,10000,...
        20000,50000,100000,200000,500000,1000000];
    distance=abs(valid_values-value_ms);
    value_ms=valid_values(min(distance)==distance); %finds the closest value
    value_ms=value_ms(1); %guarantees to take only one value, in case of tie
end

%% Split into ms,s
num=value_ms;
value_ms = rem(num,1000);
num=floor(num/1000);
value_s = num;

%% Write in addresses for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 80;
    value_msToAbacus=convertEngToSci(0,0,value_ms,value_s);
    writeSerial32(abacus_object,"write",address,value_msToAbacus);
    [~,~,value_ms,value_s]=convertSciToEng(value_msToAbacus);    
else%if device_type == 1002, 1502 or 1902
    address = 18;
    writeSerial(abacus_object,"write",address,value_ms);
    address = 19;
    writeSerial(abacus_object,"write",address,value_s);
end

%% Calculate value in ms
value_ms = uint32(value_ms + value_s*1000);

end

