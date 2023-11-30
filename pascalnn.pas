unit pascalnn;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, forms,fphttpclient;

//Definitie van TNN

const cBufsize=1 shl 16;


type
  Tfloat = single;
  pfloat = ^Tfloat;

type
  Tarrayoffloat = array of Tfloat;
  Parrayoffloat = ^Tarrayoffloat;

type
  Tweigth = record
    Name: string;
    Data: Tarrayoffloat
  end;

type
  Tlayer = record
    Name: string;
    size: integer;
  end;

type
  Tenumdtype=(dtSingle,dtDouble,dtInt32,dtInt16,dtInt8);

  { TNN }

  TNN = class(TObject)
    procedure FSetlayer(avalue: string);
  private

    function Fgetlayercount: integer;
    procedure Fsaveweights;
    function modeldir: string;
    procedure plog(s: string);
  public
    log: TStrings; static;
    dtype :Tenumdtype; static;
    Fname: string;
    Flogits: Tarrayoffloat;
    Fweight: array of Tweigth;
    FLayer: array of Tlayer;
    input: pointer;
    procedure Floadweights;


    procedure GetOutput(p: pointer);
    procedure init;
    procedure RandomWeights;
    function propagate(p: pointer = nil): pointer;
    procedure save;
    property layer: string write FSetlayer;
    property layer_count: integer read Fgetlayercount;
    property Name: string read Fname write Fname;

  end;

operator := (s: string): TNN;

var
  nn: Tnn;
  __PASCALNNCACHEDIR: string;

implementation

operator := (s: string): TNN;
var
  sl: TStringList;
  i: integer;
  dir: String;
  isurl,ismodelname,isfilename :boolean;

begin
  Result := TNN.Create;
  result.Name:=changefileext(extractfilename(s),'');
  IsFileName:=pos('file:///', s) > 0;
  IsModelName:=pos('model:///', s) > 0;
  if (IsFilename) or (Ismodelname) then
  begin
    sl := TStringList.Create;

    //if Ismodelname then
    dir:=__PASCALNNCACHEDIR + result.name + '/';
//    if Isfilename  then dir:=extractfilepath(s)+result.name+'/';

   sl.loadfromfile(dir+'config');///lowercase(copy(s, 8)));

   // Result.Name := sl[0];
    for i := 0 to sl.Count - 1 do Result.layer := sl[i];


    Result.init;
    result.Floadweights;
    sl.Free;
  end;

end;

{ TNN }

procedure TNN.FSetlayer(avalue: string);
var
  sl: TStringList;
  last: SizeInt;
  i: Integer;
  Q: String;
begin
  sl := TStringList.Create;
  sl.delimiter := '.';
  sl.delimitedtext := avalue;
  //'neural.input.768'
  setlength(Flayer, length(Flayer) + 1);
  last := length(Flayer) - 1;
  Flayer[last].size := StrToInt(sl[sl.Count - 1]);
  sl.Delete(sl.count-1);
  // join routine
  Q:='';
  for i:=0 to sl.Count-1 do
    Flayer[last].Name := Flayer[last].Name +Q+sl[i];Q:='.';

  setlength(Flogits, Flayer[last].size);

  plog(format('Added Layer :%s', [avalue]));
end;

function TNN.Fgetlayercount: integer;
begin
  Result := length(Flayer);
end;

procedure TNN.GetOutput(p: pointer);
var
  i: integer;
begin
  for i := 0 to Flayer[length(Flayer) - 1].size - 1 do
  begin
    pfloat(p)^ := Flogits[i];
    Inc(p);
  end;

end;

procedure TNN.plog(s: string);
begin
  if Tnn.log <> nil then

    Tnn.log.add(format('[pascalnn] : %s', [s]));

end;

function TNN.propagate(p: pointer = nil): pointer;
var
  j, k, x0, n: integer;
begin
  plog('propagate');


  for j := 0 to length(Fweight) - 1 do
  begin
    n := 0;
    for k := 0 to Flayer[j + 1].size do
    begin
      Flogits[n] := Flogits[n] * Fweight[j].Data[n];
      Inc(n);
    end;
  end;
  if p <> nil then
  begin
    GetOutput(p);
    Result := p;
    exit;
  end;

end;

procedure TNN.init;
var
  j, k, size: integer;
begin
  plog('initializing');

  setlength(Fweight, length(Flayer) - 1);
  plog('   [init] Weights layer count :' + IntToStr(length(Flayer)));


  for j := 0 to Length(Fweight) - 1 do
  begin
    size := Flayer[j].size * Flayer[j + 1].size;
    setlength(Fweight[j].Data, size);
    plog('   [init] Added weight size :' + IntToStr(size));
  end;
end;

procedure TNN.RandomWeights;
var
  j, k,n: Integer;
begin
  n:=0;
  for j:=0  to length(Fweight) - 1 do
  begin
    plog('   [init] Randomizing weight layer :' + IntToStr(j));
    for k:=0 to length(Fweight[j].Data) do
     begin
     Fweight[j].Data[k] := system.random;
     if n mod 100000 = 0 then begin application.ProcessMessages; end;
     inc(n);
     end;
  end;

end;


// v
procedure TNN.Fsaveweights;
var
  f :Tfilestream;
  i, n, j, k: Integer;
  buf :array[0..cBufsize-1] of Tfloat;
begin

  f:=Tfilestream.create(Modeldir+'weights',fmopenwrite or fmcreate);
  plog('Saving weights...');
  application.ProcessMessages;
  for i:=0 to length(Fweight)-1 do
  begin
  plog(format('       (%d saved)',[i]));
  // copieer per block de weights in de buffer
  n:=0;
  for j:=1 to  length(Fweight[i].data) div cBufsize do
  begin
    for k:=0 to cBufsize-1 do begin buf[k]:=Fweight[i].data[n];inc(n);end;
    f.Write(buf,cbufsize*4);
    if n mod 100000 = 0 then begin application.ProcessMessages; end;

  end;

  if length(Fweight[i].data) mod cBufsize <>0 then
  begin
   for k:=0 to (length(Fweight[i].data) mod cBufsize)-1 do begin buf[k]:=Fweight[i].data[n];inc(n);end;
   f.Write(buf,4 * (length(Fweight[i].data) mod cBufsize));
  end;

  end;
    f.free;
end;

procedure TNN.Floadweights;

var
  f :Tfilestream;
  i, n, j, k: Integer;
  buf :array[0..cBufsize-1] of Tfloat;

begin

  f:=Tfilestream.create(Modeldir+'weights',fmopenwrite or fmcreate);
  plog('loading weights...');
  application.ProcessMessages;

  for i:=0 to length(Fweight)-1 do
  begin
  plog(format('       (%d loaded)',[i]));
  application.ProcessMessages;

  // copieer per block de weights in de buffer
  n:=0;
  for j:=1 to  length(Fweight[i].data) div cBufsize do
  begin
    f.read(buf,cbufsize*4);
    for k:=0 to cBufsize-1 do begin Fweight[i].data[n]:=buf[k];inc(n);
    if n mod 100000 = 0 then begin application.ProcessMessages; end;
    end;

  end;

  if length(Fweight[i].data) mod cBufsize <>0 then
  begin
   f.read(buf,4 * (length(Fweight[i].data) mod cBufsize));
   for k:=0 to (length(Fweight[i].data) mod cBufsize)-1 do begin Fweight[i].data[n]:=buf[k];inc(n);
    end;

  end;

  end;
    f.free;


end;

function TNN.modeldir :string;
var
  dir: String;

begin
  dir:=__PASCALNNCACHEDIR + name + '/';
  forcedirectories(dir);
  result:=dir;
end;

procedure TNN.save;
var
  sl: TStringList;
  i: integer;
begin
  sl := TStringList.Create;

  // save de configuratie
  for i := 0 to length(Flayer) - 1 do
    sl.add(format('%s.%d', [Flayer[i].Name, Flayer[i].size]));
  sl.SaveToFile(Modeldir + 'config');
  sl.Free;

  Fsaveweights
  // save de configuratie

  //  __PASCALNNCACHEDIR
end;

begin
  __PASCALNNCACHEDIR := GetUserDir + '.cache/pascalnn/';
  forcedirectories(__PASCALNNCACHEDIR);
  TNN.dtype:=dtSingle;


end.



Var
  URL, S : String;
begin
  URL := ParamStr(1);
  with TFPHttpClient.Create(Nil) do
    try
      S := Get(URL);
    finally
      Free;
    end;
  Writeln('Content: ', S);
end.
