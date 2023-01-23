function [ data_out, labels_out ] = queryAllSettings( abacus_object )
%QUERYALLSETTINGS Reads all settings from a Tausand Abacus.
%   [V,S] = queryAllSettings(OBJ) reads all the configuration parameters of 
%   the Tausand Abacus device connected to serial port object OBJ. Returns 
%   two equally sized arrays, V with integer values, and S with their 
%   corresponding parameter label strings.
%
%   Possible 'labels' in array S are:
%   "sampling": in ms
%   "coincidence_window": in ns
%   "delay_I": delay in ns in channel I
%   "sleep_I": sleep time in ns in channel I
%   "config_multiple_J": multi-fold coincidence configuration for counter J
%
%   This function is more efficient than reading every setting separately.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % Read all current settings in the device:
%       [data,labels] = queryAllSettings(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
% 
%   See also CONFIGUREBYNAME, READMEASUREMENT.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2023-01-23. Version: 1.2.
%
% v1.2. 2023-01. Includes new devices AB2002, AB2004, AB2502 and AB2504.
%                Optimized reading in AB2000 devices using new read mode
%                x"3". Typical read times of 12ms-14ms in AB250x devices.
% v1.1. 2020-08. Includes new devices AB1502, AB1504, AB1902 and AB1904.
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)     
end

%% Function code
tStartLocal = tic;
data_out = [];
labels_out = [];
maxtimeout = 0.5;   %500ms

%some constants
C2Pow8=256;         %2^8
C2Pow16=65536;      %2^16
C2Pow24=16777216;   %2^24

%% Get device type
[device_type,is32bitdevice,num_channels]=getDeviceTypeFromName(abacus_object);

%% Read request and wait for data available in port
numtries = 4;
localmaxtimeout = maxtimeout/numtries;
if is32bitdevice && (num_channels == 4)%when using a 4-channel device: 1004, 1504, 1904, 2004, 2504
    if device_type > 2000 %v1.2
        %since AB2000, read mode x"3" (all settings) is available
        expectedBytes = 58; %5*(4+4+2+1)values + 1*(2prefix + 1checksum)
        data_value=[hex2dec('03000000')]; %use value=x"03000000" to enable read mode x"3", all counters 
        address=[0]; %address is ignored in read mode x"3".
    else
        expectedBytes = 67; %5*11 values + 4*(2 prefix + 1 checksum)
        address=[64,72,80,88];
        data_value=[4,4,2,1];
    end
elseif is32bitdevice && (num_channels == 2)%v1.2: when using a 2-channel device of 32-bits: 2002, 2502
    if device_type > 2000 %v1.2
        %since AB2000, read mode x"3" (all settings) is available
        expectedBytes = 58; %5*(4+4+2+1)values + 1*(2prefix + 1checksum). Although is a 2ch device, responds like a 4ch device in read mode x"3".
        data_value=[hex2dec('03000000')]; %use value=x"03000000" to enable read mode x"3", all counters 
        address=[0]; %address is ignored in read mode x"3".
    else
        expectedBytes = 39; %5*6 values + 3*(2 prefix + 1 checksum)
        address=[64,72,80];
        data_value=[2,2,2];
    end
else%when using a 2-channel device of 16-bits: 1002, 1502 or 1902
    expectedBytes = 69; %3*22 values + 2 prefix + 1 checksum        
    address=[0];
    data_value=[22];
end
av=[address;data_value];

clearBuffer(abacus_object); %v1.2 clear buffer 
repeatRdWr = 1;
while repeatRdWr == 1
    repeatWr = 1;
    while repeatWr == 1
        clearBuffer(abacus_object); % clear buffer

%         if is32bitdevice %if device_type == 1004, 1504 or 1904
%             for k=av
%                 writeSerial32(abacus_object,'read',k(1),k(2)); % send 6 commands to Abacus
%             end
%         else%if device_type == 1002, 1502 or 1902
%             writeSerial(abacus_object,'read',0,22); % send command to Abacus
%         end
        
        if is32bitdevice %if device_type == 1004, 1504, 1904, 2002, 2004, 2502 or 2504
            for k=av
                %v1.2: writes a 'read' command, and waits until bytesAvailable 
                %      changes before sending the next 'read' command, 
                %      i.e. waits until serial device responds
                prev_bytesAvailable = abacus_object.BytesAvailable; %new v1.2
                writeSerial32(abacus_object,'read',k(1),k(2)); % send 4 or 3 commands to Abacus
                while (abacus_object.BytesAvailable == prev_bytesAvailable) && (toc(tStartLocal) < maxtimeout)
                    pause(0.001) %v1.2: added 1ms pause. Without this pause, may fail with higher probability
                end
            end
        else%if device_type == 1002, 1502 or 1902
            writeSerial(abacus_object,'read',0,22); % send command to Abacus
        end
        
        waitForBytes(abacus_object,expectedBytes,localmaxtimeout);
        
        tElapsedLocal = toc(tStartLocal);
        if (tElapsedLocal > maxtimeout)
            repeatWr=0;   %disp('Too many retries. Timeout error.')
        elseif (tElapsedLocal > localmaxtimeout)
            repeatWr=1;   %disp('Automatic retry')
        else
            repeatWr=0;
        end
        localmaxtimeout = localmaxtimeout + (maxtimeout/numtries);

    end

    %% Read data available in port

    readDatastream=[];
    cumNumBytes = 0;
    if is32bitdevice %if device_type == 1004, 1504, 1904, 2002, 2004, 2502 or 2504
        numReads = length(address); %v1.2: 4 or 3, depending on num_channels
    else%if device_type == 1002, 1502 or 1902
        numReads=1;
    end

    for i=1:numReads
        tElapsedLocal = toc(tStartLocal);
        if tElapsedLocal > maxtimeout
            warning('TAUSAND:timeout','Timeout in function queryAllSettings.')
            return
        end    
        firstByte=fread(abacus_object,1);
        %v1.1: scan for available bytes until x"7E" is found
        while (abacus_object.BytesAvailable>0) && (firstByte ~= 126)
            firstByte=fread(abacus_object,1);
        end
        if firstByte ~= 126 %not found within available bytes
            %char(firstByte)
            errorStruct.message = 'Expected first byte is not correct. Read cancelled.';
            errorStruct.identifier = 'TAUSAND:unexpectedReadByte';
            error(errorStruct) 
            %return
        end
        numBytes=fread(abacus_object,1); %2nd byte says number of bytes that follows
        waitForBytes(abacus_object,numBytes,0.1);    %timeout 100ms
        thisReadDatastream=fread(abacus_object,numBytes); %read N bytes
        checksum=fread(abacus_object,1); %read checksum byte

        %checksum verification
        ver=uint8(sum(thisReadDatastream)+checksum);
        if ver ~= 255
            %error('Checksum failed. Read cancelled.')
            errorStruct.message = 'Checksum failed. Read cancelled.';
            errorStruct.identifier = 'TAUSAND:checksumFailed';
            error(errorStruct) 
            %return
        end
        readDatastream=[readDatastream;thisReadDatastream];
        cumNumBytes = cumNumBytes + numBytes;
    end

    %% Organize datastream
    if is32bitdevice %if device_type == 1004, 1504 or 1904
        readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
    else%if device_type == 1002, 1502 or 1902
        readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value
    end

    addresses_out=readDatastream(1,:)';
    data_out=readDatastream(2:end,:)';
    
    if is32bitdevice %when using 32-bit devices: 1004, 1504, 1904, 2002, 2004, 2502 or 2504
        data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
        if (num_channels == 4) || ((device_type > 2000) && (num_channels == 2)) %when using 4-channel devices: 1004, 1504, 1904, 2004, 2504, or when 2ch of AB2xx2
            addresses_ok=isequal(sort(addresses_out)',[64:67,72:75,80,81,88]);
        else %v1.2: when using 2-channel devices: 2002, 2502
            addresses_ok=isequal(sort(addresses_out)',[64,65,72,73,80,81]);
        end
        
    else%if device_type == 1002, 1502 or 1902
        data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
        addresses_ok=isequal(sort(addresses_out)',0:21);
    end

    tElapsedLocal = toc(tStartLocal);
    if addresses_ok
        repeatRdWr = 0; %do not repeat; done
    elseif tElapsedLocal < maxtimeout
        repeatRdWr = 1; %do repeat, if there is time to do it
    else
        warning('TAUSAND:timeout','Timeout in function queryAllSettings.');
        return
    end
end

%% Get and return labels and data from read datastream
%if is32bitdevice %if device_type == 1004, 1504 or 1904
if num_channels >= 4 %if using a 4-channel device: 1004, 1504, 1904, 2004 or 2504
    labelArray=["sampling";"coincidence_window";
        "delay_A";"delay_B";"delay_C";"delay_D";
        "sleep_A";"sleep_B";"sleep_C";"sleep_D";
        "config_multiple_1"];
else%if device_type == 1002, 1502 or 1902
    labelArray=["sampling";"coincidence_window";
        "delay_A";"delay_B";
        "sleep_A";"sleep_B"];
end

data_out_2=zeros(length(labelArray),1);

if is32bitdevice %if device_type == 1004, 1504 or 1904
    aux=data_out(addresses_out==80); %sampling
    [~,~,value_ms,value_s]=convertSciToEng(aux);
    data_out_2(1,1)=value_ms + 1000*value_s;
    
    aux=data_out(addresses_out==81); %coincidence_window
    [value_ns,value_us]=convertSciToEng(aux);
    data_out_2(2,1)=value_ns + 1000*value_us;
    
    aux=data_out(addresses_out==64); %delay_A
    data_out_2(3,1)=convertSciToEng(aux); %get value_ns
    
    aux=data_out(addresses_out==65); %delay_B
    data_out_2(4,1)=convertSciToEng(aux); %get value_ns
    
    if (num_channels > 2) %v1.2
        aux=data_out(addresses_out==66); %delay_C
        data_out_2(5,1)=convertSciToEng(aux); %get value_ns
        
        aux=data_out(addresses_out==67); %delay_D
        data_out_2(6,1)=convertSciToEng(aux); %get value_ns
        
        aux=data_out(addresses_out==72); %sleep_A
        data_out_2(7,1)=convertSciToEng(aux); %get value_ns
    
        aux=data_out(addresses_out==73); %sleep_B
        data_out_2(8,1)=convertSciToEng(aux); %get value_ns
    
        aux=data_out(addresses_out==74); %sleep_C
        data_out_2(9,1)=convertSciToEng(aux); %get value_ns
        
        aux=data_out(addresses_out==75); %sleep_D
        data_out_2(10,1)=convertSciToEng(aux); %get value_ns
        
        data_out_2(11,1)=data_out(addresses_out==88); %config_multiple_1
    else %if num_channels <= 2
        %append only sleepA and sleepB at positions 5 and 6 of dataout
        aux=data_out(addresses_out==72); %sleep_A
        data_out_2(5,1)=convertSciToEng(aux); %get value_ns
    
        aux=data_out(addresses_out==73); %sleep_B
        data_out_2(6,1)=convertSciToEng(aux); %get value_ns
    end

else%if device_type == 1002, 1502 or 1902
    % Method 1: prefixed addresses. Takes less than 0.1ms to run
    data_out_2(1,1)=data_out(addresses_out==18)+1000*data_out(addresses_out==19); %sampling
    data_out_2(2,1)=data_out(addresses_out==20)+1000*data_out(addresses_out==21); %coincidence_window
    data_out_2(3,1)=data_out(addresses_out==0); %delay_A
    data_out_2(4,1)=data_out(addresses_out==4); %delay_B
    data_out_2(5,1)=data_out(addresses_out==8); %sleep_A
    data_out_2(6,1)=data_out(addresses_out==12); %sleep_B

end

data_out=uint32(data_out_2); %2021-03: returns unsigned integer array
labels_out = labelArray;


end

