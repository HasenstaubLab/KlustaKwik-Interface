function [Times, XVals, YVals, TriCounts, ClusterSpCounts, XYDim] = queryTDT (Tankpath_Base, blockno, filename, clustdata, clustno)
%% Astra Bryant, Jan 14, 2015

%We need to create ExptDesc,TimingDesc,FiltDesc,XYDim
	ExptDesc.Tankpath=sprintf('%s\\%s\\',Tankpath_Base,filename(1:8));
	ExptDesc.Block=sprintf('block-%d',blockno);
	TimingDesc.TimChan='Stim';
	%TimingDesc.STime=Agg_Units{unum,6};
	%TimingDesc.ETime=Agg_Units{unum,7};
	
	%FiltDesc=sprintf('sort=%d AND CHAN=%d',Agg_Units{unum,5},Agg_Units{unum,4});
	XYDim.YDim='Atte';
	XYDim.XDim='Freq';
    
	BlockSelected=0;
%Open tank
while(BlockSelected==0)
	disp('Opening tank');
	TTX = actxcontrol('TTank.X');
	TankConnected = TTX.ConnectServer('Local', 'Me')
	TankOpened=TTX.OpenTank(ExptDesc.Tankpath, 'R')
	BlockSelected=TTX.SelectBlock(ExptDesc.Block)
	TTX.CreateEpocIndexing();
	disp('Opened tank')
  end    
    disp('Setting filters')
	TTX.ResetFilters;

%Get list of X and Y vals
	disp('Getting X and Y vals')
	XEpocs=TTX.GetEpocsExV(XYDim.XDim,0);
	XVals=unique(XEpocs(1,:));
	if(strcmp(XYDim.YDim,'CHAN')) %We have to handle channels differently
		YVals=XYDim.Chans;
	else
		YEpocs=TTX.GetEpocsExV(XYDim.YDim,0);
		YVals=unique(YEpocs(1,:));
	end
	
	
	%Get times list
    disp('Getting times')
	TEpocs=TTX.GetEpocsExV(TimingDesc.TimChan,0);
	Times=TEpocs(2,:);
    
    %Initialize
	TriCounts=zeros(numel(YVals),numel(XVals));
	SpCounts=zeros(numel(YVals),numel(XVals));
    
    %For each time, which X and Y cell does it belong to?
offset=0.00;
duration=0.05;

for n=1:clustno
    temp=clustdata(n).times/24414.0625; %the 10000 is to get the spike timing data from .kwik into the same order of magnitude as the TDT timing information
   
    
    %Initialize
	TriCounts=zeros(numel(YVals),numel(XVals));
	SpCounts=zeros(numel(YVals),numel(XVals));
    
    for i=1:numel(Times)
        startbin=Times(i)+offset;
        endbin=startbin+duration;
        
        ENeuEvents = size(find(temp>startbin & temp<endbin),1);
        ENeuCount  = ENeuEvents;
        
        XVal       = TTX.QryEpocAtV(XYDim.XDim,Times(i),0);
        YVal       = TTX.QryEpocAtV(XYDim.YDim,Times(i),0);
        XInd       = find(XVal==XVals);
        YInd       = find(YVal==YVals);
        XVector(i) = XVal;
        YVector(i) = YVal;
        
        TriCounts(YInd,XInd)=TriCounts(YInd,XInd)+1;
        if(isfinite(ENeuCount) && ENeuCount>0)
            SpCounts(YInd,XInd)=SpCounts(YInd,XInd)+ENeuCount;
        end
    end
     eval(['ClusterSpCounts(:,:,' num2str(n) ')=SpCounts;']);
end
    
    %Close tank
	disp('Closing tank');
	TTX.CloseTank();
	disp('Tank closed')
	%Release server
	disp('Releasing server')
	TTX.ReleaseServer();
	disp('Server released');
    
end