%A set of commands to test Tausand_AB1000_MatlabLibrary
%to be used in Matlab's command window
%
% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% September 2020; Last update: 1-Sep-2020

findDevices(1504)   %searches for Tausand Abacus AB1504 devices
findDevices(0)      %searches for any device of the Tausand Abacus family
my_ports=findDevices(0)      %searches for any device of the Tausand Abacus family
%my_abacus=openAbacus('COM28'); %change COM port depending on your results of 'findDevices'
my_abacus=openAbacus(my_ports{1}); %connects to the first found port

%countersIdQuery(my_abacus)

configureByName(my_abacus,["sampling"],[2500]) %sets sampling to 2.5s
configureChannel(my_abacus,'B',20,50) %sets delay to 20ns and sleep to 50ns, or the closest valid values
configureChannel(my_abacus,'a',10,59) %sets delay to 10ns and sleep to 59ns, or the closest valid values
configureCoincidenceWindow(my_abacus,133) %sets to 133ns, or the closest valid value
configureDelay(my_abacus,'c',35) %sets to 35ms, or the closest valid value
configureSleep(my_abacus,'a',35) %sets to 35ms, or the closest valid value
configureMultipleCoincidence(my_abacus,"ABD")
configureSamplingTime(my_abacus,555) %sets to 555ms, or the closest valid value
countersIdQuery(my_abacus)
idnQuery(my_abacus)
queryAllSettings(my_abacus)
[my_sett_data,my_sett_labels]=queryAllSettings(my_abacus)
queryCoincidenceWindow(my_abacus)
%queryDelay(my_abacus)  %this line leads to an error due to a lack of channel selection: a,b,c or d.
queryDelay(my_abacus,'A') %this is correctly used
queryMultipleCoincidence(my_abacus)
querySamplingTime(my_abacus)
queryAllSettings(my_abacus)
readMeasurement(my_abacus)
[my_meas_data,my_meas_labels]=readMeasurement(my_abacus)
timeLeftQuery(my_abacus)
waitForAcquisitionComplete(my_abacus,10)
configureSamplingTime(my_abacus,5000)
waitForAcquisitionComplete(my_abacus,10)
closeAbacus(my_abacus)