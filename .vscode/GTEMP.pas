program earthquake;
uses crt,sysutils;

type quantity = array[1..30,1..30] of integer;
type risk = array[1..900] of integer; //Place all the values of cost/deaths here to calculate max/min risk

type zone = Record
    name:string;
    r,c:integer; //Rows,columns
    i:integer; //Intensity
    victims,cost:quantity; //Each zone has a matrix that represents costs and victims after the disaster
end;

var place: array[1..9] of zone;
var vectorRisk:risk;

//Other useful variables

var path:string; //Path of the input file
var input:text; //Input file

function select:integer;
var op:integer;
begin
    op:=1;
    writeln('   1. ', place[1].name);
    writeln('   2. ', place[2].name);
    writeln('   3. ', place[3].name);
    writeln('   4. ', place[4].name);
    writeln('   5. ', place[5].name);
    writeln('   6. ', place[6].name);
    writeln('   7. ', place[7].name);
    writeln('   8. ', place[8].name);
    writeln('   9. ', place[9].name);
    writeln('   0. Regresar');
    readln(op);
select:=op;
end;

function searchForMistakes(var input:text):boolean;
var line,aux:string;
var error:boolean;
var lcount,i,j,countSpaces,rowCount,rows,columns:integer;
begin
    aux:='';
    error:=false;
    rows:=0;
    columns:=0;
    lcount:=0;
    rowCount:=0;
    reset(input);
        while not eof (input) do begin
            readln(input,line);
            //writeln(line);
                if (lcount = 0) then begin
                    if not (line[1]='*') then begin //Each region should start with *
                        error:=true;
                        if (strtoint(line[1])<>0) then begin
                            error:=true;
                            writeln('ERROR: Numero de filas es menor a las colocadas en matriz, fila extra: ',line);
                            writeln;
                            break;
                        end;
                        writeln('ERROR: Cada nombre de region debe empezar con *, Ejemplo: * 1 Cordillera central.');
                        writeln;
                    end;
                    if not (line[2]=' ') then begin //After the * there must be a space
                        error:=true;
                        writeln('ERROR: Seguido de cada asterico debe haber un espacio, Ejemplo: * 1 Cordillera central.');
                        writeln;
                    end;
                    if not (line[3] in ['0'..'9']) then begin //Third character must be a number between 1 and 9
                        error:=true;
                        writeln('ERROR: Numero de region debe estar comprendido desde el 1 hasta el 9, Ejemplo: * 1 Cordillera central');
                        writeln;
                    end
                    else begin
                        if (line[3]='0') then begin
                            error:=true;
                            writeln('ERROR: Numero de region debe estar comprendido desde el 1 hasta el 9, Ejemplo: * 1 Cordillera central');
                            writeln;
                        end;
                    end;
                    if not (line[4]=' ') then begin
                        error:=true;
                        writeln('ERROR: Debe haber un espacio luego del numero de region, Ejemplo: * 1 Cordillera central.');
                        writeln;
                    end;
                    if not (line[length(line)]='.') then begin
                        error:=true;
                        writeln('ERROR: Debe haber un punto luego del nombre de la region, Ejemplo: * 1 Cordillera central.');
                        writeln;
                    end;
                end;

                if (lcount = 1) then begin
                countSpaces:=0;

                if (pos(' ',line)=0) then begin
                    error:=true;
                    writeln('ERROR: Debe haber un espacio entre el numero de filas y columnas. Ejemplo: 4 6');
                    writeln;
                    break;
                end;

                for i:=1 to length(line) do begin
                    if (line[i]=' ') then countSpaces:=countSpaces+1;
                end;

                if (countSpaces>1) then begin
                    error:=true;
                    writeln('ERROR: Debe haber un solo espacio entre el numero de filas y columnas. Ejemplo: 4 6');
                    writeln;
                end;

                aux:=copy(line,1,pos(' ',line)-1);

                try
                    strtoint(aux);
                except
                    On E : EConvertError do
                    begin
                        error:=true;
                        writeln('ERROR: Numero de filas debe ser un numero entero');
                        writeln;
                    end;
                end;

                if (strtoint(aux)<=0) then begin
                    error:=true;
                    writeln('ERROR: Numero de filas debe ser un numero entero positivo mayor a cero.');
                    writeln;
                    break;
                end;

                rows:=strtoint(aux);
                //writeln('Rows ',aux);

                i:=pos(' ',line);
                while (line[i]=' ') do begin
                    i:=i+1;
                end;

                aux:=copy(line,i,length(line));

                columns:=strtoint(aux);
                //writeln('Columns ',aux);

                for j:=1 to length(aux) do begin
                    if not (aux[j] in ['0'..'9']) then begin
                    error:=true;
                    writeln('ERROR: Numero de columnas debe ser un numero entero positivo mayor a cero.');
                    writeln;
                    break;
                    end;
                end;

                if (strtoint(aux)=0) then begin
                    error:=true;
                    writeln('ERROR: Numero de columnas debe ser un numero entero positivo mayor a cero');
                    writeln;
                end;

                if (error) then break; //Invalid character after the number or not number
                end;

                if (lcount >= 2) then begin
                aux:='';
                rowCount:=rowCount+1;
                countSpaces:=0; //Making sure number of columns fits with the number of spaces since file can't have double spaces anyway
                    for i:=1 to length(line) do begin
                        if not (line[i]=' ') then begin
                            if (line[i] in ['0'..'9']) then begin
                                aux:=aux+line[i];
                            end
                            else begin
                                error:=true;
                                if ((line[1]='*') or (line[2]=' ') or (line[4]=' ') or (line[length(line)]='.')) then begin
                                    error:=true;
                                    writeln('ERROR: Numero de filas es menor a las filas escritas');
                                    writeln('Error se encuentra antes de esta linea ',line);
                                    writeln;
                                    break;
                                end;

                                writeln('ERROR: Valores en matriz deben ser numeros enteros, se detecto un caracter invalido: ', line[i]);
                                writeln('Linea: ',line);
                                writeln;
                            end;
                        end;
                        if (line[i]=' ') then begin
                            aux:='';
                            countSpaces:=countSpaces+1;
                        end;
                    end;

                    if (countSpaces<>columns-1) then begin
                        error:=true;
                        writeln('ERROR: Numero de columnas especificado no coincide con numero de elementos colocados, es posible que haya insertado un elemento extra o falte');
                        writeln('Recuerde que cada elemento debe estar separado por un unico espacio.');
                        writeln('Linea: ',line);
                        writeln;
                    end;

                    //Assuming number of rows in file is correct
                    
                    if (rowCount=rows*2) then begin 
                        lcount:=-1;
                    end;
                end;
        lcount:=lcount+1;
    end;
    close(input);
searchForMistakes:=error;
end;

procedure fillMatrix(var X:quantity; i,columns:integer; line:string);
var k,j:integer;
var aux:string;
begin
    j:=1;
    k:=1;
    aux:='';
        for j:=1 to columns do begin
            while((line[k]<>' ') and (k<=length(line))) do begin
                aux:=aux+line[k];
                k:=k+1;
            end;
            X[i,j]:=strtoint(aux);
            aux:='';
            k:=k+1;
    end;
end;

procedure fillData(var input:text);
var line,aux:string;
var lcount,i,j,k,rowCount,regions,mCount:integer;
begin
    aux:='';
    lcount:=0;
    regions:=0;
    mCount:=0;
    reset(input);
        while not eof (input) do begin
            readln(input,line);
            if (lcount=0) then begin
                regions:=regions+1;
                place[regions].name:=copy(line,5,length(line));
            end;

            if (lcount=1) then begin
                aux:=copy(line,1,pos(' ',line)-1);
                place[regions].r:=strtoint(aux);
                //writeln('Numero de filas de region es: ',place[regions].r);

                aux:='';

                i:=pos(' ',line);

                aux:=copy(line,i+1,length(line));
                place[regions].c:=strtoint(aux);

                //writeln('Numero de columnas de region es: ',place[regions].c);
                rowCount:=1;
            end;
            if (lcount>=2) then begin
                    if ((place[regions].r>=rowCount) and (mCount=0)) then begin
                        fillMatrix(place[regions].cost, rowCount, place[regions].c, line);
                        rowCount:=rowCount+1;
                    end;

                    if ((rowCount>place[regions].r) and (mCount=0)) then begin
                        rowCount:=1; 
                        mCount:=1;
                        continue;
                    end; 

                    if ((place[regions].r>=rowCount) and (mCount=1)) then begin
                        fillMatrix(place[regions].victims, rowCount, place[regions].c, line);
                        rowCount:=rowCount+1;
                    end;

                    if ((rowCount>place[regions].r) and (mCount=1)) then begin 
                        lcount:=-1;
                        mCount:=0;
                        rowCount:=1;
                    end;

            end;

            lcount:=lcount+1;
        end;
    close(input);
end;

procedure fopen(var path:string);
var error:boolean;
begin
    error:=false;
    writeln('Indique ruta de archivo, formato aceptado: C:\Users\Usuario\Desktop\ejemplo.txt');
    readln(path);
    if not FileExists(path) then begin
        writeln('Archivo no existe'); 
        writeln('Presione cualquier tecla para regresar al menu principal');
        readkey; 
        exit; 
        end;
    assign(input,path);
    error:=searchForMistakes(input); //Search for mistakes
        if (error = true) then begin
            writeln('Se encontro un error en el archivo, para continuar con la operacion por favor corrija los errores encontrados y vuelvalo a cargar');
        end
        else begin
            fillData(input);
            writeln('Presione cualquier tecla para continuar');
            readkey;
        end;
end;

procedure showDataMatrix(var X: quantity; r,c:integer);
var i,j:integer;
begin
    for i:=1 to r do begin
        for j:=1 to c do begin
            write(X[i,j],' | ');
        end;
        writeln;
    end;
end;

procedure showZones;
var op:integer;
begin
    op:=-1;
        if (op<>0) then begin
            writeln('Seleccione una zona');
            writeln;
            op:=select;
        end;

        if (op = 0) then exit
        else begin
            writeln('Datos costo para la region ',place[op].name);
            writeln;
            showDataMatrix(place[op].cost, place[op].r, place[op].c);
            writeln;
            writeln('Datos dolor para la region ',place[op].name);
            writeln;
            showDataMatrix(place[op].victims, place[op].r, place[op].c);
            writeln;
            writeln;
            writeln('Presione cualquier tecla para continuar');
            readkey;
        end;
end;

procedure generateMatrix(var X:quantity; r,c:integer);
var i,j,num:integer;
begin
    for i:=1 to r do
        for j:=1 to c do begin
            num:=random(300)+1;
            X[i,j]:=num;
        end;
end;


procedure writeOverwrite;
var op:integer;
begin
op:=-1;
    if (op<>0) then begin
        writeln('Seleccione en que posicion le gustaria agregar una zona');
        writeln('Si selecciona una zona que ya posee un nombre asignado esta se sobrescribira');
        writeln;
        op:=select;

        if (op = 0) then exit
        else begin
            writeln('Escriba un nombre para la zona ',op);
            readln(place[op].name);
            repeat
                writeln('Escriba el numero de filas para la zona ', place[op].name);
                readln(place[op].r);
                if ((place[op].r<0) or not(place[op].r in [1..30])) then writeln('Numero de filas debe ser un numero entero positivo mayor que cero y menor o igual a 30');
            until (place[op].r>0);

            repeat
            writeln('Escriba el numero de columnas para la zona ', place[op].name);
            readln(place[op].c);
                if ((place[op].c<0) or not(place[op].c in [1..30])) then writeln('Numero de columnas debe ser un numero entero positivo mayor que cero y menor o igual a 30');
            until (place[op].c>0);
            randomize;
            generateMatrix(place[op].cost,place[op].r,place[op].c);
            generateMatrix(place[op].victims,place[op].r,place[op].c);
            writeln('Datos generados satisfactoriamente, para consultar los datos');
            writeln('regrese al menu principal presionando cualquier tecla y seleccionando la opcion 7');
            readkey;
        end;        
    end;
end;


function selectMatrix:integer;
var op:integer;
begin
op:=-1;
    if (op<>0) then begin
        writeln('Seleccione una matriz a modificar');
        writeln;
        writeln('   1. Costo');
        writeln('   2. Dolor');
        writeln('   0. Regresar');
        readln(op);
    end;
selectMatrix:=op;
end;


procedure modifyData;
var op,modf,nr,nc,newD:integer;
var X:quantity;
begin
op:=-1;
nr:=0;
nc:=0;
newD:=0;
modf:=-1;
    writeln('Seleccione una region a modificar');
    writeln;
    op:=select;

    if (op=0) then 
    begin
    clrscr;
    exit
    end

    else begin
        if ((place[op].r<=0) or (place[op].c<=0)) then begin
            writeln('Esta region esta vacia, se tomara como nueva');
            writeln('Escriba un nombre para la zona ',op);
            readln(place[op].name);
            repeat
                writeln('Escriba el numero de filas para la zona ', place[op].name);
                readln(place[op].r);
                if ((place[op].r<0) or not(place[op].r in [1..30])) then writeln('Numero de filas debe ser un numero entero positivo mayor que cero y menor o igual a 30');
            until (place[op].r>0);

            repeat
            writeln('Escriba el numero de columnas para la zona ', place[op].name);
            readln(place[op].c);
                if ((place[op].c<0) or not(place[op].c in [1..30])) then writeln('Numero de columnas debe ser un numero entero positivo mayor que cero y menor o igual a 30');
            until (place[op].c>0);
            randomize;
            generateMatrix(place[op].cost,place[op].r,place[op].c);
            generateMatrix(place[op].victims,place[op].r,place[op].c);
            writeln('Datos generados satisfactoriamente, para consultar los datos');
            writeln('regrese al menu principal presionando cualquier tecla y seleccionando la opcion 7');
            readkey;
            clrscr;
            exit;
        end;

        writeln('Datos costo para la region ',place[op].name);
        writeln;
        showDataMatrix(place[op].cost, place[op].r, place[op].c);
        writeln;
        writeln('Datos dolor para la region ',place[op].name);
        writeln;
        showDataMatrix(place[op].victims, place[op].r, place[op].c);
        writeln;
        writeln;

        repeat
            writeln('Escriba la posicion de fila donde le gustaria modificar el dato');
            readln(nr);
                if ((nr>place[op].r) or (nr<=0)) then begin
                    writeln('Fila ingresada esta fuera del rango (maximo: ',place[op].r,')');
                end;
        until ((nr<=place[op].r) and (nr>0));

        repeat
            writeln('Escriba la posicion de columna donde le gustaria modificar el dato');
            readln(nc);
                if ((nc>place[op].c) or (nc<=0)) then begin
                    writeln('Columna ingresada esta fuera del rango (maximo: ',place[op].c,')');
                end;
        until ((nc<=place[op].c) and (nc>0));

        //Select matrix to modify
        modf:=selectMatrix;

            if (modf=0) then begin
                clrscr;
                modifyData;
            end
            else begin
                repeat
                    writeln('Escriba nuevo dato');
                    readln(newD);
                        if (newD<=0) then writeln('Nuevo dato debe ser un numero mayor o igual que cero');
                until (newD>0);

                if (modf=1) then begin
                    X:=place[op].cost;
                    X[nr,nc]:=newD;
                    place[op].cost:=X;
                end;

                if (modf=2) then begin
                    X:=place[op].victims;
                    X[nr,nc]:=newD;
                    place[op].victims:=X;
                end;

                writeln('Presione cualquier tecla para continuar');
                readkey;
            end;
        end;

end;

function calculateEarthquake(var X:quantity; limR,limC,r,c,dir,degree:integer):integer;
var init,limit,value:integer;
begin
    value:=0;
    init:=r-degree;
    limit:=r+degree;
    if (dir=0) then begin //Left
        for init:=init to limit do begin
            if (c-1<=0) then break;
                if (init>limR) then break;
                    value:=value+X[init,c-1];
        end;
    end;

    if (dir=1) then begin //Center
        for init:=init to limit do begin
            if (init>limR) then break;
                value:=value+X[init,c];
        end;
    end;

    if (dir=2) then begin
        for init:=init to limit do begin
            if (c+1>limC) then break;
                if (init>limR) then break;
                    value:=value+X[init,c+1];
        end;
    end;
calculateEarthquake:=value;
end;

procedure eq;
var degree,op,deaths,costs,epR,epC,cost:integer;
begin
    op:=-1;

    writeln('Seleccione una region a calcular');
    writeln;
    op:=select;

    if (op=0) then 
    begin
        clrscr;
        exit;
    end
    else begin
    repeat
        writeln('Ingrese grado del terremoto');
        readln(degree);
        if ((degree<0) or (degree>place[op].r) or (degree>place[op].c)) then begin
            writeln('Grado de terremoto se sale del rango o es un numero invalido');
            writeln('Debe ser un numero entero positivo mayor que cero');
        end;
    until((degree>0) and (degree<=place[op].r) and (degree<=place[op].c));

    repeat
        writeln('Ingrese el epicentro del terremoto (fila)');
        readln(epR);
            if ((epR<0) or (epR>place[op].r)) then begin
                writeln('Epicentro es invalido, debe ser un numero mayor que cero que no se salga del rango de la region especificada');
                writeln('Numero de filas de la region: ',place[op].r,' Numero de columnas de la region: ',place[op].c);
            end;
    until ((epR>0) and (epR<=place[op].r));

    repeat
        writeln('Ingrese el epicentro del terremoto (columna)');
        readln(epC);
            if ((epC<0) or (epC>place[op].c)) then begin
                writeln('Epicentro es invalido, debe ser un numero mayor que cero que no se salga del rango de la region especificada');
                writeln('Numero de filas de la region: ',place[op].r,' Numero de columnas de la region: ',place[op].c);
            end;
    until ((epC>0) and (epC<=place[op].c));

    cost:=calculateEarthquake(place[op].cost,place[op].r,place[op].c,epR,epC,0,degree);
    cost:=cost+calculateEarthquake(place[op].cost,place[op].r,place[op].c,epR,epC,1,degree);
    cost:=cost+calculateEarthquake(place[op].cost,place[op].r,place[op].c,epR,epC,2,degree);
    writeln('Perdidas economicas estimadas en la zona',place[op].name,': ',cost);
    deaths:=calculateEarthquake(place[op].victims,place[op].r,place[op].c,epR,epC,0,degree);
    deaths:=deaths+calculateEarthquake(place[op].victims,place[op].r,place[op].c,epR,epC,1,degree);
    deaths:=deaths+calculateEarthquake(place[op].victims,place[op].r,place[op].c,epR,epC,2,degree);
    writeln('Perdidas humanas estimadas en la zona',place[op].name,': ',deaths);
    writeln;
    writeln('Presione cualquier tecla para continuar');
    readkey;
    end;
end;

procedure clear(var X:risk);
var i:integer;
begin
    for i:=1 to 900 do
        X[i]:=-1;
end;

//This method will be deprecated, it's only here for testing purposes

procedure show(var X:risk);
var i:integer;
begin
    for i:=1 to 900 do
        write(X[i],' ');
end;

procedure getMaxMin(var Y:risk; typ,limR,limC:integer);
var i,pos,aux,newI,newJ:integer;
begin
aux:=0;
i:=1;
pos:=0;
     while ((i<900) and (Y[i]<>-1)) do begin
        if (typ=1) then begin //Get max risk
            if (Y[i]>aux) then begin
                aux:=Y[i];
                pos:=i;
            end;
        end;
        if (typ=2) then begin //Get max risk
            if ((Y[i]<aux) and (i>1)) then begin
                aux:=Y[i];
                pos:=i;
            end
            else if (i=1) then begin
                aux:=Y[i];
            end;
        end;
        i:=i+1;
    end;
    pos:=pos-1;
    newI:=0;
    newJ:=0;
        if (limC=limR) then begin
            newJ:= (pos mod limR)+1;
            newI:= (pos div limR)+1;
        end;

        if (limC>limR) then begin
            newJ:= pos mod limC;
            newJ:=newJ+1;
            newI:= pos div limC;
            newI:= newI+1;
        end;
        
        if (limR>limC) then begin
            newJ:= pos mod limC;
            newJ:=newJ+1;
            newI:= pos div limC;
            newI:= newI+1;
        end;

    if (typ=1) then begin
        writeln('Epicentro de maximo riesgo: [',newI,',',newJ,']');
        writeln('Muertes: ',aux);
    end
    else begin
        writeln('Epicentro de minimo riesgo: [',newI,',',newJ,']');
        writeln('Muertes: ',aux);
    end;
end;

procedure allDeaths(var X:quantity; var Y:risk; limR,limC,degree:integer);
var i,j,epC,epR,deaths:integer;
begin
j:=1;
    for epR:=1 to limR do
        for epC:=1 to limC do begin
            deaths:=0;
            deaths:=calculateEarthquake(X,limR,limC,epR,epC,0,degree);
            deaths:=deaths+calculateEarthquake(X,limR,limC,epR,epC,1,degree);
            deaths:=deaths+calculateEarthquake(X,limR,limC,epR,epC,2,degree);
            Y[j]:=deaths;
            writeln('Perdidas humanas en el epicentro [',epR,',',epC,']: ',Y[j]);
            j:=j+1;
        end;
end;

procedure maxMinRisk;
var degree,epC,epR,minDeaths,maxDeaths,epMR,epMC,op:integer;
begin
op:=-1;
    writeln('Seleccione una region a calcular');
    writeln;
    op:=select;

    if (op=0) then 
    begin
        clrscr;
        exit;
    end
    else begin
        repeat
            writeln('Ingrese grado del terremoto');
            readln(degree);
                if ((degree<0) or (degree>place[op].r) or (degree>place[op].c)) then begin
                    writeln('Grado de terremoto se sale del rango o es un numero invalido');
                    writeln('Debe ser un numero entero positivo mayor que cero');
                end;
        until((degree>0) and (degree<=place[op].r) and (degree<=place[op].c));

    clear(vectorRisk);
    allDeaths(place[op].victims,vectorRisk,place[op].r,place[op].c,degree);
    getMaxMin(vectorRisk,1,place[op].r,place[op].c);
    getMaxMin(vectorRisk,2,place[op].r,place[op].c);
    writeln;
    writeln('Presione cualquier tecla para continuar');
    readkey;
    end;
end;

function calculateAvg(var X:quantity; limR,limC,degree:integer):integer;
var i,j,epC,epR,totalcost,cost,q:integer;
begin
j:=1;
cost:=0;
totalcost:=0;
q:=0;
    for epR:=1 to limR do
        for epC:=1 to limC do begin
            cost:=0;
            cost:=calculateEarthquake(X,limR,limC,epR,epC,0,degree);
            cost:=cost+calculateEarthquake(X,limR,limC,epR,epC,1,degree);
            cost:=cost+calculateEarthquake(X,limR,limC,epR,epC,2,degree);
            writeln('Costo en epicentro [', epR,',',epC,']: ',cost);
            totalcost:=totalcost+cost;
        end;
    q:=limR*limC;
    totalcost:=totalcost div q;
calculateAvg:=totalcost;
end;

procedure averageCost;
var degree,epC,epR,op,av:integer;
begin
op:=-1;
av:=0;
    writeln('Seleccione una region a calcular');
    writeln;
    op:=select;

    if (op=0) then 
    begin
        clrscr;
        exit;
    end
    else begin
        repeat
            writeln('Ingrese grado del terremoto');
            readln(degree);
                if ((degree<0) or (degree>place[op].r) or (degree>place[op].c)) then begin
                    writeln('Grado de terremoto se sale del rango o es un numero invalido');
                    writeln('Debe ser un numero entero positivo mayor que cero');
                end;
        until((degree>0) and (degree<=place[op].r) and (degree<=place[op].c));

    av:=calculateAvg(place[op].cost,place[op].r,place[op].c,degree);
    writeln('Costo promedio en la region ',place[op].name,': ',av);
    writeln;
    writeln('Presione cualquier tecla para continuar');
    readkey;
    end;
end;

procedure showMenu;
var op:char;
begin
op:='9';
clrscr;
    while (op<>'0') do begin
        writeln('Bienvenido al menu principal del programa terremoto, por favor seleccione una opcion');
        writeln;
        writeln('   1. Cargar datos por medio de un archivo');
        writeln('   2. Cargar datos manualmente');
        writeln('   3. Modificar datos');
        writeln('   4. Calcular estimacion de las consecuencias del terremoto');
        writeln('   5. Calcular estimacion de la zona de maximo y minimo riesgo');
        writeln('   6. Calcular estimacion del costo medio');
        writeln('   7. Consultar una region geografica');
        writeln('   0. Salir del programa');
        readln(op);

        case op of
        '1':
        begin
            fopen(path);
            clrscr;
            showMenu;
        end;
        '2':
        begin
            writeOverwrite;
            clrscr;
            showMenu;
        end;
        '3':
        begin
            modifyData;
            clrscr;
            showMenu;
        end;
        '4':
        begin
            eq;
            clrscr;
            showMenu;
        end;
        '5':
        begin
            maxMinRisk;
            clrscr;
            showMenu;
        end;
        '6':
        begin
            averageCost;
            clrscr;
            showMenu;
        end;
        '7':
        begin
            showZones;
            clrscr;
            showMenu;
        end;
        '0':
        begin
            halt(0);
        end;
        else begin
            writeln('Opcion fuera de rango');
            readln;
            clrscr;
        end;
        end;
    end;
end;

begin
    //Open the file
    showMenu;
    writeln('Fin del programa');
    readkey;
end.


























