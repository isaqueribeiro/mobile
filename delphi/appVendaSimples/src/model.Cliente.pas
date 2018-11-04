unit model.Cliente;

interface
uses
  UConstantes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TCliente = class(TObject)
    private
      aID      : TGUID;
      aCodigo  : Currency;
      aTipo    : TTipoCliente;
      aNome       ,
      aCpfCnpj    ,
      aContato    ,
      aTelefone   ,
      aCelular    ,
      aObservacao : String;
      aAtivo        ,
      aEntregue     ,
      aSincronizado : Boolean;
      aReferencia   : TGUID;

      procedure SetNome(Value : String);
    public
      constructor Create; overload;
//      destructor Destroy; overload;

      property ID      : TGUID read aID write aID;
      property Codigo  : Currency read aCodigo write aCodigo;
      property Tipo    : TTipoCliente read aTipo write aTipo;
      property Nome    : String read aNome write SetNome;
      property CpfCnpj : String read aCpfCnpj write aCpfCnpj;
      property Contato    : String read aContato write aContato;
      property Telefone   : String read aTelefone write aTelefone;
      property Celular    : String read aCelular write aCelular;
      property Observacao : String read aObservacao write aObservacao;
      property Ativo        : Boolean read aAtivo write aAtivo;
      property Entregue     : Boolean read aEntregue write aEntregue;
      property Sincronizado : Boolean read aSincronizado write aSincronizado;
      property Referencia   : TGUID read aReferencia write aReferencia;

      procedure NewID;

      function ToString : String; override;
  end;

implementation

{ TCliente }

constructor TCliente.Create;
begin
  inherited Create;
  aId      := GUID_NULL;
  aCodigo  := 0;
  aTipo    := tcPessoaFisica;
  aNome    := EmptyStr;
  aContato := EmptyStr;
  aCpfCnpj := EmptyStr;
  aAtivo         := True;
  aEntregue      := False;
  aSincronizado  := False;
  aObservacao    := EmptyStr;
  aReferencia    := GUID_NULL;
end;

procedure TCliente.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

procedure TCliente.SetNome(Value: String);
begin
  aNome := Trim(aNome);
end;

function TCliente.ToString: String;
begin
  Result := aNome;
end;

end.
