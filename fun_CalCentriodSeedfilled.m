function [Rx Cy]=fun_CalCentriodSeedfilled(I)
  [m n]=size(I);
  mv=mean(I(:));
  dv=std(I(:));
  threshold=mv+2*dv;
%-----------------------------------------------------------------------
  mask=zeros(m,n);
  mask(fix(m/2)+1,fix(n/2)+1)=1;
  seedList=zeros(2*(m+n),2);
  seedList(1,:)=[fix(m/2)+1,fix(n/2)+1];
  seedCount=1;
  n=seedCount+1;
  while(seedCount>0)
     for k=1:seedCount
        for i=-1:1
           for j=-1:1 
              if I(seedList(k,1)+i,seedList(k,2)+j)>=threshold && mask(seedList(k,1)+i,seedList(k,2)+j)==0 && i*j==0
                 seedList(n,:)=[seedList(k,1)+i,seedList(k,2)+j];
                 mask(seedList(k,1)+i,seedList(k,2)+j)=1;
                 n=n+1;
              end  
           end               
        end
        seedList(k,:)=0;
     end
     %h=figure();imagesc(mask);colormap(gray);axis('off');
     
     if n-seedCount-1>0
       seedList(1:n-seedCount-1,:)=seedList(seedCount+1:n-1,:);
       seedCount=n-seedCount-1;
       n=seedCount+1;
     else
       break;          
     end   
  end
  
  %------------------------------------------------------------------------ 
  Im=(I-mv).*mask; 
  %h=figure();imagesc(Im);colormap(gray);axis('off');
  S=sum(Im(:));
  t=linspace(1,m,m);
  k=ones(1,m);
  w=k'*t;
  C=sum(sum(Im.*w));
  R=sum(sum(Im.*rot90(w,3)));
  
  Rx=R/S;
  Cy=C/S;
end

