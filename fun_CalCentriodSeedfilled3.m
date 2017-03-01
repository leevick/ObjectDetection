function [Rx Cy]=fun_CalCentriodSeedfilled3(I)
%   h=figure();imagesc(I);colormap(gray);axis('off');
  [m n]=size(I);
  mask=zeros(m,n);
  mask(fix(m/2)+1,fix(n/2)+1)=1;
  seedList=zeros(2*(m+n),2);
  seedList(1,:)=[fix(m/2)+1,fix(n/2)+1];
  corDW=1;
  %-----------------------------------------------------------------------
  newseedCount=1;
  while newseedCount>0
     newseedCount=0;
     for k=1:corDW
        curThreshold=I(seedList(k,1),seedList(k,2));     
        for i=-1:1
            for j=-1:1 
                 curR=seedList(k,1)+i;curC=seedList(k,2)+j;
                 if curR>=1 && curR<=m && curC>=1 && curC<=n
                    if I(curR,curC)<=curThreshold && mask(curR,curC)==0 && i*j==0 
                       newseedCount= newseedCount+1;
                       seedList(corDW+newseedCount,:)=[curR,curC];
                       mask(curR,curC)=1;  
                    end  
                 end
            end 
        end
     end
     if newseedCount>0
        seedList(1:newseedCount,:)=seedList(corDW+1:corDW+newseedCount,:);        
        corDW=newseedCount;
     else
        break;
     end
  end 
%    h=figure();imagesc(mask);colormap(gray);axis('off');
 %------------------------------------------------------------------------ 
 Im=I.*mask; 
 
%  mv=mean(Im(:));
%  dv=std(Im(:));
%  k=mv+2*dv;
%  Im=abs(Im-k).*mask;
 Im=(Im./max(Im(:))).^2;
%   h=figure();imagesc(Im);colormap(gray);axis('off'); 
 Im(Im<0.1)=0;
%    h=figure();imagesc(Im);colormap(gray);axis('off'); 
 
 S=sum(Im(:));
 t=linspace(1,m,m);
 k=ones(1,m);
 w=k'*t;
 C=sum(sum(Im.*w));
 R=sum(sum(Im.*rot90(w,3)));
  
 Rx=R/S;
 Cy=C/S;
 
%   h=figure();imagesc(I);colormap(gray);axis('off');
%   h=figure();imagesc(mask);colormap(gray);axis('off');
%   h=figure();imagesc(Im);colormap(gray);axis('off');
%   hold on
%   plot(Cy,Rx,'b*');
 
end

