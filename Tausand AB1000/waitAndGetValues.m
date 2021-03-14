function [ data_out, labels_out ] = waitAndGetValues( abacus_object, channels, maxwait_s, max_try )
%WAITANDGETVALUES Waits and read counters of the specified channels.
%   Waits until counters_ID changes in a Tausand Abacus. Then, reads a set
%   of measurements. Returns a subset of the measurements, following the
%   specified channels as input.
%
%   Input arguments:
%       abacus_object   Reference to the Tausand Abacus device
%
%   Optional arguments: 
%       channels        String array. Indicates the channels to be read.
%                       Default: return all measurements.
%                       Examples:   
%                           ["A","B","AB"]      to read counts in A, in B,
%                           and coincidences in AB
%                           ["AB","AC","AD"]    to read coindicences
%                           between A and B,C,D.
%                           ["A","multiple_1"]  use the string "multiple_1"
%                           to get coincidences of the multi-fold channel #1.
%                           ["hello"]   since no channel is named 'hello',
%                           this funcion will return an empty
%       maxwait_s   Maximum time to wait. Default=10.
%       max_try     Maximum trials of communication. Default=6.
%
%   Outputs:
%       data_out    Array of integer values

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% March 2021; Last revision: 9-Mar-2021

    %% 1. Validate inputs
    if ~isa(abacus_object,'serial')
        errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
        errorStruct.identifier = 'TAUSAND:incorrectType';
        error(errorStruct)
    end
    
    if (nargin<2)
        %if channels is not given, declare as empty array
        channels = [];
    end
    
    if (nargin<3)
        %if maxwait_s is not given
        maxwait_s=10;   %set default value: 10 seconds
    else
        %validate maxwait_s
        if ~isreal(maxwait_s)
            errorStruct.message = 'Input ''maxwait_s'' must be a number.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        end
        if (maxwait_s < 0)
            errorStruct.message = 'Input ''maxwait_s'' must be a non-negative number.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        end
    end
    
    if (nargin<4)
        %if max_try is not given
        max_try=6;   %set default value: 6.
    else
        %validate max_try
        if ~isreal(max_try)
            errorStruct.message = 'Input ''max_try'' must be a positive integer number.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        elseif (mod(max_try,1) ~= 0) %if it is not an integer
            errorStruct.message = 'Input ''max_try'' must be a positive integer number.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        end
        if max_try < 1
            errorStruct.message = 'Input ''max_try'' must be a positive integer number.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        end
    end
    
    %get current state of warning 'TAUSAND:timeout'
    s=warning('query','TAUSAND:timeout');
    wasTimeoutWarningOn = strcmp(s.state,'on');

    %% 2. Wait

    waitForAcquisitionComplete(abacus_object,maxwait_s,max_try);

    %% 3. Read measurements
    if wasTimeoutWarningOn
        warning('off','TAUSAND:timeout');   %turn off timeout warnings. If so, a retry will be done anyway.
    end
    for (attempt=1:max_try)
        try
            [ all_data, all_labels ] = readMeasurement( abacus_object );
            if ~isempty(all_data) %if data read ok
                break;  %force end for loop
            end
        catch ME
            switch ME.identifier
                case 'MATLAB:serial:fwrite:opfailed'
                    closeAbacus(abacus_object)
                    try
                        openAbacus(abacus_object)
                    catch
                        %ignore error
                    end
                otherwise
                    rethrow(ME)
            end
        end
    end
    if wasTimeoutWarningOn
        warning('on','TAUSAND:timeout');   %turn back on timeout warnings.
    end
    if (attempt == max_try)
        warning('TAUSAND:timeout',['Communication error after ',int2str(max_try),' attempts']);
    end

    %% 4. Return desired subset
    if ~isempty(all_data)
        if ~isempty(channels)
            channels = ["ID",channels]; %this forces to prepend counters_ID to result
            channels = strcat("_",channels); %prepend "_" to each selection
            %return only data with label ending with "_X".
            labels_out = all_labels(endsWith(all_labels,channels));
            data_out = all_data(endsWith(all_labels,channels));
        else
            %if channels is not given, return all
            labels_out = all_labels;
            data_out = all_data;
        end
    else
        %error using readMeasurement
        labels_out = [];
        data_out = [];
    end
    
end