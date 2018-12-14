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
  function StrIsCPF(const Num: string; const PermitirVerdadeiroFalso : Boolean = FALSE): Boolean;
  function StrIsCNPJ(const Num: string; const PermitirVerdadeiroFalso : Boolean = FALSE): Boolean;

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

function StrIsCPF(const Num: string; const PermitirVerdadeiroFalso : Boolean = FALSE): Boolean;
var
  I, Numero, Resto: Byte ;
  Dv1, Dv2: Byte ;
  Total, Soma: Integer ;
  Valor: string;
const
  VERDADEIRO_FALSO : Array[0..9] of String = (
      '00000000000',
      '11111111111', '22222222222', '33333333333',
      '44444444444', '55555555555', '66666666666',
      '77777777777', '88888888888', '99999999999'
    );
begin
  if ( StrToIntDef(Copy(Num, 1, 2), -1) = -1 ) then
  begin
    Result := False;
    Exit;
  end;

  // Remover da string caracteras não numéricos
  Valor := Num;
  for I := 1 to Length(Valor) do
    if not (Valor[I] in ['0'..'9']) then Delete(Valor, I, 1);
  try
    StrToInt(Copy(Valor, 1, 5));
  except
    Result := True;
    Exit;
  end;

  if not PermitirVerdadeiroFalso then
    for I := Low(VERDADEIRO_FALSO) to High(VERDADEIRO_FALSO) do
      if (Valor = VERDADEIRO_FALSO[I]) then
      begin
        Result := False;
        Exit;
      end;

  Result := False;

  if Length(Valor) = 11 then
  begin
    Total := 0 ;
    Soma := 0 ;
    for I := 1 to 9 do
    begin
      try
        Numero := StrToInt (Valor[I]);
      except
        Numero := 0;
      end;
      Total := Total + (Numero * (11 - I)) ;
      Soma := Soma + Numero;
    end;
    Resto := Total mod 11;
    if Resto > 1
      then Dv1 := 11 - Resto
      else Dv1 := 0;
    Total := Total + Soma + 2 * Dv1;
    Resto := Total mod 11;
    if Resto > 1
      then Dv2 := 11 - Resto
      else Dv2 := 0;
    if (IntToStr (Dv1) = Valor[10]) and (IntToStr (Dv2) = Valor[11])
      then Result := True;
  end;
end;

function StrIsCNPJ(const Num: string; const PermitirVerdadeiroFalso : Boolean = FALSE): Boolean;
var
  Dig: array [1..14] of Byte;
  I, Resto: Byte;
  Dv1, Dv2: Byte;
  Total1, Total2: Integer;
  Valor: string;
const
  VERDADEIRO_FALSO : Array[0..9] of String = (
      '00000000000000',
      '11111111111111', '22222222222222', '33333333333333',
      '44444444444444', '55555555555555', '66666666666666',
      '77777777777777', '88888888888888', '99999999999999'
    );
begin
  if ( StrToIntDef(Copy(Num, 1, 2), -1) = -1 ) then
  begin
    Result := False;
    Exit;
  end;

  // Remover da string caracteras não numéricos
  Valor := Num;
  for I := 1 to Length(Valor) do
    if not (Valor[I] in ['0'..'9']) then
      Delete(Valor, I, 1);

  if ( StrToIntDef(Copy(Valor, 1, 5), 0) = 0 ) then
  begin
    Result := False;
    Exit;
  end;

  try
    StrToInt(Copy(Valor, 1, 5));
  except
    Result := True;
    Exit;
  end;

  if not PermitirVerdadeiroFalso then
    for I := Low(VERDADEIRO_FALSO) to High(VERDADEIRO_FALSO) do
      if (Valor = VERDADEIRO_FALSO[I]) then
      begin
        Result := False;
        Exit;
      end;

  Result := False;

  if Length(Valor) = 14 then
  begin
    for I := 1 to 14 do
      try
        Dig[I] := StrToInt (Valor[I]);
      except
        Dig[i] := 0;
      end;

    Total1 := Dig[1]  * 5 + Dig[2]  * 4 + Dig[3]  * 3 +
              Dig[4]  * 2 + Dig[5]  * 9 + Dig[6]  * 8 +
              Dig[7]  * 7 + Dig[8]  * 6 + Dig[9]  * 5 +
              Dig[10] * 4 + Dig[11] * 3 + Dig[12] * 2 ;

    Resto := Total1 mod 11;

    if Resto > 1 then
      Dv1 := 11 - Resto
    else
      Dv1 := 0;

    Total2 := Dig[1]  * 6 + Dig[2]  * 5 + Dig[3]  * 4 +
              Dig[4]  * 3 + Dig[5]  * 2 + Dig[6]  * 9 +
              Dig[7]  * 8 + Dig[8]  * 7 + Dig[9]  * 6 +
              Dig[10] * 5 + Dig[11] * 4 + Dig[12] * 3 + Dv1 * 2 ;

    Resto := Total2 mod 11;

    if Resto > 1 then
      Dv2 := 11 - Resto
    else
      Dv2 := 0;

    if (Dv1 = Dig[13]) and (Dv2 = Dig[14]) then
      Result := True;
  end;
end;

end.
