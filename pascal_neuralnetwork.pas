unit pascal_neuralnetwork;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ValEdit,
  LCLType, appconfig, pascalnn,fphttpclient;

type

  { TForm1 }

  TForm1 = class(TForm)
    appconfig_display: TMemo;
    appconfig_editor: TValueListEditor;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.FormCreate(Sender: TObject);
begin
  appconfig_editor.Visible:=false;
  application.Title:='PascalNeuralnetwork';
  // data from RAD
  //UseComponentData := true;
  Manifest(self);
  print(application.Title);
  // print(_r('testvar'));

end;


procedure TForm1.Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
      if vk_return=key then begin print(edit1.text);edit1.clear;end;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
    dataout:pFloat;// :array[0..1023] of Tfloat;
    datain :pFloat;// :array[0..1023]of Tfloat;
    sl :Tstringlist;
begin

  // in eerste instantie wil ik dit zo simpel mogelijk houden.
  // het eenvoudigst is het om gewoon een variabele te defineren

    Tnn.log:=displayout.lines;

  // het model kan met 1 zin worden ingeladen

  //nn:='simplenn';
 nn:='model:///simplenn';





//  nn:='file:///home/ray/models/simple.pnn';

  // of het model kan een naam gegeven worden met
 // nn:='simplenn';

  // of het model kan van een website worden downloaded
//  nn:='http://127.0.0.1/models/simple.pnn';

  // data van het model komt in

  // GetUserDir+'/.cache/pascalnn/<modelnaam>'






  datain:=allocmem(16*sizeof(Tfloat));
  dataout:=allocmem(8*sizeof(Tfloat));
//   exit;
  //setlength(datain,1024);
  //setlength(dataout,256);

  //nn.save;

 // nn:='Simple Neural Pascal Network.';
  with nn do
 begin
   //layer:='input.300';
   //layer:='hidden.300';
   //layer:='output.300';
   //init;
   ////
   //input:=datain;
   //propagate(dataout);

   print(layer_count);
   RandomWeights;
   save;

 end;
  print('done.');


end;

procedure TForm1.Button2Click(Sender: TObject);
var
  SS: TStringStream;
begin
 SS:=Tstringstream.create(TFPHttpClient.SimpleGet('http://127.0.0.1/weights'));
 ss.SaveToFile('test');

end;






end.

