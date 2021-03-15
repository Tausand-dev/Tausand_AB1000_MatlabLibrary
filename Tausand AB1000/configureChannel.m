function [ delay_ns, sleep_ns ] = configureChannel( abacus_object, channel_char, delay_ns, sleep_ns )
%CONFIGURECHANNEL Configures delay and sleep in a single channel.
%   [Z,W] = configureChannel(OBJ,CHR,X,Y) changes the configuration of the
%   single channel specified in character CHR of the Tausand Abacus device 
%   connected to serial port object OBJ. Assigns a delay of X nanoseconds 
%   and a sleep time of Y nanoseconds. Returns Z as the actual new value of 
%   delay in nanoseconds, and W as the actual new value of sleep in 
%   nanoseconds, after coercing input values.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign delay in B = 20ns and sleep in B = 40ns:
%       configureChannel(abacus_obj,'B',20,40);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);


% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end
if ~isnumeric(delay_ns)
    errorStruct.message = 'Input ''delay_ns'' must be a number.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end
if ~isnumeric(sleep_ns)
    errorStruct.message = 'Input ''sleep_ns'' must be a number.';
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

delay_ns = configureDelay(abacus_object,channel_char,delay_ns);
sleep_ns = configureSleep(abacus_object,channel_char,sleep_ns);

end