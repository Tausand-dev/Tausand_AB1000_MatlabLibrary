function [ value_ns, value_us, value_ms, value_s ] = convertSciToEng( value_sci )
%CONVERTSCITOENG Converts a 16-bit value in the format used in Tausand Abacus AB1004 to engineering notation, c*10^(e-1) ns --> [ns,us,ms,s].
%   The first 4 bits are e, and the following 12 bits are c.
%   c: integer between 10 and 99. e: integer between 0 and 15.
%   Examples: x"A00A" --> c=10, e=10 --> 10*10^(10-1)ns = 10s
%   x"0032" --> c=50, e=0 --> 50*10^(0-1)ns = 5ns
%   x"3020" --> c=32, e=3 --> 32*10^(3-1)ns = 3,2us

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    value_sci=uint16(value_sci);

    if value_sci == 0
        value_ns = 0;
        value_us = 0;
        value_ms = 0;
        value_s = 0;
    else

        %% Extract coefficient c and exponent e.
        % c is in bits 12 to 1
        % e is in bits 16 to 13
        c=bitand(value_sci,hex2dec('FFF'));
        e=bitshift(bitand(value_sci,hex2dec('F000')),-12);

        %typecast required calculate num
        c=double(c);
        e=double(e); 

        num=c*10^(e-1);

        value_ns = rem(num,1000);
        num=floor(num/1000);
        value_us = rem(num,1000);
        num=floor(num/1000);
        value_ms = rem(num,1000);
        num=floor(num/1000);
        value_s = num; %rem(num,1000)
    end

end

