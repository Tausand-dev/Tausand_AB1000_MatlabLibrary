function [ ] = waitForAcquisitionComplete( abacus_object, maxwait_s, max_try )
%WAITFORACQUISITIONCOMPLETE Waits for the current acquisition to finish.
%   Waits until counters_ID changes in a Tausand Abacus. The maximum
%   waiting time is specified on input maxwait_s.
%   Optional arguments: 
%       maxwait_s   Maximum time to wait. Default=10.
%       max_try     Maximum trials of communication. Default=6.

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
    
    if (nargin<3) %new v1.1
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
    for (attempt=1:max_try)
        try
            initialId = countersIdQuery(abacus_object);
            fprintf("Current ID is %d\n",initialId);
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
    fprintf("Next data is available in       ");
    while waiting
        
        %Step 3: get time to wait
        if wasTimeoutWarningOn
            warning('off','TAUSAND:timeout');   %turn off timeout warnings. If so, a retry will be done anyway.
        end
        for (attempt=1:max_try)
            try
                timeLeft_ms = timeLeftQuery(abacus_object);
                fprintf("\b\b\b\b\b\b\b",timeLeft_ms/1000);
                fprintf("%6.1fs",timeLeft_ms/1000);
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
        for (attempt=1:max_try)
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
            fprintf("\n");
            fprintf("Now, current ID is %d\n",currentId);
            waiting = false;
        %Step 7: max timeout validation
        elseif tElapsed > maxwait_s
            fprintf("\n");
            %fprintf("Maxwait expired. Consider extending your maxwait.\n");
            warning('TAUSAND:timeout','Maxwait expired. Consider extending your maxwait.')
            waiting = false;
        end

    end
    

end

