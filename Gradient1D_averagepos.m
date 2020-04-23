%Collection of image positions that you want to average together
pos_collection=[187,188,193,196,222,228,230];

%Retrieving 
datapath='Volumes/Samsung_T5/200305/1DGrad';

%The length of the gradient that you are analyzing (the gradient general
%does not extend the full length of the image so you do not need to look at
%the full 1124 pixel length)
fieldsize=350;
%Boundary defined as the point where the mTurquoise (sender signal) is 10%
%of the intial
bounddrop=.1;

%%%%%%%%%%%%%%%%%%%%%%
%Setting up Variables%
%%%%%%%%%%%%%%%%%%%%%%

%Empty matrixes so when the images are all averaged together, they
%fit into one matrix
%Xx = zeros(timepoints, image length in pixels, length of pos_collection)
meanYFP_smo=zeros(108,1024,size(pos_collection,2));
sumCFP_smo=zeros(108,1024,size(pos_collection,2));
%List to collect
senderamps=zeros(108,1,size(pos_collection,2)); 
%List to collect boundaries
bound=zeros(108,1,size(pos_collection,2)); 

%Empty matrix for when the 
meanYFP_smo_align=zeros(108,fieldsize,size(pos_collection,2));

%parallel to i
m=1;
%For each element in pos_collection
for i=pos_collection
    %Concatenating the file name and loading it
    filename=strcat('datamean',num2str(i,'%03d'),'.mat');
    load(fullfile(datapath,filename));
    %Takes ___ data file from the "datamean" data structure
    sumCFP_smo(:,:,m)=datamean.sumCFP_smo;
    meanYFP_smo(:,:,m)=datamean.meanYFP_smo;
    %For each time point, finding the maximum signal which is then used to align the signal
    %peaks
    for k=1:108
        %Finds the median value of CFP signal of the first 100 pixels 
        %perpendicular to the boundary of m position in pos_collection
        senderamps(k,1,m)= median(sumCFP_smo(k,1:100,m));
        %Out of all the median values of CFP signal in the first 100 pixels, 
        %find the first position "x" value where the boundary condition is met
        ID=find(sumCFP_smo(k,50:end,m)<=senderamps(k,1,m)*bounddrop);  
        %Storing the boundary parameter
        bound(k,1,m)=ID(1); 
        %Adjusted so that only the values ranging from the  
        %[boundary : boundary+field size] are kept from meanYFP_smo 
        %values 
        meanYFP_smo_align(k,:,m)=meanYFP_smo(k,bound(k,1,m):bound(k,1,m)+fieldsize-1,m);      
    end
    %increases m parallel to index of element i
    m=m+1;
end

%%
    
% calculate the mean across positions
meanYFP_smo_mean=zeros(108,fieldsize);
meanYFP_smo_std=zeros(108,fieldsize);

for i=1:108
    for j=1:fieldsize
        meanYFP_smo_mean(i,j)=mean(meanYFP_smo_align(i,j,:));
        meanYFP_smo_std(i,j)=std(meanYFP_smo_align(i,j,:));
    end
end


    % define colormap
    time_frames=108;
    cmapr=zeros(time_frames,3);
    for i=1:time_frames
        cmapr(i,:,1)=[1 1 0]-i/time_frames*[0 1 0];
    end
    
    x=[0:1:fieldsize-1]*1.3;
    
    Fig1=figure()
    for j=1:size(pos_collection,2)
        subplot(3,4,j)
        hold on
        for i=1:10:time_frames
            plot(x,meanYFP_smo_align(i,:,j),'Color',[1 1 0]-i/time_frames*[0 1 0])
        end
        hold off
    end
    
    %%
     
    Fig2=figure();
    name1=('Total Fluorescence');
    hold on
    for i=1:7:time_frames
        plot(x,meanYFP_smo_mean(i,:),'Color',[1 1 0]-i/time_frames*[0 1 0])
%         errorbar(x(1:5:end),meanYFP_smo_mean(i,1:5:end),meanYFP_smo_std(i,1:5:end)/...
%             sqrt(size(pos_collection,2)),'Color',[1 1 0]-i/time_frames*[0 1 0])
    end
    xlabel('Distance from sender(um)')
    ylabel('Total Citrine (a.u.)')
    hold off
    colormap(cmapr); 
    cl=colorbar;
    ylabel(cl,'Timepoints (hr)','FontSize',14); 
    
    
   %%
   baseline=mean(meanYFP_smo_mean(1,fieldsize-50:end));
   
    Fig3=figure();
    name1=('Total Fluorescence');
    hold on
    for i=1:7:time_frames
        plot(x,meanYFP_smo_mean(i,:)/baseline-1,'Color',[1 1 0]-i/time_frames*[0 1 0])
%         errorbar(x(1:5:end),meanYFP_smo_mean(i,1:5:end),meanYFP_smo_std(i,1:5:end)/...
%             sqrt(size(pos_collection,2)),'Color',[1 1 0]-i/time_frames*[0 1 0])
    end
    xlabel('Distance from sender(um)')
    ylabel('Total Citrine (a.u.)')
    hold off
    colormap(cmapr); 
    cl=colorbar;
    ylabel(cl,'Timepoints (hr)','FontSize',14); 
