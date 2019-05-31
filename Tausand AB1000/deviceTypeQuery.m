function [ device_type ] = deviceTypeQuery( abacus_object )
%DEVICETYPEQUERY Returns an integer with the Tausand Abacus device type (1002 or 1004)
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

text=idnQuery(abacus_object);
if isempty(text)
    text="";
end
if contains(text,"AB1004")
    device_type=1004;
elseif contains(text,"AB1002")
    device_type=1002;
else
    device_type=0;
end

end

