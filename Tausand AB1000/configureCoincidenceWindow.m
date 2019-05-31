function [ value_ns ] = configureCoincidenceWindow( abacus_object, value_ns )
%CONFIGURECOINCIDENCEWINDOW Writes the coincidence window in a Tausand Abacus.
%   Value in nanoseconds.
%   Applies data validation before writting by coercing values if required.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Data validation: coerce
if value_ns < 5
    value_ns = 5;   %minimum 5ns
elseif value_ns > 50000 && device_type == 1002
    value_ns = 50000; %maximum 50us for AB1002
elseif value_ns > 10000 
    value_ns = 10000; %maximum 10us for any other device
end
value_ns = value_ns+2.5-rem(value_ns+2.5,5); %round to multiple of 5ns

num=value_ns;
value_ns = rem(num,1000);
num=floor(num/1000);
value_us = num;

%% Write addresses for specific device type
if device_type == 1002
    address = 20;
    writeSerial(abacus_object,"write",address,value_ns);
    address = 21;
    writeSerial(abacus_object,"write",address,value_us);
else%if device_type == 1004
    address = 81;
    value_nsToAbacus=convertEngToSci(value_ns,value_us,0,0);
    writeSerial32(abacus_object,"write",address,value_nsToAbacus);
    [value_ns,value_us]=convertSciToEng(value_nsToAbacus);
end

%% Calculate value in ns
value_ns = value_ns + value_us*1000;


end