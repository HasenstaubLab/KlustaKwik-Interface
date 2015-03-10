function [Times, XVals, YVals, TriCounts, ClusterSpCounts, ClusterWaveforms, XYDim, offset, duration] = queryOE (clustdata, timingfile, clustno)
%% Astra Bryant, March 4, 2015
%This function is called by kwikimportOE.m

eid=fopen(timingfile);
if eid == -1
	error('Could not open ADC file %s', timingfile); 
	return
end

%get times lise
disp('Getting times')
[Times sfq]= kwikOEdetecttiming (eid); %this generates an nx2 array, where column 1 is the start timing of a stimulus, and column 2 is the end time of the stimulus
%Note: Times are in real time (seconds)

%Stimulus Identity
disp('Getting stimulus values');
[zmqfilename, zmq_dir] = uigetfile('*.mat','Pick a ZMQ-generated .mat file'); %replace with an automatic process? Figure out how to intuit the naming conventions.
addpath(genpath(zmq_dir)); 
load(zmqfilename)

XYDim.YDim='Atte';
XYDim.XDim='Freq';
%x_idx = strmatch('audio_freq',var_list,'exact');
%y_idx = strmatch('audio_atten',var_list,'exact');
x_idx = strmatch('audio_dur',var_list,'exact');
y_idx = strmatch('audio_dur',var_list,'exact');
x_prms = stim_vals{x_idx};
y_prms = stim_vals{y_idx};

% get number of levels for each plotting var
XVals = unique(x_prms);
YVals = unique(y_prms);
nr_uniq_x = numel(XVals); %maybe not necessary
nr_uniq_y = numel(YVals);
xy = [x_prms' y_prms'];

%Initialize
TriCounts=zeros(numel(YVals),numel(XVals));
SpCounts=zeros(numel(YVals),numel(XVals));
Waveforms=cell(numel(YVals),numel(XVals));
 
%For each time, which X and Y cell does it belong to?
offset=0.00;
duration=0.05; %these are in seconds, so 50 ms

for n=1:clustno
	%Determine which spikes belong within the time windows specified in
	%temp=clustdata(n).times;
	temp=clustdata(n).times/sfq; %This line is necessary if .kwik timing
	%data is in another time base than the data in the .continuous file.
	%Won't know until I can run them.
	
	for i=1:numel(Times(:,1))
		startbin=Times(i,1)+offset; %these will set the duration of the response here. can also use the full duration, by setting endbin to Times(i,2)
		endbin=startbin+duration;
		ENeuEvents = size(find(temp>startbin & temp<endbin),1);
		ENeuInd    = find(temp>startbin & temp<endbin);
		ENeuCount  = ENeuEvents;
		
		XVal       = xy(i,1);
        YVal       = xy(i,2);
        XInd       = find(XVal==XVals);
        YInd       = find(YVal==YVals);
        XVector(i) = XVal;
        YVector(i) = YVal;
        
		TriCounts(YInd,XInd)=TriCounts(YInd,XInd)+1;
        if(isfinite(ENeuCount) && ENeuCount>0)
            SpCounts(YInd,XInd)=SpCounts(YInd,XInd)+ENeuCount;
			Waveforms{YInd,XInd}=vertcat(Waveforms{YInd, XInd},clustdata(n).waves(ENeuInd,:));
        end
	end
	eval(['ClusterSpCounts(:,:,' num2str(n) ')=SpCounts;']);
	eval(['ClusterWaveforms(:,:,' num2str(n) ')=Waveforms;']);
end   
end