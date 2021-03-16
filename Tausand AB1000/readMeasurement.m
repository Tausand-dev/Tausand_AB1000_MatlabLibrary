function [ data_out, labels_out ] = readMeasurement( abacus_object )
%READMEASUREMENT Reads all counter and coincidence values form a Tausand Abacus.
%   [V,S] = readMeasurement(OBJ) reads a full set of current measurements,
%   including single and coincidence counters, within the the Tausand 
%   Abacus device connected to serial port object OBJ. Returns two equally 
%   sized arrays, V with integer values, and S with their corresponding 
%   counter label strings.
%
%   Possible 'labels' in array S are:
%     "counter_I":  counts in single channel I
%     "counter_IJ": coincidence counts between channels I and J
%     "counter_multiple_K": multi-fold coincidences as configured by user 
%                           in counter K
%     "counters_ID": consecutive identifier for a measurement. When 
%                    configuration changes, resets to 0. This value may
%                    overflow at 1 million.
%     "time_left": remaining time, in milliseconds, for the next data to be 
%                  available.
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       abacus_obj = openAbacus('COM3');
%
%     % Wait to a new data set to be avaiable to read (not required):
%       waitForAcquisitionComplete(abacus_obj);
%
%     % Read a full set of current data in the device:
%       [data,labels] = readMeasurement(abacus_obj);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(abacus_obj);
%
%   See also QUERYALLSETTINGS, WAITANDGETVALUES.

% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2019-05. Last revision: 2021-03-16. Version: 1.1.
%
% v1.1. 2020-09. Includes new devices AB1502, AB1504, AB1902 and AB1904.
%       2021-03. Returns unsigned integer.
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

% Some timing measurements:
%   In a AB1504, to read the set of 83 bytes, the timer tElapsed = 0.035s
%   in a Windows PC.
%   Waiting for 0.04s would be enough to receive all data.
%       maxtimeout: 0.32
%       numtries:   8

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct) 
end

tStartLocalReadMeasurement = tic;
data_out = [];
labels_out = [];
maxtimeout = 0.32;    %320ms: timeout for the whole routine
buffertimeout = 0.05; %50ms: timeout for a single input buffer read
numtries = 8;
localmaxtimeout = maxtimeout/numtries;  %about 320/8=40ms
singlereadtimeout = maxtimeout/numtries;%about 320/8=40ms

%some constants
C2Pow8=256;         %2^8
C2Pow16=65536;      %2^16
C2Pow24=16777216;   %2^24

%% Get device type
[~,is32bitdevice]=getDeviceTypeFromName(abacus_object);

%% Read request and wait for data available in port

if is32bitdevice %if device_type == 1004, 1504 or 1904
    expectedBytes = 83; %5*(4+3+2+1+2+1)values + 6(2prefix + 1chechsum)
    address=[0,9,18,27,83,96];
    data_value=[4,3,2,1,2,1];
    av=[address;data_value];
else%if device_type == 1002, 1502 or 1902
    expectedBytes = 18; %3*5 values + 2 prefix + 1 checksum
    %address=24;
    %data_value=8;
end

repeatRdWr = 1;
while repeatRdWr == 1
    repeatWr = 1;
    while repeatWr == 1
        clearBuffer(abacus_object); % clear buffer
        if is32bitdevice %if device_type == 1004, 1504 or 1904
            for k=av
                writeSerial32(abacus_object,'read',k(1),k(2)); % send 6 commands to Abacus
            end
        else%if device_type == 1002, 1502 or 1902
            writeSerial(abacus_object,'read',24,8); % send command to Abacus
        end

        waitForBytes(abacus_object,expectedBytes,singlereadtimeout); %v1.1 always wait up to singlereadtimeout
        
        tElapsedLocalReadMeasurement = toc(tStartLocalReadMeasurement);
        if (abacus_object.BytesAvailable >= expectedBytes)
            repeatWr=0; %done ok
        elseif (tElapsedLocalReadMeasurement > maxtimeout)
            repeatWr=0;   %disp('Too many retries. Timeout error.')
        elseif (tElapsedLocalReadMeasurement > localmaxtimeout)
            repeatWr=1;   %disp('Automatic retry')
            singlereadtimeout = singlereadtimeout*1.2; %v1.1 Increase 20% singleread timeout
            %v1.1 2021-03-14 Updated localmaxtimeout: add to tElapsed
            localmaxtimeout = tElapsedLocalReadMeasurement + singlereadtimeout;
        else
            repeatWr=0;
        end

    end

    %% Read data available in port

    readDatastream=[];
    cumNumBytes = 0;
    
    if is32bitdevice %if device_type == 1004, 1504 or 1904
        numReads=6; %length(address) = 6
    else%if device_type == 1002, 1502 or 1902
        numReads=1;
    end
    
    for i=1:numReads
        tElapsedLocalReadMeasurement = toc(tStartLocalReadMeasurement);
        if tElapsedLocalReadMeasurement > maxtimeout
            warning('TAUSAND:timeout','Timeout in function readMeasurement.')
            return
        end 

        bytesavail = abacus_object.BytesAvailable;
        tByteStart = tic;
        tByteEnd = 0;
        while (bytesavail < 2) && (tByteEnd < buffertimeout) %if there are not 2 bytes, wait for them (max timeout=100ms)
            bytesavail = abacus_object.BytesAvailable; %check how many bytes are in input buffer
            tByteEnd = toc(tByteStart); %get time since entered this while loop
        end
        if bytesavail >= 2
            %if there are 2 bytes in buffer, read them
            firstByte=fread(abacus_object,1);
            
            if isempty(firstByte)
                warning('TAUSAND:timeout','Timeout in readMeasurement.')
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
        else
            firstByte=0;
            numBytes=0;
        end
        
        if numBytes > 0
            bytesavail = abacus_object.BytesAvailable;
            tByteStart = tic;
            tByteEnd = 0;
            while (bytesavail < numBytes) && (tByteEnd < buffertimeout) %if there are not enough bytes, wait for them (max timeout=100ms)
                bytesavail = abacus_object.BytesAvailable;  %check how many bytes are in input buffer
                tByteEnd = toc(tByteStart); %get time since entered this while loop
            end
            if bytesavail >= numBytes
                thisReadDatastream=fread(abacus_object,numBytes); %read N bytes
                checksum=fread(abacus_object,1); %read checksum byte

                %checksum verification
                ver=uint8(sum(thisReadDatastream)+checksum);
                if ver ~= 255
                    errorStruct.message = 'Checksum failed. Read cancelled.';
                    errorStruct.identifier = 'TAUSAND:checksumFailed';
                    error(errorStruct) 
                    %return
                end
                readDatastream=[readDatastream;thisReadDatastream];
                cumNumBytes = cumNumBytes + numBytes;
            else %no valid bytes in port
                errorStruct.message = 'Missing data. Read cancelled.';
                errorStruct.identifier = 'TAUSAND:missingReadData';
                error(errorStruct)
                %return
            end
        end
    end

    %% Organize datastream

    if is32bitdevice %if device_type == 1004, 1504 or 1904
        readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
    else%if device_type == 1002, 1502 or 1902
        readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value
    end
    addresses_out=readDatastream(1,:)';
    data_out=readDatastream(2:end,:)';

    % % method 1: takes about 15ms
    % tic
    % x=zeros(size(value_out,2),1)
    % k=1
    % for a=value_out
    %     aux=swapbytes(typecast(uint8(a), 'uint16'))
    %     x(k)=swapbytes(typecast(uint8(a), 'uint16'))
    %     k=k+1;
    % end
    % toc

    % method 2 takes about 1ms
    %tic
    if is32bitdevice %if device_type == 1004, 1504 or 1904
        data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
        addresses_ok=isequal(sort(addresses_out),[0;1;2;3;9;10;11;18;19;27;83;84;96]);
    else%if device_type == 1002, 1502 or 1902
        data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
        addresses_ok=isequal(sort(addresses_out)',24:31);
    end
    %toc

    tElapsedLocalReadMeasurement = toc(tStartLocalReadMeasurement);
    if addresses_ok
        repeatRdWr = 0; %do not repeat; done
    elseif tElapsedLocalReadMeasurement < maxtimeout
        repeatRdWr = 1; %do repeat, if there is time to do it
    else
        warning('TAUSAND:timeout','Timeout in function readMeasurement.')
        return
    end
    %tElapsedLocalReadMeasurement %testing
    
end

%% Get and return labels and data from read datastream

if is32bitdevice %if device_type == 1004, 1504 or 1904
    labelArray=["counters_ID";"counter_A";"counter_B";"counter_C";"counter_D";
        "counter_AB";"counter_AC";"counter_AD";"counter_BC";"counter_BD";"counter_CD";
        "counter_multiple_1";
        "time_left"];
else%if device_type == 1002, 1502 or 1902
    labelArray=["counters_ID";"counter_A";"counter_B";
        "counter_AB";"time_left"];
end

data_out_2=zeros(length(labelArray),1);

if is32bitdevice %if device_type == 1004, 1504 or 1904
    data_out_2(1,1)=data_out(addresses_out==83); %counters_ID  
    data_out_2(2,1)=data_out(addresses_out==0); %counter_A
    data_out_2(3,1)=data_out(addresses_out==9); %counter_B
    data_out_2(4,1)=data_out(addresses_out==18); %counter_C
    data_out_2(5,1)=data_out(addresses_out==27); %counter_D
    data_out_2(6,1)=data_out(addresses_out==1); %counter_AB
    data_out_2(7,1)=data_out(addresses_out==2); %counter_AC
    data_out_2(8,1)=data_out(addresses_out==3); %counter_AD
    data_out_2(9,1)=data_out(addresses_out==10); %counter_BC
    data_out_2(10,1)=data_out(addresses_out==11); %counter_BD
    data_out_2(11,1)=data_out(addresses_out==19); %counter_CD
    data_out_2(12,1)=data_out(addresses_out==96); %counter_multiple_1
    data_out_2(13,1)=data_out(addresses_out==84); %time_left

else%if device_type == 1002, 1502 or 1902
    % Method 1: prefixed addresses. Takes less than 0.1ms to run
    data_out_2(1,1)=data_out(addresses_out==30); %counters_ID
    data_out_2(2,1)=data_out(addresses_out==24)+data_out(addresses_out==25)*65536; %counters_A
    data_out_2(3,1)=data_out(addresses_out==26)+data_out(addresses_out==27)*65536; %counters_B
    data_out_2(4,1)=data_out(addresses_out==28)+data_out(addresses_out==29)*65536; %counters_AB
    data_out_2(5,1)=data_out(addresses_out==31); %time_left
    
    %special case for time_left in AB1002
    %if first bit is '1', indicates the remaining bits have the value in seconds
    if data_out_2(5,1) >= 32768
        data_out_2(5,1) = (data_out_2(5,1)-32768)*1000;
    end

    % % Method 2: dynamic address search. Takes about 1ms to run
    % k=1;
    % for a=labelArray'
    %     %beware: first address in abacus is 0, first index in Matlab is 1
    %     if contains(a,'counter_')
    %         aux_addr = find(ADDRESS_DIR_AB1002 == strcat(a,"_MSB")) - 1; %first address in Abacus is 0
    %         aux_data = data_out(addresses_out==aux_addr)*65536; %times 2^16
    %         aux_addr = find(ADDRESS_DIR_AB1002 == strcat(a,"_LSB")) - 1; %first address in Abacus is 0
    %         aux_data = aux_data+data_out(addresses_out==aux_addr);
    %     else
    %         aux_addr = find(ADDRESS_DIR_AB1002 == a) - 1;
    %         aux_data = data_out(addresses_out==aux_addr);
    %     end
    %     data_out_2(k,1) = aux_data;
    %     k=k+1;
    % end

end

data_out=uint32(data_out_2); %2021-03: returns unsigned integer array
labels_out = labelArray;

end