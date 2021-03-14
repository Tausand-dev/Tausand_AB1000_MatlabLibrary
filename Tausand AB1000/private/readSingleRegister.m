function [ data_out ] = readSingleRegister( abacus_object, address )
%READSINGLEREGISTER Reads a single register within a Tausand AB1000 device
%   User must specify abacus_object and register address. 
%   This function handles each device type (AB1x0x) to read it in the 
%   required format.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 11-Mar-2021
% v1.1 July 2020. Includes AB1502, AB1504, AB1902, AB1904 as valid device
% types.
%      March 2021. Returns unsigned integer.

tStartRead = tic;
maxtimeout = 0.5;   %500ms
data_out = -1;

%some constants
C2Pow8=256;         %2^8
C2Pow16=65536;      %2^16
C2Pow24=16777216;   %2^24

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Read request and wait for data available in port

numtries = 4;
localmaxtimeout = maxtimeout/numtries;
if is32bitdevice %if device_type == 1004, 1504 or 1904
    expectedBytes = 8;
else %if device_type == 1002, 1502 or 1902
    expectedBytes = 6;
end

repeatRdWr = 1;
while repeatRdWr == 1
    repeatWr = 1;
    while repeatWr == 1
        clearBuffer(abacus_object); % clear buffer

        if is32bitdevice %updated on v1.1 (2020-07-07)
            writeSerial32(abacus_object,"read",address,0); % send command to Abacus
        else
            writeSerial(abacus_object,"read",address,0); % send command to Abacus            
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
        warning('Timeout in readSingleRegister.')
        return
    end    
    firstByte=fread(abacus_object,1);
    if isempty(firstByte)
        warning('Timeout in readSingleRegister.')
        return
    elseif firstByte ~= 126 %if first byte is not x"7E", quit
        %v1.1: scan for available bytes until x"7E" is found
        while (abacus_object.BytesAvailable>0) && (firstByte ~= 126)
            firstByte=fread(abacus_object,1);
        end
        if firstByte ~= 126 %not found within available bytes
            errorStruct.message = 'Expected first byte is not correct. Read cancelled.';
            errorStruct.identifier = 'TAUSAND:unexpectedReadByte';
            error(errorStruct) 
            %return
        end
    end
    numBytes=fread(abacus_object,1); %2nd byte says number of bytes that follows
    if isempty(numBytes)
        warning('Timeout in readSingleRegister.')
        return
    end
    thisReadDatastream=fread(abacus_object,numBytes); %read N bytes
    if isempty(thisReadDatastream)
        warning('Timeout in readSingleRegister.')
        return
    end
    checksum=fread(abacus_object,1); %read checksum byte
    if isempty(checksum)
        warning('Timeout in readSingleRegister.')
        return
    end

    %checksum verification
    ver=uint8(sum(thisReadDatastream)+checksum);
    if ver ~= 255
        errorStruct.message = 'Checksum failed. Read cancelled.';
        errorStruct.identifier = 'TAUSAND:checksumFailed';
        error(errorStruct)
        %error('Checksum failed. Read cancelled.')
        return
    end
    readDatastream=[readDatastream;thisReadDatastream];
    cumNumBytes = cumNumBytes + numBytes;


    %% Organize datastream

    if is32bitdevice %device_type == 1004, 1504 or 1904
        readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
    else%if device_type == 1002, 1502 or 1902
        readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value        
    end
    addresses_out=readDatastream(1,:)';
    data_out=readDatastream(2:end,:)';

    addresses_ok=isequal(addresses_out(1),address);%single address
    
    if is32bitdevice %device_type == 1004, 1504 or 1904
        data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
    else%if device_type == 1002, 1502 or 1902
        data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
    end
    
    data_out = uint32(data_out);    %2021-03: returns unsigned integer

    tElapsedRead = toc(tStartRead);
    if addresses_ok
        repeatRdWr = 0; %do not repeat; done
    elseif tElapsedRead < maxtimeout
        repeatRdWr = 1; %do repeat, if there is time to do it
    else
        warning('Timeout in readSingleRegister.');
        return
    end
end

end

