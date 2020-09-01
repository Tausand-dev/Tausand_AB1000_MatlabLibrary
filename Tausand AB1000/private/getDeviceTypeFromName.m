function [ device_type, is32bit, num_channels ] = getDeviceTypeFromName( abacus_object )
%GETDEVICETYPEFROMNAME Obtains device type from the 'Name' parameter in a serial object.
%   Gets the 'Name' parameter, searches for AB1x0x strings on it,
%   and returns a number associated to the device. As a second parameter
%   returns if the device_type uses a 32-bit address system. 2-channel
%   devices use a 16-bit system, while 4 and 8-channel devices use a 32-bit
%   system. As a third parameter returns the input channels.
%   If the device type is not written in the 'Name', a Query is made to the 
%   connected device.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 31-Aug-2020
% v1.1 July 2020. Includes AB1502, AB1504, AB1902, AB1904 as valid device
% types.

    serial_name = get(abacus_object,'Name');
    if contains(serial_name,"AB1002")
        device_type=1002;
    elseif contains(serial_name,"AB1004")
        device_type=1004;
    elseif contains(serial_name,"AB1502")%new on v1.1 (2020-07-07)
        device_type=1502;
    elseif contains(serial_name,"AB1504")%new on v1.1 (2020-07-07)
        device_type=1504;
    elseif contains(serial_name,"AB1902")%new on v1.1 (2020-07-07)
        device_type=1902;
    elseif contains(serial_name,"AB1904")%new on v1.1 (2020-07-07)
        device_type=1904;
    else
        device_type=deviceTypeQuery(abacus_object); %updated on v1.1 (2020-07-07)
        %if not in valid devices list:
        if ~ismember(device_type,[1002,1004,1502,1504,1902,1904]) %updated on v1.1 (2020-07-07)
            %disp('Unknown device type')
            device_type=0;
        end
    end
    
    %new on v1.1:
    is32bit = ~ismember(device_type,[1002,1502,1902]);
    num_channels = mod(device_type,10); %last digit

end
