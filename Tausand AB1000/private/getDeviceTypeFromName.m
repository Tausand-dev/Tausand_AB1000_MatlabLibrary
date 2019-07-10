function [ device_type ] = getDeviceTypeFromName( abacus_object )
%GETDEVICETYPEFROMNAME Obtains device type from the 'Name' parameter in a serial object.
%   Gets the 'Name' parameter, searches for AB1002 or AB1004 strings on it,
%   and returns a number associated to the device. If the device type is
%   not written in the 'Name', a Query is made to the connected device.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    serial_name = get(abacus_object,'Name');
    if contains(serial_name,"AB1004")
        device_type=1004;
    elseif contains(serial_name,"AB1002")
        device_type=1002;
    else
        device_type=DeviceTypeQuery(abacus_object);
        if (device_type ~= 1002) && (device_type ~= 1004)
            %disp('Unknown device type')
            device_type=0;
        end
    end

end
