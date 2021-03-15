function [ ] = configureByName( abacus_object, labels_strings, values )
%CONFIGUREBYNAME Configure Tausand Abacus by label and value pairs.
%   configureByName(OBJ,S,V) changes the configuration of the Tausand 
%   Abacus device with serial port object OBJ, by assigning the numerical 
%   integer values of array V to the settings stated in the string array S.
%
%   Valid 'labels' in array S are:
%   "sampling": in ms
%   "coincidence_window": in ns
%   "delay_I": delay in ns in channel I
%   "sleep_I": sleep time in ns in channel I
%   "config_multiple_J": multi-fold coincidence configuration for counter J
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To assign coincidence window = 50ns and sampling time = 2 seconds:
%       configureByName(abacus_obj,["coincidence_window","sampling"],[50,2000]);
%
%     % To assign delay in A = 0ns and delay in B = 10ns:
%       configureByName(abacus_obj,["delay_A","delay_B"],[0,10]);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also CONFIGURECHANNEL, QUERYALLSETTINGS.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 11-Mar-2021

    %% Input validation
    if ~isa(abacus_object,'serial')
        errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
        errorStruct.identifier = 'TAUSAND:incorrectType';
        error(errorStruct)
    end
    
    if ~isnumeric(values)
        errorStruct.message = 'Input ''values'' must be a numeric array.';
        errorStruct.identifier = 'TAUSAND:incorrectType';
        error(errorStruct)
    end

    % Verify equal length of input arrays
    if length(labels_strings) < length(values)
        values = values(1:length(labels_strings));
        warning('TAUSAND:invalidInput','Length mismatch: ''values'' has more elements than ''labels_strings''. Last ''values'' are ignored.');
    elseif length(labels_strings) > length(values)
        labels_strings = labels_strings(1:length(values));
        warning('TAUSAND:invalidInput','Length mismatch: ''labels_strings'' has more elements than ''values''. Last ''labels_strings'' are ignored.');
    end
    

    %% Configure each request
    k=1;
    for text = lower(labels_strings)
        if text == 'sampling'
            configureSamplingTime(abacus_object,values(k));
        elseif text == 'coincidence_window'
            configureCoincidenceWindow(abacus_object,values(k));
        elseif text == 'delay_a'
            configureDelay(abacus_object,'A',values(k));
        elseif text == 'delay_b'
            configureDelay(abacus_object,'B',values(k));
        elseif text == 'delay_c'
            configureDelay(abacus_object,'C',values(k));
        elseif text == 'delay_d'
            configureDelay(abacus_object,'D',values(k));
        elseif text == 'sleep_a'
            configureSleep(abacus_object,'A',values(k));
        elseif text == 'sleep_b'
            configureSleep(abacus_object,'B',values(k));
        elseif text == 'sleep_c'
            configureSleep(abacus_object,'C',values(k));
        elseif text == 'sleep_d'
            configureSleep(abacus_object,'D',values(k));
        elseif text == 'config_multiple_1'
            %extract the enabled channels as a sequence of letters
            selectedChannels=boolean(bitget(values(k),8:-1:1));
            allChannels='A':'H';
            config_string=allChannels(selectedChannels); 
            configureMultipleCoincidence(abacus_object,config_string);
        else
            warning('TAUSAND:invalidInput','Label ''%s'' is not valid. Ignored.',text);
        end
        k=k+1;
    end

end

