function [ data_out, labels_out ] = readMeasurement( abacus_object )
%READMEASUREMENT Reads all counter values form a Tausand Abacus.
%     Returns two equally sized arrays: 'data_out' and 'labels_out'. Possible 'labels' are: 
%     "counter_X": counts in single channel X
%     "counter_XY": coincidence counts between channels X and Y
%     "counter_multiple_X": multi-fold coincidences as configured by user in counter X
%     "counters_ID": consecutive identifier for a measurement. When configuration changes, resets to 0.
%     "time_left": miliseconds remaining for the next data to be available.

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

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
% serial_name = get(abacus_object,'Name');
% if contains(serial_name,"AB1004")
%     device_type=1004;
% elseif contains(serial_name,"AB1002")
%     device_type=1002;
% else
%     device_type=DeviceTypeQuery(abacus_object);
%     if (device_type ~= 1002) && (device_type ~= 1004)
%         disp('Unknown device type')
%         return
%     end
% end


%% Read request and wait for data available in port



numtries = 4;
localmaxtimeout = maxtimeout/numtries;
if device_type == 1002
    expectedBytes = 18; %3*5 values + 2 prefix + 1 checksum
else%if device_type == 1004
    expectedBytes = 83;
end

address=[0,9,18,27,83,96];
data_value=[4,3,2,1,2,1];
av=[address;data_value];

repeatRdWr = 1;
while repeatRdWr == 1
    repeatWr = 1;
    while repeatWr == 1
        clearBuffer(abacus_object); % clear buffer

        if device_type == 1002
            writeSerial(abacus_object,'read',24,8); % send command to Abacus
        else%if device_type == 1004
            for k=av
                writeSerial32(abacus_object,'read',k(1),k(2)); % send 6 commands to Abacus
            end
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
    if device_type == 1002
        numReads=1;
    else%if device_type == 1004
        numReads=6;
    end

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

    if device_type == 1002
        readDatastream=reshape(readDatastream,3,cumNumBytes/3); %1-byte address + 2-bytes value
    else%if device_type == 1004
        readDatastream=reshape(readDatastream,5,cumNumBytes/5);%1-byte address + 4-bytes value
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
    if device_type == 1004
        data_out=data_out(:,1)*C2Pow24+data_out(:,2)*C2Pow16+data_out(:,3)*C2Pow8+data_out(:,4);
        addresses_ok=isequal(sort(addresses_out),[0;1;2;3;9;10;11;18;19;27;83;84;96]);
    else%if device_type == 1002
        data_out=data_out(:,1)*C2Pow8+data_out(:,2); %first byte * 2^8 + second byte
        addresses_ok=isequal(sort(addresses_out)',24:31);
    end
    %toc

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

if device_type == 1002
    labelArray=["counters_ID";"counter_A";"counter_B";
        "counter_AB";"time_left"];
else
    labelArray=["counters_ID";"counter_A";"counter_B";"counter_C";"counter_D";
        "counter_AB";"counter_AC";"counter_AD";"counter_BC";"counter_BD";"counter_CD";
        "counter_multiple_1";
        "time_left"];
end

data_out_2=zeros(length(labelArray),1);

if device_type == 1002
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
else %if device_type == 1004
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
    data_out_2(11,1)=data_out(addresses_out==19); %counter_CD
    data_out_2(12,1)=data_out(addresses_out==96); %counter_multiple_1
    data_out_2(13,1)=data_out(addresses_out==84); %time_left
end
data_out=data_out_2;
labels_out = labelArray;

end


% function clearBuffer(abacus_object)
%     bytesInPort = abacus_object.BytesAvailable;
%     if bytesInPort > 0
%         fread(abacus_object,bytesInPort); %clear buffer if any
%         %disp('Buffer cleared')
%     end
% end

% function writeSerial(abacus_object,command,address,value)
%     if command == 'read'
%         valCommand = 14;
%     elseif command == 'write'
%         valCommand = 15;
%     else
%         valCommand = 0;
%     end
%     aux=typecast(uint16(value),'uint8');
%     dataMsb=aux(2);
%     dataLsb=aux(1);
%     word16=[2,valCommand,address,dataMsb,dataLsb,4];
%     fwrite(abacus_object,word16);
% end

% function writeSerial32(abacus_object,command,address,value)
%     if command == 'read'
%         valCommand = 14;
%     elseif command == 'write'
%         valCommand = 15;
%     else
%         valCommand = 0;
%     end
%     aux=typecast(uint32(value),'uint8');
%     dataMsb=aux(4);
%     data2ndMsb=aux(3);
%     data2ndLsb=aux(2);
%     dataLsb=aux(1);
%     word32=[2,valCommand,address,dataMsb,data2ndMsb,data2ndLsb,dataLsb,4];
%     fwrite(abacus_object,word32);
% end

% function waitForBytes(abacus_object,expectedBytes,timeout)
%     while (abacus_object.BytesAvailable < expectedBytes) && (toc < timeout)
%         %waits until all bytes are available or a timeout happens
%     end
% end
