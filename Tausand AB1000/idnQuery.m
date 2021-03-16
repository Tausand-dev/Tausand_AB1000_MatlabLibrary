function [ idn ] = idnQuery( abacus_object )
%IDNQUERY Identification request *IDN?
%   STR = idnQuery(OBJ) returns a string STR corresponding to the 
%   identifier string linked to the serial port object OBJ. If OBJ does not 
%   exist, is closed, or is not a Tausand Abacus device, you will not be 
%   able to get a response.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % To query the identifier of the device:
%       idn = idnQuery(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also DEVICETYPEQUERY, FINDDEVICES.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-15. Version: 1.1.
%
% v1.1. 2020-07. '\n' added at the end of request: '*IDN?\n'
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)     
end

%% Function
tIdnQuery = tic;
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
while (bytesInPort == 0) && (toc(tIdnQuery) < maxtimeout)
    bytesInPort = abacus_object.BytesAvailable;
end

while (bytesInPort > 0) && (toc(tIdnQuery) < maxtimeout)
    idn = [idn,fscanf(abacus_object,'%c',bytesInPort)]; % '%c' includes whitespaces
    pause(secsToWait);
    bytesInPort = abacus_object.BytesAvailable;
end

if toc(tIdnQuery) > maxtimeout
    warning('TAUSAND:timeout','Timeout in function idnQuery.')
    %toc(tIdnQuery);
end

end