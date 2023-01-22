function [ value_ns ] = configureSleep( abacus_object, channel_char, value_ns )
%CONFIGURESLEEP Writes a single sleep time in a Tausand Abacus.
%   Y = configureSleep(OBJ,CHR,X) changes the sleep time configuration of 
%	the single channel specified in character CHR of the Tausand Abacus 
%   device connected to serial port object OBJ. Assigns a sleep time of X 
%   nanoseconds. Returns Y as the actual new value of sleep time in 
%   nanoseconds after coercing input values.
%
%   The sleep time indicates to a channel that once a pulse arrives at time
%   T1, any pulse that arrives between t = T1 and t = T1 + X has to be 
%   ignored.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign sleep in B = 20ns:
%       configureSleep(abacus_obj,'B',20);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also CONFIGURECHANNEL, QUERYSLEEP.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2023-01-22. Version: 1.2.
%
% v1.2. 2023-01. Includes AB2002, AB2004, AB2502, AB2504 as valid devices.
% v1.1. 2020-07. Includes different resolutions, depending on each device.
% Accepts AB1502, AB1504, AB1902, AB1904 as valid device types.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)    
end
if ~isnumeric(value_ns)
    errorStruct.message = 'Input ''value_ns'' must be a number.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)    
end
if isstring(channel_char)
    %if input is a string, convert to a char array
    channel_char = char(channel_char);
end
if length(channel_char) ~= 1
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

%% Get device type and resolution
[device_type,is32bitdevice,num_channels]=getDeviceTypeFromName(abacus_object);
resolution_ns = getResolutionFromName(abacus_object); %new on v1.1 (2020-07-07)

%% Assign address for specific device type
if is32bitdevice %when using 32-bit devices
    if (num_channels == 4) %devices: 1004,1504,1904,2004,2504
        address = 72:75; %sleepA..sleepD
    else %devices: 2002, 2502
        address = 72:73; %sleepA,sleepB
    end
else%when using 16-bit devices: 1002, 1502 or 1902
    address = [8,12];
end

if (numChannel <= length(address)) && (numChannel > 0)
   address =  address(numChannel);
else
   address = 0;
   errorStruct.message = ['Input ''channel_char'' is not a valid channel for Tausand Abacus AB',num2str(device_type)];
   errorStruct.identifier = 'TAUSAND:invalidInput';
   error(errorStruct)
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

value_ns = uint32(value_ns);

end
