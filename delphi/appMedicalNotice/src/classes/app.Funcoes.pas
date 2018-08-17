unit app.Funcoes;

interface

uses
  IdHashMessageDigest,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

  function MD5(const aTexto : String) : String;

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

end.
