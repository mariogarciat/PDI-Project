close all, clear all, clc

video = VideoReader('video vehiculos.mp4'); % Abre el archivo de video

% rowSize = video.Height; 
% space = rowSize*0.05;
numFrames = get(video,'NumberOfFrames'); % Obtiene el numero de frames del video
shot = read(video,1); % Toma un frame de referencia
shot = imrotate(shot, -90); % Rota el frame


% Define los umbrales de tolerancia a partir de los cuales se considera que
% el cambio es por un vehiculo
umbralSuperior = 60000;
umbralInferior = 250000;


[fil,col,cap] = size(shot); %Toma las medidas del frame

maskDown = shot * 0; % Crea en negro la mascara inferior
maskUp = shot * 0; % Crea en negro la mascara superior

% maskDown(953:973, 885:1090, :) = 150;
% maskUp(410:430, 910:1000, :) = 150;

maskDown(1010:1050, 200:550, :) = 150; % Define el area a analizar de la parte inferior del frame
maskUp(130:150, 310:410, :) = 150; % Define el area a analizar de la parte superior del frame

indDown = find(maskDown ~= 0); % Obtiene los indices del area a analizar
indUp = find(maskUp ~= 0); % Obtiene los indices del area a analizar

maskDownActual = maskDown; % Crea una mascara para analizar el frame actual
maskUpActual = maskUp; % Crea una mascara para analizar el frame actual
maskDownSiguiente = maskDown; % Crea una mascara para analizar el frame siguiente
maskUpSiguiente = maskUp; % Crea una mascara para analizar el frame siguiente

% myfotog = read(video, 401);
% myfotog = imrotate(myfotog, -90);
% figure(8); imshow(myfotog); impixelinfo;
% figure(9); imshow(maskUp); impixelinfo;


frameId = 4964; % Frame de inicio del video

entradas = 0; % Contador de autos que entran al area de inspeccion
vehiculoPasandoUp = 0; % Bandera para saber si un auto esta pasando por la mascara superior
vehiculoPasandoDown = 0; % Bandera para saber si un auto esta pasando por la mascara inferior

% Ciclo para recorrer todos los frames del video y analizarlos
while (frameId < numFrames) 
    frameActual = read(video, frameId); % Lee un frame
    frameActual = imrotate(frameActual, -90); % Gira el frame
    frameSiguiente = read(video, frameId+2); % Lee un segundo frame dejando uno de por medio para notar el cambio
    frameSiguiente = imrotate(frameSiguiente, -90); % Gira el frame
    
    % Llena las mascaras superiores con los datos de los dos frames frames
    maskUpActual(indUp) = frameActual(indUp);
    maskUpSiguiente(indUp) = frameSiguiente(indUp);
    
    % Realiza la resta entre ambas mascaras para denotar el cambio
    diferenciaUp = maskUpActual - maskUpSiguiente;
    % Suma todos los valores de la imagen que cambiaron y los reduce a un solo numero
    diferenciaUp = sum(sum(sum(diferenciaUp)));
    
    entradas
    diferenciaUp
    
    % Verifica si el cambio supera el umbral y la bandera para saber si ya
    % habia iniciado un cambio debido a un vehiculo
    if(diferenciaUp > umbralSuperior && vehiculoPasandoUp == 0)
        entradas = entradas + 1; % Suma uno al contador de vehiculos que entran en el area de analisis
        vehiculoPasandoUp = 1; % Cambia la bandera para no seguir sumando vehiculos sin necesidad
        
    % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
    % se cambia la bandera
    elseif(diferenciaUp <= umbralSuperior && vehiculoPasandoUp == 1)
        vehiculoPasandoUp = 0;
    end
    
    % Se inicializa la variable del cambio de la mascara inferior
    diferenciaDown = 0;
    
    % Verifica si hay vehiculos en el area para analizarlos
    if(entradas > 0)
        % Llena las mascaras inferiores con los datos de los dos frames frames
        maskDownActual(indDown) = frameActual(indDown);
        maskDownSiguiente(indDown) = frameSiguiente(indDown);
        
        % Realiza la resta entre ambas mascaras para denotar el cambio
        diferenciaDown = maskDownActual - maskDownSiguiente;
        % Suma todos los valores de la imagen que cambiaron y los reduce a un solo numero
        diferenciaDown = sum(sum(sum(diferenciaDown)));
        
        % Verifica si el cambio supera el umbral y la bandera para saber si ya
        % habia iniciado un cambio debido a un vehiculo
        if(diferenciaDown > umbralInferior && vehiculoPasandoDown == 0)
            % Disminuye el contador debido a que salio un vehiculo del area
            entradas = entradas - 1;
            % Cambia el valor de la bandera
            vehiculoPasandoDown = 1;
            
        % Si no se supera el umbral y si ya habia un vehiculo sobre la mascara
        % se cambia la bandera
        elseif(diferenciaDown <= umbralInferior && vehiculoPasandoDown == 1)
            vehiculoPasandoDown = 0;
        end
    
    % Si no hay vehiculos en el area se desactiva la bandera
    elseif(entradas == 0)
        vehiculoPasandoDown = 0;
    end
    
    
    if(diferenciaUp > umbralSuperior || diferenciaDown > umbralInferior)
        figure(7); imshow(frameActual); impixelinfo;
    end
    
%     x = sum(sum(sum(diferenciaDown)));
%     if(x > 150000)
%         
%         frameId
%         63193+79751+73899+73148+55083+58974+85976+135823+133757+89376
%     end
%     mysum = mysum + x;
%     x = sum(sum(sum(diferenciaDown)));
%     mysum = mysum + x;
%     if(mod(frameId,30) == 0)
%         frameId/30
%         round(mysum/30)
%         x = 0;
%         mysum = 0;
%     end
    
    % Para la superior un cambio mayor a 35000 se considera un vehiculo
%     sum(sum(sum(diferenciaDown)))
    
%     figure(1); imshow(diferenciaDown);
%     figure(2); imshow(diferenciaDown);
%     figure(3); imshow(frameActual-frameSiguiente);
%     figure(4); imshow([diferenciaDown diferenciaUp]); impixelinfo;
    vehiculoPasandoDown
    vehiculoPasandoUp
    
    % Itera el numero del frame
    frameId = frameId + 1
end

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

