unit appconfig;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, ValEdit, forms, LResources, StdCtrls, FileUtil,
  wordvectortypes;

// dit werkt op de volgende manier :
// toeg appconfig toe aan het project
// in oncreate van de mainform
// application.Title:='<titelapplicatie>';
// en doe Appconfig.Manifest(self);
// daarna als een component
// Tvalueeditor is en de naam appconfig_editor heeft wordt deze automatisch weggeschreven
// Appconfig_display is en een Tmemo dan heeft het de volgende routines print , print('#CLEAR');
// ook zal een file getest worden als de key in de valueeditor een 'file' string bevat
// er worden dan 3 vraagtekens aan de string aangehangen als de file niet bestaat



type

{ Tappobj }

 Tappobj=class(Tobject)
  public
  vl :Tvaluelisteditor;
  procedure OnFindClass(Reader: TReader; const AClassName: string;
    var ComponentClass: TComponentClass);
  procedure EditingDone(Sender: TObject);
  end;
var
  AppObj :Tappobj;
  app_dir: string;
  app_data: string;
  app_name: string;
  displayout:Tmemo=nil;
  UseComponentData:boolean=false;

procedure manifest(aform:Tform);
procedure _manifest;
procedure AppReadConfig(vl: Tvaluelisteditor);
procedure AppwriteConfig;

procedure print(s:string);
procedure print(sl:Tstringlist);
procedure print(f:real);
procedure print(i:integer);
procedure printvec(v:TWvector;condense:boolean=false);


function _r(s:string):string;
function _ri(s:string):integer;


implementation

function _ri(s:string):integer;
begin
 result:=strtoint(_r(s));
end;

// lees vl en geeft een string uit
// waar het om gaat is dat ik makkelijk parameters kan gebruiken uit de config
// komt de string in de key voor dan is output de parameter
function _r(s:string):string;
var
  i: Integer;
begin
 for i:=0 to Appobj.vl.RowCount-1 do
   if pos(s,Appobj.vl.Keys[i])>0 then
    result:=Appobj.vl.Values[Appobj.vl.Keys[i]];

end;


procedure Tappobj.OnFindClass(Reader: TReader; const AClassName: string;
  var ComponentClass: TComponentClass);
begin
  if CompareText(AClassName, 'TValuelistEditor') = 0 then
    ComponentClass := TValuelistEditor;
end;


procedure _manifest;
begin
  app_dir := GetUserDir + '.config/lanhouse/lazarus-apps';
  forcedirectories(app_dir);
  app_data := app_dir + '/' + app_name + '.data';// wordvectordatabase.data';
end;

procedure manifest(aform:Tform);
var
  i: Integer;
  F: TForm;
begin
  app_name:=application.Title;
  _manifest;
  AppObj:=Tappobj.create;

  F:=aform;

  for i:=0 to F.ComponentCount-1 do
  begin
   if F.Components[i] is Tvaluelisteditor then
     if Tvaluelisteditor(F.components[i]).Name='appconfig_editor' then
   begin
     Appobj.vl:=Tvaluelisteditor(F.Components[i]);
     Appobj.vl.OnEditingDone:=@Appobj.EditingDone;
     if not fileexists(app_data)  then  AppwriteConfig ;
     if UseComponentData  then  AppwriteConfig;
     AppReadConfig(Appobj.vl);
   end;
   if F.Components[i] is Tmemo then
     if Tmemo(F.components[i]).Name='appconfig_display' then
       Displayout:=Tmemo(F.components[i]);

end;

end;

procedure Tappobj.EditingDone(sender:Tobject);
var
  i: Integer;
  _: String;
begin
  // checkhier of de bestanden kunnen worden gelezen
  // maar alleen als (fe) = fileexist in de key voorkomt
  // het idee is dat na invoer al duidelijk is of de filenaam bestaat

   for i:=0 to appobj.vl.ColCount do
   begin
     _:=appobj.vl.Keys[i];
     if pos('(fe)',appobj.vl.Keys[i])>0 then
        if not fileexists(appobj.vl.Values[appobj.vl.Keys[i]]) then
          if   pos('???',appobj.vl.Values[appobj.vl.Keys[i]])=0 then
            appobj.vl.Values[appobj.vl.Keys[i]]:=appobj.vl.Values[appobj.vl.Keys[i]]+'???';
   end;
   AppWriteConfig;
end;


procedure AppwriteConfig;
   var
  AStream: TFileStream;
begin

  if appobj.vl=nil then exit;

  AStream:=TFileStream.Create(app_data,fmOpenwrite or fmCreate);
  try
    WriteComponentAsBinaryToStream(AStream, Appobj.vl);
  finally
    AStream.Free;
  end;


end;

procedure AppReadConfig(vl: Tvaluelisteditor);
var
  Astream: Tfilestream;
begin
  Appobj.vl:=vl; //
    Appobj.vl.OnEditingDone:=@Appobj.EditingDone;
//  Appobj.vl.OnKeyPress:=@Appobj.kp;
  if fileexists(app_data) then
  begin
    AStream := TFileStream.Create(app_data, fmOpenread);
    try
      LResources.ReadComponentFromBinaryStream(Astream, TComponent(vl), @Appobj.onfindClass);
    finally
      AStream.Free;
    end;

  end;
end;


procedure print(s:string);
begin
  if displayout=nil then exit;
  if s='#CLEAR' then
     DisplayOut.clear
     else
 DisplayOut.lines.add(s);
end;

procedure print(sl:Tstringlist);
begin
  if displayout=nil then exit;
 DisplayOut.lines.addstrings(sl);

end;
procedure print(f:real);
begin
  if displayout=nil then exit;
 DisplayOut.lines.add(floattostr(f));

end;
procedure print(i:integer);
begin
  if displayout=nil then exit;
 DisplayOut.lines.add(inttostr(i));
end;

procedure printvec(v:TWvector;condense:boolean=false);
var
  i: Integer;
  elipsis,Acc:string;
begin
 acc:='[';
 elipsis:=' ... ';

 for i:=0 to length(v)-1 do
       case condense of
        True:if (i<2) or (i>length(v)-3) then acc:=acc+format('%.6f ',[v[i]]) else begin acc:=acc+elipsis;elipsis:='';end;
        False:acc:=acc+format('%.6f ',[v[i]]);
       end;

 acc:=acc+']';
 print(acc);
end;



end.
