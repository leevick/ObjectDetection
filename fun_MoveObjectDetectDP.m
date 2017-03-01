function AllObjInf=fun_MoveObjectDetectDP(MaxIndexFrame,MaxValFrame)

%--------------------------------------------------------------------------
[M N]=size(MaxIndexFrame);
maskIndex=zeros(M,N,5);
for ii=1:5   
  tempIM=MaxIndexFrame;
  tempIM(MaxIndexFrame~=ii)=0;
  maskIndex(:,:,ii)=tempIM./ii;
  %h=figure();imagesc(maskIndex(:,:,ii));colormap(jet);axis('off');
end
%--------------------------------------------------------------------------
offset=0;
for ii=1:5
    [LFrame,LNum]=bwlabel(maskIndex(:,:,ii),8);%第2、3、4帧中分别待搜索目标个数
  objNum(ii)=LNum;
  %h=figure();imagesc(LFrame);colormap(jet);axis('off');
  
   for jj=1:objNum(ii)
         [r,c]=find(LFrame==jj);%找到连通域标记后的图像中每个运动目标的坐标范围
         objPosiR(jj)=round((max(r)+min(r))./2);%求出目标的粗略质心，以便与连通域提取图像进行配对，从而为求出原灰度图像中运动目标的精确质心做准备
          objPosiC(jj)=round((max(c)+min(c))./2);        
         objPointList(jj+offset,:)=[ii,jj,objPosiR(jj),objPosiC(jj)];%对初步运动目标信息进行存储，包括帧号,目标编号，x、y坐标
  end
     offset=offset+objNum(ii);
 end
%--------------------------------------------------------------------------
% [m n]=size(objPointList);
% for ii=1:m
%   %tempIM=IMArr(:,:,objPointList(ii,1));
%   r1=objPointList(ii,3)-2;
%   r2=objPointList(ii,3)+2;
%   c1=objPointList(ii,4)-2;
%   c2=objPointList(ii,4)+2;
%   if r1<1 continue; end
%   if r2>M continue; end
%   if c1<1 continue; end
%   if c2>N continue; end
%   IM=MaxValFrame(r1:r2,c1:c2);
%   %IM=(IM./max(IM(:))).^4;
%   [rx cy]=fun_CalCentriodSeedfilled3(IM);  
%   objPointList(ii,3)=objPointList(ii,3)+rx-3;
%   objPointList(ii,4)=objPointList(ii,4)+cy-3;
% end

%--------------------------------------------------------------------------
Vr=30;%最大速度阈值，根据实际情况给出；

maxObjNum=max(objNum);
AllObjInf=zeros(maxObjNum*5,3);
curObjNum=0;

objPointF2=objPointList(objNum(1)+1:sum(objNum(1:2)),3:4);
objPointF3=objPointList(sum(objNum(1:2))+1:sum(objNum(1:3)),3:4);
objPointF4=objPointList(sum(objNum(1:3))+1:sum(objNum(1:4)),3:4);
for ii=1:objNum(3)
   for jj=1:objNum(2)
     Dis23=sqrt((objPointF3(ii,1)-objPointF2(jj,1)).^2+(objPointF3(ii,2)-objPointF2(jj,2)).^2); 
     R23=[(objPointF3(ii,1)-objPointF2(jj,1)),(objPointF3(ii,2)-objPointF2(jj,2))];
     
     if (Dis23<=Vr)
         minDisErr=Vr;
         minDPErr=Vr;
         for kk=1:objNum(4)
           Dis34=sqrt((objPointF4(kk,1)-objPointF3(ii,1)).^2+(objPointF4(kk,2)-objPointF3(ii,2)).^2);   
           R34=[(objPointF4(kk,1)-objPointF3(ii,1)),(objPointF4(kk,2)-objPointF3(ii,2))];
           curDP=(R23*R34')./(Dis34*Dis23);
           curDPErr=1-curDP;
           curDisErr=abs(Dis23-Dis34);
        
          if (curDPErr<minDPErr)&&(curDPErr<=0.1)&&(curDisErr<minDisErr)&&(curDisErr<=3)
              minDPErr=curDPErr;
              minDisErr=curDisErr;
              curObjNum=curObjNum+1;              
              AllObjInf((curObjNum-1)*5+1:curObjNum*5,3)=curObjNum;
              AllObjInf((curObjNum-1)*5+2,1:2)=objPointF2(jj,:);
              AllObjInf((curObjNum-1)*5+3,1:2)=objPointF3(ii,:);
              AllObjInf((curObjNum-1)*5+4,1:2)=objPointF4(kk,:);              
          end  
        end
     end     
   end
end

AllObjInf=AllObjInf(1:curObjNum*5,:);
AllObjNum=curObjNum;
%---------------------------------------------------------------
objPointF1=objPointList(1:objNum(1),3:4);
objPointF5=objPointList(sum(objNum(1:4))+1:sum(objNum(1:5)),3:4);

for ii=1:AllObjNum
  minDisErr=Vr;
  minDPErr=Vr;
  for jj=1:objNum(5)
    Dis54=sqrt((AllObjInf((ii-1)*5+4,1)-objPointF5(jj,1)).^2+(AllObjInf((ii-1)*5+4,2)-objPointF5(jj,2)).^2); 
    R54=[(AllObjInf((ii-1)*5+4,1)-objPointF5(jj,1)),(AllObjInf((ii-1)*5+4,2)-objPointF5(jj,2))];
    
    Dis43=sqrt((AllObjInf((ii-1)*5+3,1)-AllObjInf((ii-1)*5+4,1)).^2+(AllObjInf((ii-1)*5+3,2)-AllObjInf((ii-1)*5+4,2)).^2); 
    R43=[(AllObjInf((ii-1)*5+3,1)-AllObjInf((ii-1)*5+4,1)),(AllObjInf((ii-1)*5+3,2)-AllObjInf((ii-1)*5+4,2))];
    curDP=(R54*R43')./(Dis43*Dis54);       
    curDPErr=1-curDP;
    curDisErr=abs(Dis54-Dis43);
    
    if (curDPErr<minDPErr)&&(curDPErr<=0.7)&&(curDisErr<minDisErr)&&(curDisErr<=3)
        minDPErr=curDPErr;
        minDisErr=curDisErr;
        AllObjInf((ii-1)*5+5,1)=objPointF5(jj,1);
        AllObjInf((ii-1)*5+5,2)=objPointF5(jj,2);
    end 
  end
  
  minDisErr=Vr;
  minDPErr=Vr;
  for jj=1:objNum(1)
   
    Dis12=sqrt((AllObjInf((ii-1)*5+2,1)-objPointF1(jj,1)).^2+(AllObjInf((ii-1)*5+2,2)-objPointF1(jj,2)).^2); 
    R12=[(AllObjInf((ii-1)*5+2,1)-objPointF1(jj,1)),(AllObjInf((ii-1)*5+2,2)-objPointF1(jj,2))];
    
    Dis23=sqrt((AllObjInf((ii-1)*5+3,1)-AllObjInf((ii-1)*5+2,1)).^2+(AllObjInf((ii-1)*5+3,2)-AllObjInf((ii-1)*5+2,2)).^2); 
    R23=[(AllObjInf((ii-1)*5+3,1)-AllObjInf((ii-1)*5+2,1)),(AllObjInf((ii-1)*5+3,2)-AllObjInf((ii-1)*5+2,2))];
    curDP=(R12*R23')./(Dis12*Dis23);       
    curDPErr=1-curDP;
    curDisErr=abs(Dis12-Dis23);
    
    
    if (curDPErr<minDPErr)&&(curDPErr<=0.1)&&(curDisErr<minDisErr)&&(curDisErr<=3)
        minDPErr=curDPErr;
        minDisErr=curDisErr;
        AllObjInf((ii-1)*5+1,1)=objPointF1(jj,1);
        AllObjInf((ii-1)*5+1,2)=objPointF1(jj,2);
    end 
  end 
    
end

%--------------------------------------------------------------------------
end

