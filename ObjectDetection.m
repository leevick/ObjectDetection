function varargout = ObjectDetection(varargin)
% OBJECTDETECTION M-file for ObjectDetection.fig
%      OBJECTDETECTION, by itself, creates a new OBJECTDETECTION or raises the existing
%      singleton*.
%
%      H = OBJECTDETECTION returns the handle to a new OBJECTDETECTION or the handle to
%      the existing singleton*.
%
%      OBJECTDETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTDETECTION.M with the given input arguments.
%
%      OBJECTDETECTION('Property','Value',...) creates a new OBJECTDETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ObjectDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ObjectDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ObjectDetection

% Last Modified by GUIDE v2.5 27-Aug-2015 09:21:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ObjectDetection_OpeningFcn, ...
                   'gui_OutputFcn',  @ObjectDetection_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ObjectDetection is made visible.
function ObjectDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ObjectDetection (see VARARGIN)

% Choose default command line output for ObjectDetection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ObjectDetection wait for user response (see UIRESUME)
% uiwait(handles.figure1);
global oriIMArr;


% --- Outputs from this function are returned to the command line.
function varargout = ObjectDetection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btn_loadData.
function btn_loadData_Callback(hObject, eventdata, handles)
% hObject    handle to btn_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global oriIMArr;

%输入原始序列图像，并将图像赋予当前序列图像变量----------------------------
[FileName,PathName] = uigetfile({'*.*','All Files(*.*)'},'Input Aperture Data','MultiSelect','on');
[m n]=size(FileName);
if n==5
   oriIMArr=zeros(1024,1024,5); 
   for ii=1:n
     str=strcat(PathName,FileName{ii}); 
     tempIM=double(imread(str));   
     [M N]=size(tempIM); 
     if M==1024
       oriIMArr(:,:,ii)=tempIM; 
     else
       oriIMArr(:,:,ii)=tempIM(2:1025,25:1048,:);
     end     
   end
   
   alpha=str2num(get(handles.edt_viewCof,'string'));
   tempIM=oriIMArr(:,:,1);
   minV=min(tempIM(:));maxV=max(tempIM(:));
   axes(handles.axe_OrigIM);imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off'); 
end   

% --- Executes on button press in btn_objDetction.
function btn_objDetction_Callback(hObject, eventdata, handles)
% hObject    handle to btn_objDetction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global oriIMArr;
global curIMArr;
global MedianValFrame;
global StarPosi;

alpha=str2num(get(handles.edt_viewCof,'string'));%读取显示缩放比例因子
curIMArr=oriIMArr;
%预处理********************************************************************
%去除背景
for ii=1:5 
  [fout,Background]=fun_IterBackgroundRremove(curIMArr(:,:,ii),11);
  %[fout,bg]=fun_THBackgroundRremove(curIMArr(:,:,ii));
  curIMArr(:,:,ii)=abs(fout);        
end 
  curIMArrBak=curIMArr;
%图像配准（以第一帧图像为基准）*********************************************
frameOffset=zeros(5,2);
for ii=2:5
  [Rx Ry]=fun_PCRegistration(curIMArr(385:640,385:640,1),curIMArr(385:640,385:640,ii));
  curIMArr(:,:,ii)=circshift(curIMArr(:,:,ii),[Rx Ry]);
  frameOffset(ii,:)=[Rx Ry];
  if Ry>0
    curIMArr(:,1:Ry,ii)=0;
  end
  if Ry<0
    curIMArr(:,1024-Ry+1:1024,ii)=0;
  end
  if Rx>0
    curIMArr(1:Rx,:,ii)=0;
  end
  if Rx<0
    curIMArr(1024-Rx+1:1024,:,ii)=0; 
  end      
end
%恒星检测******************************************************************
% MedianValFrame=median(curIMArr(:,:,1:5),3);%中值投影帧提取
% % tempIM=MedianValFrame;
% % minV=min(tempIM(:));maxV=max(tempIM(:));
% % h=figure();imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off'); 
% 
% T=150;%人工设定二值化阈值，限定恒星亮度
% medfBW=MedianValFrame;
% medfBW(medfBW<=T)=0;
% medfBW(medfBW>T)=1;
% 
% se=strel('disk',2, 0);
% Mask=imdilate(medfBW,se);
% 
% %[ConnectRegion,RegionNum]=myregion4(Mask);
% ConnectRegion=bwlabel(Mask,4);
% RegionNum=max(ConnectRegion(:));
% 
% [M N]=size(ConnectRegion);
% StarPosi=zeros(RegionNum,3);
% for ii=1:M
%     for jj=1:N
%       if ConnectRegion(ii,jj)~=0  
%         StarPosi(ConnectRegion(ii,jj),1) = StarPosi(ConnectRegion(ii,jj),1) +ii*MedianValFrame(ii,jj);
%         StarPosi(ConnectRegion(ii,jj),2) = StarPosi(ConnectRegion(ii,jj),2) +jj*MedianValFrame(ii,jj);  
%         StarPosi(ConnectRegion(ii,jj),3) = StarPosi(ConnectRegion(ii,jj),3)+MedianValFrame(ii,jj);         
%       end  
%     end
% end
% StarPosi(:,1) =StarPosi(:,1)./StarPosi(:,3);
% StarPosi(:,2) =StarPosi(:,2)./StarPosi(:,3);
% StarPosi=round(StarPosi(:,1:2));
% 
% %清除位于边界的恒星---------------------------------------------------------
% tempTable=StarPosi(:,1:2)*0;
% tempNum=0;
% for ii=1:RegionNum
%     if (StarPosi(ii,1)>124 && StarPosi(ii,1)<900 && StarPosi(ii,2)>124 && StarPosi(ii,2)<900)
%        tempNum=tempNum+1;
%        tempTable(tempNum,:)=StarPosi(ii,1:2);       
%     end    
% end
% StarPosi=tempTable(1:tempNum,:);
% starNUM=tempNum;
% %显示初步恒星检测结果,像素级精度-------------------------------------------
% tempIM=MedianValFrame;
% minV=min(tempIM(:));maxV=max(tempIM(:));
% h=figure('Name','中值帧-恒星像素级检测结果');imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off'); 
% hold on
% plot(StarPosi(:,2),StarPosi(:,1),'r*');

%目标检测******************************************************************
[MaxValFrame MaxIndexFrame]=max(curIMArr(:,:,1:5),[],3);
MedianValFrame=median(curIMArr(:,:,1:5),3);
% h=figure();imagesc(MaxIndexFrame);colormap(jet);axis('off');

tempIM=MaxValFrame;
minV=min(tempIM(:));maxV=max(tempIM(:));
% h=figure();imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off');
tempIM=MedianValFrame;
minV=min(tempIM(:));maxV=max(tempIM(:));
% h=figure();imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off');

norFrame=abs(MaxValFrame-MedianValFrame);
tempIM=norFrame;
minV=min(tempIM(:));maxV=max(tempIM(:));
% h=figure();imagesc(tempIM,[minV,minV+0.1*(maxV-minV)]);colormap(gray);axis('off');

fout=norFrame;
maskIM=fout.*0;
k=median(fout(:))+4*sqrt(median(fout(:)));
k=max(5,k);
maskIM(norFrame>k)=1;
norIndexFrame=maskIM.*MaxIndexFrame;
%  h=figure();imagesc(maskIM);colormap(gray);axis('off');
%  h=figure();imagesc(norIndexFrame);colormap(jet);axis('off');

CorMaxIndexFrame=fun_MaxIndexFrameClear(norIndexFrame);
%   h=figure();imagesc(CorMaxIndexFrame);colormap(jet);axis('off');
 
 mask=CorMaxIndexFrame;
 mask(mask>0)=1;
 testIM=mask.*MaxValFrame;
%  h=figure();imagesc(testIM);colormap(gray);axis('off');
%  检测运动目标，并在最大值帧上显示初步检测结果,像素级精度-------------------
objPosi=fun_MoveObjectDetectDP(CorMaxIndexFrame,MaxValFrame);
objPosiINT=round(objPosi);
%---------------------------------------------------------
[M N]=size(objPosiINT);
for ii=1:M
   XX=objPosiINT(ii,1);YY=objPosiINT(ii,2); 
   if XX~=0 && YY~=0
      Mask=CorMaxIndexFrame(XX-7:XX+7,YY-7:YY+7);
      frameNO=mod(ii,5);
      if frameNO==0 
         frameNO=5;
      end 
      Mask(Mask~=frameNO)=0;
      Mask(Mask==frameNO)=1;
      %h=figure();imagesc(Mask);colormap(gray);axis('off');       
      tempIM=Mask.*MaxValFrame(XX-7:XX+7,YY-7:YY+7);
      %h=figure();imagesc(tempIM);colormap(gray);axis('off');      
      [max1,loc1]=max(tempIM);
      [max2,loc2]=max(max1);
      Rx=loc1(loc2);
      Cy=loc2;
   
     %[Rx Cy] =fun_CalCentroid(tempIM.^4);
     objPosiINT(ii,1)=round(objPosiINT(ii,1)-(8-Rx));
     objPosiINT(ii,2)=round(objPosiINT(ii,2)-(8-Cy));
   end
end
%---------------------------------------------------------
tempIM=MaxValFrame;
minV=min(tempIM(:));maxV=max(tempIM(:));
h=figure('Name','最大值帧-运动目标像素级检测结果');imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off');
hold on
plot(objPosiINT(:,2),objPosiINT(:,1),'r*');

%计算每帧图像上目标及恒星的亚像元位置，并输出结果数据目标检测**************
%计算恒星亚像素精确位置----------------------------------------------------
% for ii=1:5
%   curCutImArr=zeros(15,15,starNUM);
%   curStarPosi=StarPosi;
%   curStarPosi(:,1)=curStarPosi(:,1)-frameOffset(ii,1);
%   curStarPosi(:,2)=curStarPosi(:,2)-frameOffset(ii,2);  
%   for jj=1:starNUM   %提取当前帧恒星数据
%     curCutImArr(:,:,jj)=oriIMArr(curStarPosi(jj,1)-7:curStarPosi(jj,1)+7,curStarPosi(jj,2)-7:curStarPosi(jj,2)+7);
%     [Rx Cy]=fun_CalCentriodSeedfilled(curCutImArr(:,:,jj));
%     curStarPosi(jj,1)=curStarPosi(jj,1)-(8-Rx);
%     curStarPosi(jj,2)=curStarPosi(jj,2)-(8-Cy);  
%   end   
% %   tempIM=oriIMArr(:,:,ii);
% %   minV=min(tempIM(:));maxV=max(tempIM(:));
% %   h=figure();imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off'); 
% %   hold on
% %   plot(curStarPosi(:,2),curStarPosi(:,1),'y*');  
%   str=strcat('恒星位置检测结果',num2str(ii),'帧.xls');
%   xlswrite(str,curStarPosi);
% end

%计算目标的亚像素精确位置----------------------------------------------------
[M N]=size(objPosi);
objArr=zeros(15,15,M);
%objArr=zeros(7,7,5);
objCor=objPosi;
for ii=1:M
  if (objPosi(ii,1)>0&&objPosi(ii,2)>0)
%      intX=round(objPosi(ii,1)-frameOffset(ii,1));
%      intY=round(objPosi(ii,2)-frameOffset(ii,2));
     intX=objPosiINT(ii,1);
     intY=objPosiINT(ii,2);
     
     frameNO=mod(ii,5);
     if frameNO==0 
        frameNO=5;
     end
     if intX~=0 && intY~=0
     %   objArr(:,:,ii)=oriIMArr(intX-7:intX+7,intY-7:intY+7,frameNO);
        objArr(:,:,ii)= curIMArrBak(intX-7:intX+7,intY-7:intY+7,frameNO); 
     
        tempIM=objArr(:,:,ii);
        [Rx Cy]=fun_CalCentriodSeedfilled3(tempIM); 

        objCor(ii,1)=intX-(8-Rx);
        objCor(ii,2)=intY-(8-Cy);
     end
  end
end

hold on
plot(objCor(:,2),objCor(:,1),'b*');


for ii=1:M
  str=strcat('P',num2str(ii),'.tif');
  imwrite(uint16(objArr(:,:,ii)),str,'tif');  
  %h=figure();imagesc(objArr(:,:,ii));colormap(gray);axis('off');       
end
xlswrite('目标位置检测结果.xls',objCor);



% --- Executes on button press in btn_paly.
function btn_paly_Callback(hObject, eventdata, handles)
% hObject    handle to btn_paly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global oriIMArr;

[M N K]=size(oriIMArr);
alpha=str2num(get(handles.edt_viewCof,'string'));
for ii=1:K  
  tempIM=oriIMArr(:,:,ii);
  minV=min(tempIM(:));maxV=max(tempIM(:));
  axes(handles.axe_OrigIM);imagesc(tempIM,[minV,minV+alpha*(maxV-minV)]);colormap(gray);axis('off');    
end  


function edt_viewCof_Callback(hObject, eventdata, handles)
% hObject    handle to edt_viewCof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edt_viewCof as text
%        str2double(get(hObject,'String')) returns contents of edt_viewCof as a double


% --- Executes during object creation, after setting all properties.
function edt_viewCof_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edt_viewCof (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btn_starDectNew.
function btn_starDectNew_Callback(hObject, eventdata, handles)
% hObject    handle to btn_starDectNew (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes during object creation, after setting all properties.
function btn_loadData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to btn_loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
