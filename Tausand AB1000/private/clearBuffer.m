function clearBuffer(abacus_object)
%CLEARBUFFER Clears the serial buffer in the specified Tausand Abacus.
%   Checks for available bytes, and discards them if any.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    bytesInPort = abacus_object.BytesAvailable;
    if bytesInPort > 0
        fread(abacus_object,bytesInPort); %clear buffer if any
    end
end