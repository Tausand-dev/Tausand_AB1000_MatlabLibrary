function [ value_ms ] = configureSamplingTime( abacus_object , value_ms )
%CONFIGURESAMPLINGTIME Writes the sampling time in a Tausand Abacus.
%   Value in miliseconds.
%   Applies data validation before writting by coercing values if required.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 7-Jul-2020
% v1.1 July 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);
is32bitdevice = ~ismember(device_type,[1002,1502,1902]);%new on v1.1 (2020-07-07)

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
value_ms = value_ms + value_s*1000;

end

