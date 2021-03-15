function [ data_out, labels_out ] = waitAndGetValues( abacus_object, channels, print_on, maxwait_s, max_try )
%WAITANDGETVALUES Waits and read counters of the specified channels.
%   [V,T] = waitAndGetValues(OBJ,S,A,X,Y)     Waits until a new set of data
%   becomes available on the Tausand Abacus device connected to serial port 
%   object OBJ, and then reads a set of measurements, including single and 
%   coincidence counters, as requested in the optional string array input 
%   S. When optional logical input A is TRUE, this function prints 
%   information messages in command window. Optional input X is a number 
%   indicating the maximum time to wait, in seconds. Optional input Y is an 
%   integer number indicating the maximum trials of communication within 
%   the function. Default values are: A=false, X=10, Y=6. Returns a subset 
%   of the measurements, as requested by the S array channels input. 
%   Returns two equally sized arrays, V with integer values, and T with 
%   their corresponding counter label strings.
%
%   [V,T]=waitAndGetValues(OBJ,S,A,X)  Uses max_try=6.
%
%   [V,T]=waitAndGetValues(OBJ,S,A)    Uses maxwait_s=10, max_try=6.
%
%   [V,T]=waitAndGetValues(OBJ,S)      Uses maxwait_s=10, max_try=6, 
%                                      print_on=false.
%
%   [V,T]=waitAndGetValues(OBJ)        Uses maxwait_s=10, max_try=6, 
%                                      print_on=false, returning all data.
%
%   The order of the returned data may not be the same as the order
%   specified in input array S. Field 'counters_ID' is always included 
%   within the output [V,T].
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % Wait and read a full set of new data in the device:
%       [data,labels] = waitAndGetValues(abacus_obj);
%
%     % Wait and read a selected subset of new data in the device:
%       [data,labels] = waitAndGetValues(abacus_obj,["B","AB","BC"]);
%
%     % Wait and read a full set of new data, printing messages:
%       [data,labels] = waitAndGetValues(abacus_obj,'',true);
%
%     % Wait and read a full set of new data, up to 5 seconds, no messages:
%       [data,labels] = waitAndGetValues(abacus_obj,'',false,5);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% March 2021; Last revision: 15-Mar-2021

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
    
    if (nargin<3) %new v1.1
        %if print_on is not given
        print_on = false;   %set default value: off
    else
        if ~islogical(print_on)
            errorStruct.message = 'Input ''print_on'' must be a logical value: true, false.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        end
    end
    
    if (nargin<4)
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
    
    if (nargin<5)
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
    waitForAcquisitionComplete(abacus_object,print_on,maxwait_s,max_try);

    %% 3. Read measurements
    if wasTimeoutWarningOn
        warning('off','TAUSAND:timeout');   %turn off timeout warnings. If so, a retry will be done anyway.
    end
    for attempt=1:max_try
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
    if (~isempty(all_data)) && (~isempty(all_labels))
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