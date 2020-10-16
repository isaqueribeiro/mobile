unit Model.Usuario;

interface

uses
  System.SysUtils, FMX.Graphics;

type
  TUsuarioModel = class
    private
      FID : TGUID;
      FCodigo : Integer;
      FNome : String;
      FEmail : String;
      FSenha : String;
      FFoto  : TBitmap;
      FLogado : Boolean;
      FTemFoto: Boolean;
      procedure SetEmail(const Value: String);
      procedure SetFoto(const Value: TBitmap);
      procedure SetID(const Value: TGUID);
      procedure SetLogado(const Value: Boolean);
      procedure SetNome(const Value: String);
      procedure SetSenha(const Value: String);
      procedure SetCodigo(const Value: Integer);
      procedure SetTemFoto(const Value: Boolean);
    public
      constructor Create;
      destructor Destroy; override;

      property ID : TGUID read FID write SetID;
      property Codigo : Integer read FCodigo write SetCodigo;
      property Nome : String read FNome write SetNome;
      property Email : String read FEmail write SetEmail;
      property Senha : String read FSenha write SetSenha;
      property Foto : TBitmap read FFoto write SetFoto;
      property TemFoto : Boolean read FTemFoto write SetTemFoto;
      property Logado  : Boolean read FLogado write SetLogado;

      class function New : TUsuarioModel;
  end;
implementation

{ TUsuarioModel }

constructor TUsuarioModel.Create;
begin
  FID     := TGUID.Empty;
  FNome   := EmptyStr;
  FEmail  := EmptyStr;
  FSenha  := EmptyStr;
  FFoto   := nil;
  FLogado := False;
end;

destructor TUsuarioModel.Destroy;
begin
  inherited;
end;

class function TUsuarioModel.New: TUsuarioModel;
begin
  Result := Self.Create;
end;

procedure TUsuarioModel.SetCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TUsuarioModel.SetEmail(const Value: String);
begin
  FEmail := Value.Trim.ToLower;
end;

procedure TUsuarioModel.SetFoto(const Value: TBitmap);
begin
  FFoto := Value;
end;

procedure TUsuarioModel.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TUsuarioModel.SetLogado(const Value: Boolean);
begin
  FLogado := Value;
end;

procedure TUsuarioModel.SetNome(const Value: String);
begin
  FNome := Value.Trim;
end;

procedure TUsuarioModel.SetSenha(const Value: String);
begin
  FSenha := Value.Trim;
end;

procedure TUsuarioModel.SetTemFoto(const Value: Boolean);
begin
  FTemFoto := Value;
end;

end.
