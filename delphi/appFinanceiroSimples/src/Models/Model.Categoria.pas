unit Model.Categoria;

interface

uses
  System.SysUtils, FMX.Graphics;

type
  TCategoriaModel = class
  private
    FCodigo    : Integer;
    FDescricao : String;
    FIcone     : TBitmap;
    FIndice    : Integer; // Índice da imagem
    procedure SetCodigo(const Value: Integer);
    procedure SetDescricao(const Value: String);
    procedure SetIcone(const Value: TBitmap);
  procedure SetIndice(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;

    property Codigo : Integer read FCodigo write SetCodigo;
    property Descricao : String read FDescricao write SetDescricao;
    property Icone : TBitmap read FIcone write SetIcone;
    property Indice : Integer read FIndice write SetIndice;

    class function New : TCategoriaModel;
  end;

  TListaCategoria = array of TCategoriaModel;

implementation

{ TCategoriaModel }

constructor TCategoriaModel.Create;
begin
  FCodigo    := 0;
  FDescricao := EmptyStr;
  FIcone     := nil;
  FIndice    := 0;
end;

destructor TCategoriaModel.Destroy;
begin
  FIcone.DisposeOf;
  inherited;
end;

class function TCategoriaModel.New: TCategoriaModel;
begin
  Result := Self.Create;
end;

procedure TCategoriaModel.SetCodigo(const Value: Integer);
begin
  FCodigo := Value;
end;

procedure TCategoriaModel.SetDescricao(const Value: String);
begin
  FDescricao := Value.Trim();
end;

procedure TCategoriaModel.SetIcone(const Value: TBitmap);
begin
  if not Assigned(FIcone) then
    FIcone := TBitmap.Create;

  FIcone.Assign( Value );
end;

procedure TCategoriaModel.SetIndice(const Value: Integer);
begin
  FIndice := Value;
end;

end.
