unit model.Loja;

interface

uses
  UConstantes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TLoja = class(TObject)
    private
      aID      : TGUID;
      aCodigo  : Currency;
      aTipo    : TTipoLoja;
      aNome    ,
      aFantasia,
      aCpfCnpj : String;
      procedure SetNome(Value : String);
    public
      constructor Create; overload;

      property ID       : TGUID read aID write aID;
      property Codigo   : Currency read aCodigo write aCodigo;
      property Tipo     : TTipoLoja read aTipo write aTipo;
      property Nome     : String read aNome write SetNome;
      property Fantasia : String read aFantasia write aFantasia;
      property CpfCnpj  : String read aCpfCnpj write aCpfCnpj;
  end;

implementation

{ TLoja }

constructor TLoja.Create;
begin
  inherited Create;
  aId       := GUID_NULL;
  aCodigo   := 0;
  aTipo     := tcPessoaJuridica;
  aNome     := EmptyStr;
  aFantasia := EmptyStr;
  aCpfCnpj  := EmptyStr;
end;

procedure TLoja.SetNome(Value: String);
begin
  aNome := Trim(Value);
end;

end.
