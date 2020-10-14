unit Services.Utils;

interface

uses
  System.SysUtils, System.StrUtils, FMX.Objects, FMX.Graphics, Soap.EncdDecd;

type
  TServicesUtils = class
    private
      class function StrToMD5(Value : String) : String;
      class function StrToEncode(Value : String) : String;
    public
      class procedure ResourceImage( aResourceName : String; aImage : TImage);
      class function Base64FromBitmap(aBitmap : TBitmap) : String;
      class function BitmapFromBase64(const aBase64 : String) : TBitmap;
      class function MonthName(aData : TDateTime) : String;
      class function StrToCurrency(Value : String) : Currency;
      class function StrToHash(Value : String; const Chave : String) : String;
      class function StrCompareHash(Base, Value : String; const Chave : String) : Boolean;
      class function StrRenewHash(Base : String; const Chave : String) : Boolean; virtual; abstract;
  end;
implementation

uses
    System.Classes
  , System.Types
  , System.DateUtils
  //, System.Hash
  , IdCoderMIME
  , IdHashMessageDigest;

{ TServicesUtils }

class function TServicesUtils.Base64FromBitmap(aBitmap: TBitmap): String;
var
  aRestorno : String;
  aInput  : TBytesStream;
  aOutput : TStringStream;
begin
  aRestorno := EmptyStr;
  try
    if Assigned(aBitmap) then
    begin
      aInput := TBytesStream.Create;
      aBitmap.SaveToStream(aInput);
      aInput.Position := 0;

      aOutput := TStringStream.Create('', TEncoding.ASCII);
      Soap.EncdDecd.EncodeStream(aInput, aOutput);

      aRestorno := aOutput.DataString;
    end;
  finally
    if Assigned(aInput) then
      aInput.DisposeOf;

    if Assigned(aOutput) then
      aOutput.DisposeOf;

    Result := aRestorno;
  end;
end;

class function TServicesUtils.BitmapFromBase64(const aBase64: String): TBitmap;
var
  aRestorno : TBitmap;
  aInput  : TStringStream;
  aOutput : TBytesStream;
begin
  aRestorno := nil;
  aInput    := TStringStream.Create(aBase64, TEncoding.ASCII);
  aOutput   := TBytesStream.Create;
  try
    if not aBase64.Trim.IsEmpty then
    begin
      Soap.EncdDecd.DecodeStream(aInput, aOutput);
      aOutput.Position := 0;

      aRestorno := TBitmap.Create;
      aRestorno.LoadFromStream(aOutput);
    end;
  finally
    if Assigned(aOutput) then
      aOutput.DisposeOf;

    if Assigned(aInput) then
      aInput.DisposeOf;

    Result := aRestorno;
  end;
end;

class function TServicesUtils.StrCompareHash(Base, Value : String; const Chave : String): Boolean;
var
  aChave   ,
  aHash    : String;
  aRetorno : Boolean;
begin
  try
    aHash := Self.StrToMD5( ReverseString(Value + Chave) ).ToLower;
    aRetorno := (Pos(aHash, Base) > 0);
  finally
    Result := aRetorno;
  end;
end;

class function TServicesUtils.MonthName(aData: TDateTime): String;
var
  aRetorno : String;
begin
  aRetorno := EmptyStr;

  case MonthOf(aData) of
     1 : aRetorno := 'Janeiro';
     2 : aRetorno := 'Fevereiro';
     3 : aRetorno := 'Março';
     4 : aRetorno := 'Abril';
     5 : aRetorno := 'Maio';
     6 : aRetorno := 'Junho';
     7 : aRetorno := 'Julho';
     8 : aRetorno := 'Agosto';
     9 : aRetorno := 'Setembro';
    10 : aRetorno := 'Outubro';
    11 : aRetorno := 'Novembro';
    12 : aRetorno := 'Dezembro';
  end;

  Result := aRetorno;
end;

class procedure TServicesUtils.ResourceImage(aResourceName: String; aImage: TImage);
var
  Resource : TResourceStream;
begin
  Resource := TResourceStream.Create(HInstance, aResourceName, RT_RCDATA);
  try
    aImage.Bitmap.LoadFromStream(Resource);
  finally
    Resource.DisposeOf;
  end;
end;

class function TServicesUtils.StrToCurrency(Value: String): Currency;
begin
  Result := StrToCurrDef(Value.Trim.Replace('.', '').Replace(',', ''), 0) / 100.0;
end;

class function TServicesUtils.StrToHash(Value: String; const Chave : String): String;
var
  aChave   ,
  aHash    ,
  aHora    ,
  aRetorno : String;
  aTamanho ,
  aPosicao : Integer;
begin
  try
    aHora  := TServicesUtils.StrToEncode( ReverseString(FormatDateTime('hh:mm:ss', Time)) ).Replace('=', '');
    aChave := TServicesUtils.StrToEncode( ReverseString(Chave.Trim.ToLower) );
    aHash  := Self.StrToMD5( ReverseString(Value + Chave) ).ToLower;

    aTamanho := aChave.Length;
    aPosicao := -1;

    while (aPosicao < 0) do
      aPosicao := Random( aTamanho );

    aRetorno := aHora + Copy(aChave, 1, aPosicao) + aHash + Copy(aChave, aPosicao + 1, aTamanho);
  finally
    Result := aRetorno;
  end;
end;

class function TServicesUtils.StrToMD5(Value: String): String;
var
  aMD5 : TIdHashMessageDigest5;
begin
  aMD5 := TIdHashMessageDigest5.Create;
  try
    Result := aMD5.HashStringAsHex(Value);
  finally
    aMD5.DisposeOf;
  end;
end;

class function TServicesUtils.StrToEncode(Value: String): String;
var
  aEncode : TIdEncoderMIME;
begin
  aEncode := TIdEncoderMIME.Create;
  try
    Result := aEncode.Encode(Value);
  finally
    aEncode.DisposeOf;
  end;
end;

end.
