function kwikplotting(TriCounts,SpCounts,XVals,YVals, XYDim, clustername, filename, pathname, offset, duration, blockno)

%%some processing of the left and right boundaries of signifiant bins
contplot=zeros(length(YVals),length(XVals));
%     for i=1:length(YVals)
%         if LBound(i)>0
%         contplot(i,LBound(i):RBound(i))=1;
%         end
%     end
    
%% And plotting    
	figure;
	imagesc(SpCounts./TriCounts);
        hold on
%     contour(contplot,1,'LineColor','white','LineWidth',2)
%         hold off
	set(gcf,'color',[1 1 1])
	set(gca,'fontsize',14)
	
	XTickDSBy=ceil(numel(XVals)/5);
	set(gca,'XTick',[1:XTickDSBy:numel(XVals)],'XTickLabel',XVals(1:XTickDSBy:numel(XVals)))
	YTickDSBy=ceil(numel(YVals)/5);
	set(gca,'YTick',[1:YTickDSBy:numel(YVals)],'YTickLabel',YVals(1:YTickDSBy:numel(YVals)))
	
	xlabel(XYDim.XDim);
	ylabel(XYDim.YDim);
	if ~isempty(blockno)
		tl=sprintf('File: %s\\ block-%d\n Timing: %s, offset %2.3f sec, duration %2.3f sec\nCluster: %d\nColor: spikes per trial',filename,blockno,'Stim',offset,duration, clustername);
	else
		tl=sprintf('File: %s \n Timing: %s, offset %2.3f sec, duration %2.3f sec\nCluster: %d\nColor: spikes per trial',filename,'Stim',offset,duration, clustername);
	end
	
	than=title(tl,'Fontsize',15);
	set(than, 'interpreter','none') %removes tex interpretation rules
  	set(than,'HorizontalAlignment','center');

cbar=colorbar();
set(cbar','fontsize',14);

global PLOTTYPE
PLOTTYPE='Activity';
figname=sprintf('Cluster %d %s %s %2.3f %2.3f %s vs %s',clustername,PLOTTYPE,'Stim',offset,duration,XYDim.XDim,XYDim.YDim);



set(gcf,'name',figname)

end