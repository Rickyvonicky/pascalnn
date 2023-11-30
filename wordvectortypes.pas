unit wordvectortypes;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  Tfloat = single;
  pFloat = ^Tfloat;
  TWvector = array of Tfloat;
  Tfloatarray = array[0..1 shl 28] of Tfloat;
  pFloatarray = ^Tfloatarray;
  TWvectorlist=array of TWvector;



var
  _Formatstring:string='%.4f';
  _bailout:integer=-1;
  _delta:integer=50;

implementation

end.

