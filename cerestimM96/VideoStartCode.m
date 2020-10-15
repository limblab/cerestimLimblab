%start video recording
cbmex('open');
cbmex('analogout', 1, 'sequence', [100 32767 1100 0], 'repeats', 0);
%stop video recording
cbmex('analogout', 1, 'sequence', [500 0 500 0], 'repeats', 0);


