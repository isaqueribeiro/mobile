unit app.Funcoes;

interface

uses
  IdHashMessageDigest,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

  function MD5(const aTexto : String) : String;
  function IsEmailValido(const aEmail : String) : Boolean;

implementation

function MD5(const aTexto : String) : String;
var
  aStr  : String;
  idmd5 : TIdHashMessageDigest5;
begin
  aStr  := EmptyStr;
  idmd5 := TIdHashMessageDigest5.Create;
  try
    aStr := AnsiLowerCase(idmd5.HashStringAsHex(aTexto));
  finally
    Result := aStr;
    idmd5.Free;
  end;
end;

function IsEmailValido(const aEmail : String) : Boolean;
var
  aStr : String;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aStr     := Trim(AnsiLowerCase(aEmail));
  try
    if (Pos('@', aStr) > 1) then
    begin
      Delete(aStr, 1, Pos('@', aStr));
      aRetorno := (Length(aStr) > 0) and (Pos('.', aStr) > 2);
    end;
  finally
    Result := aRetorno;
  end;
end;

end.
