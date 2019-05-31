function writeSerial(abacus_object,command,address,value)
%WRITESERIAL Sends a serial command to a 16-bit Abacus decive (e.g. AB1002)
%   Detailed explanation goes here

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    if command == "read"
        valCommand = 14;
    elseif command == "write"
        valCommand = 15;
    else
        valCommand = 0;
    end
    aux=typecast(uint16(value),'uint8');
    dataMsb=aux(2);
    dataLsb=aux(1);
    word16=[2,valCommand,address,dataMsb,dataLsb,4];
    fwrite(abacus_object,word16);
end
