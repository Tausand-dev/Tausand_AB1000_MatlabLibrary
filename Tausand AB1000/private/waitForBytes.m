function waitForBytes(abacus_object,expectedBytes,timeout)
%WAITFORBYTES Waits for expected bytes at serial port, or until timeout expires
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 14-Mar-2021
% v1.1  2021-03-14: tic,toc associated to local timer tWaitForBytes
    tWaitForBytes = tic;
    while (abacus_object.BytesAvailable < expectedBytes) && (toc(tWaitForBytes) < timeout)
        %waits until all bytes are available or a timeout happens
    end

end