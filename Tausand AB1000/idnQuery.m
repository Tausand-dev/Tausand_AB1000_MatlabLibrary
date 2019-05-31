function [ idn ] = idnQuery( abacus_object )
%IDNQUERY Identification request *IDN?
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

tic
maxtimeout = 0.5; %500ms

bytesInPort = abacus_object.BytesAvailable;
if bytesInPort > 0
    fread(abacus_object,bytesInPort); %clear buffer if any
    disp('cleared')
end

fprintf(abacus_object,'*IDN?'); %request identifier


% waits the serial buffer to stabilize in size
secsToWait=0.05; %50ms

% %Method 1
% bytesInPortOld = abacus_object.BytesAvailable;
% pause(secsToWait) %wait 10ms
% bytesInPort = abacus_object.BytesAvailable;
% while (bytesInPortOld < bytesInPort) || (bytesInPort==0)
%     pause(secsToWait) %wait 10ms
%     bytesInPortOld = bytesInPort;
%     bytesInPort = abacus_object.BytesAvailable;
% end
% 
% %now that is stable, read
% idn = fscanf(abacus_object,'%c',bytesInPort); % '%c' includes whitespaces

% method 2: read and ask if more bytes arrive
bytesInPort = abacus_object.BytesAvailable;
idn = [];
while (bytesInPort == 0) && (toc < maxtimeout)
    bytesInPort = abacus_object.BytesAvailable;
end

while bytesInPort > 0 && (toc < maxtimeout)
    idn = [idn,fscanf(abacus_object,'%c',bytesInPort)]; % '%c' includes whitespaces
    pause(secsToWait);
    bytesInPort = abacus_object.BytesAvailable;
end

if toc > maxtimeout
    disp('Timeout error.')
    toc
end

end