function [ delay_ns, sleep_ns ] = configureChannel( abacus_object, channel_char, delay_ns, sleep_ns )
%CONFIGURECHANNEL Configures the characteristics of the channel to which an input is connected.
%   Channel must be specified as char ('A','B',...)
%   Values in nanoseconds.
%   Applies data validation before writting by coercing values if required.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

delay_ns = configureDelay(abacus_object,channel_char,delay_ns);
sleep_ns = configureSleep(abacus_object,channel_char,sleep_ns);

end

