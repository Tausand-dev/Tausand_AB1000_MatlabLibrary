function [ id ] = countersIdQuery( abacus_object )
%COUNTERSIDQUERY Reads ID of last measurement. Integer consecutive number.
%   Y = countersIdQuery(OBJ) returns the current available consecutive data
%   measurement integer identifier, Y, on the Tausand Abacus device 
%   connected to serial port object OBJ.
%
%   When configuration in the device changes, this identifier resets to 0.
%   This value may overflow at 1 million.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To read current counters ID:
%       my_first_id = countersIdQuery(abacus_obj);
%
%     % Wait to a new data set to be avaiable to read:
%       waitForAcquisitionComplete(abacus_obj);
%
%     % To read once again current counters ID:
%       my_second_id = countersIdQuery(abacus_obj);
%
%       if my_second_id == (my_first_id + 1)
%           disp('Success. New set of data available.');
%       elseif my_second_id ~= my_first_id
%           disp('Fair success. New set of data available; some missing data.');
%       end
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 15-Mar-2021
% v1.1 July 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)     
end

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if is32bitdevice %device_type == 1004, 1504 or 1904
    address = 83;
else%if device_type == 1002, 1502 or 1902
    address = 30;
end

%% Read single register
id=readSingleRegister(abacus_object,address);

end

