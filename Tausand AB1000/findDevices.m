function [ ports, count ] = findDevices( device_type )
%FINDDEVICES Finds serial ports of Tausand Abacus devices matching device_type. Possible device_type values are: 1002, 1004 or 0 (for both).

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 11-Mar-2021
%   v1.1 Input 'device_type' is not mandatory
%        warnings thrown by deviceTypeQuery are turned off

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