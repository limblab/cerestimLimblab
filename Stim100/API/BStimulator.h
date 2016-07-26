//////////////////////////////////////////////////////////////////////////////
//
// (c) Copyright 2010 - 2011 Blackrock Microsystems
//
// $Workfile: BStimulator.h $
// $Archive: /BStimAPI/BStimulator.h $
// $Revision: 1 $
// $Date: 6/20/11 1:10p $
// $Author: Rudy & Ehsan $
//
// $NoKeywords: $
//
//////////////////////////////////////////////////////////////////////////////
//
// PURPOSE:
//
// Blackrock Stim SDK
// This header file is distributed as part of the SDK
//

#if !defined(BSTIMULATOR)
#define BSTIMULATOR

// ----------------------------- BStimulator Defines -------------------------------------- //

#ifndef INT8
typedef signed char     INT8;
#endif
#ifndef UINT8
typedef unsigned char   UINT8;
#endif
#ifndef INT16
typedef signed short    INT16;
#endif
#ifndef UINT16
typedef unsigned short  UINT16;
#endif
#ifndef INT32
typedef signed int      INT32;
#endif
#ifndef UINT32
typedef unsigned int    UINT32;
#endif

typedef UINT32 BStimHandle;				// Handle to the Blackrock Stimulator object

#define MAXMODULES	16					// Max number of modules in stim100
#define MAXCHANNELS 100					// Max number of channels in stim100
#define INTERNALRESISTANCE 0			// Internal resistance configuration pattern number
#define MAXCONFIGURATIONS 16			// Number of pattern configurations.

#define DEFAULTMAXVOLTAGE		10		// Default value for max compliance voltage is 6.5V which is 0x0A or 10
#define DEFAULTMAXAMPLITUDE		100		// Default value for the max phase amplitude 100uA
#define DEFAULTMAXWIDTH			300		// Default value for the max phase width 300uS
#define DEFAULTMAXINTERPHASE	300		// Default value for the max interphase 300uS
#define DEFAULTMAXINTERPULSE	300		// Default value for the max interpulse 300uS
#define DEFAULTMAXPHASECHARGE	30000	// Default value for the max charge per phase 30nC
	
#define MAX_STIMULATORS	5				// Max number of BStimulator objects that can be defined at once

#define BSTIM_USBVID    0x04d8			// Default USB VID
#define BSTIM_USBPID    0x003f			// Default USB PID
#define BSTIM_RS232COM  1				// Default RS232 Com Port
#define BSTIM_RS232BAUD 8000			// Default RS232 Baud Rate

// ----------------------------- BStimulator Enumerations ------------------------------------- //
/* BStim Interfaces */
enum BInterfaceType
{
    BINTERFACE_DEFAULT	= 0,	// Default interface (windows USB)
    BINTERFACE_WUSB,			// Windows USB interface
    BINTERFACE_WRS232,			// Windows RS232 interface
	BINTERFACE_UUSB,			// Unix USB interface
	BINTERFACE_URS232,			// Unix RS232 interface
	BINTERFACE_MUSB,			// Mac USB interface
	BINTERFACE_MRS232,			// Mac RS232 interface
	BINTERFACE_COUNT			// Always the last one
};

/* Anodic Cathodic Type */
enum BWFType
{
    BWF_ANODIC_FIRST = 0,
    BMWF_CATHODIC_FIRST,
    BMWF_INVALID // Allways the last value
};

/* Sequence State */
enum BSeqType
{
    BSEQ_STOP = 0,
    BSEQ_PLAYING,
    BSEQ_PAUSE,
    BSEQ_WRITING,
    BSEQ_INVALID // Allways the last value
};

/* Module Status */
enum BModuleStatus
{
	BMODULE_UNAVAILABLE = 0,
	BMODULE_ENABLED,
	BMODULE_DISABLED,
	BMODULE_OK,
	BMODULE_VOLTAGELIMITATION,
	BMODULE_COUNT
};

/* Configuration Patterns */
enum BConfig
{
	BCONFIG_0 = 0,
	BCONFIG_1,
	BCONFIG_2,
	BCONFIG_3,
	BCONFIG_4,
	BCONFIG_5,
	BCONFIG_6,
	BCONFIG_7,
	BCONFIG_8,
	BCONFIG_9,
	BCONFIG_10,
	BCONFIG_11,
	BCONFIG_12,
	BCONFIG_13,
	BCONFIG_14,
	BCONFIG_15,
	BCONFIG_COUNT
};

/* Output Compliance Voltage Values */
enum BOCVolt
{
	BOCVOLT3_5 = 5,
	BOCVOLT4_1,
	BOCVOLT4_7,
	BOCVOLT5_3,
	BOCVOLT5_9,
	BOCVOLT6_5,
	BOCVOLT7_1,
	BOCVOLT7_7,
	BOCVOLT8_3,
	BOCVOLT8_9,
	BOCVOLT9_5,
	BOCVOLT_INVALID
};

/* BStim enum values and types */
enum BEventType
{
    BEVENT_DEVICE_ATTACHED = 0,
    BEVENT_DEVICE_DETACHED,
    BEVENT_COUNT // Allways the last value
};

enum BCallbackType
{
    BCALLBACK_ALL = 0, // Monitor all events
    BCALLBACK_DEVICE_ATTACHMENT, // Monitor device attachment
    BCALLBACK_COUNT // Allways the last value
};
typedef void (* BCallback)(BEventType type, void* pCallbackData);

/* BStimulator Return Values */
enum BResult
{
    //----- Errors returned (software side) --------------------------- //
    BRETURN                 =     1, // Early returned warning
    BSUCCESS                =     0, // Successful operation
    BNOTIMPLEMENTED         =    -1, // Not implemented
    BUNKNOWN                =    -2, // Unknown error
    BINVALIDHANDLE          =    -3, // Invalid handle
    BNULLPTR                =    -4, // Null pointer
    BINVALIDINTERFACE       =    -5, // Invalid intrface specified or interface not supported
    BINTERFACETIMEOUT       =    -6, // Timeout in creating the interface
	BDEVICEREGISTERED		=	 -7, // Device with that address already connected.
    BINVALIDPARAMS          =    -8, // Invalid parameters
    BDISCONNECTED           =    -9, // Stim is disconnected, invalid operation
    BCONNECTED              =   -10, // Stim is connected, invalid operation
	BSTIMATTACHED			=	-11, // Stim is attached, invalid operation
	BSTIMDETACHED			=	-12, // Stim is detached, invalid operation
    BDEVICENOTIFY           =   -13, // Cannot register for device change notification
    BINVALIDCOMMAND         =   -14, // Invalid command
    BINTERFACEWRITE         =   -15, // Cannot open interface for write
    BINTERFACEREAD          =   -16, // Cannot open interface for read
    BWRITEERR               =   -17, // Cannot write command to the interface
    BREADERR                =   -18, // Cannot read command from the interface
    BINVALIDMODULE          =   -19, // Invalid module number specified
    BINVALIDCALLBACKTYPE    =   -20, // Invalid callback type
    BCALLBACKREGFAILED      =   -21, // Callback register/unregister failed

    //----- Errors returned (hardware side) --------------------------- //
    BINVALIDCHANNEL         =  -101, // Channel not valid
    BINVALIDCONFIG          =  -102, // Config not valid
    BMODULEUNAVAILABLE      =  -103, // Module not available
    BINVALIDRW              =  -104, // Read/write not valid
    BINVALIDVOLTAGE         =  -105, // Voltage not valid
    BINVALIDAFCF            =  -106, // AF/CF not valid
    BINVALIDPULSES          =  -107, // Pulses not valid
	BINVALIDAMPL			=  -108, // Amplitude is not valid
	BINVALIDWIDTH			=  -109, // Width is not Valid
	BINVALIDINTERPULSE		=  -110, // Interpulse is not valid
	BINVALIDINTERPHASE		=  -111, // Interphase is not valid
    BINVALIDFASTDISCHARGE   =  -112, // Fast discharge not valid
    BSEQUENCEERR            =  -113, // Sequence error
    BSTIMULIMODULEERR       =  -114, // More stimuli into the group than modules enabled
    BCHANNELGROUPERR        =  -115, // Channel already used into the same group
    BNOMODULEENABLED        =  -116, // No module enabled
    BEMPTYCONFIG            =  -117, // Empty config
    BECHOERR                =  -118, // Command echo not correct
    BNOK                    =  -119, // Comamnd result not OK
	BPHASENOTBALANCED		=  -120, // Phases not balanced
	BPHASEGREATMAX			=  -121, // Phase charge is greater than max allowed
	BAMPGREATMAX			=  -122, // Amplitude greater than max allowed
	BWIDTHGREATMAX			=  -123, // Width greater than max allowed
	BINTERPULSEGREATMAX		=  -124, // Interpulse greater than max allowed
	BINTERPHASEGREATMAX		=  -125, // Interphase greater than max allowed
	BVOLTAGEGREATMAX		=  -126, // Voltage greater than max allowed
	BPHASELESSAMPWIDTH		=  -127, // Phase charge is less than amplitude*width
	BINVALIDGROUPNUMBER		=  -128	 // Number in group is invalid
};

// --------------------------------- BStimulator Structures ---------------------------------------- //

// One-byte packing
#pragma pack(push, 1) 
/* Required USB Parameters */
struct BUsbParams{
    UINT32 size;					// sizeof(BStimUsbParams)
    UINT32 timeout;					// How long to try before timeout (mS)
    UINT32 vid;						// vendor ID
    UINT32 pid;						// product ID
};

/* Required RS232 Parameters */
struct BRs232Params{
    UINT32 size;					// sizeof(BStimRs232Params)
    UINT32 timeout;					// How long to try before timeout (mS)
    UINT32 com;						// COM port
    UINT32 baud;					// baud rate
};
#pragma pack(pop)

/* Library Version Information. */
struct  BVersion{
    UINT32 major;
    UINT32 minor;
    UINT32 release;
    UINT32 beta;
};

/* Measure Output Voltage Results */
struct BOutputMeasurement
{
    INT16	measurement[5];			// Signed int (mV)
};

/* Maximum output voltage results */
struct BMaxOutputVoltage
{
	UINT16 miliVolts;
};

/* Read Device Information Results */
struct BDeviceInfo
{
    UINT16	serialNo;				// Hardware serial number (from 0x0000 to 0xFFFF)
    UINT16	mainboardVersion;		// MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
    UINT16	protocolVersion;		// MSB = version , LSB = subversion (i.e. 0x020A = version 2.10)
    UINT8	moduleStatus[16];		// 0x00 = Not available.   0x01 = Enabled.   0x02 = Disabled
    UINT16	moduleVersion[16];		// MSB = version , LSB = subversion (i.e. 0x020A = version 2.10) 
};

/* Read Stimulus Configuration Pattern Results */
struct BStimulusConfiguration
{
    UINT8	anodicFirst;			// 0x01 = anodic first, 0x00 = cathodic first
    UINT8	pulses;					// Number of biphasic pulses (from 1 to 255)
    UINT8	amp1;					// Amplitude first phase (uA)
    UINT8	amp2;					// Amplitude second phase (uA)
    UINT16	width1;					// Width first phase (us) 
    UINT16	width2;					// Width second phase (us) 
    UINT16	interpulse;				// Time between pulses (us) 
    UINT16	interphase;				// Time between phases (us) 
    UINT8	fastDischarge;			// Fast discharge during interphases and interpulses 0x01 = yes 0x00 = no
};

/* Read sequence Status */
struct BSequenceStatus
{
	UINT8	status;					// 0x00 = Stopped, 0x01 = Playing, 0x02 = Paused, 0x03 = Writing Sequence
};

/* Read Maximum Values Results */
struct BMaximumValues
{
	UINT8	voltage;				// Max voltage value see voltage table
	UINT8	amplitude;				// Amplitude (uA)
	UINT16	width;					// Phase width (uS)
	UINT16	interphase;				// Interphase (uS)
	UINT16	interpulse;				// Interpulse (uS)
	UINT32	phaseCharge;			// Charge per phase (pC)
};

/* Test Module Results */
struct BTestModules
{
	UINT16 modulesMV[MAXMODULES][5];			// Voltage in mV
	BModuleStatus   modulesStatus[MAXMODULES];	// BMODULE_UNAVAILABLE, BMODULE_DISABLED, BMODULE_OK, BMODULE_VOLTAGELIMITATION
};

/* Test Electrodes Results */
struct BTestElectrodes
{
	UINT16 electrodes[MAXCHANNELS];			// Impedance value in Kohms
};

/* Group Stimulus Channel Configuration */
struct BGroupStimulus
{
	UINT8 channel[MAXMODULES];			// Channel to stimulate
	UINT8 pattern[MAXMODULES];			// Configuration Patter to use with coresponding channel
};

/*-------------------------------BStimulator class for interfacing with stim100---------------------------------------------*/
class BStimulator
{
private:

	static UINT32 m_iStim100Objects;
	struct BStim100Data;
	BStim100Data	*m_psData;			// Private data members

public:
	// Exception class that is thrown when there are to many objects of BStimulator.  This will need to be caught when creating an object
	class maxStimulatorError{};

	BStimulator();		// Constructor
	~BStimulator();		// Destructor
	BResult connect(BInterfaceType stimInterface, void * params);	// Sets up what interface the PC will talk to the Stim100 over
	BResult disconnect();	// Removes the connection from PC to the Stim100

	// Calls that are made to the Stim100
	BResult manualStimulus(UINT8 channel, BConfig configID);
	BResult measureOutputVoltage(BOutputMeasurement * output, UINT8 module, UINT8 channel);
	BResult beginningOfSequence();
	BResult endOfSequence();
	BResult beginningOfGroup();
	BResult endOfGroup();
	BResult autoStimulus(UINT8 channel, BConfig configID);
	BResult wait(UINT8 miliSeconds);
	BResult play(UINT16 times);
	BResult stop();
	BResult pause();
	BResult maxOutputVoltage(BMaxOutputVoltage * output, UINT8 rw, BOCVolt voltage);
	BResult readDeviceInfo(BDeviceInfo * output);
	BResult enableModule(UINT8 module);
	BResult disableModule(UINT8 module);
	BResult configureStimulusPattern(BConfig configID, BWFType afcf, UINT8 pulses, UINT8 amp1, UINT8 amp2, 
									 UINT16 width1, UINT16 width2, UINT16 interpulse, UINT16 interphase, bool fastDischarge);
	BResult readStimulusPattern(BStimulusConfiguration * output, BConfig configID);
	BResult readSequenceStatus(BSequenceStatus * output);
	BResult stimulusMaxValues(BMaximumValues * output, UINT8 rw, BOCVolt voltage, UINT8 amplitude, UINT16 width, 
							  UINT16 interphase, UINT16 interpulse, UINT32 phaseCharge);
	BResult groupStimulus(UINT8 number, BGroupStimulus * input);
	BResult testElectrodes(BTestElectrodes * output);
	BResult testModules(BTestModules * output);


	bool isConnected();	// Returns true if you currently have an interface established between the PC and Stim100
	BInterfaceType getInterface();	// Returns the type of interface that is establishded between PC and Stim100
	void *	getParams();	// Returns the parameters that the interface is using.
	UINT16 getSerialNumber(); // Returns the Stim100 Serial Number
	UINT16 getMotherboardFirmwareVersion(); // Returns the Stim100 motherboard firmware version
	UINT16 getProtocolVersion(); // Returns the Stim100 protocol version
	void getModuleFirmwareVersion(UINT16* output); // Pass in the address of an UINT16 output[MAXMODULES]
	void getModuleStatus(UINT8* output); // Pass in the address of an UINT8 output[MAXMODULES]
};

#endif