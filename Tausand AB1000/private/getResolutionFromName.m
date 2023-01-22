function [ resolution_ns ] = getResolutionFromName( abacus_object )
%GETRESOLUTIONFROMNAME Obtains device resolution, in ns, from the 'Name' parameter in a serial object.
%   Gets the 'Name' parameter, searches for AB1x0x strings on it,
%   and returns a number associated to the resolution of the device, in 
%   nanoseconds. If the device type is not written in the 'Name', a Query 
%   is made to the connected device.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% Created 2020-07; Last update: 22-Jan-2023
% v1.2 2023-01. Includes AB20xx and AB25xx as valid device types.

    serial_name = get(abacus_object,'Name');
    if contains(serial_name,"AB10")
        resolution_ns=5;
    elseif contains(serial_name,"AB15")
        resolution_ns=2;
    elseif contains(serial_name,"AB19")
        resolution_ns=1;
    elseif contains(serial_name,"AB20")
        resolution_ns=5;
    elseif contains(serial_name,"AB25")
        resolution_ns=2;
    else
        warning('Not a valid device. Resolution set to 5ns (default).')
        resolution_ns=5;
    end

end
