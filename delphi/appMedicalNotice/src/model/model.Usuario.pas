unit model.Usuario;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TUsuario = class(TObject)
    strict private
      aId     : TGUID;
      aCodigo ,
      aNome   ,
      aEmail  ,
      aSenha  ,
      aObservacao : String;
      aPrestador  : Currency;
      aAtivo      : Boolean;
      aTokenDispositivo : String;
      constructor Create();
      procedure SetCodigo(Value : String);
      procedure SetEmail(Value : String);
      class var aInstance : TUsuario;
    public
      property Id     : TGUID read aId write aId;
      property Codigo : String read aCodigo write SetCodigo;
      property Nome   : String read aNome write aNome;
      property Email  : String read aEmail write SetEmail;
      property Senha  : String read aSenha write aSenha;
      property Observacao : String read aObservacao write aObservacao;
      property Prestador  : Currency read aPrestador write aPrestador;
      property Ativo      : Boolean read aAtivo write aAtivo;
      property TokenDispositivo : String read aTokenDispositivo write aTokenDispositivo;

      procedure NewId;
      function ToString : String; override;

      class function GetInstance : TUsuario;
  end;

implementation

{ TUsuario }

constructor TUsuario.Create;
begin
  inherited Create;
  aId     := GUID_NULL;
  aCodigo := EmptyStr;
  aNome   := EmptyStr;
  aEmail  := EmptyStr;
  aSenha  := EmptyStr;
  aObservacao := EmptyStr;
  aPrestador  := 0.0;
  aAtivo      := False;
  aTokenDispositivo := EmptyStr;
end;

class function TUsuario.GetInstance: TUsuario;
begin
  if not Assigned(aInstance) then
    aInstance := TUsuario.Create();

  Result := aInstance;
end;

procedure TUsuario.NewId;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

procedure TUsuario.SetCodigo(Value: String);
begin
  aCodigo := AnsiLowerCase(Trim(Value));
end;

procedure TUsuario.SetEmail(Value: String);
begin
  aEmail := Trim(AnsiLowerCase(Value));
end;

function TUsuario.ToString: String;
begin
  Result := aCodigo;
end;

end.
