# Eyetracker_Fixation_Time

This script loads raw eyetracker data and estimates the total fixation time,
and fixation times in regions of interest (i.e.square regions defined by bounds) 
on the left and right side of the screen. Because of a low (~30 Hz) and variable 
sampling rate of the eyetracker, which do not allow to reliably detect saccades, 
the fixation times are estimated by linear interpolation of gaze position data, 
upsampling from 30 Hz to 1000 Hz, exclusion of out-of-bound samples, and count 
of remaining valid samples within regions of interest. 

Input is a .csv file with raw data from one subject.

Output is a table 'subjdata' containing fixation times for each trial.
Optional plotting can be done setting 'make_plots' true.

christian.pfeiffer@uzh.ch
15.09.2019
