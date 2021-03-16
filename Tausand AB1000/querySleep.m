function [ value_ns ] = querySleep( abacus_object, channel_char )
%QUERYSLEEP Reads the sleep in a given channel, in ns, from a Tausand Abacus.
%   Y = querySleep(OBJ,CHR) reads the sleep time configuration of the
%   single channel specified in character CHR of the Tausand Abacus device 
%   connected to serial port object OBJ. Returns Y, the current sleep time 
%   in nanoseconds.
%
%   The sleep time indicates to a channel that once a pulse arrives at time
%   T1, any pulse that arrives between t = T1 and t = T1 + Y has to be 
%   ignored.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign sleep in B = 20ns:
%       configureSleep(abacus_obj,'B',20);
%
%     % To read current sleep in B:
%       my_sleep_B_ns = querySleep(abacus_obj,'B');
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also CONFIGURECHANNEL, CONFIGURESLEEP.

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
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
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
    address = 72:75;
else%if device_type == 1002, 1502 or 1902
    address = [8,12];
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

