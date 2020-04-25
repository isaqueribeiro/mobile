unit app.Funcoes;

interface

uses
  app.OpenViewUrl,

  {$IF DEFINED (ANDROID)}
  Androidapi.Jni,
  Androidapi.Jni.Net,
  Androidapi.Jni.JavaTypes,
  Androidapi.JNI.Telephony,
  Androidapi.JNI.Provider,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNIBridge,
  Androidapi.Helpers,

  FMX.Helpers.Android,

  {$ENDIF}
  {$IF DEFINED (IOS)}
  Macapi.Helpers,
  IOSapi.Foundation,
  IOSApi.Helpers,
  FMX.Helpers.IOS,
  {$ENDIF}

  IdHashMessageDigest,
  System.MaskUtils,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,

  Soap.EncdDecd,
  FMX.Graphics,
  FMX.Forms;

  procedure CriarForm(InstanceClass: TComponentClass; var Referencia;
    const Exibir : Boolean = TRUE);
  procedure CallWhasApp(const aProtocolo, aMensagem : String);
  procedure SendEmail(const aEmail, aAssunto, aMensagem : String);

  function MD5(const aTexto : String) : String;
  function IsEmailValido(const aEmail : String) : Boolean;
  function GetNumeroSIM : String;
  function FormatarTexto(aFormato, aStr : String) : String;
  function SomenteNumero(aStr : String) : String;
  function StrToIntegerLocal(aStr : String) : Integer;
  function StrToMoneyLocal(aStr : String) : Currency;
  function StrToDateLocal(aFormato, aStr : String) : TDateTime;
  function StrIsGUID(const aStr: String): Boolean;
  function StrIsCPF(const Num: string; const PermitirVerdadeiroFalso : Boolean = FALSE): Boolean;
  function StrIsCNPJ(const Num: string; const PermitirVerdadeiroFalso : Boolean = FALSE): Boolean;
  function StrClearValueJson(const aValue : String) : String;

  function Base64FromBitmap(aBitmap : TBitmap) : String;
  function BitmapFromBase64(const aBase64 : String) : TBitmap;

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

procedure CallWhasApp(const aProtocolo, aMensagem : String);
var
  aMsg : String;
  {$IF DEFINED (ANDROID)}
  aIntentsWhatsApp : JIntent;
  {$ENDIF}
  {$IF DEFINED (IOS)}
  aNSU : NSUrl;
  aRetorno : Boolean;
  {$ENDIF}
begin
  aMsg := Trim(aProtocolo) + Trim(aMensagem);

  {$IF DEFINED (ANDROID)}
  aIntentsWhatsApp := TJIntent.JavaClass.init(TJIntent.JavaClass.ACTION_SEND);
  aIntentsWhatsApp.setType(StringToJString('text/plain'));
  aIntentsWhatsApp.putExtra(TJIntent.JavaClass.EXTRA_TEXT, StringToJString(aMsg));
  aIntentsWhatsApp.setPackage(StringToJString('com.whatsapp'));
  SharedActivity.startActivity(aIntentsWhatsApp);
  {$ENDIF}
  {$IF DEFINED (IOS)}
  aNSU := StrToNSUrl(aMsg);
  aRetorno := SharedApplication.openUrl(aNSU);
  {$ENDIF}
end;

procedure SendEmail(const aEmail, aAssunto, aMensagem : String);
var
  aUrl : String;
begin
  //mailto:heber@99coders.com.br?subject=Assunto&body=Texto
  aUrl := 'mailto:' + AnsiLowerCase(Trim(aEmail)) + '?subject=' + Trim(aAssunto) + '&body=' + Trim(aMensagem);
  OpenURL(aUrl);
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
    idmd5.DisposeOf;
    Result := aStr;
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

function SomenteNumero(aStr : String) : String;
var
  aRetorno : String;
  I : Byte;
begin
  aRetorno := '';
  try
    for I := 1 to Length(aStr) do
      if (aStr[I] in ['0'..'9']) Then
        aRetorno := aRetorno + aStr[I];
  finally
    Result := aRetorno;
  end;
end;

function StrToIntegerLocal(aStr : String) : Integer;
begin
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace(',', '', [rfReplaceAll]);

  Result := StrToIntDef(aStr, 0);
end;

function StrToMoneyLocal(aStr : String) : Currency;
begin
  aStr := aStr.Replace('.', '', [rfReplaceAll]);
  aStr := aStr.Replace(',', '', [rfReplaceAll]);

  Result := StrToCurrDef(aStr, 0) / 100;
end;

function StrToDateLocal(aFormato, aStr : String) : TDateTime;
var
  aAno ,
  aMes ,
  aDia : Word;
begin
  if (AnsiUpperCase(Trim(aFormato)) = 'DD/MM/YYYY') then
  begin
    aDia := StrToIntDef( Copy(Trim(aStr), 1, 2), 1);
    aMes := StrToIntDef( Copy(Trim(aStr), 4, 2), 1);
    aAno := StrToIntDef( Copy(Trim(aStr), 7, 4), 1);
  end
  else
  if (AnsiUpperCase(Trim(aFormato)) = 'MM/DD/YYYY') then
  begin
    aMes := StrToIntDef( Copy(Trim(aStr), 1, 2), 1);
    aDia := StrToIntDef( Copy(Trim(aStr), 4, 2), 1);
    aAno := StrToIntDef( Copy(Trim(aStr), 7, 4), 1);
  end
  else
  begin
    aMes := 1;
    aDia := 1;
    aAno := 1;
  end;

  Result := EncodeDate(aAno, aMes, aDia)
end;

function StrIsGUID(const aStr: String): Boolean;
var
  aGuid : TGUID;
begin
  try
    if (Trim(aStr) <> EmptyStr) then
    begin
      aGuid  := StringToGUID(Trim(aStr));
      Result := True;
    end
    else
      Result := False;
  except
    Result := False;
  end;
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

function StrClearValueJson(const aValue : String) : String;
begin
  Result := StringReplace(StringReplace(StringReplace(aValue, '"', '', [rfReplaceAll]), '\/', '/', [rfReplaceAll]), '\r\n', #13, [rfReplaceAll]);
end;

function Base64FromBitmap(aBitmap : TBitmap) : String;
var
  aRestorno : String;
  Input  : TBytesStream;
  Output : TStringStream;
begin
  aRestorno := EmptyStr;
  try
    Input := TBytesStream.Create;
    aBitmap.SaveToStream(Input);
    Input.Position := 0;

    Output := TStringStream.Create('', TEncoding.ASCII);
    Soap.EncdDecd.EncodeStream(Input, Output);

    aRestorno := Output.DataString;
  finally
    Input.DisposeOf;
    Output.DisposeOf;

    Result := aRestorno;
  end;
end;

function BitmapFromBase64(const aBase64 : String) : TBitmap;
var
  aRestorno : TBitmap;
  aInput  : TStringStream;
  aOutput : TBytesStream;
begin
  aRestorno := nil;
  aInput    := TStringStream.Create(aBase64, TEncoding.ASCII);
  aOutput   := TBytesStream.Create;
  try
    Soap.EncdDecd.DecodeStream(aInput, aOutput);
    aOutput.Position := 0;

    aRestorno := TBitmap.Create;
    aRestorno.LoadFromStream(aOutput);
  finally
    aOutput.DisposeOf;
    aInput.DisposeOf;

    Result := aRestorno;
  end;
end;

end.
