unit app.Funcoes;

interface

uses
  {$IF DEFINED (ANDROID)}
  Androidapi.JNI.Telephony,
  Androidapi.JNI.Provider,
  Androidapi.JNIBridge,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers,
  FMX.Helpers.Android,
  {$ENDIF}
  {$IF DEFINED (IOS)}
  IOSApi.Helpers,
  FMX.Helpers.IOS,
  {$ENDIF}

  IdHashMessageDigest,
  System.MaskUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Forms;

  procedure CriarForm(InstanceClass: TComponentClass; var Referencia;
    const Exibir : Boolean = TRUE);

  function MD5(const aTexto : String) : String;
  function IsEmailValido(const aEmail : String) : Boolean;
  function GetNumeroSIM : String;
  function FormatarTexto(aFormato, aStr : String) : String;

implementation

procedure CriarForm(InstanceClass: TComponentClass; var Referencia;
  const Exibir : Boolean = TRUE);
begin
  if (TForm(Referencia) = nil) or (not Assigned(TForm(Referencia))) then
  begin
    Application.CreateForm(InstanceClass, Referencia);
    Application.RealCreateForms;

    if Exibir then
      TForm(Referencia).Show;
  end;
end;

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

function GetNumeroSIM : String;
var
  {$IF DEFINED (ANDROID)}
  aManagerFone : JTelephonyManager;
  {$ENDIF}
  aPhoneNumber : String;
begin
  aPhoneNumber := EmptyStr;
  {$IF DEFINED (ANDROID)}
  aManagerFone := TJTelephonyManager.Wrap((SharedActivityContext.getSystemService(TJContext.JavaClass.TELEPHONY_SERVICE) as ILocalObject).GetObjectID);
  aPhoneNumber := JStringToString(aManagerFone.getLine1Number);
  {$ENDIF}
  Result := Trim(aPhoneNumber);
end;

function FormatarTexto(aFormato, aStr : String) : String;
begin
  Result := FormatMaskText(aFormato, aStr);
end;

end.
