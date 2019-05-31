function [ value_ns ] = querySleep( abacus_object, channel_char )
%QUERYSLEEP Reads the sleep in a given channel, in ns, from a Tausand Abacus.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

numChannel = uint8(channel_char);
if numChannel >= uint8('a')
    numChannel = numChannel - uint8('a') + 1;
elseif numChannel >= uint8('A')
    numChannel = numChannel - uint8('A') + 1;
end

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if device_type == 1002
    address = [8,12];
else%if device_type == 1004
    address = 72:75;
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
if device_type~=1002
    value_ns=convertSciToEng(value_ns); %conversion not required for AB1002
end

end

