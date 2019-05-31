function [ value_ns ] = configureDelay( abacus_object, channel_char, value_ns )
%CONFIGUREDELAY Writes a single delay in a Tausand Abacus.
%   Channel must be specified as char ('A','B',...)
%   Value in nanoseconds.
%   Applies data validation before writting by coercing values if required.

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
    address = [0,4];
else%if device_type == 1004
    address = 64:67;
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
value_ns = value_ns+2.5-rem(value_ns+2.5,5); %round to multiple of 5ns

%% Write single register

if device_type==1002
    writeSerial(abacus_object,"write",address,value_ns);
else%if device_type==1004
    value_nsToAbacus=convertEngToSci(value_ns,0,0,0);
    writeSerial32(abacus_object,"write",address,value_nsToAbacus)
    value_ns=convertSciToEng(value_nsToAbacus);
end

end

