function [ config_string, config_value ] = queryMultipleCoincidence( abacus_object )
%QUERYMULTIPLECOINCIDENCE Reads multiple-coincidence counter configuration.
%   [STR,X] = queryMultipleCoincidence(OBJ) reads the current configuration 
%   of the multiple coincidence counter on the Tausand Abacus device 
%   connected  to serial port object OBJ, in order to measure 3-fold or 
%   4-fold coincidences as indicated by the 3 or 4 character long string 
%   STR. Each character in the string STR represents each input channel. 
%   Returns the applied configuration string STR, and its corresponding 
%   config_value X.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To configure a 4-fold coincidence between channels A, B, C and D:
%       configureMultipleCoincidence(abacus_obj,"ABCD");
%
%     % To read current multi-fold coindicence counter configuration:
%       multifold_config_string = queryMultipleCoincidence(abacus_obj);
%
%     % Wait to a new data set to be avaiable to read:
%       waitForAcquisitionComplete(abacus_obj);
%
%     % Read multi-fold coincidences, by looking for label "counter_multiple_1":
%       [data,labels]=readMeasurement(abacus_obj);
%       mutli_fold_value = data(labels=="counter_multiple_1");
%
%     % Alternative to wait and read multi-fold data, using
%     % waitAndGetValues function:
%       [data,labels]=waitAndGetValues(abacus_obj,["multiple_1","A","AB"]);
%       mutli_fold_value = data(labels=="counter_multiple_1");
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   Output 'config_value' X is an integer associated with the following 
%   binary representations, for 3-fold coincidences:
%   b"1110 0000": ABC
%   b"1011 0000": ABD
%   ...
%   b"0000 0111": FGH
%   and for 4-fold coincidences
%   b"1111 0000": ABCD
%   b"1110 1000": ABCE
%   ...
%   b"0000 1111": EFGH
%
%   This function does not work on devices with less than 4 input channels,
%   e.g. AB1002, AB1502, AB1902.
%
%   See also CONFIGUREMULTIPLECOINCIDENCE, READMEASUREMENT.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-08. Includes new devices AB1502, AB1504, AB1902 and AB1904.
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

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

