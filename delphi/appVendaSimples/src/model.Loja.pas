unit model.Loja;

interface

uses
  UConstantes,
  app.Funcoes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TLoja = class(TObject)
    private
      aID      : TGUID;
      aCodigo  : Currency;
      aNome    ,
      aFantasia,
      aCpfCnpj : String;
      procedure SetNome(Value : String);
      procedure SetFantasia(Value : String);
      procedure SetCpfCnpj(Value : String);

      function GetTipo : TTipoLoja;
      function GetCpfCnpj : String;
    public
      constructor Create; overload;

      property ID       : TGUID read aID write aID;
      property Codigo   : Currency read aCodigo write aCodigo;
      property Tipo     : TTipoLoja read GetTipo;
      property Nome     : String read aNome write SetNome;
      property Fantasia : String read aFantasia write SetFantasia;
      property CpfCnpj  : String read GetCpfCnpj write aCpfCnpj;

      procedure NewID;

      function ToString : String; override;
  end;

  TLOjas = Array of TLoja;

implementation

{ TLoja }

constructor TLoja.Create;
begin
  inherited Create;
  aId       := GUID_NULL;
  aCodigo   := 0;
  aNome     := EmptyStr;
  aFantasia := EmptyStr;
  aCpfCnpj  := EmptyStr;
end;

function TLoja.GetCpfCnpj: String;
begin
  Result := aCpfCnpj;
end;

function TLoja.GetTipo: TTipoLoja;
begin
  if StrIsCNPJ(aCpfCnpj) then
    Result := TTipoCliente.tcPessoaJuridica
  else
    Result := TTipoCliente.tcPessoaFisica;
end;

procedure TLoja.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

procedure TLoja.SetCpfCnpj(Value: String);
var
  aStr : String;
begin
  aStr :=  SomenteNumero(AnsiLowerCase(Trim(Value)));
  if StrIsCPF(aStr) then
    aCpfCnpj := FormatarTexto('999.999.999-99;0', aStr)
  else
  if StrIsCNPJ(aStr) then
    aCpfCnpj := FormatarTexto('99.999.999/9999-99;0', aStr)
  else
    aCpfCnpj := EmptyStr;
end;

procedure TLoja.SetFantasia(Value: String);
begin
  aFantasia := Trim(Value);
end;

procedure TLoja.SetNome(Value: String);
begin
  aNome := Trim(Value);
end;

function TLoja.ToString: String;
begin
  Result := aFantasia + ' (' + aCpfCnpj + ')';
end;

end.
