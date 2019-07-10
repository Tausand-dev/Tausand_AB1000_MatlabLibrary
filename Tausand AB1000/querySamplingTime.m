function [ value_ms ] = querySamplingTime( abacus_object )
%QUERYSAMPLINGTIME Reads the sampling time, in ms, from a Tausand Abacus.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Read addresses for specific device type
if device_type == 1002
    address = 18;
    value_ms=readSingleRegister(abacus_object,address);
    address = 19;
    value_s=readSingleRegister(abacus_object,address);
else%if device_type == 1004
    address = 80;
    value_ms=readSingleRegister(abacus_object,address);
    [~,~,value_ms,value_s]=convertSciToEng(value_ms);
end

%% Calculate value in ms
value_ms = value_ms + value_s*1000;

end
