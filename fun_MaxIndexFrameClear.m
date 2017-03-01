function B=fun_MaxIndexFrameClear(A)
[M N]=size(A);
B=A.*0;
for ii=2:M-1
    for jj=2:N-1
      eNUM=(A(ii-1,jj-1)==A(ii,jj))+(A(ii-1,jj)==A(ii,jj))+(A(ii-1,jj+1)==A(ii,jj))+(A(ii,jj-1)==A(ii,jj))...
            +(A(ii,jj+1)==A(ii,jj))+(A(ii+1,jj-1)==A(ii,jj))+(A(ii+1,jj)==A(ii,jj))+(A(ii+1,jj+1)==A(ii,jj));        
      if(eNUM>=2)    
         B(ii,jj)=A(ii,jj);    
      end
    end
end  



