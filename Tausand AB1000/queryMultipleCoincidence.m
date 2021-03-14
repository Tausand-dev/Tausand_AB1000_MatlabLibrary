function [ config_string, config_value ] = queryMultipleCoincidence( abacus_object )
%QUERYMULTIPLECOINCIDENCE Reads the configuration of the multiple coincidence counters from a Tausand Abacus. Not available in AB1002.
%   config_string returns the letters of the enabled channels in multi-fold
%   coincidence configuration
%
%   config_value is an integer associated with the following binary
%   representations, for 3-fold coincidences:
%   b"1110 0000": ABC
%   b"1011 0000": ABD
%   ...
%   b"0000 0111": FGH
%   and for 4-fold coincidences
%   b"1111 0000": ABCD
%   b"1110 1000": ABCE
%   ...
%   b"0000 1111": EFGH

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 11-Mar-2021
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end

config_value = -1;
config_string = "";

%% Get device type
[device_type,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Read addresses for specific device type
if is32bitdevice %if device_type == 1004, 1504 or 1904
    address = 88;
    config_value=readSingleRegister(abacus_object,address);
    
    %extract the enabled channels as a sequence of letters
    selectedChannels=boolean(bitget(config_value,8:-1:1));
    allChannels='A':'H';
    config_string=allChannels(selectedChannels);
else%if device_type == 1002, 1502 or 1902
    warning('TAUSAND:incorrectType',['Multiple coincidence feature does not exist in Tausand Abacus ',num2str(device_type)])
    return
end


end

