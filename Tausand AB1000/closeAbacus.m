function [ ] = closeAbacus( abacus_object )
%CLOSEABACUS Same as fclose.
%   closeAbacus(x) = fclose(x)
%
%   Example:
%     % To create and connect to a Tausand Abacus device:
%       my_abacus_object = openAbacus('COM3');
%
%     % To query the identifier of the device:
%       idn = idnQuery(my_abacus_object);
%
%     % To disconnect the object from the serial port:
%       closeAbacus(my_abacus_object);

% Author: David Guzman
% Tausand Electronics, Colombia
% email: dguzman@tausand.com
% Website: http://www.tausand.com
% May 2019; Last revision: 10-Mar-2021

%% Input validation
if ~isa(abacus_object,'serial')
    errorStruct.message = 'Input must be a serial port object.';
    errorStruct.identifier = 'TAUSAND:incorrectType';
    error(errorStruct)
end

fclose(abacus_object);

end

