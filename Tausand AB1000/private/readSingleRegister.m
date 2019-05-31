function [ data_out ] = readSingleRegister( abacus_object, address )
%READSINGLEREGISTER Reads a single register within a Tausand AB1000 device
%   User must specify abacus_object and register address. 
%   This function handles each device type (AB1002 or AB1004) to read it in 
%   the required format.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

tStartRead = tic;
maxtimeout = 0.5;   %500ms
data_out = -1;

%some constants
C2Pow8=256;         %2^8
C2Pow16=65536;      %2^16
C2Pow24=16777216;   %2^24

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);

%% Read request and wait for data available in port

numtries = 4;
localmaxtimeout = maxtimeout/numtries;
if device_type == 1002
    expectedBytes = 6;
else%if device_type == 1004
    expectedBytes = 8;
end

repeatRdWr = 1;
while repeatRdWr == 1
    repeatWr = 1;
    while repeatWr == 1
        clearBuffer(abacus_object); % clear buffer

        if device_type == 1002
            writeSerial(abacus_object,"read",address,0); % send command to Abacus
        else%if device_type == 1004
            writeSerial32(abacus_object,"read",address,0); % send command to Abacus
        end

        waitForBytes(abacus_object,expectedBytes,localmaxtimeout);
        tElapsedRead = toc(tStartRead);
        if (tElapsedRead > maxtimeout)
            repeatWr=0;   %disp('Too many retries. Timeout error.')
        elseif (tElapsedRead > localmaxtimeout)
            repeatWr=1;   %disp('Automatic retry')
        else
            repeatWr=0;
        end

        localmaxtimeout = localmaxtimeout + (maxtimeout/numtries);

    end

    %% Read data available in port

    readDatastream=[];
    cumNumBytes = 0;

    tElapsedRead = toc(tStartRead);
    if tElapsedRead > maxtimeout
        disp('Timeout error.')
        return
    end    
    firstByte=fread(abacus_object,1);
    if firstByte ~= 126 %if first byte is not x"7E", quit
        disp("Expected first byte is not correct. Read cancelled.");
        return
    end
    numBytes=fread(abacus_object,1); %2nd byte says number of bytes that follows
    thisReadDatastream=fread(abacus_object,numBytes); %read N bytes
    checksum=fread(abacus_object,1); %read checksum byte

    %checksum verification
    ver=uint8(sum(thisReadDatastream)+checksum);
    if ver ~= 255
        disp('Checksum failed. Read cancelled.')
        return
    end
    readDatastream=[readDatastream;thisReadDatastream];
    cumNumBytes = cumNumBytes + numBytes;


    %% Organize datastream

    if device_type == 1002
        readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value
    else%if device_type == 1004
        readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
    end
    addresses_out=readDatastream(1,:)';
    data_out=readDatastream(2:end,:)';

    addresses_ok=isequal(addresses_out(1),address);%single address
    
    if device_type == 1004
        data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
    else%if device_type == 1002
        data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
    end

    tElapsedRead = toc(tStartRead);
    if addresses_ok
        repeatRdWr = 0; %do not repeat; done
    elseif tElapsedRead < maxtimeout
        repeatRdWr = 1; %do repeat, if there is time to do it
    else
        disp("Timeout error.");
        return
    end
end

end
