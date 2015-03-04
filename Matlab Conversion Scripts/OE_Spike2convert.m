function OE_Spike2convert
dirname = uigetdir('Z:\astra\OpenEphys sample data\', 'Select Data Directory');
cd(dirname);

dirData = dir(fullfile(dirname, '100_CH*.continuous'));
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
q=17;

for i=1:2 %Only need adc channels 1 and 2. Hacky, maybe
	
	[data] = load_open_ephys_data(ADCList{i});
	compile(q,:)=double(data);
	q=q+1;%def hacky, it's late at night
	clear data
	
end
exportlength=(size(compile,1)*size(compile,2));
exportdata=reshape(compile, exportlength,1);

filename='Traces.dat';
filestring=fullfile(dirname, filename);
fid=fopen(filestring,'w');
fwrite(fid,exportdata,'int64');

fclose('all');

clc
clear all
close all
clear functions

end