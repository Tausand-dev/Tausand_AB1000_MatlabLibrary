function [ value_sci, value_ns, value_us, value_ms, value_s] = convertEngToSci( value_ns, value_us, value_ms, value_s )
%CONVERTENGTOSCI Converts a time in engineering notation to a 16-bit value in the format used in Tausand Abacus AB1004, [ns,us,ms,s] --> c*10^(e-1) ns
%   where the first 4 bits are e, and the following 12 bits are c.
%   c: integer between 10 and 99. e: integer between 0 and 15.
% 
%   Examples: 10s = 10*10^(10-1)ns --> c=10, e=10 --> x"A00A"
%             5ns = 50*10^(0-1)ns --> c=50, e=0 --> x"0032"
%             3,2us = 32*10^(3-1)ns --> c=32, e=3 --> x"3020"

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 31-May-2019

    if (value_ns == 0) && (value_us == 0) && (value_ms == 0) && (value_s == 0)
        value_sci = 0;
    else
        num = value_ns + value_us*1000 + value_ms*1000000 + value_s*1000000000;
        myLog = floor(log10(num));
        num = num / (10^(myLog-1));
        c=round(num);
        e=myLog;
        if c >= 100
            c=c/10;
            e=e+1;
        end

        % Coerce c
        if c < 10
            c = 10;
        elseif c > 99
            c = 99;
        end

        % Coerce e
        if e < 0
            e = 0;
        elseif e > 15
            e = 15;
        end

        value_sci = e*4096 + c;
    end

end