function [ value_ns ] = configureSleep( abacus_object, channel_char, value_ns )
%CONFIGURESLEEP Writes a single sleep time in a Tausand Abacus.
%   Channel must be specified as char ('A','B',...)
%   Value in nanoseconds.
%   Applies data validation before writting by coercing values if required.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 7-Jul-2020
% v1.1 July 2020. Includes different resolutions, depending on each device.
% Accepts AB1502, AB1504, AB1902, AB1904 as valid device types.

numChannel = uint8(channel_char);
if numChannel >= uint8('a')
    numChannel = numChannel - uint8('a') + 1;
elseif numChannel >= uint8('A')
    numChannel = numChannel - uint8('A') + 1;
end

%% Get device type and resolution
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);
resolution_ns = getResolutionFromName(abacus_object); %new on v1.1 (2020-07-07)

%% Assign address for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 72:75;
else%if device_type == 1002, 1502 or 1902
    address = [8,12];
end

if (numChannel <= length(address)) && (numChannel > 0)
   address =  address(numChannel);
else
   address = 0;
   disp('Invalid channel char.')
   return
end

%% Data validation: coerce
if value_ns < 0
    value_ns = 0;   %minimum 0ns
elseif value_ns > 100
    value_ns = 100; %maximum 100ns
end
value_ns = value_ns+resolution_ns/2-rem(value_ns+resolution_ns/2,resolution_ns); %round to multiple of resolution_ns

%% Write single register
if is32bitdevice%device_type==1004, 1504 or 1904
    value_nsToAbacus=convertEngToSci(value_ns,0,0,0);
    writeSerial32(abacus_object,"write",address,value_nsToAbacus);
    value_ns=convertSciToEng(value_nsToAbacus);
else%if device_type==1002, 1502 or 1902
    writeSerial(abacus_object,"write",address,value_ns);    
end

end
