function [ ] = waitForAcquisitionComplete( abacus_object, print_on, maxwait_s, max_try )
%WAITFORACQUISITIONCOMPLETE Waits for the current acquisition to finish.
%   waitForAcquisitionComplete(OBJ,A,X,Y)   Waits until a new set of data
%   becomes available on the Tausand Abacus device connected to serial port 
%   object OBJ. This happens once the device counter 'counters_ID' changes.
%   When optional logical input A is TRUE, this function prints information 
%   messages in command window. Optional input X is a number indicating the 
%   maximum time to wait, in seconds. Optional input Y is an integer number 
%   indicating the maximum trials of communication within the function. 
%   Default values are: A=false, X=10, Y=6.
%
%   waitForAcquisitionComplete(OBJ,A,X)   Uses max_try=6.
%
%   waitForAcquisitionComplete(OBJ,A)     Uses maxwait_s=10, max_try=6.
%
%   waitForAcquisitionComplete(OBJ)       Uses maxwait_s=10, max_try=6, 
%                                         print_on=false.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % Wait to a new data set to be avaiable to read:
%       waitForAcquisitionComplete(abacus_obj);
%
%     % Read a full set of current data in the device:
%       [data,labels] = readMeasurement(abacus_obj);
%
%     % Wait printing information messages:
%       waitForAcquisitionComplete(abacus_obj,true);
%
%     % Wait without printing information messages, up to 5 seconds:
%       waitForAcquisitionComplete(abacus_obj,false,5);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also COUNTERSIDQUERY, READMEASUREMENT, TIMELEFTQUERY,
%   WAITANDGETVALUES.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 11-Mar-2021
% v1.1: maxwait_s is an optional argument
%       improved algorithm handling special scenarios

    %% Input validation
    if ~isa(abacus_object,'serial')
        errorStruct.message = 'Input ''abacus_object'' must be a serial port object.';
        errorStruct.identifier = 'TAUSAND:incorrectType';
        error(errorStruct)
    end

    tStart = tic;
    update_ms = 200;    %update value each 200ms
    timeLeft_ms = 0;
    initialId = 0;
    currentId = 0;            
    
    %% Step 1: validate optional arguments
    
    if (nargin<2) %new v1.1
        %if print_on is not given
        print_on = false;   %set default value: off
    else
        if ~islogical(print_on)
            errorStruct.message = 'Input ''print_on'' must be a logical value: true, false.';
            errorStruct.identifier = 'TAUSAND:incorrectType';
            error(errorStruct)
        end
    end
    if (nargin<3) %new v1.1
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
    
    if (nargin<4) %new v1.1
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
    
    %% Step 2: get initial ID
    if wasTimeoutWarningOn
        warning('off','TAUSAND:timeout');   %turn off timeout warnings. If so, a retry will be done anyway.
    end
    for attempt=1:max_try
        try
            initialId = countersIdQuery(abacus_object);
            if print_on
                %only print in command window when print_on==true
                fprintf("Current ID is %d\n",initialId);
            end
            break;  %force end for loop            
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
    
    %% Steps 3,4,5: get time to wait, wait, and read new ID.
    
    waiting = true;
    if print_on
        %only print in command window when print_on==true
        fprintf("Next data is available in       ");
    end
    while waiting
        
        %Step 3: get time to wait
        if wasTimeoutWarningOn
            warning('off','TAUSAND:timeout');   %turn off timeout warnings. If so, a retry will be done anyway.
        end
        for attempt=1:max_try
            try
                timeLeft_ms = timeLeftQuery(abacus_object);
                if print_on
                    %only print in command window when print_on==true
                    fprintf("\b\b\b\b\b\b\b");
                    fprintf("%6.1fs",double(timeLeft_ms)/1000);
                end
                break;  %force end for loop            
            catch ME
                %disp(ME.identifier)
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
        
        %Step 4: wait up to 200ms (constant update_ms)
        pause(min(timeLeft_ms,update_ms)/1000);
        
        %Step 5: read new ID
        if wasTimeoutWarningOn
            warning('off','TAUSAND:timeout');   %turn off timeout warnings. If so, a retry will be done anyway.
        end
        for attempt=1:max_try
            try
                currentId = countersIdQuery(abacus_object);
                break;  %force end for loop            
            catch ME
                %disp(ME.identifier)
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
        
        %Step 6: validation
        if currentId == 0
            initialId = 0;  %this case avoids to wait double for id=1 after id=0
        end
        
        tElapsed = toc(tStart);
        if (initialId ~= currentId) && (currentId > 0)
            if print_on
                %only print in command window when print_on==true
                fprintf("\n");
                fprintf("Now, current ID is %d\n",currentId);
            end
            waiting = false;
        %Step 7: max timeout validation
        elseif tElapsed > maxwait_s
            if print_on
                %only print in command window when print_on==true
                fprintf("\n");
            end
            %fprintf("Maxwait expired. Consider extending your maxwait.\n");
            warning('TAUSAND:timeout','Maxwait expired. Consider extending your maxwait.')
            waiting = false;
        end

    end
    

end