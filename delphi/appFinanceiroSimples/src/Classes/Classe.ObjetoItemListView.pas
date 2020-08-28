unit Classe.ObjetoItemListView;

interface

uses
  System.SysUtils, System.Classes;

type
  TObjetoItemListView = class
  private
    FID: TGUID;
    FCodigo: Integer;
    FDescricao: String;
    FCategoria: String;
    FValor: String;
    FDataMovimento: String;
    FImage : String;
    procedure SetCategoria(const Value: String);
    procedure SetDataMovimento(const Value: String);
    procedure SetDescricao(const Value: String);
    procedure SetID(const Value: TGUID);
    procedure SetValor(const Value: String);
    procedure SetCodigo(const Value: Integer);
    procedure SetImage(const Value: String);
  public
    constructor Create;
    destructor Destroy; override;

    property ID : TGUID read FID write SetID;
    property Codigo : Integer read FCodigo write SetCodigo;
    property Descricao : String read FDescricao write SetDescricao;
    property Categoria : String read FCategoria write SetCategoria;
    property Valor : String read FValor write SetValor;
    property DataMovimento : String read FDataMovimento write SetDataMovimento;
    property Image : String read FImage write SetImage;
  end;

  TListaObjetos = Array of TObjetoItemListView;

implementation

{ TObjetoItemListView }

constructor TObjetoItemListView.Create;
begin
  FID := TGUID.Empty;
  FCodigo := 0;
  FDescricao := EmptyStr;
  FCategoria := EmptyStr;
  FValor     := FormatFloat(', 0.00', 0);
  FDataMovimento := FormatDateTime('dd/mm', Date);
end;

destructor TObjetoItemListView.Destroy;
begin
  inherited;
end;

procedure TObjetoItemListView.SetCategoria(const Value: String);
begin
  FCategoria := Value.Trim;
end;

procedure TObjetoItemListView.SetCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TObjetoItemListView.SetDataMovimento(const Value: String);
begin
  FDataMovimento := Value.Trim;
end;

procedure TObjetoItemListView.SetDescricao(const Value: String);
begin
  FDescricao := Value.Trim;
end;

procedure TObjetoItemListView.SetID(const Value: TGUID);
begin
  FID := Value;
end;

procedure TObjetoItemListView.SetImage(const Value: String);
begin
  FImage := Value.Trim();
end;

procedure TObjetoItemListView.SetValor(const Value: String);
begin
  FValor := Value.Trim;
end;

end.
