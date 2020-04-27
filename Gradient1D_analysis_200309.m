%time range
t0=1;
tfin=108;

%
datapath = uigetdir('','Select the position');
iniposid=strfind(datapath,'Pos');
dir_root=datapath(1:iniposid-1);
namepre=strcat('200302xy',datapath(iniposid+3:end));
load(fullfile(dir_root,'/Background.mat'));
%%

%For each time point
for k=1:tfin
    nameCFP=strcat(namepre,'c1t',num2str(k,'%03d'),'.tif');  % File name
    im=im2double(imread(fullfile(datapath,nameCFP)))*65535; % when converting unit16 to double, the data get rescaled (unit16 uses[0 65535] range)
    CFPmedian=median(median(im)); % this number is consistently 326 among many positions
    CFPstd=500;  % this is about the std of background control (use this std for 2015 movies)
    CFPcutoff=CFPmedian+3*CFPstd; %this is the threshold for determining if a pixel is CFP positive or not
    %generating CFP binary mask
    CFPmask=zeros(1024,1024);
    for l=1:1024
        for m=1:1024
            if im(l,m)>CFPcutoff
               CFPmask(l,m)=1;
            else
            end
        end
    end
    back{1}.avback_norm(:,:,k)=CFPmask(:,:); % return a binary mask 
    back{1}.avback(:,:,k)=im(:,:); %returns modified CFP data

    nameYFP=strcat(namepre,'c2t',num2str(k,'%03d'),'.tif'); %Building YFP file name
    im=im2double(imread(fullfile(datapath,nameYFP)))*65535; % when converting unit16 to double, the data get rescaled (unit16 uses[0 65535] range)
    %normalizing the data: data = (data - MediaBack)/(FluorescentBack-MediaBack)
    %BUT FluorescentBack not actually factored in because the final data was
    %noramlized
    back{2}.avback_norm(:,:,k)=(im(:,:)-MediaOnly_YFPmean)./(PosField_YFPmean-MediaOnly_YFPmean);
end
    
%%    
%Determining if the gradient is coming from the left or the right
    time_frames=tfin-t0+1;
    %If the sum of the first 10 pixels columns (left side) < the sum of
    %the last 10 pixel columns (right side)
    if sum(sum(back{1}.avback_norm(:,1:10,1)))<sum(sum(back{1}.avback_norm(:,end-10:end,1)))
        CFP=fliplr(back{1}.avback_norm(:,:,:));
        CFP_raw=fliplr(back{1}.avback(:,:,:));
        YFP=fliplr(back{2}.avback_norm(:,:,:));
    else
        CFP=back{1}.avback_norm(:,:,:);
        CFP_raw=back{1}.avback(:,:,:);
        YFP=back{2}.avback_norm(:,:,:);
    end
    
%%
    % calculate the mean along each column
    meanYFP=zeros(time_frames,1024);
    sumCFP=zeros(time_frames,1024);
    
    meanYFP_smox=zeros(time_frames,1024);
    meanYFP_smo=zeros(time_frames,1024);  
    sumCFP_smox=zeros(time_frames,1024);  
    sumCFP_smo=zeros(time_frames,1024); 
    
    %Line smoothing parameters
    xspan=15;
    tave=9;
    
    % Only use the pixels that are CFP negative to caculate the mean
    % YFP or RFP, which can help with the drop at the boundary, most
    % likely caused by the invasion of senders. 
    % Also take the sum of CFP along each column.
        
    for k=1:time_frames
        CFPinv=(CFP(:,:,k)-1)*(-1);  
        meanYFP(k,:)=sum(YFP(:,:,k).*CFPinv(:,:))./sum(CFPinv(:,:)); % one potential bug is when a column is completely filled up with CFP, then sum(CFPinv) would be zero. 
        sumCFP(k,:)=sum(CFP(:,:,k),1);
        %smooth data across time points
        meanYFP_smox(k,:)=smooth(meanYFP(k,:),xspan);
        sumCFP_smox(k,:)=smooth(sumCFP(k,:),xspan);
    end
    %Smooth data across positions
    for j=1:1024
        meanYFP_smo(:,j)=smooth(meanYFP_smox(:,j),tave); 
        sumCFP_smo(:,j)=smooth(sumCFP_smox(:,j),tave);       
    end

%%  
    %generate figure
    figure()
    subplot(2,1,1)
    plot((1:1024)*1.3,sumCFP_smo(end,:))
    xlabel('Distance (um)')
    ylabel('Sender CFP (a.u.)')

    subplot(2,1,2)
    plot((1:1024)*1.3,meanYFP_smo(end,:))
    xlabel('Distance (um)')
    ylabel('Citrine (a.u.)')

    %%
    % find the boundary
    senderamps=zeros(time_frames,1);
    bound=zeros(time_frames,1);
    %Boundary set when the sender amplitude drops to 10% of its maximum
    bounddrop=.1;
    for k=1:time_frames
        senderamps(k,1)= mean(sumCFP_smo(k,1:50));
        %Finds the column where the boundary condition is met
        ID=find(sumCFP_smo(k,:)<=senderamps(k,1)*bounddrop);  
        %list of the boundary position at each time point
        bound(k,1)=ID(1);
    end
           
%%
    % define colormap
    cmapr=zeros(time_frames,3);
    for i=1:time_frames
        cmapr(i,:,1)=[1 1 0]-i/time_frames*[0 1 0];
    end
    
    fieldsize=300;
    
    Fig1=figure();
    name1=('Total Fluorescence');
    hold on
    for i=1:10:time_frames-1
        plot((0:fieldsize-1)*1.3,meanYFP_smo(i,bound(i,1):bound(i,1)+fieldsize-1),...
            'Color',[1 1 0]-i/time_frames*[0 1 0])
    end
%     ylim([0 1]);
    xlabel('Distance from sender(um)')
    ylabel('Total Citrine (a.u.)')
    hold off
    colormap(cmapr);  
    cl=colorbar;
    ylabel(cl,'Timepoints (hr)','FontSize',14); 


    myStyle = hgexport('factorystyle');
    myStyle.Format = 'eps';
    myStyle.Resolution = 300;

    hgexport(Fig1,name1,myStyle);  
    save(fullfile(datapath, 'Fig1'),'Fig1');
    
    %%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create movies with CFP and YFP channels combined %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % set uniform greyscale 
    mxy=5; 
    mxc=15000;

    % make movie
    name1='Combined_channels_mov_backsub.avi';
    outfilename2=fullfile(datapath,name1);
    t0=1;
    aviobj = VideoWriter(outfilename2); 
    aviobj.FrameRate = 10;
    open(aviobj);

    ind=0;
    h=waitbar(0,'Generating the combined channels movie'); % generates a waitbar

    imm=zeros(1024,1024,3);

    for k=1:time_frames
        waitbar(1.0*ind/time_frames); 

        ind=ind+1;     
        imm(:,:,1)=YFP(:,:,k)/mxy;
        imm(:,:,2)=YFP(:,:,k)/mxy;
        imm(:,:,3)=(CFP_raw(:,:,k)-2000)/mxc; % subtract the background value of 330

        imshow(imm);      % default colormap of imshow is RGB

        M1 = getframe;
        writeVideo(aviobj, M1);
    end 

    close(h)
    close(aviobj);

%%
    %saving data path file for the next step
    datamean.sumCFP=sumCFP;
    datamean.meanYFP=meanYFP;
    datamean.sumCFP_smo=sumCFP_smo;
    datamean.meanYFP_smo=meanYFP_smo;
    datamean.bound=bound;
    datamean.t0=t0;
    datamean.tfin=tfin;
    datamean.bounddrop=bounddrop;
    
    save(fullfile(datapath,strcat('datamean.mat')),'datamean');

    close all  
        
