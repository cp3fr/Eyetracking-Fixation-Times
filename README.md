# Eyetracker_Fixation_Time

This script loads raw eyetracker data and estimates the total fixation time
an fixation time within a left and right region of interest on a screen (defined by bounds).
Because the eyetracker's sampling rate is very low (~30 Hz) and highly variable, 
fixation time estimates are approximated by linear interpolation of gaze position data and 
upsampling to 1000 Hz, and exclusion of out-of-bound samples. The remaining samples are
taken into account to estimate the total (valid) fixation duration, and the relativefixation 
durations on the left and the right side.

Output is a table 'subjdata' containing time information for each trial
Optional plotting can be done setting 'make_plots' true

christian.pfeiffer@uzh.ch
15.09.2019
