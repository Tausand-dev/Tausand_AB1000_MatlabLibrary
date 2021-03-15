%% Tausand AB1000 Matlab library example: Multiple Read Example
% Reads continously and saves data from a Tausand Abacus coincidence 
% counter. Uses functions in the Tausand_AB1000_MatlabLibrary. Handles 
% errors and retry readings and connections when lost. To be used in 
% Matlab's command window.
%
% Author: David Guzman.
% Tausand Electronics, Colombia.
% March 2021; Last update: 15-Mar-2021.
%
% Contact email: dguzman@tausand.com. 
% Website: http://www.tausand.com
%


%% Constants to be defined by user
% Change this parameter to set how many samples to read:
samples_to_read = 10; 
%%
% Change this parameter to set your sampling time. 1000=1s:
my_sampling_time_ms = 1000; 
%%
% Change this port to the adequate one:
my_port = 'COM23'; 

%%
% Define the desired channels to be read. Example:
channels_to_read = ["A","B","C","AB","AC","multiple_1"]; 
%%
% where string "multiple_1" corresponds to a multi-fold measurement, to be 
% configured, e.g. 'ABC'

%% Establish a connection
disp("******************************");
disp("MATLAB multiple read example");
disp("******************************");
disp("1. Establish a connection");

my_abacus = openAbacus(my_port)
device_idn = idnQuery(my_abacus)

%% Write and read new settings
disp("2. Write and read new settings");
%%
% Write settings, using configureByName function:
configureByName(my_abacus,"sampling",my_sampling_time_ms);
%%
% Several configurations may be applied with a single command line:
configureByName(my_abacus,...
    ["coincidence_window","delay_A","delay_B","sleep_A","sleep_B"],...
    [50,0,10,0,20]);
    %this sets: coincidence_window=50ns, delay_A=0ns, delay_B=10ns,
    %sleep_A=0ns, sleep_B=20ns.
    
%%
% Upgrade 'TAUSAND:timeout' warning to an error, to catch them.
my_warn = warning('error', 'TAUSAND:timeout');
%%
% Read current settings
max_try=5;
for attempt=1:max_try
    try
        [setting_values,setting_labels]=queryAllSettings(my_abacus);
        current_settings=[setting_labels,setting_values];
        disp('Current settings are:');
        disp([setting_labels,setting_values]);
        break;
    catch ME
        switch ME.identifier
            case {'TAUSAND:unexpectedReadByte',...
                    'TAUSAND:checksumFailed','TAUSAND:timeout'}
                %ignore these errors, just retry.                    
            case 'MATLAB:serial:fwrite:opfailed'
                %if connection is lost, maybe device has been
                %disconnected
                closeAbacus(my_abacus)
                try
                    openAbacus(my_abacus)
                catch
                    %ignore error
                end                    
            otherwise
                warning('Unexpected error. Device connection closed.')
                closeAbacus(my_abacus)
                rethrow(ME)
        end
    end
end
warning(my_warn.state, 'TAUSAND:timeout'); % Restore this warning back to their previous (non-error) state
if (attempt == max_try)
    warning('TAUSAND:timeout',['Communication error after ',int2str(max_try),' attempts']);
end

%% Create plaintext file
disp("3. Create file");
date_time_string = string(datetime,'yyyy-MM-dd_HHmmss');
column_headers = cat(2,["PC time","countersID"],channels_to_read);
file_name = strcat('data_multipleReadExample_',date_time_string,'.txt');
%%
% Create file,
myfile = fopen(file_name, 'a'); %create file in append mode
disp(strcat("File ",file_name," has been created"));
%%
% and write file headers,
fwrite(myfile,['multipleReadExample',newline]);
fwrite(myfile,['-------------------',newline]);
fwrite(myfile,['Begin time: ',char(date_time_string),newline]);
fwrite(myfile,['Device: ',device_idn,newline]);
fwrite(myfile,['Settings: ',newline]);
fprintf(myfile,'%s\t%s\n',[setting_labels,num2str(setting_values)]');
fwrite(myfile,[newline,newline]);
fprintf(myfile,'%s\t',column_headers);
fwrite(myfile,newline);

%% Multiple read using function waitAndGetValues 
disp('4. Multiple read using waitAndGetValues function begins');
fprintf('\t%s',column_headers); %print in command window
fprintf('\n');
tMultipleReadExample = tic;
for sample=1:samples_to_read
    try
        my_data = waitAndGetValues(my_abacus,channels_to_read);
        s=strcat(sprintf('%.3f',toc(tMultipleReadExample)),sprintf('\t%d',my_data),string(newline));
        fwrite(myfile,s);
        t = [num2str(sample),'/',num2str(samples_to_read)];
        fprintf('%s\t%s',t,s);    %print data in command window
    catch ME
        switch ME.identifier
            case {'TAUSAND:unexpectedReadByte',...
                    'TAUSAND:checksumFailed','TAUSAND:timeout'}
                %ignore these errors, just continue.                    
            case 'MATLAB:serial:fwrite:opfailed'
                %if connection is lost, maybe device has been
                %disconnected
                closeAbacus(my_abacus)
                try
                    openAbacus(my_abacus)
                catch
                    %ignore error
                end                    
            otherwise
                warning('Unexpected error. Device connection closed. File access closed.')
                fclose(myfile);
                closeAbacus(my_abacus)
                rethrow(ME)
        end
    end
end

%% Close connection and close file
fclose(myfile);
closeAbacus(my_abacus)