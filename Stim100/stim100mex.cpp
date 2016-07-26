/*This code was originally left @ the miller limblab by Ted Ballou circa 2014
Original source of this code unknown- probably a collaboration between Ted
Sliman Bensmaia's code guru's and Blackrock staff. Code was originally written
to work with the first generation cerestim 96M devices
Code was 'resurrected' but Tucker Tomlinson in July 2016 to work with OLD 
stim100 beta stimulatiors borrowed from Sliman Bensmaia's lab. */

//2016-07-06: Tucker: located original code in Ted Ballou's user folder on fsmresfiles (copied from old citadel server) 
//2016-07-06: Tucker: corrected/expanded comments, mainly within configure_command subroutine
//2016-07-06: Tucker: cleaned up includes
//2016-07-06: Tucker: generate new git repo for stim100



/*original file included several headers that appear unnecessary by including csmex.h
and has many includes that don't appear relevant*/
//#include "csmex.h"
#include "BStimulator.h"
#include "mex.h"
#include "matrix.h"


double getpar(const mxArray* prhs[], int i);
int configure_command(int nrhs, const mxArray* prhs[]);
void errorMsg(char *msg1, char *msg2);

static BStimulator myStim;
int verbose=0;

void mexFunction(int nlhs, mxArray* plhs[], int nrhs, const mxArray* prhs[]) {
    if (nrhs < 1) {
        mexErrMsgTxt("csmex: At least one input required.");
    }
    
    if (!mxIsClass(prhs[0], "char")) {
        mexErrMsgTxt("csmex: First argument must be a command");
        return;
    }
        
    BMaximumValues maxValues;
    const char    *cs_cmd;
    int i=0;
    BUsbParams	myParams;
    
    /***** LIST OF COMMANDS *********************************/
    static char cmd_list[] = "\tconnect\n\tdisconnect\n\tconfigure\n\tstim_max\n\
\treadDeviceInfo\n\tbeginningOfSequence\n\tendOfSequence\n\t\
beginningOfGroup\n\tendOfGroup\n\tautoStimulus\n\tplay\n";
    
    cs_cmd = mxArrayToString(prhs[i]);
	if (verbose) mexPrintf("\nCommand (arg %d): %s\n", i, cs_cmd);
    
    /***** connect************************************************/
    if (!strcmp(cs_cmd, "connect")) {
        myParams.timeout = 2000; // in ms
        myParams.vid = 0;
        myParams.pid = 0;
        BResult retval = myStim.connect(BINTERFACE_DEFAULT, &myParams);
		if (verbose) {
	        mexPrintf("Attempt connection to Cerestim: retval=%d\n", retval);
	        if (!retval) {
		        mexPrintf("Vendor ID = %d, Product ID = %d\n", myParams.vid, myParams.pid);
			}
		}
		plhs[0] = mxCreateDoubleScalar((double)retval);
        
        return;
    }
    /***** disconnect *******************************************/
    if (!strcmp(cs_cmd, "disconnect")) {
        int retval = myStim.disconnect();
		if (retval!=BSUCCESS) {
	        mexPrintf("Failed disconnection from Cerestim: retval=%d\n", retval);
		} else if (verbose) {
	        mexPrintf("Disconnected from Cerestim: retval=%d\n", retval);
		}
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** configure ***************************************/
    if (!strcmp(cs_cmd, "configure")) {
        int retval = configure_command(nrhs, &prhs[0]);
		plhs[0] = mxCreateDoubleScalar((double)retval);
		return;
    }
    /**** stim_max ********************************************/
    if (!strcmp(cs_cmd, "stim_max")) {
        //Ensure that the max values are set high enough so you don't get errors when configuring patterns
        int retval = myStim.stimulusMaxValues(&maxValues, 1, BOCVOLT9_5, 215, 65535, 950000, 5154);
        if (retval != BSUCCESS) {
			mexPrintf("maxValues NOT set at Cerestim: %d\n", retval);
        }else if(verbose){
            mexPrintf("maxValues SET at Cerestim\n");
        }
	    return ;
	}
    /***** readDeviceInfo*****************************/
    if (!strcmp(cs_cmd, "readDeviceInfo")) {
        BDeviceInfo output;
        int retval = myStim.readDeviceInfo(&output);
        if (retval!=BSUCCESS) {
            mexPrintf("Read Device Info Failed\n");
        } else if(verbose){
            for (i=0;i<MAXMODULES;i++) {
                mexPrintf("Device Info: module status = %d\n", output.moduleStatus[i]);
                mexPrintf("Device Info: module version = %d\n", output.moduleVersion[i]);            }
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** beginningOfSequence *****************************/
    if (!strcmp(cs_cmd, "beginningOfSequence")) {
        int retval = myStim.beginningOfSequence();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail beginning of sequence: %d\n", retval);
        } else if (verbose){
            mexPrintf("Beginning of sequence executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** endOfSequence *****************************/
    if (!strcmp(cs_cmd, "endOfSequence")) {
        int retval = myStim.endOfSequence();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail End of sequence: %d\n", retval);
        } else if(verbose){
            mexPrintf("End of sequence executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** beginningOfGroup *****************************/
    if (!strcmp(cs_cmd, "beginningOfGroup")) {
        int retval = myStim.beginningOfGroup();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail beginning of group: %d\n", retval);
        } else if(verbose){
            mexPrintf("Beginning of group executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** endOfGroup *****************************/
    if (!strcmp(cs_cmd, "endOfGroup")) {
        int retval = myStim.endOfGroup();
        if (retval!=BSUCCESS) {
            mexPrintf("Fail end of group: %d\n", retval);
        } else if(verbose){
            mexPrintf("End of group executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** autoStimulus *****************************/
    if (!strcmp(cs_cmd, "autoStimulus")) {
        if (nrhs != 3) {
            mexPrintf("Error: autoStimulus requires 2 parameters, channel and configID\n");
            return;
        }
        UINT8 channel;
        
        int i=1;
        channel = (UINT8)getpar(prhs, i);
        i++;

		int cfgID0 = getpar(prhs,i);
		BConfig cfgID = (BConfig)cfgID0;

	    if ((cfgID > 15)||(cfgID==0)) {
	        mexPrintf("csmex ERROR: configID=%d, range=1-15\n", cfgID);
		    return;
	    }

        int retval = myStim.autoStimulus(channel, cfgID);
        if (retval!=BSUCCESS) {
            mexPrintf("Fail autoStimulus: %d\n", retval);
        } else if(verbose){
            mexPrintf("autoStimulus executed.\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    /***** play *****************************/
    if (!strcmp(cs_cmd, "play")) {
		int count;
		if (nrhs == 2) {
			count = 1;
		} else if (nrhs  == 2) {
			count = getpar(prhs, 2);
			if (count <1) {
				mexPrintf("ERROR: count paremeter must be at least 1\n");
				return;
			}
		} else {
			mexPrintf("ERROR: play takes one parameter, the count of # times to run\n");
			return;
		}
		int retval = myStim.play(count);
        if (retval=BSUCCESS) {
			mexPrintf("play Failed:%d\n", retval);
        } else if(verbose){
			mexPrintf("play executed\n");
        }
		plhs[0] = mxCreateDoubleScalar((double)retval);
        return;
    }
    
    /***** Here for NO recognized command ***************/
    mexPrintf("Cannot recognize command %s\n\n", cs_cmd);
    mexPrintf("Legal commands are:\n%s", cmd_list);
}

double getpar(const mxArray* prhs[], int i) {
    const char    *argclass;
    int retvalue;
    argclass=mxGetClassName(prhs[i]);
    if (!strcmp(argclass, "double")) {
        retvalue = mxGetScalar(prhs[i]); /* conversion double to int ok? */
		if (verbose>1) mexPrintf("\nInput arg %d: %d\n", i, retvalue);
    } else {
        mexErrMsgTxt("csmex: argument must be a number");
    }
    return retvalue;
}

int configure_command(int nrhs, const mxArray* prhs[]) {
    int NUMCFGPARS = 10;
	int retval = -2;
/*Note that the first element in prhs will be the string indicating the command, that was
	passed into the main mex function, and carried along here by default, in this
	case 'configure' since we got into the configure_command routine. Since that element
	is not useful here, we just skip it and start at parameter 1. When checking the
	number of inputs, we need to add one so that we are checking for the number of 
	configuration parameters, plus the unused string input*/
    if (nrhs < NUMCFGPARS) {
        mexPrintf("csmex ERROR: see %d parameters; configure requires %d parameters\n",
                nrhs, NUMCFGPARS);
        mexErrMsgTxt("Parameter count mismatch");
        return retval;
    }

    /*handle the first input, which should be the configuration ID#*/
    int i=1;
	/*get the integer ID for which configuration we are modifying*/
	int cfgID0 = getpar(prhs,i);
	/*create a Bconfig enum using the value of the cfgID0'th value of the
		enum. since the BConfig enum (BStimulator.h) starts at zero, 
		this is equivalent to setting the value of cfgID to cfgID0, but
		would allow changes to the enum in the header file to affect
		that*/
    BConfig cfgID = (BConfig)cfgID0;
	/* check whether the value in cfgID0 is greater than the number of 
		enum values. BCONFIG_COUNT is the last value of the BConfig
		enum, and should automatically take on a value equivalent to
		the number of elements in the enum-1. This ONLY works because
		the enum has values from 0-16, corresponding to the number of */
    if ((cfgID >= BCONFIG_COUNT)||(cfgID==BCONFIG_0)) {
        mexPrintf("csmex ERROR: passed configID=%d, allowed range=1-15\n", cfgID);
        return retval;
    }
    /* handle the second input, which should be the flag for anodal first/cathodal first stimulation*/
    i++;
	int afcf0 = getpar(prhs,i);
	/*BFWType is an enum of the BStimulator.h include, and is basically a flag variable,
		taking on values of 0 or 1 only*/
	BWFType afcf = (BWFType)afcf0;

    if ((afcf > 1)||(cfgID<0)) {
        mexPrintf("csmex ERROR: passed AnodicFirstCathodicFirst=%d, allowed range=0-1\n", afcf);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /*handle the third input which should be the number of pulses*/
    i++;
	int npuls0 = getpar(prhs,i);
	UINT8 npuls = (UINT8) npuls0;
    
    if ((npuls0 > 255)||(npuls0==0)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: passed NumberOfPulses=%d, allowed range=1-255\n", npuls);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /* handle the fourth input which should be the amplitude of the first phase*/
    i++;
	int amp10 = getpar(prhs, i);
    UINT8 amp1 = (UINT8) amp10;
    
    if ((amp10 > 215)||(amp10==0)) {  // test amp10 instead of amp1 since UINT8 stops at 255
        mexPrintf("csmex ERROR: passed Amp1=%d, allowed range=1-215\n", amp10);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /*handle the fifth input which should be the amplitude of the second phase*/
    i++;
	int amp20 = getpar(prhs, i);
	UINT8 amp2 = amp20;
 
    if ((amp20 > 215)||(amp20==0)) {  // test amp20 instead of amp2 since UINT8 stops at 255
        mexPrintf("csmex ERROR: passed amp2=%d, allowed range=1-215\n", amp20);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /*handle the sixth input, which should be width of the first phase*/
    i++;
    int width10 = getpar(prhs, i);
    UINT16 width1 = (UINT16)width10;
    
    if ((width10 > 65565)||(width10<44)) {  
        mexPrintf("csmex ERROR: passed width1=%d, allowed range=44-65565\n", width10);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /*handle the seventh input, which should be the width of the second phase*/
    i++;
    int width20 = getpar(prhs, i);
    UINT16 width2 = (UINT16)width20;

    if ((width20 > 65565)||(width20<44)) {  
        mexPrintf("csmex ERROR: passed width2=%d, allowed range=44-65565\n", width20);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /*handle the eigth input, which should be the frequency of the stimulus delivery*/
    i++;
    int freq0 = getpar(prhs, i);
    UINT16 freq = (UINT16)freq0;

	if ((freq0 > 5154)||(freq0<4)) {  
        mexPrintf("csmex ERROR: passed frequency=%d, allowed range=53-65565\n", freq0);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    /*handle the ninth input, which should be the interphase lag*/
    i++;
    int interphase0 = getpar(prhs, i);
    UINT16 interphase = (UINT16)interphase0;
    
    if ((interphase0 > 65565)||(interphase0<53)) {  // test npuls0 instead of npuls since UINT8 stops at 255
        mexPrintf("csmex ERROR: passed interphase=%d, allowed range=53-65565\n", interphase0);
        mexErrMsgTxt("Parameter value mismatch");
        return retval;
    }
    if (verbose) 
    mexPrintf("Parameters: %d, %d, %d, %d, %d, %d, %d, %d, %d\n",
            cfgID,
            afcf,
            npuls,
            amp1,
            amp2,
            width1,
            width2,
            freq,
            interphase);
    retval = myStim.configureStimulusPattern(
            cfgID,
            afcf,
            npuls,
            amp1,
            amp2,
            width1,
            width2,
            freq,
            interphase);
    if (verbose)
    mexPrintf("Attempt Configure Cerestim: retval=%d\n", retval);
    return retval;
}

void errorMsg(char *msg1, char *msg2) {
    mexPrintf(msg1);
    mexErrMsgTxt(msg2);
    return;
}