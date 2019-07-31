program earthquake;
uses crt,sysutils;

type quantity = array[1..30,1..30] of integer;

type zone = Record
    name:string;
    r,c:integer; //Rows,columns
    i:integer; //Intensity
    victims,cost:quantity; //Each zone has a matrix that represents costs and victims after the disaster
end;

var place: array[1..9] of zone;

//Other useful variables

var path:string; //Path of the input file
var input:text; //Input file

function verifyExistence(var input:text):boolean; 
var x:word; //IOResult
var r:boolean;
    begin
        {$I-}
        reset(input);
        {$I+}
        x:=IOResult;
            if (x <> 0) then
	      	    r:=false //File does not exist
	        else
	            r:=true; //File exists
        close(input);
        verifyExistence:=r;
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
        for j:=1 to columns do begin
            while((k<=length(line)) and (line[k]<>' ')) do begin
                if not (line[k]=' ') then begin
                    if (line[k] in ['0'..'9']) then begin
                        aux:=aux+line[k];
                    end;
                end;
            k:=k+1;
            end;

            X[i,j]:=strtoint(aux);
            //writeln('Numero ahorita es: ',X[i,j]);
            aux:='';

            while ((k<=length(line)) and (line[k]=' ')) do begin 
                k:=k+1;
                aux:='';
            end;

        end;
end;

procedure fillData(var input:text);
var line,aux:string;
var lcount,i,j,k,rowCount,columns,regions,mCount:integer;
begin
    aux:='';
    columns:=1;
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
var exists, error:boolean;
begin
    error:=false;
    writeln('Indique ruta de archivo, formato aceptado: C:\Users\Usuario\Desktop\ejemplo.txt');
    readln(path);
    assign(input,path);
    exists:=verifyExistence(input);
        if exists then begin
            //writeln('Archivo existe');
            error:=searchForMistakes(input); //Search for mistakes
                if (error = true) then begin
                    writeln('Se encontro un error en el archivo, para continuar con la operacion por favor corrija los errores encontrados y vuelvalo a cargar');
                end
                else begin
                    fillData(input);
                    writeln('Presione cualquier tecla para continuar');
                    readkey;
                end;
        end
        else begin
            //writeln('Archivo no existe');
        end;
end;

procedure showZones;
var op:integer;
begin
    op:=-1;
        while (op<>0) do begin
            writeln('Seleccione una zona');
            writeln;
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
        end;

        if (op = 0) then exit
        else begin

        end;
end;

procedure showMenu;
var op:char;
begin
op:='9';
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
        end;
        '3':
        begin
        end;
        '4':
        begin
        end;
        '5':
        begin
        end;
        '6':
        begin
        end;
        '7':
        begin
            showZones;
            clrscr;
            showMenu;
        end;
        '0':
        begin
            exit;
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




































































































































































