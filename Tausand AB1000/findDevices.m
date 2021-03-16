function [ ports, count ] = findDevices( device_type )
%FINDDEVICES Scans and finds serial ports with Tausand Abacus devices.
%   [S,N] = findDevices()   Scans every serial port in the computer, tries
%   to open them as a Tausand Abacus device, with any valid reference (i.e.
%   AB1002, AB1004, AB1502, AB1504, AB1902, AB1904). Returns a string array 
%   S with the current valid ports responding adequately, and the size N of
%   this array.
%
%   [S,N] = findDevices(X)   Scans every serial port in the computer, tries
%   to open them as a Tausand Abacus device, matching with the device type
%   indicated in the integer value X. Valid values of input X are: 1002,
%   1004, 1502, 1504, 1902 and 1904. Returns a string array S with the 
%   current valid ports responding adequately with matching type, and the 
%   size N of this array.
%
%   Once you find the serial port associated to your device, you do not 
%   need to use this function anymore. The first time a Tausand Abacus 
%   device connects to a computer, it gets a unique serial port that is 
%   assigned and reserved for future connections.
%
%   Example:
%     % Scan and find serial ports with any Tausand Abacus device:
%       [my_ports, num_ports] = findDevices();
%
%     % Connect and disconnect to the first found device:
%       if num_ports > 0
%           abacus_obj = openAbacus(my_ports{1});   %connect
%           disp(['Connected to Tausand Abacus in port ',my_ports{1}]);
%           % use the device (read, configure,...)
%           closeAbacus(abacus_obj);    %disconnect
%       else
%           disp('No Tausand Abacus devices were found');
%       end
%
%     % Scan and find serial ports with Tausand Abacus AB1504 devices:
%       [my_ports_1504, num_ports_1504] = findDevices(1504);
%
%   See also CLOSEABACUS, DEVICETYPEQUERY, IDNQUERY, OPENABACUS.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-07. Input 'device_type' is not mandatory.
%                Warnings thrown by deviceTypeQuery are turned off.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if nargin == 0
    device_type = 0;    %look for any Tausand Abacus device
end
if ~isnumeric(device_type)
    errorStruct.message = 'Input ''device_type'' must be a number (e.g.: 1002, 1504).';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end

%% Function code
fullList = seriallist; %gets serial ports on system
k=1;
numSerials=length(fullList);
types=zeros(numSerials,1);
warning('off','TAUSAND:timeout');
for a=fullList
    myobject=openAbacus(a);
    types(k,1)=deviceTypeQuery(myobject);
    fclose(myobject);
    fprintf('Progress: %d/%d\n',k,numSerials)
    k=k+1;
end
warning('on','TAUSAND:timeout');
if device_type == 0
    ports=fullList(types>0); %returns elements that match any Tausand device
else
    ports=fullList(types==device_type); %returns elements that match the specific Tausand device type
end
count=length(ports);

end