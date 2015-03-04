function TDT2Dat
%rearranges raw information stored in a TDT tank into a .dat file capable
%of being understood by KlustKwik software. 
%The desired .dat file format is [Time1Channel1, Time1Channel2...
%Time1ChannelN...TimeNChannelN. 
%So for a 16 channel probe, this program needs to a) read in the tank
%information, b) rearrange the raw waveform so that time moves iteratively
%through each channel. 
% Astra Bryant 1/7/15

%Using TDT-provided matlab code for importing TDT data: TDT2mat.m  
%fullpath=uigetdir();
fullpath='C:\Users\Onyx\Data\EP052914\EP052914\block-4';
%'C:\Users\Batcave\Documents\Data\EP062414\block-9';
tankname= regexp(fullpath,'EP(\w+)','match');
blockname= regexp(fullpath,'block-.*','match');
filename= strcat(tankname,'.dat');
 
data=TDT2mat(tankname, blockname);

channelno=size(data.streams.Raws.data,1);
duration=size(data.streams.Raws.data,2);
sfq=data.streams.Raws.fs;

%% Rearrange data imported from the TDT into a vector with the form [Channel1Sample1, Channel2,Sample1,...etc] 
% This bit is very inefficient. Could be done better/faster
% spot=1;
% for x=1:duration
%    for y=1:channelno
% refdata(spot)=data.streams.Raws.data(y,x);
% spot=spot+1;
%    end
% end

%Blissfully more efficent version
refdata=reshape(data.streams.Raws.data, (channelno*duration),1);

%% Convert data to signed 2 byte data, write to a .dat file
refdata=int16(refdata);

filestring=fullfile(tankname,filename);
fid=fopen(filestring, 'w');
fwrite(fid, refdata, 'int16');
fclose(fid);
end

	