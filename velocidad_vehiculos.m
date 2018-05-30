close all, clear all, clc
import java.util.LinkedList
qArriba = LinkedList();
qAbajo = LinkedList();
video = VideoReader('video2.mp4'); % Abre el archivo de video

numFrames = get(video,'NumberOfFrames'); % Obtiene el numero de frames del video
shot = read(video,1); % Toma un frame de referencia

% figure(1); imshow (shot); impixelinfo;


% Define los umbrales de tolerancia a partir de los cuales se considera que
% el cambio es por un vehiculo
umbral = 25000;
umbralderecha = 250000;


[fil,col,cap] = size(shot); %Toma las medidas del frame



% CREACION DE LAS MASCARAS

maskDerArriba = shot * 0; % Crea en negro la mascara derecha del carril superior
maskIzqArriba = shot * 0; % Crea en negro la mascara izquierda del carril superior

maskDerAbajo = shot * 0; % Crea en negro la mascara derecha del carril inferior
maskIzqAbajo = shot * 0; % Crea en negro la mascara izquierda del carril inferior

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

% myfotog = read(video, 401);
% myfotog = imrotate(myfotog, -90);
% figure(8); imshow(myfotog); impixelinfo;
% figure(9); imshow(maskUp); impixelinfo;

maskIzqArriba(indIzqArriba) = shot(indIzqArriba);
maskDerArriba(indDerArriba) = shot(indDerArriba);
maskIzqAbajo(indIzqArriba) = shot(indIzqArriba);
maskDerAbajo(indDerAbajo) = shot(indDerAbajo);



% frameId = 140; % Frame de inicio del video
frameId = 1; % Frame de inicio del video

entradasCarrilSuperior = 0; % Contador de autos que entran en el carril superior
entradasCarrilInferior = 0; % Contador de autos que entran en el carril inferior

vehiculoPasandoDerArriba = 0; % Bandera para saber si un auto esta pasando por la mascara derecha del carril superior
vehiculoPasandoIzqArriba = 0; % Bandera para saber si un auto esta pasando por la mascara izquierda del carril superior
vehiculoPasandoDerAbajo = 0; % Bandera para saber si un auto esta pasando por la mascara derecha del carril inferior
vehiculoPasandoIzqAbajo = 0; % Bandera para saber si un auto esta pasando por la mascara izquierda del carril inferior

velocidad = 0;
framesParaPromediar = 5;
% Ciclo para recorrer todos los frames del video y analizarlos
while(frameId < numFrames-framesParaPromediar)
    sumaIzqArriba = 0;
    sumaIzqAbajo = 0;
    sumaDerArriba = 0;
    sumaDerAbajo = 0;
    
    promedioArribaIzq = 0;
    promedioAbajoIzq = 0;
    promedioArribaDer = 0;
    promedioAbajoDer = 0;
    
    frameActual = read(video, frameId + i);
    for i = 0:framesParaPromediar
        frameSiguiente = read(video, frameId + i+1);
        
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
            maskDerArribaActual(indDerArriba) = frameActual(indDerArriba);
            maskDerArribaSiguiente(indDerArriba) = frameSiguiente(indDerArriba);
            
            diferenciaArribaDer = maskDerArribaActual - maskDerArribaSiguiente;
            
            sumaDerArriba = sumaDerArriba + sum(sum(sum(diferenciaArribaDer)));
        end
        
        frameActual = frameSiguiente;
    end
    
    promedioArribaIzq = sumaIzqArriba / framesParaPromediar;
    promedioAbajoIzq = sumaIzqAbajo / framesParaPromediar;
    
    promedioArribaDer = sumaDerArriba / framesParaPromediar;
    promedioAbajoDer = sumaDerAbajo / framesParaPromediar;
    
    if(promedioArribaIzq > umbral && vehiculoPasandoIzqArriba == 0)
        entradasCarrilSuperior = entradasCarrilSuperior + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoIzqArriba = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        qArriba.add(frameId);
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioArribaIzq <= umbral && vehiculoPasandoIzqArriba == 1)
        vehiculoPasandoIzqArriba = 0;
    end
    
    % Igual para el carril inferior
    if(promedioAbajoIzq > umbral && vehiculoPasandoIzqAbajo == 0)
        entradasCarrilInferior = entradasCarrilInferior + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoIzqAbajo = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        qAbajo.add(frameId);
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioAbajoIzq <= umbral && vehiculoPasandoIzqAbajo == 1)
        vehiculoPasandoIzqAbajo = 0;
    end
    
    %A la derecha
    if(promedioArribaDer > umbral && vehiculoPasandoDerArriba == 0)
        entradasCarrilSuperior = entradasCarrilSuperior - 1; % resta uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoDerArriba = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioArribaDer <= umbral && vehiculoPasandoDerArriba == 1)
        vehiculoPasandoDerArriba = 0;
    end
    
    if(promedioAbajoDer > umbral && vehiculoPasandoDerAbajo == 0)
        entradasCarrilInferior = entradasCarrilInferior - 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoDerAbajo = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        frameEntrada = q.poll();
        frames = frameId - frameEntrada;
        tiempoSeg = frames/24;
        tiempoHoras = tiempoSeg/3600
        velocidad = 0.012 /tiempo;
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(promedioAbajoDer <= umbral && vehiculoPasandoDerAbajo == 1)
        vehiculoPasandoDerAbajo = 0;
    end
    
    entradasCarrilSuperior
    entradasCarrilInferior
    frameId
    
    figure(8); imshow(frameActual); impixelinfo;
    
    frameId = frameId + 1;
end

% while (frameId < numFrames) 
%     frameActual = read(video, frameId); % Lee un frame
%     frameSiguiente = read(video, frameId+4); % Lee un segundo frame para comparar
%         
%     % Llena las mascaras de la izquierda de ambos carriles con los datos de
%     % los dos frames
%     maskIzqArribaActual(indIzqArriba) = frameActual(indIzqArriba);
%     maskIzqAbajoActual(indIzqAbajo) = frameActual(indIzqAbajo);
%     maskIzqArribaSiguiente(indIzqArriba) = frameSiguiente(indIzqArriba);
%     maskIzqAbajoSiguiente(indIzqAbajo) = frameSiguiente(indIzqAbajo);
%     
%     figure(2); imshow ([maskIzqArribaActual;maskIzqArribaSiguiente]); impixelinfo;
%     
%     % calcula la diferencia entre las mascaras de la izquierda de los dos frames para ambos carriles
%     diferenciaArribaIzq = maskIzqArribaActual - maskIzqArribaSiguiente;
%     diferenciaAbajoIzq = maskIzqAbajoActual - maskIzqAbajoSiguiente;
%     % Suma todos los valores de la imagen que cambiaron y los reduce a un
%     % solo numero para ambos carriles
%     diferenciaArribaIzq = sum(sum(sum(diferenciaArribaIzq)));
%     diferenciaAbajoIzq = sum(sum(sum(diferenciaAbajoIzq)));
%     
%     
% %     entradasCarrilSuperior
% %     vehiculoPasandoIzqArriba
% %     diferenciaArribaIzq
% %     frameId
%     
% %     Verifica si el cambio supera el umbral y la bandera para saber si ya
% %     habia iniciado un cambio debido a un vehiculo
%     if(diferenciaArribaIzq > umbral && vehiculoPasandoIzqArriba == 0)
%         entradasCarrilSuperior = entradasCarrilSuperior + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
%         vehiculoPasandoIzqArriba = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
%         
%     % Si no se .supera el umbral y si ya habia un vehiculo sobre la mascara
%     % se cambia la bandera
%     elseif(diferenciaArribaIzq <= umbral && vehiculoPasandoIzqArriba == 1)
%         vehiculoPasandoIzqArriba = 0;
%     end
%     
% %     diferenciaArribaIzq
% %     vehiculoPasandoIzqArriba
% %     entradasCarrilSuperior
%     
%     % Se inicializa la variable del cambio de la mascara derecha
%     diferenciaDown = 0;
%     
%     % Verifica si hay vehiculos en el area para analizarlos
%     if(entradas > 0)
%         % Llena las mascaras derechaes con los datos de los dos frames frames
%         maskDownActual(indDown) = frameActual(indDown);
%         maskDownSiguiente(indDown) = frameSiguiente(indDown);
%         
%         % Realiza la resta entre ambas mascaras para denotar el cambio
%         diferenciaDown = maskDownActual - maskDownSiguiente;
%         % Suma todos los valores de la imagen que cambiaron y los reduce a un solo numero
%         diferenciaDown = sum(sum(sum(diferenciaDown)));
%         
%         % Verifica si el cambio supera el umbral y la bandera para saber si ya
%         % habia iniciado un cambio debido a un vehiculo
%         if(diferenciaDown > umbralderecha && vehiculoPasandoDown == 0)
%             % Disminuye el contador debido a que salio un vehiculo del area
%             entradas = entradas - 1;
%             % Cambia el valor de la bandera
%             vehiculoPasandoDown = 1;
%             
%         % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
%         % se cambia la bandera
%         elseif(diferenciaDown <= umbralderecha && vehiculoPasandoDown == 1)
%             vehiculoPasandoDown = 0;
%         end
%     
%     % Si no hay vehiculos en el area se desactiva la bandera
%     elseif(entradas == 0)
%         vehiculoPasandoDown = 0;
%     end
%     
%     
%     if(diferenciaUp > umbralizquierda || diferenciaDown > umbralderecha)
%         figure(7); imshow(frameActual); impixelinfo;
%     end
%     
% %     x = sum(sum(sum(diferenciaDown)));
% %     if(x > 150000)
% %         
% %         frameId
% %         63193+79751+73899+73148+55083+58974+85976+135823+133757+89376
% %     end
% %     mysum = mysum + x;
% %     x = sum(sum(sum(diferenciaDown)));
% %     mysum = mysum + x;
% %     if(mod(frameId,30) == 0)
% %         frameId/30
% %         round(mysum/30)
% %         x = 0;
% %         mysum = 0;
% %     end
%     
%     % Para la izquierda un cambio mayor a 35000 se considera un vehiculo
% %     sum(sum(sum(diferenciaDown)))
%     
% %     figure(1); imshow(diferenciaDown);
% %     figure(2); imshow(diferenciaDown);
% %     figure(3); imshow(frameActual-frameSiguiente);
% %     figure(4); imshow([diferenciaDown diferenciaUp]); impixelinfo;
% % % %     vehiculoPasandoDown
% % % %     vehiculoPasandoUp
% % % %     
% % % %     % Itera el numero del frame
%     frameId = frameId + 1;
% end

% mysum/150


% while hasFrame(video)
%     img1 = readFrame(video);
%     img2 = readFrame(video);
%     upMark = space;
%     downMark = rowSize - space;
%    
% end
% 906 430 izq up
% 1000 430 der up
% x = 1;
% while (x < 3)
%     imgs{x} = read(video, x);
%     x = x +1;
% end
% b = imgs{1, 1} - imgs{1, 2};
% figure(1); imshow(maskDown);
% figure(3); imshow(maskUp);
% figure(2); imshow(imgs{1, 2}); impixelinfo;

% 885 973 izq down
% 1090 973 der down

