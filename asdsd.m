function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 30-May-2018 03:34:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)
import java.util.LinkedList
handles.qArriba = LinkedList();
handles.qAbajo = LinkedList();
handles.video = VideoReader('video2.mp4'); % Abre el archivo de video
handles.numFrames = get(handles.video,'NumberOfFrames');
handles.shot = read(handles.video,1);
handles.umbral = 25000;
handles.umbralderecha = 250000;
handles.distancia = 0.012;
[fil,col,cap] = size(handles.shot);


% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in btnBegin.
function btnBegin_Callback(hObject, eventdata, handles)
% hObject    handle to btnBegin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('dssfagsfsfdg');

set(handles.textVehicles, 'String', '0');
set(handles.textSpeed, 'String', '0');
maskDerArriba = handles.shot * 0; % Crea en negro la mascara derecha del carril superior
maskIzqArriba = handles.shot * 0; % Crea en negro la mascara izquierda del carril superior

maskDerAbajo = handles.shot * 0; % Crea en negro la mascara derecha del carril inferior
maskIzqAbajo = handles.shot * 0; % Crea en negro la mascara izquierda del carril inferior

maskDerArriba(480:630, 1800:1840, :) = 150; % Define el area a analizar de la parte derecha del frame del carril superior
maskIzqArriba(480:630, 90:130, :) = 150; % Define el area a analizar de la parte izquierda del frame del carril superior

maskDerAbajo(690:850, 1800:1840, :) = 150; % Define el area a analizar de la parte derecha del frame del carril inferior
maskIzqAbajo(690:850, 90:130, :) = 150; % Define el area a analizar de la parte izquierda del frame del carril inferior


% TOMA DE INDICES DE LAS MASCARAS
indDerArriba = find(maskDerArriba ~= 0);
indIzqArriba = find(maskIzqArriba ~= 0);
indDerAbajo = find(maskDerAbajo ~= 0);
indIzqAbajo = find(maskIzqAbajo ~= 0); 

% CREA COPIAS DE LAS MASCARAS PARA DOS FRAMES A COMPARAR 
% (ACTUAL Y SIGUIENTE)
maskDerArribaActual = maskDerArriba;
maskIzqArribaActual = maskIzqArriba;
maskDerAbajoActual = maskDerAbajo;
maskIzqAbajoActual = maskIzqAbajo;

maskDerArribaSiguiente = maskDerArriba;
maskIzqArribaSiguiente = maskIzqArriba;
maskDerAbajoSiguiente = maskDerAbajo;
maskIzqAbajoSiguiente = maskIzqAbajo;
maskIzqArriba(indIzqArriba) = handles.shot(indIzqArriba);
maskDerArriba(indDerArriba) = handles.shot(indDerArriba);
maskIzqAbajo(indIzqArriba) = handles.shot(indIzqArriba);
maskDerAbajo(indDerAbajo) = handles.shot(indDerAbajo);


entradasCarrilSuperior = 0; % Contador de autos que entran en el carril superior
entradasCarrilInferior = 0; % Contador de autos que entran en el carril inferior

vehiculoPasandoDerArriba = 0; % Bandera para saber si un auto esta pasando por la mascara derecha del carril superior
vehiculoPasandoIzqArriba = 0; % Bandera para saber si un auto esta pasando por la mascara izquierda del carril superior
vehiculoPasandoDerAbajo = 0; % Bandera para saber si un auto esta pasando por la mascara derecha del carril inferior
vehiculoPasandoIzqAbajo = 0; % Bandera para saber si un auto esta pasando por la mascara izquierda del carril inferior

frameId = 1; % Frame de inicio del video
framesParaPromediar = 7;

while(frameId < handles.numFrames-framesParaPromediar)
    sumaIzqArriba = 0;
    sumaIzqAbajo = 0;
    sumaDerArriba = 0;
    sumaDerAbajo = 0;
    
    promedioArribaIzq = 0;
    promedioAbajoIzq = 0;
    promedioArribaDer = 0;
    promedioAbajoDer = 0;
    frameActual = read(handles.video, frameId);

    
    for i = 0:framesParaPromediar
        frameSiguiente = read(handles.video, frameId + i+1);
        
        maskIzqArribaActual(indIzqArriba) = frameActual(indIzqArriba);
        maskIzqAbajoActual(indIzqAbajo) = frameActual(indIzqAbajo);
        maskIzqArribaSiguiente(indIzqArriba) = frameSiguiente(indIzqArriba);
        maskIzqAbajoSiguiente(indIzqAbajo) = frameSiguiente(indIzqAbajo);
        
        diferenciaArribaIzq = maskIzqArribaActual - maskIzqArribaSiguiente;
        diferenciaAbajoIzq = maskIzqAbajoActual - maskIzqAbajoSiguiente;
        
        sumaIzqArriba = sumaIzqArriba + sum(sum(sum(diferenciaArribaIzq)));
        sumaIzqAbajo = sumaIzqAbajo + sum(sum(sum(diferenciaAbajoIzq)));
        
        if(entradasCarrilSuperior > 0 && vehiculoPasandoDerArriba == 0)
            maskDerArribaActual(indDerArriba) = frameActual(indDerArriba);
            maskDerArribaSiguiente(indDerArriba) = frameSiguiente(indDerArriba);
            
            diferenciaArribaDer = maskDerArribaActual - maskDerArribaSiguiente;
            
            sumaDerArriba = sumaDerArriba + sum(sum(sum(diferenciaArribaDer)));
        end
        
        if(entradasCarrilInferior > 0 && vehiculoPasandoDerAbajo == 0)
            maskDerAbajoActual(indDerAbajo) = frameActual(indDerAbajo);
            maskDerAbajoSiguiente(indDerAbajo) = frameSiguiente(indDerAbajo);
            
            diferenciaAbajoDer = maskDerAbajoActual - maskDerAbajoSiguiente;
            
            sumaDerAbajo = sumaDerAbajo + sum(sum(sum(diferenciaAbajoDer)));
        end
        
        frameActual = frameSiguiente;
    end
    promedioArribaIzq = sumaIzqArriba / framesParaPromediar;
    promedioAbajoIzq = sumaIzqAbajo / framesParaPromediar;
    
    promedioArribaDer = sumaDerArriba / framesParaPromediar;
    promedioAbajoDer = sumaDerAbajo / framesParaPromediar;
    
    if(promedioArribaIzq > handles.umbral && vehiculoPasandoIzqArriba == 0)
        entradasCarrilSuperior = entradasCarrilSuperior + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoIzqArriba = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        handles.qArriba.add(frameId);
        set(handles.textVehicles, 'String', handles.qArriba.size());
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioArribaIzq <= handles.umbral && vehiculoPasandoIzqArriba == 1)
        vehiculoPasandoIzqArriba = 0;
    end
    
    promedioAbajoIzq
    handles.qAbajo.size()
    
    % Igual para el carril inferior
    if(promedioAbajoIzq > handles.umbral && vehiculoPasandoIzqAbajo == 0)
        entradasCarrilInferior = entradasCarrilInferior + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoIzqAbajo = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        handles.qAbajo.add(frameId);
%         set(handles.textVehicles2, 'String', handles.qAbajo.size());
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioAbajoIzq <= handles.umbral && vehiculoPasandoIzqAbajo == 1)
        vehiculoPasandoIzqAbajo = 0;
    end
    
    %A la derecha
    if(promedioArribaDer > handles.umbral && vehiculoPasandoDerArriba == 0)
        entradasCarrilSuperior = entradasCarrilSuperior - 1; % resta uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoDerArriba = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        
        % Calcula la velocidad del auto
        frameEntrada = handles.qArriba.poll();
        set(handles.textVehicles, 'String', handles.qArriba.size());
        frames = frameId - frameEntrada;
        tiempoSeg = frames/24;
        tiempoHoras = tiempoSeg/3600;
        disp(tiempoHoras);
        velocidad = handles.distancia ./tiempoHoras;
        
        disp(velocidad);
        set(handles.textSpeed, 'String', velocidad);
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioArribaDer <= handles.umbral && vehiculoPasandoDerArriba == 1)
        vehiculoPasandoDerArriba = 0;
    end
    
    if(promedioAbajoDer > handles.umbral && vehiculoPasandoDerAbajo == 0)
        entradasCarrilInferior = entradasCarrilInferior - 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoDerAbajo = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        
        % Calcula la velocidad del auto
        frameEntrada = handles.qAbajo.poll();
%         set(handles.textVehicles2, 'String', handles.qAbajo.size());
        frames = frameId - frameEntrada;
        tiempoSeg = frames ./ 24;
        tiempoHoras = tiempoSeg/3600;
        velocidad = handles.distancia ./tiempoHoras;
        
        disp(velocidad);
%         set(handles.textSpeed2, 'String', velocidad);
        
%         set(handles.textSpeed, 'String', velocidad);
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioAbajoDer <= handles.umbral && vehiculoPasandoDerAbajo == 1)
        vehiculoPasandoDerAbajo = 0;
    end
    
    imshow(frameActual, 'Parent',handles.axesIm);
%     imshow(handles.frame,'Parent', handles.axesIm);
%     disp(frameId);
    pause(0.001);
    frameId = frameId+1;
end

% --- Executes on button press in btnFinish.
function btnFinish_Callback(hObject, eventdata, handles)
% hObject    handle to btnFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.textSpeed, 'String', "15Km/h");
