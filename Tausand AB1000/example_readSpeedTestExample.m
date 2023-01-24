%% Tausand AB1000 Matlab library example: Read Speed Test Example
% Repeat reading of counters and settings for a specified number of times, and returns statistics on the timing of execution of these reading functions: 
% 
% * readMeasurement()
% * queryAllSettings()
%
% Author: David Guzmán.
% Tausand Electronics, Colombia.
%
% Created: 2023-01. Last revision: 2023-01-24. Version: 1.2.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com

%% User's parameters
port = 'COM6';  %indicate the port to connect with. E.g.: 'COM4'
samples = 1000;  %how many times the read test should be made

%% Connection with Tausand Abacus device
% Open connection with device
my_tausand = openAbacus(port);

idn_string = idnQuery(my_tausand);
fprintf("Connected to: ");
fprintf(idn_string);
fprintf("\n");

%% Read speed tests
% Create empty arrays
tRdCounters=zeros(samples,1);
tRdSettings=zeros(samples,1);
%%
% Do not show this type of warnings
warning('off','TAUSAND:timeout'); 

%%
% Print in command window progress percentage
fprintf("Read speed test. Progress=%5.1f%%",0);
k=1;
if samples < k
    samples = k;
end

%%
% Perform reading tests, and get their timing
while k <= samples
    try
        stopwatch = tic();
        d=readMeasurement(my_tausand);
        tRdCounters(k,1)=toc(stopwatch);
        
        stopwatch = tic();
        q=queryAllSettings(my_tausand);
        tRdSettings(k,1)=toc(stopwatch);
        
        % if both stopwatchs are non-zero, measument is ok. Go to next
        % mesurement.
        if (tRdCounters(k,1) > 0) && (tRdSettings(k,1) > 0)
            k=k+1; %go to next reading
        end
        
    catch ME
        switch ME.identifier
            case 'TAUSAND:unexpectedReadByte'
                fprintf("\n");
                warning('Read failed. Repeating read.');
                fprintf("\nRead speed test. Progress=%5.1f%%",k/samples*100);
                
            case 'TAUSAND:timeout'
                fprintf("\n");
                warning('Read timeout. Repeating read.');
                fprintf("\nRead speed test. Progress=%5.1f%%",k/samples*100);
            otherwise
                rethrow(ME)
        end
    end
    
    fprintf("\b\b\b\b\b\b");
    fprintf("%5.1f%%",(k-1)/samples*100);
end
fprintf("\n");

%%
% Enable back those warnings that were turned off:
warning('on','TAUSAND:timeout'); 

%% Close connection

closeAbacus(my_tausand);

%% Statistics

fprintf("Statistics report for ");
fprintf(idn_string);
fprintf("\n");
fprintf("NumReads:  %d\n",k-1)
fprintf("readMeasurement() statistics\n")
fprintf("  Min:  %0.5f s\n", min(tRdCounters))
fprintf("  Max:  %0.5f s\n", max(tRdCounters))
fprintf("  Mean: %0.5f s\n", mean(tRdCounters))
fprintf("  StdD: %0.5f s\n", std(tRdCounters))
fprintf("queryAllSettings() statistics\n")
fprintf("  Min:  %0.5f s\n", min(tRdSettings))
fprintf("  Max:  %0.5f s\n", max(tRdSettings))
fprintf("  Mean: %0.5f s\n", mean(tRdSettings))
fprintf("  StdD: %0.5f s\n", std(tRdSettings))
