unit Model.Lancamento;

interface

uses
  System.SysUtils, Model.Categoria, Services.ComplexTypes;

type
  TLancamentoModel = class
    private
      FValor    : Currency;
      FDescricao: String;
      FCodigo: Integer;
      FID    : TGUID;
      FData  : TDateTime;
      FCategoria : TCategoriaModel;
      FTipo : TTipoLancamento;
      procedure SetCodigo(const Value: Integer);
      procedure SetData(const Value: TDateTime);
      procedure SetDescricao(const Value: String);
      procedure SetID(const Value: TGUID);
      procedure SetValor(const Value: Currency);
      procedure SetCategoria(const Value: TCategoriaModel);
      procedure SetTipo(const Value: TTipoLancamento);
    public
      constructor Create;
      destructor Destroy; override;

      property ID : TGUID read FID write SetID;
      property Codigo : Integer read FCodigo write SetCodigo;
      property Tipo : TTipoLancamento read FTipo write SetTipo;
      property Descricao : String read FDescricao write SetDescricao;
      property Data : TDateTime read FData write SetData;
      property Valor : Currency read FValor write SetValor;
      property Categoria : TCategoriaModel read FCategoria write SetCategoria;

      class function New : TLancamentoModel;
  end;

implementation

{ TLancamentoModel }

constructor TLancamentoModel.Create;
begin
  FID     := TGUID.Empty;
  FCodigo := 0;
  FDescricao := EmptyStr;
  FData      := Date;
  FValor     := 0.0;
  FCategoria := TCategoriaModel.Create;
  FTipo := TTipoLancamento.tipoDespesa;
end;

destructor TLancamentoModel.Destroy;
begin
  FCategoria.DisposeOf;
  inherited;
end;

class function TLancamentoModel.New: TLancamentoModel;
begin
  Result := Self.Create;
end;

procedure TLancamentoModel.SetCategoria(const Value: TCategoriaModel);
begin
  FCategoria := Value;
end;

procedure TLancamentoModel.SetCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TLancamentoModel.SetData(const Value: TDateTime);
begin
  FData := Value;
end;

procedure TLancamentoModel.SetDescricao(const Value: String);
begin
  FDescricao := Value.Trim;
end;

procedure TLancamentoModel.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TLancamentoModel.SetTipo(const Value: TTipoLancamento);
begin
  FTipo := Value;
end;

procedure TLancamentoModel.SetValor(const Value: Currency);
begin
  FValor := Value;
end;

end.
