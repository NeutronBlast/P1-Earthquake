program earthquake;
uses crt,sysutils;

type quantity = array[1..30,1..30] of integer;

type zone = Record
    name:string;
    r,c:integer; //Rows,columns
    i:integer; //Intensity
    victims,cost:quantity; //Each zone has a matrix that represents costs and victims after the disaster
end;

type place = array[1..9] of zone;

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
var lcount,i,j,countSpaces:integer;
begin
    aux:='';
    error:=false;
    lcount:=0;
    reset(input);
        while not eof (input) do begin
            readln(input,line);
            writeln(line);
                if (lcount = 0) then begin
                    if not (line[1]='*') then begin //Each region should start with *
                        error:=true;
                        writeln('ERROR: Cada nombre de region debe empezar con *, Ejemplo: * 1 Cordillera central.');
                    end;
                    if not (line[2]=' ') then begin //After the * there must be a space
                        error:=true;
                        writeln('ERROR: Seguido de cada asterico debe haber un espacio, Ejemplo: * 1 Cordillera central.');
                    end;
                    if not (line[3] in ['0'..'9']) then begin //Third character must be a number between 1 and 9
                        error:=true;
                        writeln('ERROR: Numero de region debe estar comprendido desde el 1 hasta el 9, Ejemplo: * 1 Cordillera central');
                    end
                    else begin
                        if (line[3]='0') then begin
                            error:=true;
                            writeln('ERROR: Numero de region debe estar comprendido desde el 1 hasta el 9, Ejemplo: * 1 Cordillera central');
                        end;
                    end;
                    if not (line[4]=' ') then begin
                        error:=true;
                        writeln('ERROR: Debe haber un espacio luego del numero de region, Ejemplo: * 1 Cordillera central.');
                    end;
                    if not (line[length(line)]='.') then begin
                        error:=true;
                        writeln('ERROR: Debe haber un punto luego del nombre de la region, Ejemplo: * 1 Cordillera central.');
                    end;
                end;

                if (lcount = 1) then begin
                countSpaces:=0;

                if (pos(' ',line)=0) then begin
                    error:=true;
                    writeln('ERROR: Debe haber un espacio entre el numero de filas y columnas. Ejemplo: 4 6');
                    break;
                end;

                for i:=1 to length(line) do begin
                    if (line[i]=' ') then countSpaces:=countSpaces+1;
                end;

                if (countSpaces>1) then begin
                    error:=true;
                    writeln('ERROR: Debe haber un solo espacio entre el numero de filas y columnas. Ejemplo: 4 6');
                end;

                aux:=copy(line,1,pos(' ',line)-1);

                try
                    strtoint(aux);
                except
                    On E : EConvertError do
                    begin
                        error:=true;
                        writeln('ERROR: Numero de filas debe ser un numero entero');
                    end;
                end;

                if (strtoint(aux)<=0) then begin
                    error:=true;
                    writeln('ERROR: Numero de filas debe ser un numero entero positivo mayor a cero.');
                    break;
                end;

                writeln('Rows ',aux);

                i:=pos(' ',line);
                while (line[i]=' ') do begin
                    i:=i+1;
                end;

                aux:=copy(line,i,length(line));

                writeln('Columns ',aux);

                for j:=1 to length(aux) do begin
                    if not (aux[j] in ['0'..'9']) then begin
                    error:=true;
                    writeln('ERROR: Numero de columnas debe ser un numero entero positivo mayor a cero.');
                    break;
                    end;
                end;

                if (strtoint(aux)=0) then begin
                    error:=true;
                    writeln('ERROR: Numero de columnas debe ser un numero entero positivo mayor a cero');
                end;

                if (error) then break; //Invalid character after the number or not number
        end;
        lcount:=lcount+1;
    end;
    close(input);
searchForMistakes:=error;
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
        end
        else begin
            //writeln('Archivo no existe');
        end;
end;

begin
    //Open the file
    fopen(path);
    writeln('Fin del programa');
    readkey;
end.



















































