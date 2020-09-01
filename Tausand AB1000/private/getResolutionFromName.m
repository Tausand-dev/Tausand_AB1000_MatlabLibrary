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
% July 2020; Last update: 7-Jul-2020

    serial_name = get(abacus_object,'Name');
    if contains(serial_name,"AB10")
        resolution_ns=5;
    elseif contains(serial_name,"AB15")
        resolution_ns=2;
    elseif contains(serial_name,"AB19")
        resolution_ns=1;
    else
        disp('not a valid device. Resolution set to 5ns (default)')
        resolution_ns=5;
    end

end
