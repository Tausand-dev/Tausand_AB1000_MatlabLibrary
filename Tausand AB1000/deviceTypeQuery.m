function [ device_type ] = deviceTypeQuery( abacus_object )
%DEVICETYPEQUERY Returns an integer with the Tausand Abacus device type.
%   Y = deviceTypeQuery(OBJ) returns integer value Y, containing the
%   device type reference of the Tausand Abacus device connected to serial 
%   port object OBJ. Possible return values are: 1002, 1004, 1502, 1504, 
%   1902 or 1904.
%
%   When the device is not recognized, returns Y = 0.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To read device type:
%       my_type = deviceTypeQuery(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also FINDDEVICES, IDNQUERY.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-07. Includes AB1502, AB1504, AB1902, AB1904 as valid device
% types.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)     
end

%% Function code
text=idnQuery(abacus_object);
if isempty(text)
    text="";
end
if contains(text,"AB1004")
    device_type=1004;
elseif contains(text,"AB1002")
    device_type=1002;
elseif contains(text,"AB1504") %new on v1.1 (2020-07-07)
    device_type=1504;
elseif contains(text,"AB1502") %new on v1.1 (2020-07-07)
    device_type=1502;
elseif contains(text,"AB1904") %new on v1.1 (2020-07-07)
    device_type=1904;
elseif contains(text,"AB1902") %new on v1.1 (2020-07-07)
    device_type=1902;    
else
    device_type=0;
end

end

