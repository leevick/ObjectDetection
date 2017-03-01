for i=1:157
fid = fopen(['F:\Research\WeakTargetDetect\Data\',num2str(i),'.raw']);
img = fread(fid,[1024 1024],'uint16');
%imshow(img,[]);
[fout,Background]=fun_IterBackgroundRremove(img,11)

%imshow(fout,[]);
fidout = fopen(['F:\Research\WeakTargetDetect\RMB_DATA\',num2str(i),'.raw'],'w');
fwrite(fidout,fout,'uint16');
fclose(fid);
fclose(fidout);
%imshow(abs(fftshift(fout(385:640,385:640))));
end

