
cbmex('open');
cbmex('analogout', 1, 'sequence', [100 32767 900 0], 'repeats', 0);
cbmex('analogout', 1, 'sequence', [500 0 500 0], 'repeats', 0);