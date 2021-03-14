function waitForBytes(abacus_object,expectedBytes,timeout)
%WAITFORBYTES Waits for expected bytes at serial port, or until timeout expires
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019
    tic
    while (abacus_object.BytesAvailable < expectedBytes) && (toc < timeout)
        %waits until all bytes are available or a timeout happens
    end

end