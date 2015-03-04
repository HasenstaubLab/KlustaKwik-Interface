function kwikimportTDT
%% Astra Bryant, Jan 14, 2015
%Important Note: This program assumes that stimulus timing information is
%saved in a TDT tank file. If this is not the case, don't use this program.
%Code that runs off of open-ephys hasn't been written yet.
%%Parameters
%clear all;
onlygoodmua=1; %Set to 1 to export only good/mua, without noise or unsorted clusters. Set to 0 to include all clusters.
blockno=2;

%% Selecting a file to analyze 
[filename, pathname] = uigetfile('*.kwik','Pick a .kwik file');
rawfilename = regexp(filename, '.kwik','split');
rawfilename=strcat(rawfilename{1},'.kwx');

cd(pathname);


%% Retrieivng spikes, clusters and waveforms from the kwik file

spiketimes = h5read(filename, '/channel_groups/0/spikes/time_samples');
whichcluster = h5read(filename, '/channel_groups/0/spikes/clusters/main');

Tankpath_Base='Z:\astra\Tanks from Biz\Sorted Tanks\';



%Get meta information about spike clusters. This group will have each
%cluster number, with the associated cluster type (0= noise, 1= MUA, 2=
%good, 3= unsorted. The cluster type information is found in
%clustermeta.Groups.Attributes

samplerate=h5readatt(filename, '/application_data/spikedetekt','sample_rate');
channelno=h5readatt(filename, '/application_data/spikedetekt','nchannels');

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

waveforms=h5read(rawfilename,'/channel_groups/0/waveforms_filtered');

%Import masks
temp=h5read(rawfilename,'/channel_groups/0/features_masks');
masks=squeeze(temp(2,[1:3:48],:));

  if onlygoodmua==1
      temp=find(extractmeta(:,2)>0 & extractmeta(:,2)<3);
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
%     for y=1:length(rowindex)
%         eval(['clustdata(' num2str(n) ').waves(y,:)=double(waveforms(rowindex(y),:,spikeindex(colindex(y))));']);
%         eval(['clustdata(' num2str(n) ').wavestimes(y,1)=double(spiketimes(spikeindex(colindex(y),1)));']);
%         
%     end
    eval(['clustdata(' num2str(n) ').times=double(spiketimes(spikeindex,1));']);
%     for y=1:channelno
%     eval(['clustdata(' num2str(n) ').avgwaves(:,y)=transpose(squeeze(mean(waveforms(y,:,spikeindex),3)));']);
%     end
    eval(['clustdata(' num2str(n) ').clustno=x']);
    eval(['clustdata(' num2str(n) ').clustype=extractmeta(n,2)']);
end

%% Which spike times belong to which stimulus presentations?
%Run this code for each cluster, output a figure for each cluster.
%Note that the timing information from the .kwik file is in miliseconds,
%whereas the timing information from the TDT is in seconds. So there needs
%to a converstion here. 
%% TDT Crap

%Setting up TDT connection variables. Will eventually be able to get rid of
%this in favor of event information in the .kwik file (yay)


% Calling the TDT tank, yielding a 2D array with the trial counts of each stimulus condition (YDim x
% XDim), and a 3D array with the number of spikes for each stimulus
% contidition, for each cluster (YDim, XDim, Clustno)
[Times, XVals, YVals, TriCounts, ClusterSpCounts, XYDim] = queryTDT(Tankpath_Base, blockno, filename, clustdata, clustno);
close all;


%Also need to introduce variablse that determines how far after stimulus
%presentation is acceptable for spikes to occur, also the offset.
%Previously: 10 ms offset, 50 ms dur
%%This code is now included in the queryTDT.m file
 offset=0.00;
 duration=0.05;
% for n=1:clustno
%     temp=clustdata(n).times/10000; %the 10000 is to get the spike timing data from .kwik into the same order of magnitude as the TDT timing information
%     for x=1:length(StimTimes)
%         startbin=StimTimes(x)+offset;
%         endbin=startbin+duration;
%         
%         eval(['stimresponsedata(' num2str(n) ').nspikes(x,1)=size(find(temp>startbin & temp<endbin),1);']);
%         %eval(['stimresponsedata(' num2str(n) ').XVector(x,1)=XVector(1,x);']);
%         %eval(['stimresponsedata(' num2str(n) ').YVector(x,1)=YVector(1,x);']);
%         
%     end
% end

%% Next: plotting
% The array stimresponsedata has vectors for whether spike(s) were
% generated for each stimulus presentation, with the stimulus properties
% determined by matching XVal and YVal vectors. 

% Next, need to arrange this data so that a heat map can be generated from
% the data. Should be able to use the code already written for Biz's
% data...
for x=1:clustno
    kwikplotting(TriCounts,ClusterSpCounts(:,:,x),XVals,YVals, XYDim, goodmua(x), filename, pathname, offset, duration, blockno);
    set(gcf,'tag','coarse actplot');
    printmany(pathname,sprintf('%s block-%d cluster=%d coarse actplot',filename, blockno, goodmua(x,1)));
close(gcf)
end

end