function kwikimportOE
%% Astra Bryant, March 9, 2015

%%%% This is a top level program!!!

%Important Note: This program assumes that stimulus timing information is
%saved in an open-ephys  file. If this is not the case, don't use this program.

%%Parameters
%clear all;
onlygoodmua=1; %Set to 1 to export only good/mua, without noise or unsorted clusters. Set to 0 to include all clusters.
%sfq=30000; %sampling rate

%% Selecting a file to analyze 
[filename, pathname] = uigetfile('*.kwik','Pick a .kwik file');
rawfilename = regexp(filename, '.kwik','split');
rawfilename=strcat(rawfilename{1},'.kwx');

cd(pathname);


%% Retrieivng spikes, clusters and waveforms from the kwik file

spiketimes = double(h5read(filename, '/channel_groups/0/spikes/time_samples'));
whichcluster = double(h5read(filename, '/channel_groups/0/spikes/clusters/main'));


%Get meta information about spike clusters. This group will have each
%cluster number, with the associated cluster type (0= noise, 1= MUA, 2=
%good, 3= unsorted. The cluster type information is found in
%clustermeta.Groups.Attributes

samplerate=double(h5readatt(filename, '/application_data/spikedetekt','sample_rate'));
channelno=double(h5readatt(filename, '/application_data/spikedetekt','nchannels'));

clustermeta= h5info(filename, '/channel_groups/0/clusters/main/');
clusterno=size(clustermeta.Groups,1);

for n=1:clusterno
    temp=regexp(regexp(clustermeta.Groups(n).Name, 'main/.*','match'),'/','split');
    extractmeta(n,1)= str2num(temp{1,1}{1,2});
    for x= 1:length(clustermeta.Groups(n).Attributes)
        if isequal(clustermeta.Groups(n).Attributes(x).Name,'cluster_group')
            extractmeta(n,2)=clustermeta.Groups(n).Attributes(x).Value;
            continue
        end
    end
end
clear temp

waveforms=double(h5read(rawfilename,'/channel_groups/0/waveforms_filtered'));

%Import masks
temp=double(h5read(rawfilename,'/channel_groups/0/features_masks'));
masks=squeeze(temp(2,[1:3:3*channelno],:));

  if onlygoodmua==1
      temp=find(extractmeta(:,2)>0 & extractmeta(:,2)<3);
      goodmua=extractmeta(temp,:);
      extractmeta=goodmua;
      clustno=size(extractmeta,1);
  else
	  temp=find(extractmeta(:,2)>0);
      goodmua=extractmeta(temp,:);
      extractmeta=goodmua;
      clustno=size(extractmeta,1);
  end

%Make average waveform for each cluster. Cluster information (along with
%cluster type) stored in varible extractmeta. Run through the values in
%column 1 of extractmeta. For each value, collect index of spikes grouped
%into that cluster. That index can be applied to the array 'whichcluster'.

%% Test code for the next loop down. Feel free to ignore 
%for n=1:clusterno
%     x=extractmeta(n,1);
%     spikeindex=find(whichcluster==x);
%    
%     
%     for y=1:length(rowindex)
%     unmaskedwaves(y,:)=waveforms(rowindex(y),:,spikeindex(colindex(y)));
%     unmaskedspiketimes(y,1)=spiketimes(spikeindex(colindex(y),1));
%     end
%     
% end
%% Making a structured array of clusters with spike timing information. May have commented out code for gathering waveforms of spikes contained in the cluster
for n=1:size(extractmeta,1)
    x=extractmeta(n,1);
    spikeindex=find(whichcluster==x);

	[rowindex, colindex] = find(masks(:,spikeindex)>0);
     for y=1:length(rowindex)
         eval(['clustdata(' num2str(n) ').waves(y,:)=double(waveforms(rowindex(y),:,spikeindex(colindex(y))));']);
         %eval(['clustdata(' num2str(n) ').wavestimes(y,1)=double(spiketimes(spikeindex(colindex(y),1)));']);
         
     end
    eval(['clustdata(' num2str(n) ').times=double(spiketimes(spikeindex,1));']); %this is not in real time but is relative to start of recording
%      for y=1:channelno
%      eval(['clustdata(' num2str(n) ').avgwaves(:,y)=transpose(squeeze(mean(waveforms(y,:,spikeindex),3)));']);
%      end
    eval(['clustdata(' num2str(n) ').clustno=x;']);
    eval(['clustdata(' num2str(n) ').clustype=extractmeta(n,2);']);
end

%% Which spike times belong to which stimulus presentations?
%This code is based off of the OE Online analysis program. It will compute
%the timing of the stimulus presentations, by importing ADC2.continuous and
%detecting the TTL pulses stored in that file. Then it will use the saved
%ZMQ-based file containing the stimulus information to create an index of
%stimulus identities, and and an array of the spike times associated with
%those stimulus presentations. 

%Run this code for each cluster, output a figure for each cluster.

timingfile='100_ADC2.continuous';
[Times, XVals, YVals, TriCounts, ClusterSpCounts,ClusterWaveforms, XYDim, offset, duration] = queryOE (clustdata, timingfile, clustno);
close all;


%% Next: plotting
% The array stimresponsedata has vectors for whether spike(s) were
% generated for each stimulus presentation, with the stimulus properties
% determined by matching XVal and YVal vectors. 

% Next, uses code adapted from TDT/Biz system to plot a waveplot.
for x=1:clustno
    kwikHeatPlot(TriCounts,ClusterSpCounts(:,:,x),XVals,YVals, XYDim, goodmua(x), filename, pathname, offset, duration, '');
	set(gcf,'tag','coarse actplot');
	printmany(pathname,sprintf('%s block-%d cluster=%d coarse actplot',filename, '', goodmua(x,1)));
	close(gcf)
	kwikWavePlot(XYDim, TriCounts,{transpose(ClusterWaveforms{:,:,x})},XVals,YVals, goodmua(x), filename, pathname,'');
	set(gcf,'tag','waveplot');
    printmany(pathname,sprintf('%s block-%d cluster=%d waveplot',filename, '', goodmua(x,1)));
	close(gcf)
end

end
