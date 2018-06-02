% ------------------ MEDIDOR DE VELOCIDAD DE VEHICULOS ------------------ %

% --------------------- DANIEL FELIPE OSPINA PEREZ ---------------------- %
% ---------------------- MARIO ANDRES GARCIA TORO ----------------------- %

% ------------------ PROCESAMIENTO DIGITAL DE IMAGENES ------------------ %






% ----------------------------------------------------------------------- %
% ------------ CÓDIGO GENERADO POR MATLAB PARA MOSTRAR LA GUI ----------- %
% ----------------------------------------------------------------------- %
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

% ----------------------------------------------------------------------- %
% ------------ CÓDIGO GENERADO POR MATLAB PARA MOSTRAR LA GUI ----------- %
% ----------------------------------------------------------------------- %





% ----------------------------------------------------------------------- %
% ------------ INICIALIZACIÓN DE VARIABLES Y CARGA DEL VIDEO ------------ %
% ----------------------------------------------------------------------- %

import java.util.LinkedList % Se usa la librería LinkedList de java para el manejo de las colas
handles.qArriba = LinkedList(); % Se crea una cola para contar los vehículos en el carril superior
handles.video = VideoReader('video2.mp4'); % Abre el archivo de video
handles.numFrames = get(handles.video,'NumberOfFrames'); % Se Obtiene el número de frames del video
handles.shot = read(handles.video,1); % Se toma el primer frame del video
handles.umbral = 25000; % Se establece un umbral para identificar un movimiento como un vehículo
imshow(handles.shot, 'Parent',handles.axesIm); % Muestra el primer frame en la GUI

% ----------------------------------------------------------------------- %
% ------------ INICIALIZACIÓN DE VARIABLES Y CARGA DEL VIDEO ------------ %
% ----------------------------------------------------------------------- %





% ----------------------------------------------------------------------- %
% ------------ CÓDIGO GENERADO POR MATLAB PARA MOSTRAR LA GUI ----------- %
% ----------------------------------------------------------------------- %

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

% ----------------------------------------------------------------------- %
% ------------ CÓDIGO GENERADO POR MATLAB PARA MOSTRAR LA GUI ----------- %
% ----------------------------------------------------------------------- %





% ----------------------------------------------------------------------- %
% --------------- COMPORTAMIENTO GENERAL DE LA APLICACIÓN --------------- %
% ----------------------------------------------------------------------- %

% --- Executes on button press in btnBegin.
function btnBegin_Callback(hObject, eventdata, handles)
% hObject    handle to btnBegin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

maskDerArriba = handles.shot * 0; % Crea en negro la mascara derecha del carril superior
maskIzqArriba = handles.shot * 0; % Crea en negro la mascara izquierda del carril superior

maskDerArriba(480:630, 1800:1840, :) = 150; % Define el area a analizar de la parte derecha del frame del carril superior
maskIzqArriba(480:630, 90:130, :) = 150; % Define el area a analizar de la parte izquierda del frame del carril superior

% TOMA DE INDICES DE LAS MASCARAS
indDerArriba = find(maskDerArriba ~= 0);
indIzqArriba = find(maskIzqArriba ~= 0);

% CREA COPIAS DE LAS MASCARAS PARA DOS FRAMES A COMPARAR 
% (ACTUAL Y SIGUIENTE)
maskDerArribaActual = maskDerArriba;
maskIzqArribaActual = maskIzqArriba;

maskDerArribaSiguiente = maskDerArriba;
maskIzqArribaSiguiente = maskIzqArriba;

% maskIzqArriba(indIzqArriba) = handles.shot(indIzqArriba);
% maskDerArriba(indDerArriba) = handles.shot(indDerArriba);

% DEFINE VARIABLES Y BANDERAS NECESARIAS
entradasCarrilSuperior = 0; % Contador de autos que entran en el carril superior

vehiculoPasandoDerArriba = 0; % Bandera para saber si un auto esta pasando por la mascara derecha del carril superior
vehiculoPasandoIzqArriba = 0; % Bandera para saber si un auto esta pasando por la mascara izquierda del carril superior

frameId = 1; % Frame de inicio del video
velocidad = 0; % Se inicia la variable velocidad en cero

framesParaPromediar = 7; % Número de frames en los que se basa para determinar si es un vehículo o no

% Ciclo para analizar todos los frames del video.
while(frameId < handles.numFrames-framesParaPromediar)
    % Variables de suma y promedio para ayudar en el análisis de los frames
    sumaIzqArriba = 0;
    sumaDerArriba = 0;
    
    promedioArribaIzq = 0;
    promedioArribaDer = 0;
    
    % Toma el primer frame a analizar del video.
    frameActual = read(handles.video, frameId);

    % Ciclo para analizar el espacio de 7 (framesParaPromediar) frames del video
    for i = 0:framesParaPromediar
        % --------------------------------------------------------------- %
        % ------------- CALCULO DE CAMBIOS EN LAS MASCARAS -------------- %
        % --------------------------------------------------------------- %
        
        % Lee el siguien frame del video para compararlo con el actual
        frameSiguiente = read(handles.video, frameId + i+1);
        
        % MASCARA IZQUIERDA (INGRESO DE VEHICULOS)
        
        % Llena las mascaras de la izquierda con la información de cada frame según los índices
        maskIzqArribaActual(indIzqArriba) = frameActual(indIzqArriba);
        maskIzqArribaSiguiente(indIzqArriba) = frameSiguiente(indIzqArriba);
        
        % Toma los cambios entre los dos frames en el área de la máscara
        diferenciaArribaIzq = maskIzqArribaActual - maskIzqArribaSiguiente;
        
        % Reduce los cambios a un sólo número
        sumaIzqArriba = sumaIzqArriba + sum(sum(sum(diferenciaArribaIzq)));
        
        
        % MASCARA DERECHA (SALIDA DE VEHICULOS)
        
        % Verifica que hayan vehículos en la via para calcular su salida
        if(entradasCarrilSuperior > 0 && vehiculoPasandoDerArriba == 0)
            % Llena las mascaras de la derecha con la información de cada frame según los índices
            maskDerArribaActual(indDerArriba) = frameActual(indDerArriba);
            maskDerArribaSiguiente(indDerArriba) = frameSiguiente(indDerArriba);
            
            % Toma los cambios entre los dos frames en el área de la máscara
            diferenciaArribaDer = maskDerArribaActual - maskDerArribaSiguiente;
            
            % Reduce los cambios a un sólo número
            sumaDerArriba = sumaDerArriba + sum(sum(sum(diferenciaArribaDer)));
        end
        
        % El frame actual lo iguala al siguiente para realizar al iteración
        frameActual = frameSiguiente;
    end
    
    % Calcula los promedios de cambio de los frames para las dos máscaras
    promedioArribaIzq = sumaIzqArriba / framesParaPromediar;
    promedioArribaDer = sumaDerArriba / framesParaPromediar;
    
    
    
    % MASCARA IZQUIERDA (INGRESO DE VEHICULOS)
    
    % Valida que el promedio supera el umbral y que antes no había un vehículo
    % cruzando por la máscara 
    if(promedioArribaIzq > handles.umbral && vehiculoPasandoIzqArriba == 0)
        entradasCarrilSuperior = entradasCarrilSuperior + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoIzqArriba = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        handles.qArriba.add(frameId); % Registra el frame en el que entra el vehículo a la zona
        set(handles.textVehicles, 'String', handles.qArriba.size()); % Envía a la GUI le número de vehículos en la calle
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera (el vehículo terminó de salir de la zona)
    elseif(promedioArribaIzq <= handles.umbral && vehiculoPasandoIzqArriba == 1)
        vehiculoPasandoIzqArriba = 0;
    end
    
    
    
    % MASCARA DERECHA (SALIDA DE VEHICULOS)
    
    % Valida que el promedio supera el umbral y que antes no había un vehículo
    % cruzando por la máscara 
    if(promedioArribaDer > handles.umbral && vehiculoPasandoDerArriba == 0) % Disminuye en uno el contador de vehiculos que entran en el area de analisis
        entradasCarrilSuperior = entradasCarrilSuperior - 1; % resta uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoDerArriba = 1; % Cambia la bandera para no seguir restando vehiculos sin necesidad
        
        
        % --------------------------------------------------------------- %
        % ------------------ CALCULO DE LA VELOCIDAD -------------------- %
        % --------------------------------------------------------------- %
        frameEntrada = handles.qArriba.poll(); % Desencola un vehículo de la zona
        set(handles.textVehicles, 'String', handles.qArriba.size()); % Actualiza en la GUI el número de vehículos en la zona
        frames = frameId - frameEntrada; % Calcula la diferencia de frames entre la salida y la entrada
        tiempoSeg = frames/24; % Video grabado a 24 frames por segundo => calcula tiempo en segundos
        tiempoHoras = tiempoSeg/3600; % Pasa el tiempo a horas
        disp(tiempoHoras); % Muestra en consola el tiempo en horas
        velocidad = 0.012 ./tiempoHoras; % Calcula la velocidad con una distancia de 12 metros entre las máscaras
        
        disp(velocidad); % Muestra en consola la velocidad
        set(handles.textSpeed, 'String', velocidad); % Muestra en la GUI la velocidad del vehículo
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera (El vehículo terminó de salir de la zona)
    elseif(promedioArribaDer <= handles.umbral && vehiculoPasandoDerArriba == 1)
        vehiculoPasandoDerArriba = 0;
    end
    
    imshow(frameActual, 'Parent',handles.axesIm); % Muestra el frame en la GUI
    pause(0.001); % Estabiliza el tiempo en que se muestra el video en la GUI
    frameId = frameId+1; % Itera el frame a analizar
end




% --- Executes on button press in btnFinish.
function btnFinish_Callback(hObject, eventdata, handles)
% hObject    handle to btnFinish (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.textSpeed, 'String', "15Km/h");
