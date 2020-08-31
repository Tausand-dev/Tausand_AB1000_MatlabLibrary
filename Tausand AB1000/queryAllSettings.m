function [ data_out, labels_out ] = queryAllSettings( abacus_object )
%QUERYALLSETTINGS Reads all settings from a Tausand Abacus.
%   This function is more efficient than reading every setting separately.
% 
%   Returns two equally sized arrays: 'labels' and 'values'. Possible 
%   'labels' are: 
%       "sampling": in ms
%       "coincidence_window": in ns
%       "delay_X": delay in ns in channel X
%       "sleep_X": sleep time in ns in channel X
%       "config_multiple_X": multi-fold coincidence configuration for 
%                            counter X

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last update: 31-Aug-2020
% v1.1 August 2020. Includes new devices AB1502, AB1504, AB1902 and AB1904.

tStartLocal = tic;
data_out = [];
labels_out = [];
maxtimeout = 0.5;   %500ms

%some constants
C2Pow8=256;         %2^8
C2Pow16=65536;      %2^16
C2Pow24=16777216;   %2^24

%% Get device type
device_type=getDeviceTypeFromName(abacus_object);
is32bitdevice = ~ismember(device_type,[1002,1502,1902]);%new on v1.1 (2020-08-31)


%% Read request and wait for data available in port
numtries = 4;
localmaxtimeout = maxtimeout/numtries;
if is32bitdevice %if device_type == 1004, 1504 or 1904
    expectedBytes = 67; %5*11 values + 4*(2 prefix + 1 checksum)
else%if device_type == 1002, 1502 or 1902
    expectedBytes = 69; %3*22 values + 2 prefix + 1 checksum        
end

address=[64,72,80,88];
data_value=[4,4,2,1];
av=[address;data_value];

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
            writeSerial(abacus_object,'read',0,22); % send command to Abacus
        end
        
%         %%old code, v1.0
%         if device_type == 1002
%             writeSerial(abacus_object,'read',0,22); % send command to Abacus
%         else%if device_type == 1004
%             for k=av
%                 writeSerial32(abacus_object,'read',k(1),k(2)); % send 6 commands to Abacus
%             end
%         end

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
    if is32bitdevice %if device_type == 1004, 1504 or 1904
        numReads=4;
    else%if device_type == 1002, 1502 or 1902
        numReads=1;
    end
%     if device_type == 1002
%         numReads=1;
%     else%if device_type == 1004
%         numReads=4;
%     end

    for i=1:numReads
        tElapsedLocal = toc(tStartLocal);
        if tElapsedLocal > maxtimeout
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
    end

    %% Organize datastream
    if is32bitdevice %if device_type == 1004, 1504 or 1904
        readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
    else%if device_type == 1002, 1502 or 1902
        readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value
    end
%     if device_type == 1002
%         readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value
%     else%if device_type == 1004
%         readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
%     end
    addresses_out=readDatastream(1,:)';
    data_out=readDatastream(2:end,:)';
    
    if is32bitdevice %if device_type == 1004, 1504 or 1904
        data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
        addresses_ok=isequal(sort(addresses_out)',[64:67,72:75,80,81,88]);
    else%if device_type == 1002, 1502 or 1902
        data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
        addresses_ok=isequal(sort(addresses_out)',0:21);
    end
%     if device_type == 1004
%         data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
%         addresses_ok=isequal(sort(addresses_out)',[64:67,72:75,80,81,88]);
%     else%if device_type == 1002
%         data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
%         addresses_ok=isequal(sort(addresses_out)',0:21);
%     end

    tElapsedLocal = toc(tStartLocal);
    if addresses_ok
        repeatRdWr = 0; %do not repeat; done
    elseif tElapsedLocal < maxtimeout
        repeatRdWr = 1; %do repeat, if there is time to do it
    else
        disp("Timeout error.");
        return
    end
end

%% Get and return labels and data from read datastream
if is32bitdevice %if device_type == 1004, 1504 or 1904
    labelArray=["sampling";"coincidence_window";
        "delay_A";"delay_B";"delay_C";"delay_D";
        "sleep_A";"sleep_B";"sleep_C";"sleep_D";
        "config_multiple_1"];
else%if device_type == 1002, 1502 or 1902
    labelArray=["sampling";"coincidence_window";
        "delay_A";"delay_B";
        "sleep_A";"sleep_B"];
end
% if device_type == 1002
%     labelArray=["sampling";"coincidence_window";
%         "delay_A";"delay_B";
%         "sleep_A";"sleep_B"];
% else%if device_type == 1004
%     labelArray=["sampling";"coincidence_window";
%         "delay_A";"delay_B";"delay_C";"delay_D";
%         "sleep_A";"sleep_B";"sleep_C";"sleep_D";
%         "config_multiple_1"];
% end

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

else%if device_type == 1002, 1502 or 1902
    % Method 1: prefixed addresses. Takes less than 0.1ms to run
    data_out_2(1,1)=data_out(addresses_out==18)+1000*data_out(addresses_out==19); %sampling
    data_out_2(2,1)=data_out(addresses_out==20)+1000*data_out(addresses_out==21); %coincidence_window
    data_out_2(3,1)=data_out(addresses_out==0); %delay_A
    data_out_2(4,1)=data_out(addresses_out==4); %delay_B
    data_out_2(5,1)=data_out(addresses_out==8); %sleep_A
    data_out_2(6,1)=data_out(addresses_out==12); %sleep_B

end
% if device_type == 1002
%     % Method 1: prefixed addresses. Takes less than 0.1ms to run
%     data_out_2(1,1)=data_out(addresses_out==18)+1000*data_out(addresses_out==19); %sampling
%     data_out_2(2,1)=data_out(addresses_out==20)+1000*data_out(addresses_out==21); %coincidence_window
%     data_out_2(3,1)=data_out(addresses_out==0); %delay_A
%     data_out_2(4,1)=data_out(addresses_out==4); %delay_B
%     data_out_2(5,1)=data_out(addresses_out==8); %sleep_A
%     data_out_2(6,1)=data_out(addresses_out==12); %sleep_B
% 
% else %if device_type == 1004
%     aux=data_out(addresses_out==80); %sampling
%     [~,~,value_ms,value_s]=convertSciToEng(aux);
%     data_out_2(1,1)=value_ms + 1000*value_s;
%     
%     aux=data_out(addresses_out==81); %coincidence_window
%     [value_ns,value_us]=convertSciToEng(aux);
%     data_out_2(2,1)=value_ns + 1000*value_us;
%     
%     aux=data_out(addresses_out==64); %delay_A
%     data_out_2(3,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==65); %delay_B
%     data_out_2(4,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==66); %delay_C
%     data_out_2(5,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==67); %delay_D
%     data_out_2(6,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==72); %sleep_A
%     data_out_2(7,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==73); %sleep_B
%     data_out_2(8,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==74); %sleep_C
%     data_out_2(9,1)=convertSciToEng(aux); %get value_ns
%     
%     aux=data_out(addresses_out==75); %sleep_D
%     data_out_2(10,1)=convertSciToEng(aux); %get value_ns
%     
%     data_out_2(11,1)=data_out(addresses_out==88); %config_multiple_1
%     
% end
data_out=data_out_2;
labels_out = labelArray;

end

