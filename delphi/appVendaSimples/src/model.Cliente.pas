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
      aEmail      ,
      aEndereco   ,
      aObservacao : String;
      aAtivo        ,
      aSincronizado : Boolean;
      aReferencia   : TGUID;
      aDataUltimaCompra  : TDateTime;
      aValorUltimaCompra : Currency;

      procedure SetEmail(Value : String);
      procedure SetNome(Value : String);
    public
      constructor Create; overload;

      property ID      : TGUID read aID write aID;
      property Codigo  : Currency read aCodigo write aCodigo;
      property Tipo    : TTipoCliente read aTipo write aTipo;
      property Nome    : String read aNome write SetNome;
      property CpfCnpj : String read aCpfCnpj write aCpfCnpj;
      property Contato    : String read aContato write aContato;
      property Telefone   : String read aTelefone write aTelefone;
      property Celular    : String read aCelular write aCelular;
      property Email      : String read aEmail write SetEmail;
      property Endereco   : String read aEndereco write aEndereco;
      property Observacao : String read aObservacao write aObservacao;
      property Ativo        : Boolean read aAtivo write aAtivo;
      property Sincronizado : Boolean read aSincronizado write aSincronizado;
      property Referencia   : TGUID read aReferencia write aReferencia;
      property DataUltimaCompra  : TDateTime read aDataUltimaCompra write aDataUltimaCompra;
      property ValorUltimaCompra : Currency read aValorUltimaCompra write aValorUltimaCompra;

      procedure NewID;

      function ToString : String; override;
  end;

  TClientes = Array of TCliente;

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
  aSincronizado  := False;
  aEmail         := EmptyStr;
  aEndereco      := EmptyStr;
  aObservacao    := EmptyStr;
  aReferencia    := GUID_NULL;

  aDataUltimaCompra  := StrToDate(EMPTY_DATE);
  aValorUltimaCompra := 0.0;
end;

procedure TCliente.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

procedure TCliente.SetEmail(Value: String);
begin
  aEmail := AnsiLowerCase(Trim(Value));
end;

procedure TCliente.SetNome(Value: String);
begin
  aNome := AnsiUpperCase(Trim(Value));
end;

function TCliente.ToString: String;
begin
  Result := 'Cliente #' + FormatFloat('##000', aCodigo);
end;

end.
