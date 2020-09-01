function [ abacus_obj ] = openAbacus( port )
%OPENABACUS Opens and configures a Tasuand Abacus AB1000
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 1-Sep-2020
% v1.1 September 2020. Sets timeout=1s.

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
serial_name = strcat(get(obj1,'Name'),device_type_str);
set(obj1,'Name',serial_name);    %assign Tag to DeviceType
set(obj1,'Timeout',1); %set timeout of device to 1s. By default Matlab sets timeout to 10s %new on v1.1
abacus_obj = obj1;


end

