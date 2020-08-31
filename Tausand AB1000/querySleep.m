function [ value_ns ] = querySleep( abacus_object, channel_char )
%QUERYSLEEP Reads the sleep in a given channel, in ns, from a Tausand Abacus.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 31-Aug-2020
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

numChannel = uint8(channel_char);
if numChannel >= uint8('a')
    numChannel = numChannel - uint8('a') + 1;
elseif numChannel >= uint8('A')
    numChannel = numChannel - uint8('A') + 1;
end

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);
is32bitdevice = ~ismember(device_type,[1002,1502,1902]);%new on v1.1 (2020-08-31)

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

%% Read single register
value_ns=readSingleRegister(abacus_object,address);
%if device_type~=1002
if is32bitdevice
    value_ns=convertSciToEng(value_ns); %conversion not required for AB1x02
end

end

