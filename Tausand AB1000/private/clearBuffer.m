function clearBuffer(abacus_object)
%CLEARBUFFER Clears the serial buffer in the specified Tausand Abacus.
%   Checks for available bytes, and discards them if any.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 1-Sep-2020
% v1.1 September 2020. Uses flushinput and flushoutput

%     %v1.0
%     bytesInPort = abacus_object.BytesAvailable;
%     if bytesInPort > 0
%         fread(abacus_object,bytesInPort); %clear buffer if any
%     end

    %v1.1
    flushinput(abacus_object);%flushes any remaining data in input buffer
    flushoutput(abacus_object);%flushes any remaining data in output buffer
end