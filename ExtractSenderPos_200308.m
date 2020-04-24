%Extracting specific sender cell positions to analyze 2D gradient
%Input: Array of all tracked sender cell positions  
%Output: Array of one tracked sender cell positions
 
senderpos=zeros(109,2);

%sendernum is the ID number of the sender in the array of cells tracked
sendernum=12;
for i=1:109
    senderpos(i,:)=Tracked{1,i}.cells{1,sendernum}.pos;
    sendernum=Tracked{1,i}.cells{1,sendernum}.descendants;
end
