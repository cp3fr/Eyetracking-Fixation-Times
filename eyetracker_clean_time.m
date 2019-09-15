%%eyetracker_cleaning.m
%
%This script loads raw eyetracker data and estimates the total fixation time
%an fixation time within a left and right region of interest on a screen (defined by bounds).
%Because the eyetracker's sampling rate is very low (~30 Hz) and highly variable, 
%fixation time estimates are approximated by linear interpolation of gaze position data and 
%upsampling to 1000 Hz, and exclusion of out-of-bound samples. The remaining samples are
%taken into account to estimate the total (valid) fixation duration, and the relative
%fixation durations on the left and the right side.
%
%Output is a table 'subjdata' containing time information for each trial
%Optional plotting can be done setting 'make_plots' true
%
%christian.pfeiffer@uzh.ch
%15.09.2019
%
clear all;close all;clc;

%settings
make_plots = false;
sr = 1000; %resample frequency in Hz
outer_bounds.x = [0.1, 0.9];
outer_bounds.y = [0.1, 0.9];
inner_bounds.x = [0.4, 0.6];

%load the data
fn = '190315095824_tobii.csv';
rawdata=readtable(fn);

%initial data inspection
if make_plots
  figure
  scatterhist(rawdata.eyeX,rawdata.eyeY)
end

%output data
subjdata = table;

%current trial
for trial = unique(rawdata.trial)';

  disp(['..trial ',num2str(trial)])

  %data for the current trial
  ind = rawdata.trial==trial;
  data = rawdata(ind,:);

  %raw data
  raw.t=data.expTime-data.expTime(1);
  raw.x=data.eyeX;
  raw.y=data.eyeY;

  %raw data inspection
  if make_plots
    figure
    subplot(2,2,1);plot(raw.x,raw.y,'-ok'),xlim([0 1]),ylim([0 1]),xlabel('x'),ylabel('y'),title('Raw Data')
    subplot(2,2,2);plot(raw.t,raw.y,'-ok'),ylim([0 1]),xlabel('Time (sec)'),ylabel('y')
    subplot(2,2,3);plot(raw.x,raw.t,'-ok'),xlim([0 1]),xlabel('x'),ylabel('Time (sec)')
    subplot(2,2,4);boxplot(1./diff(raw.t));ylabel('Hz');title('SR')
  end

  %resample
  x = raw.t;
  xv = x(1):1/sr:x(end);
  res.t=interp1(x,raw.t,xv);
  res.x=interp1(x,raw.x,xv);
  res.y=interp1(x,raw.y,xv);

  %resampled data inspection
  if make_plots
    figure
    subplot(2,2,1);plot(res.x,res.y,'-ok'),xlim([0 1]),ylim([0 1]),xlabel('x'),ylabel('y'),title('Resampled Data')
    subplot(2,2,2);plot(res.t,res.y,'-ok'),ylim([0 1]),xlabel('Time (sec)'),ylabel('y')
    subplot(2,2,3);plot(res.x,res.t,'-ok'),xlim([0 1]),xlabel('x'),ylabel('Time (sec)')
    subplot(2,2,4);boxplot(1./diff(res.t));ylabel('Hz');title('SR')
  end

  %remove out ouf bound sampling points
  ind = (res.x < outer_bounds.x(1)) ...
      | (res.x > inner_bounds.x(1) & inner_bounds.x(2) < 0.6) ... %dead band in the center
      | (res.x > outer_bounds.x(2)) ...
      | (res.y < outer_bounds.y(1)) ...
      | (res.y > outer_bounds.y(2));
  clean = res;
  clean.x(ind)=NaN;
  clean.y(ind)=NaN;

  %cleaned data inspection
  if make_plots
    figure
    subplot(2,2,1);plot(clean.x,clean.y,'-ok'),xlim([0 1]),ylim([0 1]),xlabel('x'),ylabel('y'),title('Cleaned Data')
    subplot(2,2,2);plot(clean.t,clean.y,'-ok'),ylim([0 1]),xlabel('Time (sec)'),ylabel('y')
    subplot(2,2,3);plot(clean.x,clean.t,'-ok'),xlim([0 1]),xlabel('x'),ylabel('Time (sec)')
    subplot(2,2,4);boxplot(1./diff(clean.t));ylabel('Hz');title('SR')
  end

  %extract duration information
  curr = table;
  curr.trial = trial;

  curr.res_time_total = res.t(end)-res.t(1); %in sec
  curr.res_time_left = sum( res.x < 0.5 ) * (1/sr); %in sec
  curr.res_time_right = sum( res.x > 0.5 ) * (1/sr); %in sec
  curr.res_left_of_total = curr.res_time_left / curr.res_time_total;
  curr.res_right_of_total = curr.res_time_right / curr.res_time_total;

  curr.clean_time_total = sum(~isnan(clean.x)) * (1/sr); %in sec
  curr.clean_time_left = sum( clean.x < 0.5 ) * (1/sr); %in sec
  curr.clean_time_right = sum( clean.x > 0.5 ) * (1/sr); %in sec
  curr.clean_left_of_total = curr.clean_time_left / curr.clean_time_total;
  curr.clean_right_of_total = curr.clean_time_right / curr.clean_time_total;

  %merge the tables
  subjdata = cat(1,subjdata,curr);

  clear curr ind clean res curr raw data x xv;

end

