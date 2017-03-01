function [X Y]=fun_PCRegistration(refIM,estIM)
  [m,n]=size(refIM);
  buf1ft=fft2(refIM);
  buf2ft=fft2(estIM);
  CC = fftshift(ifft2(buf1ft.*conj(buf2ft)./(abs(buf1ft).*abs(buf2ft))));     
  [max1,loc1] = max(CC);
  [max2,loc2] = max(max1);
  rloc=loc1(loc2);
  cloc=loc2;
  X=rloc-(m/2+1);
  Y=cloc-(n/2+1);
  %h=figure();imagesc(CC);colormap(jet);axis('off');
end

