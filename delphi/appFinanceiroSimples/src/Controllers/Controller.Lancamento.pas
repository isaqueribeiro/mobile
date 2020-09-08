unit Controller.Lancamento;

interface

uses
  System.SysUtils, Model.Lancamento, Services.ComplexTypes,
  System.Generics.Collections;

type
  TLancamentoController = class
    strict private
      class var _instance : TLancamentoController;
    protected
      constructor Create;
      destructor Destroy; override;
    private
      FOperacao : TTipoOperacaoController;
      FModel : TLancamentoModel;
      FLista : TDictionary<TGUID, TLancamentoModel>;
    public
      class function GetInstance : TLancamentoController;

      property Operacao : TTipoOperacaoController read FOperacao;
      property Attributes : TLancamentoModel read  FModel;
      property Lista : TDictionary<TGUID, TLancamentoModel> read FLista;
  end;

implementation

{ TLancamentoController }

uses
    DataModule.Conexao
  , Classes.ScriptDDL
  , FMX.Graphics;

class function TLancamentoController.GetInstance: TLancamentoController;
begin
  if not Assigned(_instance) then
    _instance := TLancamentoController.Create;

  Result := _instance;
end;

constructor TLancamentoController.Create;
begin
  FOperacao := TTipoOperacaoController.operControllerBrowser;
  FModel := TLancamentoModel.New;
  FLista := TDictionary<TGUID, TLancamentoModel>.Create;

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableLancamento.Text, True);
end;

destructor TLancamentoController.Destroy;
var
  aObj : TLancamentoModel;
begin
  if Assigned(FModel) then
    FModel.DisposeOf;

  if Assigned(FLista) then
  begin
    for aObj in FLista.Values do
    begin
      FLista.Remove(aObj.ID);
      aObj.DisposeOf;
    end;

    FLista.Clear;
    FLista.TrimExcess;
    FLista.DisposeOf;
  end;

  inherited;
end;

end.
