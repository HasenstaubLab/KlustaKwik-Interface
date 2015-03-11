function OpenEphys2Dat
%rearranges raw information stored in a series of open-ephys .continuous files into a .dat file capable
%of being understood by KlustKwik software. 
%The desired .dat file format is [Time1Channel1, Time1Channel2...
%Time1ChannelN...TimeNChannelN. 

%So for an n channel probe, this program needs to a) read in the
%.continous files, b) rearrange the raw waveform so that time moves iteratively
%through each channel. 

%The program allows the user to select which recorded channels are saved in
%the .dat file. This is important because as of 3/11/15, Klustasuite in the
%H-lab freezes on .dat files containing the full 16 channels of recording.
%Unclear why. 

% Astra Bryant 3/11/15


dirname = uigetdir('Z:\astra\OpenEphys sample data\', 'Select Data Directory');
cd(dirname);

     

temp=regexp(dirname,'\','split');
filename= strcat(temp{end},'.dat');

dirData = dir(fullfile(dirname, '100_CH*.continuous')); %the 100 file id means that this is the mostly unfiltered data recorded from the rhythm fpga board.
dirIndex = [dirData.isdir];
fileList = {dirData(~dirIndex).name}';

sortedfile=[1;9;10;11;12;13;14;15;16;2;3;4;5;6;7;8]; %reordering channels. works.
fileList=fileList(sortedfile);

temp=regexp(fileList,'CH\d*','match');
for i=1:length(temp)
    chanList(i)=temp{i};
end
chanList=chanList';

dirADC=dir(fullfile(dirname,'100_ADC*.continuous'));
ADCIndex=[dirADC.isdir];
ADCList={dirADC(~ADCIndex).name}';

%Ask user which channels to save
[selection, ok] = listdlg('PromptString', 'Select channels to save in .dat file', 'SelectionMode','multiple', 'ListString',chanList);
nchannelstosave=numel(selection);

%for i=1:size(fileList,1)
for i=1:nchannelstosave	
	[data]=load_open_ephys_data(fileList{selection(i)});
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
