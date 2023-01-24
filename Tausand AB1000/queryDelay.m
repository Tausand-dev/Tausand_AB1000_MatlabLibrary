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

% Author: David Guzm�n.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2023-01-22. Version: 1.2.
%
% v1.2. 2023-01. Includes AB2002, AB2004, AB2502, AB2504 as valid devices.
% v1.1. 2020-08. Includes new devices AB1502, AB1504, AB1902 and AB1904.
%       2021-03. Returns unsigned integer.
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

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
[device_type,is32bitdevice,num_channels]=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if is32bitdevice %when using a 32-bit device: 1004, 1504, 1904, 2002, 2004, 2502, 2504
    if (num_channels >= 4) %devices: 1004, 1504, 1904, 2004, 2504
        address = 64:67; %delayA..delayD
    else %if 2-channel devices: 2002, 2502
        address = 64:65; %delayA,delayB
    end
else%when using a 16-bit device: 1002, 1502 or 1902
    address = [0,4];
end

if (numChannel <= length(address)) && (numChannel > 0)
   address =  address(numChannel);
else
    %error('Invalid channel char.')
    errorStruct.message = ['Input ''channel_char'' is not a valid channel for Tausand Abacus AB',num2str(device_type)];
    errorStruct.identifier = 'TAUSAND:invalidInput';
    error(errorStruct)
   %return
end

%% Read single register
value_ns=readSingleRegister(abacus_object,address);

if is32bitdevice
    value_ns=convertSciToEng(value_ns); %conversion not required for AB1x02
end

value_ns = uint32(value_ns);

end

