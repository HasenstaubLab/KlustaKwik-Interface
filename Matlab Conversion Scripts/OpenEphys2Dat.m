function OpenEphys2Dat
%rearranges raw information stored in a series of open-ephys .continuous files into a .dat file capable
%of being understood by KlustKwik software. 
%The desired .dat file format is [Time1Channel1, Time1Channel2...
%Time1ChannelN...TimeNChannelN. 

%So for a 16 channel probe, this program needs to a) read in the
%.continous files, b) rearrange the raw waveform so that time moves iteratively
%through each channel. 

% Note, this assumes there is a 16 channel probe.

% Astra Bryant 2/20/15

dirname = uigetdir('Z:\astra\OpenEphys sample data\', 'Select Data Directory');
cd(dirname);

temp=regexp(dirname,'\','split');
filename= strcat(temp{end},'.dat');

dirData = dir(fullfile(dirname, '100_CH*.continuous')); %the 100 file id means that this is the mostly unfiltered data recorded from the rhythm fpga board.
dirIndex = [dirData.isdir];
fileList = {dirData(~dirIndex).name}';

sortedfile=[1;9;10;11;12;13;14;15;16;2;3;4;5;6;7;8]; %reordering channels. works.
fileList=fileList(sortedfile);

dirADC=dir(fullfile(dirname,'100_ADC*.continuous'));
ADCIndex=[dirADC.isdir];
ADCList={dirADC(~ADCIndex).name}';


for i=1:size(fileList,1)
	
	[data]=load_open_ephys_data(fileList{i});
	compile(i,:)=double(data);
	clear data
end

channelno=size(compile,1);
duration=size(compile,2);

refdata=reshape(compile, (channelno*duration),1);

%% Convert data to signed 2 byte data, write to a .dat file
refdata=int16(refdata);

filestring=fullfile(dirname,filename);
fid=fopen(filestring, 'w');
fwrite(fid, refdata, 'int16');
fclose(fid);


end
