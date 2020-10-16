unit Services.Hash;

interface

uses
  System.SysUtils, System.StrUtils;

type
  TServicesHash = class
    strict private
      class var _instance : TServicesHash;
    private
      class function StrToMD5(Value : String) : String;
      class function StrToEncode(Value : String) : String;
      class function StrToDecode(Value : String) : String;
    public
      class function getInstance() : TServicesHash;
      class function StrToHash(Value : String; const Chave : String) : String;
      class function StrRenewHash(Base : String; const Chave : String) : String;
      class function StrCompareHash(Base, Value : String; const Chave : String) : Boolean;
      class function StrIsHash(Value : String) : Boolean;
  end;
implementation

uses
    System.Classes
  , System.Types
  , System.DateUtils
  , IdCoderMIME
  , IdHashMessageDigest;

{ TServicesHash }

class function TServicesHash.getInstance: TServicesHash;
begin
  if not Assigned(_instance) then
    _instance := TServicesHash.Create;

  Result := _instance;
end;

class function TServicesHash.StrToDecode(Value: String): String;
var
  aDecode : TIdDecoderMIME;
begin
  aDecode := TIdDecoderMIME.Create;
  try
    Result := aDecode.DecodeString(Value);
  finally
    aDecode.DisposeOf;
  end;
end;

class function TServicesHash.StrToEncode(Value: String): String;
var
  aEncode : TIdEncoderMIME;
begin
  aEncode := TIdEncoderMIME.Create;
  try
    Result := aEncode.EncodeString(Value);
  finally
    aEncode.DisposeOf;
  end;
end;

class function TServicesHash.StrToHash(Value: String; const Chave: String): String;
var
  aChave   ,
  aHash    ,
  aHora    ,
  aMarcacao,
  aRetorno : String;
  aTamanho ,
  aPosicao : Integer;
begin
  try
    aHora  := TServicesHash.StrToEncode( ReverseString(FormatDateTime('hh:mm:ss', Time)) ).Replace('=', ''); // Tamanho 11
    aChave := TServicesHash.StrToEncode( ReverseString(Chave.Trim.ToLower) );

    aTamanho := aChave.Length;
    aPosicao := -1;

    while (aPosicao < 1) do
      aPosicao := Random( aTamanho );

    aMarcacao := TServicesHash.StrToEncode( FormatFloat('000', aPosicao) ); // Tamanho 4
    aHash     := Self.StrToMD5( ReverseString(Value + Chave) ).ToLower;     // Tamanho 32

    if ((aPosicao mod 2) = 0) then
      aHash := ReverseString( aHash );

    aRetorno := aHora
      + Copy(aChave, 1, aPosicao)
      + aHash
      + Copy(aChave, aPosicao + 1, aTamanho)
      + ReverseString( aMarcacao );
  finally
    Result := aRetorno;
  end;
end;

class function TServicesHash.StrRenewHash(Base: String; const Chave: String): String;
var
  aBase    ,
  aChave   ,
  aHash    ,
  aHora    ,
  aMarcacao,
  aRetorno : String;
  aTamanho ,
  aPosicao : Integer;
begin
  try
    // Remover hora
    aBase := Copy(Base, 12, Base.Length);

    // Capiturar posição inicial do hash
    aMarcacao := ReverseString( Copy(aBase, aBase.Length - 3, 4) ); // Tamanho 4
    aPosicao  := TServicesHash.StrToDecode(aMarcacao).ToInteger();
    aHash     := Copy(aBase, aPosicao + 1, 32);                     // Tamanho 32

    // Remover hash e marcador da posição da base
    aBase := aBase.Replace(aHash, EmptyStr);
    aBase := Copy(aBase, 1, aBase.Length - 4);

    aHora    := TServicesHash.StrToEncode( ReverseString(FormatDateTime('hh:mm:ss', Time)) ).Replace('=', ''); // Tamanho 11
    aTamanho := aBase.Length;
    aPosicao := -1;

    while (aPosicao < 1) do
      aPosicao := Random( aTamanho );

    aMarcacao := TServicesHash.StrToEncode( FormatFloat('000', aPosicao) ); // Tamanho 4

    aRetorno := aHora
      + Copy(aBase, 1, aPosicao)
      + ReverseString( aHash )
      + Copy(aBase, aPosicao + 1, aTamanho)
      + ReverseString( aMarcacao );
  finally
    Result := aRetorno;
  end;
end;

class function TServicesHash.StrCompareHash(Base, Value: String; const Chave: String): Boolean;
var
  aChave   ,
  aMarcacao,
  aHash0   ,
  aHash1   : String;
  aRetorno : Boolean;
begin
  try
    aMarcacao := ReverseString( Copy(Base, Base.Length - 3, 4) );       // Tamanho 4
    aHash0    := Self.StrToMD5( ReverseString(Value + Chave) ).ToLower; // Tamanho 32
    aHash1    := ReverseString( aHash0 );
    aRetorno  := (Pos(aHash0, Base) > 0) or (Pos(aHash1, Base) > 0);
  finally
    Result := aRetorno;
  end;
end;

class function TServicesHash.StrIsHash(Value: String): Boolean;
var
  aMarcacao : String;
  aPosicao  : Integer;
begin
  try
    aMarcacao := ReverseString( Copy(Value, Value.Length - 3, 4) ); // Tamanho 4
    Result    := TryStrToInt(TServicesHash.StrToDecode(aMarcacao), aPosicao);
  except
    Result := False;
  end;
end;

class function TServicesHash.StrToMD5(Value: String): String;
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

end.
