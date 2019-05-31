function [ ] = configureByName( abacus_object, labels_strings, values )
%CONFIGUREBYNAME Configure several settings in a Tausand Abacus by label and value pairs.
%   Valid 'labels' are:
%   "sampling": in ms
%   "coincidence_window": in ns
%   "delay_X": delay in ns in channel X
%   "sleep_X": sleep time in ns in channel X
%   "config_multiple_X": multi-fold coincidence configuration for counter X

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    %% Verify equal length of input arrays
    if length(labels_strings) < length(values)
        values = values(1:length(labels_strings));
        disp('Length mismatch: ''values'' has more elements than ''labels_strings''. Last ''values'' are ignored.');
    elseif length(labels_strings) > length(values)
        labels_strings = labels_strings(1:length(values));
        disp('Length mismatch: ''labels_strings'' has more elements than ''values''. Last ''labels_strings'' are ignored.');
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
            fprintf("Label '%s' is not valid. Ignored.\n",text);
        end
        k=k+1;
    end

end

