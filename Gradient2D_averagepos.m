% List of image file name positions
pos_collection=[4,13,22,29,33,57,63,85,86];
datapath='Volumes/Samsung_T5/200305/2DGrad';

fieldsize=120;
%data smoothing parameters over time and position
tave=5;
xspan=13;

YFP=zeros(108,196,size(pos_collection,2));
bound=zeros(108,1,size(pos_collection,2));
YFP_aligned=zeros(108,fieldsize,size(pos_collection,2));
YFP_smox=zeros(108,fieldsize,size(pos_collection,2));
YFP_smo=zeros(108,fieldsize,size(pos_collection,2));

m=1;
%load each data structure saved from "Gradient2D_analysis" for each
%position
%Extract and store each YFP_radial_mean in a YFP matrix
for i=pos_collection
    filename=strcat('circledata',num2str(i,'%03d'),'.mat');
    load(fullfile(datapath,filename));
    YFP(:,:,m)=circledata.YFP_radial_mean;
    
    %Align the peaks of the YFP signals at each time point by finding the
    %position of the maximum YFP signal in the first 80 averages
    for k=1:108
        bound(k,1,m)=find(YFP(k,:,m)==max(YFP(k,1:80,m)));
        %119 is based on the 120 field size plotted
        YFP_aligned(k,:,m)=YFP(k,bound(k,1,m):bound(k,1,m)+119);
    end
    %smoothing data with respect to position
    for j=1:fieldsize
        YFP_smox(:,j,m)=smooth(YFP_aligned(:,j,m),tave);
    end
    %smoothing data with respect to time 
    for k=1:108
        YFP_smo(k,:,m)=smooth(YFP_smox(k,:,m),xspan); 
    end
    
    m=m+1;
end

%%
    
% calculate the mean across positions
YFP_smo_mean=zeros(108,fieldsize);
YFP_smo_std=zeros(108,fieldsize);

%for each time point and each position in the field size, an average and
%standard deviation is calculated
for i=1:108
    for j=1:fieldsize
        YFP_smo_mean(i,j)=mean(YFP_smo(i,j,:));
        YFP_smo_std(i,j)=std(YFP_smo(i,j,:));
    end
end


    % define colormap
    time_frames=108;
    cmapr=zeros(time_frames,3);
    for i=1:time_frames
        cmapr(i,:,1)=[1 1 0]-i/time_frames*[0 1 0];
    end
    
    %1.3 is the conversion from pixel to um
    x=[0:1:fieldsize-1]*1.3;
    
    Fig2=figure()
    for j=1:size(pos_collection,2)
        subplot(3,4,j)
        hold on
        for i=1:10:time_frames
            plot(x,YFP_smo(i,:,j),'Color',[1 1 0]-i/time_frames*[0 1 0])
        end
        hold off
    end
    
    %%
     
    Fig1=figure();
    name1=('Total Fluorescence');
    hold on
    for i=1:10:time_frames
        plot(x,YFP_smo_mean(i,:),'Color',[1 1 0]-i/time_frames*[0 1 0])
        errorbar(x(1:5:end),YFP_smo_mean(i,1:5:end),YFP_smo_std(i,1:5:end)/...
            sqrt(size(pos_collection,2)),'Color',[1 1 0]-i/time_frames*[0 1 0])
    end
    xlabel('Distance from sender(um)')
    ylabel('Total Citrine (a.u.)')
    hold off
    colormap(cmapr); 
    cl=colorbar;
    ylabel(cl,'Timepoints (hr)','FontSize',14); 
    
    %%
    %Baseline is determined to be the average of the last 50 averages of
    %the plot
    baseline=mean(YFP_smo_mean(1,fieldsize-50:end));
   
    Fig3=figure();
    name1=('Total Fluorescence');
    hold on
    for i=1:10:time_frames
        plot(x,YFP_smo_mean(i,:)/baseline-1,'Color',[1 1 0]-i/time_frames*[0 1 0])
%         errorbar(x(1:5:end),meanYFP_smo_mean(i,1:5:end),meanYFP_smo_std(i,1:5:end)/...
%             sqrt(size(pos_collection,2)),'Color',[1 1 0]-i/time_frames*[0 1 0])
    end
    xlabel('Distance from sender(um)')
    ylabel('Total Citrine (a.u.)')
    hold off
    colormap(cmapr); 
    cl=colorbar;
    ylabel(cl,'Timepoints (hr)','FontSize',14); 

