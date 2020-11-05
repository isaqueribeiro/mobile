unit Model.Compromisso;

interface

uses
  System.SysUtils, Model.Categoria, Services.ComplexTypes;

type
  TCompromissoModel = class
    private
      FValor: Currency;
      FDescricao: String;
      FCodigo: Integer;
      FID: TGUID;
      FCategoria: TCategoriaModel;
      FTipo: TTipoCompromisso;
      FData: TDateTime;
      FRealizado: Boolean;
      procedure SetCategoria(const Value: TCategoriaModel);
      procedure SetCodigo(const Value: Integer);
      procedure SetData(const Value: TDateTime);
      procedure SetDescricao(const Value: String);
      procedure SetID(const Value: TGUID);
      procedure SetTipo(const Value: TTipoCompromisso);
      procedure SetValor(const Value: Currency);
      procedure SetRealizado(const Value: Boolean);
    public
      constructor Create;
      destructor Destroy; override;

      property ID : TGUID read FID write SetID;
      property Codigo : Integer read FCodigo write SetCodigo;
      property Tipo : TTipoCompromisso read FTipo write SetTipo;
      property Descricao : String read FDescricao write SetDescricao;
      property Data : TDateTime read FData write SetData;
      property Valor : Currency read FValor write SetValor;
      property Categoria : TCategoriaModel read FCategoria write SetCategoria;
      property Realizado : Boolean read FRealizado write SetRealizado;

      procedure Assign(Source : TCompromissoModel);

      function ToString : String; override;

      class function New : TCompromissoModel;
  end;

implementation

{ TCompromissoModel }

class function TCompromissoModel.New: TCompromissoModel;
begin
  Result := Self.Create;
end;

procedure TCompromissoModel.Assign(Source: TCompromissoModel);
begin
  if Assigned(Source) then
  begin
    FID        := Source.ID;
    FCodigo    := Source.Codigo;
    FDescricao := Source.Descricao;
    FValor     := Source.Valor;
    FData      := Source.Data;
    FTipo      := Source.Tipo;

    FCategoria.Assign(Source.Categoria);
  end;
end;

constructor TCompromissoModel.Create;
begin
  FID     := TGUID.Empty;
  FCodigo := 0;
  FDescricao := EmptyStr;
  FData      := Date;
  FValor     := 0.0;
  FCategoria := TCategoriaModel.Create;
  FRealizado := False;
  FTipo      := TTipoCompromisso.tipoCompromissoAPagar;
end;

destructor TCompromissoModel.Destroy;
begin
  FCategoria.DisposeOf;
  inherited;
end;

procedure TCompromissoModel.SetCategoria(const Value: TCategoriaModel);
begin
  FCategoria := Value;
end;

procedure TCompromissoModel.SetCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TCompromissoModel.SetData(const Value: TDateTime);
begin
  FData := Value;
end;

procedure TCompromissoModel.SetDescricao(const Value: String);
begin
  FDescricao := Value.Trim;
end;

procedure TCompromissoModel.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TCompromissoModel.SetRealizado(const Value: Boolean);
begin
  FRealizado := Value;
end;

procedure TCompromissoModel.SetTipo(const Value: TTipoCompromisso);
begin
  FTipo := Value;
end;

procedure TCompromissoModel.SetValor(const Value: Currency);
begin
  FValor := Value;
end;

function TCompromissoModel.ToString: String;
begin
  Result := FID.ToString;
end;

end.
