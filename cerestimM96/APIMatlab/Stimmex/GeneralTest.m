% General communication test script

clear all; 
close all;
clc;

% Create stimulator object
stimulator = cerestim96();

% Connect and print library version
stimulator.connect; 
if (stimulator.isConnected())
    display('IsConnected says we are connected');
else
    display('IsConnected says we are not connected');
end
stimulator.libraryVersion;

% Read current compliance voltage, modify and read it again
voltage = 15;
x = stimulator.maxOutputVoltage();
y = stimulator.maxOutputVoltage(voltage);
if ( x == y )
    display('Max compliance voltage not changed');
else
    display('Max compliance voltage successfully changed');
end

% Read device info
devinfo = stimulator.deviceInfo();

fieldsExist = isfield(devinfo, 'serialNo') && isfield(devinfo, 'motherboardVersion') && ...
    isfield(devinfo, 'protocolVersion') && isfield(devinfo, 'moduleStatus') && ... 
    isfield(devinfo, 'moduleVersion'); 

if (fieldsExist) 

    emptyfield = isempty(devinfo.serialNo) || isempty(devinfo.motherboardVersion) || ...
        isempty(devinfo.protocolVersion) || isempty(devinfo.moduleStatus) || ... 
        isempty(devinfo.moduleVersion);

    if emptyfield
        display('One or more fields are empty');
    else 
        display('Device info read');
    end
else
    display('One or more fields in Device Info Struct does not exist');
end

% Disable and re-enable module
module = find(devinfo.moduleStatus == 1);
module = module(1);
stimulator.disableModule(module);
temp = stimulator.deviceInfo();
if (temp.moduleStatus(module) ~= devinfo.moduleStatus(module))
    display('Module successfully disabled');
else 
    display('Failed to disable module');
end

stimulator.enableModule(module);
temp = stimulator.deviceInfo();
if (temp.moduleStatus(module) == devinfo.moduleStatus(module))
    display('Module successfully re-enabled');
else 
    display('Failed to re-enable module');
end

% Set and get new waveforms
waveform_id = 1;
stimulator.disableStimulus(waveform_id);
display('Waveform id 1 disabled');
stimulator.setStimPattern('waveform',waveform_id,...
    'polarity',1,...
    'pulses',1,...
    'amp1',500,...
    'amp2',500,...
    'width1',120,...
    'width2',120,...
    'interphase',200,...
    'frequency',200);
waveform = stimulator.getStimPattern(waveform_id);
display('Waveform configuration read');

% Read stimulus max values and modify them
stimulus_max = stimulator.stimulusMaxValue();

voltage = stimulus_max.voltage;
amplitude = stimulus_max.amplitude;
phaseCharge = stimulus_max.phaseCharge; 
freq = stimulus_max.frequency/2;
[~] = stimulator.stimulusMaxValue(voltage, amplitude, phaseCharge, freq);
stimulus_max2 = stimulator.stimulusMaxValue();
[~] = stimulator.stimulusMaxValue(voltage, amplitude, phaseCharge, freq*2);

if (stimulus_max.frequency == stimulus_max2.frequency*2)
    display('Max stimulus parameters successfully updated');
else
    display('Failed to update stimulus parameters');
end

% Test trigger mode
edge = 3;
stimulator.trigger(edge);
status = stimulator.getSequenceStatus();
if (status == 4)
    display('Stimulator is waiting for trigger');
else
    display('Trigger not set');
end
stimulator.disableTrigger;


% Read hardware values
hardware_values = stimulator.getHardwareValues;

% Misc
interface = stimulator.getInterface;
[minamp, maxamp] = stimulator.getMinMaxAmplitude;
usb = stimulator.usbAddress; 
safetydisabled = stimulator.isSafetyDisabled;
locked = stimulator.isLocked;

stimulator.disconnect;
clear status temp waveform_id voltage freq module phaseCharge amplitude edge fieldsExist...
    stimulator stimmex;



