%Calculate background by averaging control images
%Input:Background image file titles
%Output:Array of averaged background images
 
MediaOnly_YFP(:,:,1)=ImagingMedia_1;
MediaOnly_YFP(:,:,2)=ImagingMedia_2;
MediaOnly_YFP(:,:,3)=ImagingMedia_3;
MediaOnly_YFP(:,:,4)=ImagingMedia_4;
MediaOnly_YFP(:,:,5)=ImagingMedia_5;
MediaOnly_YFPmean=mean(MediaOnly_YFP,3);

PosField_YFP(:,:,1)=x10NMFluoresceinCad_1;
PosField_YFP(:,:,2)=x10NMFluoresceinCad_2;
PosField_YFP(:,:,3)=x10NMFluoresceinCad_3;
PosField_YFP(:,:,4)=x10NMFluoresceinCad_4;
PosField_YFP(:,:,5)=x10NMFluoresceinCad_5;
PosField_YFPmean=mean(PosField_YFP,3);
