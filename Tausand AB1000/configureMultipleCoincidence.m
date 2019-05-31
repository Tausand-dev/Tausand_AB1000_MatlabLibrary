function [ config_string, config_value ] = configureMultipleCoincidence( abacus_object, config_string )
%CONFIGUREMULTIPLECOINCIDENCE Writes a single multiple coincidence configuration
%   Has no effect in AB1002.
%
%   config_string contains the letters of the enabled channels in a 
%   multi-fold coincidence configuration. Examples: 'ABC', 'ABD',..., 'ABCD'
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

    %% Get device type
    device_type=getDeviceTypeFromName(abacus_object);

    %% Read addresses for specific device type
    if device_type == 1002
        disp('Multiple coincidence feature does not exist in Tausand Abacus AB1002.')
        return
    else%if device_type == 1004

        %% String coerce
        config_string = unique(char(upper(config_string))); %sorts and removes repeated letters
        length_string = strlength(config_string);
        if (length_string == 3) 
            valid_string = any(contains(['ABC','ABD','ACD','BCD'],config_string)); %is a 3-fold valid case?
        elseif(length_string == 4)
            valid_string = isequal('ABCD',config_string);  %is the only 4-fold valid case?
        else
            valid_string = false;
            disp('String must have 3 or 4 different letters. Multi-fold configuration cancelled.')
            return
        end

        %% Config_value calculation    
        if valid_string
            config_value = 0;
            for x='A':'D'
                config_value = bitshift(config_value,1);
                if contains(config_string,x)
                    config_value = config_value + 1;
                end
            end
            config_value = bitshift(config_value,4); %E..H for future use
        else
            disp('Invalid string. Multi-fold configuration cancelled.')
            return
        end

        %% Write operation
        address = 88;   %config_multiple_1
        writeSerial32(abacus_object,"write",address,config_value);

    end

end

