function [ value_ns ] = queryDelay( abacus_object, channel_char )
%QUERYDELAY Reads the delay in a given channel, in ns, from a Tausand Abacus.
%   Y = queryDelay(OBJ,CHR) reads the delay configuration of the single 
%   channel specified in character CHR of the Tausand Abacus device 
%   connected to serial port object OBJ. Returns Y, the current delay in 
%   nanoseconds.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign delay in B = 20ns:
%       configureDelay(abacus_obj,'B',20);
%
%     % To read current delay in B:
%       my_delay_B_ns = queryDelay(abacus_obj,'B');
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also CONFIGURECHANNEL, CONFIGUREDELAY.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 11-Mar-2021
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.
%      March 2021. Returns unsigned integer.

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)       
end
if isstring(channel_char)
    %if input is a string, convert to a char array
    channel_char = char(channel_char);
end
if length(channel_char)> 1
    errorStruct.message = 'Input ''channel_char'' must be a single char.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end

%build numChannel array mapping channel_char: A-->1, B-->2,...
numChannel = uint8(channel_char);
if numChannel >= uint8('a')
    numChannel = numChannel - uint8('a') + 1;
elseif numChannel >= uint8('A')
    numChannel = numChannel - uint8('A') + 1;
end

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 64:67;
else%if device_type == 1002, 1502 or 1902
    address = [0,4];
end

if (numChannel <= length(address)) && (numChannel > 0)
   address =  address(numChannel);
else
    %error('Invalid channel char.')
    errorStruct.message = 'Input ''channel_char'' is not a valid channel.';
    errorStruct.identifier = 'TAUSAND:invalidInput';
    error(errorStruct)
   %return
end

%% Read single register
value_ns=readSingleRegister(abacus_object,address);
%if device_type~=1002
if is32bitdevice
    value_ns=convertSciToEng(value_ns); %conversion not required for AB1x02
end

value_ns = uint32(value_ns);

end

