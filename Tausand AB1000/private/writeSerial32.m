function writeSerial32(abacus_object,command,address,value)
%WRITESERIAL32 Sends a serial command to a 32-bit Abacus decive (e.g. AB1004)
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
    aux=typecast(uint32(value),'uint8');
    dataMsb=aux(4);
    data2ndMsb=aux(3);
    data2ndLsb=aux(2);
    dataLsb=aux(1);
    word32=[2,valCommand,address,dataMsb,data2ndMsb,data2ndLsb,dataLsb,4];
    fwrite(abacus_object,word32);
end

