function [ device_type ] = deviceTypeQuery( abacus_object )
%DEVICETYPEQUERY Returns an integer with the Tausand Abacus device type (1002,1004,1502,1504,1902 or 1904)
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 7-Jul-2020
% v1.1 July 2020. Includes AB1502, AB1504, AB1902, AB1904 as valid device
% types.

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

