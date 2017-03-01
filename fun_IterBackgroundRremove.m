function [fout,Background]=fun_IterBackgroundRremove(fin,var)   %去除背景

[M N]=size(fin);                                %求像高、像宽
imL=fin(:,1:fix(N/2));                          %左半部分
imR=fin(:,fix(N/2)+1:end);                      %右半部分
%-------------------------------------------------------------------------
%for ii=1:3
for ii=1:4
%  w=1/10000.*ones(100,100);
  w=1/1024.*ones(32,32);
  
  imLB=imfilter(imL,w,'symmetric');
  imRB=imfilter(imR,w,'symmetric');
  
  imLFree=min(imL,imLB+2*var);
  imRFree=min(imR,imRB+2*var);
  
  imL=imLFree;
  imR=imRFree;
end

Background=[imLB,imRB];
fout=fin-Background;
fout(fout<0)=0;

end





