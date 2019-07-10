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
% May 2019; Last revision: 31-May-2019

config_value = -1;
config_string = "";

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);


%% Read addresses for specific device type
if device_type == 1002
    disp('Multiple coincidence feature does not exist in Tausand Abacus AB1002.')
    return
else%if device_type == 1004
    address = 88;
    config_value=readSingleRegister(abacus_object,address);
    
    %extract the enabled channels as a sequence of letters
    selectedChannels=boolean(bitget(config_value,8:-1:1));
    allChannels='A':'H';
    config_string=allChannels(selectedChannels); 
end



end

