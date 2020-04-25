function [circledata]=Gradient2D_analysis_200308()

% specify the timespans
t0=1;
tfin=108;
ts=t0:tfin;
time_frames=length(ts);


datapath = uigetdir('Select the data set location');

if ~datapath
return;
end

load(fullfile(datapath,'senderpos.mat'));
load(fullfile(datapath,'Background.mat'));

posid=strfind(datapath,'Pos');
pos=datapath(posid+3:end);
% pos=str2double(datapath(posid+3:end));

namepre=strcat('200302xy',pos);


YFP=zeros(1024,1024,time_frames);
YFP_norm=zeros(1024,1024,time_frames);
for i=t0:tfin
    YFPfilename=strcat(namepre,'c2t',num2str(i,'%03d'),'.tif');
    CFPfilename=strcat(namepre,'c1t',num2str(i,'%03d'),'.tif');
    YFP(:,:,i)=imread(fullfile(datapath,YFPfilename));
    CFP(:,:,i)=imread(fullfile(datapath,CFPfilename));
    YFP_norm(:,:,i)=(YFP(:,:,i) - MediaOnly_YFPmean)./(PosField_YFPmean - MediaOnly_YFPmean);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create movies with CFP and YFP channels combined
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% set uniform greyscale 
mxy=5; 
mxc=2000;

% make movie
name1='Combined_channels_mov_backsub.avi';
outfilename2=fullfile(datapath,name1);
t0=1;
aviobj = VideoWriter(outfilename2); 
aviobj.FrameRate = 10;
open(aviobj);
 
ind=0;
h=waitbar(0,'Generating the combined channels movie'); % generates a waitbar

imm=zeros(300,300,3);
 
for k=1:time_frames
    waitbar(1.0*ind/time_frames); 
    x0 = senderpos(k,1);
    y0 = senderpos(k,2);
     
    ind=ind+1;     
    imm(:,:,1)=YFP_norm(x0-149:x0+150,y0-149:y0+150,k)/mxy;
    imm(:,:,2)=YFP_norm(x0-149:x0+150,y0-149:y0+150,k)/mxy;
    imm(:,:,3)=(CFP(x0-149:x0+150,y0-149:y0+150,k)-2000)/mxc; % subtract the background value of 330
     
    imshow(imm);      % default colormap of imshow is RGB
 
    M1 = getframe;
    writeVideo(aviobj, M1);
end 
 
close(h)
close(aviobj);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create circles and quantify gradient
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

radius = 200;
width = 5.0; % define the width of the circle

radius_vals = width:floor(radius); 
fluor_avg_vals_YFP = 0*radius_vals;
YFP_radial_mean = zeros(time_frames,size(fluor_avg_vals_YFP,2));

for k=t0:tfin
    x0 = senderpos(k,2);
    y0 = senderpos(k,1);
    
    for i=1:length(radius_vals)
        circlemark{i} = make_circlemark(radius_vals(i),x0,y0,YFP_norm(1:end-1,:,k),width);
        num_pix_circle(i) = sum(sum(circlemark{i}));
        YFP_radial_mean(k,i) = sum(sum(YFP_norm(1:end-1,:,k).*circlemark{i}))/num_pix_circle(i);
    end
end

circledata.YFP_radial_mean=YFP_radial_mean;
save(fullfile(datapath, 'circledata'),'circledata');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Plot the gradient
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% find the boundary
    fieldsize=150;
    bound=zeros(time_frames,1);
    YFP_aligned=zeros(time_frames,fieldsize);
    
    for i=1:time_frames
        bound(i,1)=find(YFP_radial_mean(i,:)==max(YFP_radial_mean(i,1:40)));
        YFP_aligned(i,:)=YFP_radial_mean(i,bound(i,1):bound(i,1)+149);
    end


    % Spatially and then temporally smoothing the total
    tave=5;
    xspan=13;
    YFP_smox=zeros(time_frames,fieldsize);
    YFP_smo=zeros(time_frames,fieldsize);

    for i=1:fieldsize
        YFP_smox(:,i)=smooth(YFP_aligned(:,i),tave);
    end

    for j=1:time_frames
        YFP_smo(j,:)=smooth(YFP_smox(j,:),xspan); 
    end
      
    
    % define colormap
    cmapr=zeros(time_frames,3);
    for i=1:time_frames
        cmapr(i,:,1)=[1 1 0]-i/time_frames*[0 1 0];
    end
    
    Fig1=figure();
    name1=('Total Fluorescence');
    hold on
    for i=1:10:time_frames-1
        plot((0:fieldsize-1)*1.3,YFP_smo(i,:),'Color',[1 1 0]-i/time_frames*[0 1 0])
    end
    xlim([0 200])
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
    
end

function circlemark=make_circlemark(radius,x0,y0,image,width)

% this function gives back a circle mask of a certain width that will be
% embedded in an image (2D matrix) afterwards by doing
% max(image,circlemark)

imagesize=size(image);

% ymaxcfp=1.0*max(max(image));

circlePixels=makecircle(radius,x0,y0,imagesize);
circlePixelsbis=makecircle(radius-width,x0,y0,imagesize);
circlemark=(circlePixels-circlePixelsbis);

end

function [circlePixels]=makecircle(radius,x0,y0,imagesize)

imagesize_x = imagesize(2);
imagesize_y = imagesize(1);
[x y] = meshgrid(1:imagesize_x, 1:imagesize_y);

circlePixels = (y - y0).^2 + (x - x0).^2 <= radius.^2;
end

