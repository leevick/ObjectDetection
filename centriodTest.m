function varargout = centriodTest(varargin)
% CENTRIODTEST MATLAB code for centriodTest.fig
%      CENTRIODTEST, by itself, creates a new CENTRIODTEST or raises the existing
%      singleton*.
%
%      H = CENTRIODTEST returns the handle to a new CENTRIODTEST or the handle to
%      the existing singleton*.
%
%      CENTRIODTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CENTRIODTEST.M with the given input arguments.
%
%      CENTRIODTEST('Property','Value',...) creates a new CENTRIODTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before centriodTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to centriodTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help centriodTest

% Last Modified by GUIDE v2.5 19-Nov-2015 16:39:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @centriodTest_OpeningFcn, ...
                   'gui_OutputFcn',  @centriodTest_OutputFcn, ...
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


% --- Executes just before centriodTest is made visible.
function centriodTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to centriodTest (see VARARGIN)

% Choose default command line output for centriodTest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes centriodTest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = centriodTest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

objIM=double(imread('P4.tif'));   
h=figure();imagesc(objIM);colormap(gray);axis('off');
% [objIM,Background]=fun_THBackgroundRremove(objIM);
% h=figure();imagesc(objIM);colormap(gray);axis('off');
[M N]=size(objIM);
% objIM=objIM./max(objIM(:));
[Rx Cy]=fun_CalCentriodSeedfilled3(objIM)
% h=figure();imagesc(g);colormap(objIM);axis('off');


% h=fspecial('sobel');
% g=sqrt(imfilter(objIM,h,'replicate').^2+imfilter(objIM,h,'replicate').^2);
% h=figure();imagesc(g);colormap(jet);axis('off');
% 
% % level = graythresh(objIM);
% % BW = im2bw(objIM,level);
% % h=figure();imagesc(BW);colormap(jet);axis('off');
% 
% SP=fftshift(fft2(objIM));
% padArr=zeros(M*10,N*10)
% padArr(1:M,1:N)=SP;
% padIM=abs(ifft2(padArr));
% % padIM(:,1:30)=0;
% h=figure();imagesc(padIM);colormap(jet);axis('off');
