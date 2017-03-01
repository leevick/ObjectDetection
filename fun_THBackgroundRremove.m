function [fout,Background]=fun_THBackgroundRremove(fin)
 [M N]=size(fin);
 bgArr=zeros(M,N,3);
 strel1=[1 1 1 1 1;1 1 1 1 1;1 1 1 1 1;1 1 1 1 1; 1 1 1 1 1];
 strel2=[0 0 1 0 0;0 1 1 1 0;1 1 1 1 1;0 1 1 1 0; 0 0 1 0 0];
 strel3=[0 0 1 0 0;0 0 1 0 0;1 1 1 1 1;0 0 1 0 0; 0 0 1 0 0];
 
%  strel1=strel('disk',7);
 
 bgArr(:,:,1)=imopen(fin,strel1);
 bgArr(:,:,2)=imopen(fin,strel2);
 bgArr(:,:,3)=imopen(fin,strel3); 
  
 Background=max(bgArr,[],3);
 fout=imsubtract(fin,Background);
end





