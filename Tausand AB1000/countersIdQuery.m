function [ id ] = countersIdQuery( abacus_object )
%COUNTERSIDQUERY Reads ID of last measurement. Integer consecutive number.
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Assign address for specific device type
if device_type == 1002
    address = 30;
else%if device_type == 1004
    address = 83;
end

%% Read single register
id=readSingleRegister(abacus_object,address);

end

