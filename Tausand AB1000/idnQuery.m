function [ idn ] = idnQuery( abacus_object )
%IDNQUERY Identification request *IDN?
%   S = idnQuery(OBJECT) returns a string S corresponding to the identifier
%   string linked to the serial port object OBJECT. If OBJECT does not
%   exist, is closed, or is not a Tausand Abacus device, you will not be 
%   able to get a response.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       my_abacus_object = openAbacus('COM3');
%
%     % To query the identifier of the device:
%       idn = idnQuery(my_abacus_object);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(my_abacus_object);

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 11-Mar-2021
% v1.1: '\n' added at the end of request: '*IDN?\n'


%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)     
end

%% Function
tic
maxtimeout = 0.2; %200ms
clearBuffer(abacus_object) %new v1.1, 2021-03

%bytesInPort = abacus_object.BytesAvailable;
%if bytesInPort > 0
%    fread(abacus_object,bytesInPort); %clear buffer if any
%    disp('cleared')
%end

% request identifier:
fprintf(abacus_object,'*IDN?\n'); %v1.1
%fprintf(abacus_object,'*IDN?'); %previous version (v1.0)

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

while (bytesInPort > 0) && (toc < maxtimeout)
    idn = [idn,fscanf(abacus_object,'%c',bytesInPort)]; % '%c' includes whitespaces
    pause(secsToWait);
    bytesInPort = abacus_object.BytesAvailable;
end

if toc > maxtimeout
    warning('TAUSAND:timeout','Timeout in function idnQuery.')
    %toc;
end

end