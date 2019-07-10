function [ ] = waitForAcquisitionComplete( abacus_object, maxwait_s )
%WAITFORACQUISITIONCOMPLETE Waits for the current acquisition to finish.
%   Waits until counters_ID changes in a Tausand Abacus. The maximum
%   waiting time is specified on input maxwait_s.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    tStart = tic;
    update_ms = 200;    %update value each 200ms
    initialId = countersIdQuery(abacus_object);

    fprintf("Current ID is %d\n",initialId);
    
    waiting = true;
    fprintf("Next data is available in       ");
    while waiting
        timeLeft_ms = timeLeftQuery(abacus_object);
        fprintf("\b\b\b\b\b\b\b",timeLeft_ms/1000);
        fprintf("%6.1fs",timeLeft_ms/1000);
        pause(min(timeLeft_ms,update_ms)/1000);
        currentId = countersIdQuery(abacus_object);
        tElapsed = toc(tStart);
        if initialId ~= currentId 
            fprintf("\n");
            fprintf("Now, current ID is %d\n",currentId);
            waiting = false;
        elseif tElapsed > maxwait_s
            fprintf("\n");
            fprintf("Maxwait expired. Consider extending your maxwait.\n");
            waiting = false;
        end

    end
    

end

