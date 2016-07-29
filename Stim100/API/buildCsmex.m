% do the mex build for csmex, interface to Blackrock stim100 beta units
mex -g -output csmex.mex stim100mex.cpp BStimAPI.lib
csmex('connect'); csmex('disconnect');