unit model.Produto;

interface

uses
  UConstantes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TProduto = class(TObject)
    private
      aID        : TGUID;
      aCodigo    : Currency;
      aDescricao : String;
      aFoto      : TImageIndex;
      aValor     : Currency;
      aAtivo        ,
      aSincronizado : Boolean;
      aReferencia   : TGUID;

      procedure SetDescricao(Value: String);
    public
      constructor Create; overload;

      property ID           : TGUID read aID write aID;
      property Codigo       : Currency read aCodigo write aCodigo;
      property Descricao    : String read aDescricao write SetDescricao;
      property Foto         : TImageIndex read aFoto write aFoto;
      property Valor        : Currency read aValor write aValor;
      property Ativo        : Boolean read aAtivo write aAtivo;
      property Sincronizado : Boolean read aSincronizado write aSincronizado;
      property Referencia   : TGUID read aReferencia write aReferencia;
  end;

  TProdutos = Array of TProduto;

implementation

{ TProduto }

constructor TProduto.Create;
begin
  inherited Create;
  aId      := GUID_NULL;
  aCodigo  := 0;
  aDescricao := EmptyStr;
  //aFoto      : TImageIndex;
  aValor     := 0.0;
  aAtivo        := True;
  aSincronizado := False;
  aReferencia   := GUID_NULL;
end;

procedure TProduto.SetDescricao(Value: String);
begin
  aDescricao := Trim(Value);
end;

end.
