#include "BStimulator.h"

int main()
{
	BStimulator cerestim;
	BMaximumValues maxValues;

	while(true)
	{
		//Connect to the cerestim device, if can't connect program aborts
		if(!cerestim.connect(BINTERFACE_DEFAULT, 0))
			break;
	}

	BResult res = BSUCCESS;
	int counter = 0;
	//Ensure that the max values are set high enough so you don't get errors when configuring patterns
	res = cerestim.stimulusMaxValues(&maxValues, 1, BOCVOLT9_5, 215, 65535, 950000, 5154);
	res = cerestim.configureStimulusPattern((BConfig) 1, BWF_CATHODIC_FIRST, 1, 10, 10, 1000, 1000, 200, 2000);
	res = cerestim.configureStimulusPattern((BConfig) 2, BWF_CATHODIC_FIRST, 1, 20, 20, 2000, 2000, 200, 2000);
	res = cerestim.configureStimulusPattern((BConfig) 3, BWF_CATHODIC_FIRST, 1, 30, 30, 3000, 3000, 200, 2000);
	
	//There are two methods for stimulating, first is a program.  With the program you have to call beg of sequence followed
	//by a number of autoStimulus and wait commands and then close it with end of sequence.  Then you will call play with
	//the number of times to play the program.
	res = cerestim.beginningOfSequence();
	for(int i = 1; i < 10; ++i)
	{
		res = cerestim.autoStimulus(i, (BConfig)1);
		res = cerestim.autoStimulus(i, (BConfig)2);
		res = cerestim.autoStimulus(i, (BConfig)3);
	}
	res = cerestim.endOfSequence();
	
	cerestim.play(100);

	//Second method is single configuration
	res = cerestim.manualStimulus(1, (BCONFIG_1));
	res = cerestim.manualStimulus(2, (BCONFIG_2));
	
	//There is a way to write a program that contains a group fo stimulus commands in one call
	//This does a group of two simultaneous stimulations with one configuration
	BGroupStimulus BGSInput;
	BGSInput.channel[0] = 1;
	BGSInput.channel[1] = 45;
	BGSInput.pattern[0] = 1;
	BGSInput.pattern[1] = 1;
	//groupStimulus(UINT8 beginSeq, UINT8 play, UINT16 times, UINT8 number, BGroupStimulus * input);
	//beginSeq should be true if this is first part of a new program
	//play should be true if you want to stimulate immedietaly after.
	//times is the number of times to play the stimulation
	//number is the number of electrodes to simulatneously stimulate
	//*input is the structure containing the electrodes and patterns to use
	res = groupStimulus(true, true, 1, 2, &BGSInput);
}