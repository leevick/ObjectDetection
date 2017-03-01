function [Rx Cy] =fun_CalCentroid(Im)
  [m n]=size(Im);
  S=sum(Im(:));
  t=linspace(1,m,m);
  k=ones(1,m);
  w=k'*t;
  C=sum(sum(Im.*w));
  R=sum(sum(Im.*rot90(w,3)));
  
  Rx=R/S;
  Cy=C/S;
  
%   [m n]=size(Im);
%   [X Y]=MESHGRID(1:n,1:m);
%   Rx=sum(sum(X.*Im))/sum(sum(Im));
%   Cy=sum(sum(Y.*Im))/sum(sum(Im));
end

