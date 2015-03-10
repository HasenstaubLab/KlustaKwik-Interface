function kwikWavePlot(XYDim,TriCounts,SpWaveArray,XVals,YVals,clustername, filename, pathname, blockno)
	
	%%This plot is called by kwikimportOE; it generates a plot of selected
	%%waveforms in each XVal by YVal combination. Adapted from WavePlot.m
	%%by Astra S. Bryant; 3/9/2015
	
	figure;
	set(gcf,'color',[1 1 1],'position',[10   50  1600  750])
	
	
	maxY=0;
	
	for i=1:numel(YVals)
		for j=1:numel(XVals)
			subplot(numel(YVals)+1,numel(XVals),numel(XVals)+j+(i-1)*numel(XVals))
			TheseWaves=SpWaveArray{i,j};
			WaveDSBy=ceil(size(TheseWaves,2)/20);
			phan=plot(TheseWaves(:,1:WaveDSBy:size(TheseWaves,2)),'k');
			% 			waterfall(TheseWaves(:,1:WaveDSBy:size(TheseWaves,2))')
			axis off
			axis tight
			% 			drawnow();
		end
	end
	
	
	for j=1:numel(XVals)
		subplot(numel(YVals)+1,numel(XVals),j)
		axis off;
		text(0,0,sprintf('%s:\n%2.2f',XYDim.XDim,XVals(j)),'fontangle','italic','fontweight','bold');
	end
	
	
	for i=1:numel(YVals)
		subplot(numel(YVals)+1,numel(XVals),(numel(XVals)*i)+1   )
		% 		axiRs off;
		% 		xloc=TimingDesc.Offset-TimingDesc.Duration;
		yl=ylim();
		th=text(-60,.8*max(yl),sprintf('%s:\n%2.2f',XYDim.YDim,YVals(i)),'fontangle','italic','fontweight','bold');
	end
	
	
	if ~isempty(blockno)
		tl=sprintf('File: %s\\ block-%d\n Cluster: %d\nColor: spikes per trial',filename,blockno,'Stim', clustername);
	else
		tl=sprintf('File: %s \n Cluster: %d\n',filename, clustername);
	end
	
	subplot(numel(YVals)+1,numel(XVals),1)
	than=text(0,1,tl,'Fontsize',12);
	set(than, 'interpreter','none') %removes tex interpretation rules
	axis off;

global PLOTTYPE
PLOTTYPE='Wave';
figname=sprintf('Cluster %d %s %s %s vs %s',clustername,PLOTTYPE,'Stim',XYDim.XDim,XYDim.YDim);

set(gcf,'name',figname)