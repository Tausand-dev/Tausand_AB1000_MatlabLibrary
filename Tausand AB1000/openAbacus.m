function [ abacus_obj ] = openAbacus( port )
%OPENABACUS Opens and configures a Tasuand Abacus AB1000
%   OBJ = openAbacus(STR) returns a serial object OBJ linked to a new 
%   connection established with a Tausand Abacus device, connected in port 
%   STR. If port STR does not exist, is not a Tausand Abacus device, or is 
%   in use, you will not be able to connect the serial port object to the 
%   device. OBJ is a serial port object, that can be used with other 
%   functions to communicate with the device.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To query the identifier of the device:
%       idn = idnQuery(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also CLOSEABACUS.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-09. Sets timeout=0.5s.
%       2021-03. Single append of device reference "ABxxxx" in object name.
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Instrument Connection

% Find a serial port object.
obj1 = instrfind('Type', 'serial', 'Port', port, 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = serial(port);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% Connect to instrument object, obj1.
fopen(obj1);
set(obj1,'BaudRate',115200);    %required baud rate is 115200
device_type_str=strcat(" AB",num2str(deviceTypeQuery(obj1)));
serial_name = get(obj1,'Name');
if ~contains(serial_name,device_type_str) %v1.1
    serial_name = strcat(serial_name,device_type_str);
    set(obj1,'Name',serial_name);    %assign Tag to DeviceType
end
set(obj1,'Timeout',0.5); %set timeout of device to 0.5s. By default Matlab sets timeout to 10s %new on v1.1
abacus_obj = obj1;

end

