# Tausand_AB1000_MatlabLibrary
Library to use Tausand Abacus AB1000 and AB2000 devices with Matlab.

## About Tausand Abacus AB1000 and AB2000

These are families of coincidence counters, ideal to measure temporal correlations in particle detection and quantum optics experiments.

To learn more about them, visit our website www.tausand.com

To obtain a Tausand's Abacus coincidence counter, visit our [online shop](http://www.tausand.com/shop) or contact us at sales@tausand.com

## Tausand Abacus AB1000 Matlab Instrument Driver Readme

### 1. Overview
Manufacturer: Tausand <br/>
Supported Language(s): MATLAB <br/>
Supported Model(s): AB1002, AB1004, AB1502, AB1504, AB1902, AB1904, AB2502, AB2504<br/>
Model(s) Tested: AB1002, AB1004, AB1502, AB1504, AB2502, AB2504<br/>
Interface(s): USB

Driver Revision: 1.2<br/>
Original Release Date: 07/10/2019 (mm/dd/yyyy)<br/>
Current Revision Date: 01/24/2023

### 2. Contents

| File | Description |
| --- | --- |
| closeAbacus | - Same as fclose. |
| configureByName | - Configure Tausand Abacus by label and value pairs. |
| configureChannel | - Configures delay and sleep in a single channel. |
| configureCoincidenceWindow | - Writes the coincidence window in a Tausand Abacus. |
|   configureDelay |                     - Writes a single delay in a Tausand Abacus.|
|   configureMultipleCoincidence |       - Writes a single multiple-coincidence configuration.|
|   configureSamplingTime         |      - Writes the sampling time in a Tausand Abacus.|
|   configureSleep                 |     - Writes a single sleep time in a Tausand Abacus.|
|   countersIdQuery                 |    - Reads ID of last measurement. Integer consecutive number.|
|   deviceTypeQuery                  |   - Returns an integer with the Tausand Abacus device type.|
|   example_abacusExample             |  - Tausand AB1000 Matlab library example: Abacus Example|
|   example_multipleReadExample        | - Tausand AB1000 Matlab library example: Multiple Read Example|
|   example_readSpeedTestExample        | - Tausand AB1000 Matlab library example: Read Speed Test Example|
|   example_singleReadExample        | - Tausand AB1000 Matlab library example: Single Read Example|
|   findDevices                        | - Scans and finds serial ports with Tausand Abacus devices.|
|   idnQuery                           | - Identification request *IDN?|
|   openAbacus                         | - Opens and configures a Tasuand Abacus AB1000|
|   queryAllSettings                   | - Reads all settings from a Tausand Abacus.|
|   queryCoincidenceWindow             | - Reads the coincidence window, in ns, from a Tausand Abacus.|
|   queryDelay                         | - Reads the delay in a given channel, in ns, from a Tausand Abacus.|
|   queryMultipleCoincidence           | - Reads multiple-coincidence counter configuration.|
|   querySamplingTime                  | - Reads the sampling time, in ms, from a Tausand Abacus.|
|   querySleep                         | - Reads the sleep in a given channel, in ns, from a Tausand Abacus.|
|   readMeasurement                    | - Reads all counter and coincidence values form a Tausand Abacus.|
|   tester_Tausand_AB1000_MatlabLibrary| - Tausand AB1000 Matlab library tester|
|   timeLeftQuery                      | - Reads time left for next measurement, in ms.|
|   waitAndGetValues                   | - Waits and read counters of the specified channels.|
|   waitForAcquisitionComplete         | - Waits for the current acquisition to finish.|


### 3. Known Issues
To report issues or provide feedback about this instrument driver, please send an email to support@tausand.com.

### 4. Revision History
The latest version of this and other Tausand instrument drivers can be downloaded at [Tausand downloads website](http://www.tausand.com/downloads/).

* REV 1.0, 07/10/2019<br/>
Created by: David Guzmán, dguzman@tausand.com, Bogota, Colombia.<br/>
Original release.


* REV 1.1, 03/16/2021<br/>
Updated by: David Guzmán, dguzman@tausand.com, Bogota, Colombia.<br/>
Added support for 2ns and 1ns devices.
New examples included.
New function _waitAndGetValues_ to ease continuous acquisitions.


* REV 1.2, 01/24/2023<br/>
Updated by: David Guzmán, dguzman@tausand.com, Bogota, Colombia.<br/>
Added support for AB2000 devices: AB2502 and AB2504.
New examples included.
Improvements on read and configure functions.