unit Controller.Compromisso;

interface

uses
    System.SysUtils
  , Classes.ScriptDDL
  , Model.Compromisso
  , Controllers.Interfaces.Observers
  , Services.ComplexTypes
  , System.Generics.Collections
  , FireDAC.Comp.Client
  , Data.DB;

type
  TCompromissoController = class(TInterfacedObject, ISubjectCompromissoController)
    strict private
      class var _instance : TCompromissoController;
    private
      FObservers : TList<IObserverCompromissoController>;
      FOperacao  : TTipoOperacaoController;
      FDDL       : TScriptDDL;
      FModel     : TCompromissoModel;
      FLista     : TList<TCompromissoModel>;
      procedure SetAtributes(const aDataSet : TDataSet; aModel : TCompromissoModel);

      procedure AdicionarObservador(Observer : IObserverCompromissoController);
      procedure RemoverTodosObservadores;
      procedure Notificar;

      function Find(aID : TGUID; aCodigo : Integer; out aErro : String;
        const RETURN_ATTRIBUTES : Boolean = FALSE) : Boolean; overload;
    protected
      constructor Create;
      destructor Destroy; override;
    public
      class function GetInstance(Observer : IObserverCompromissoController) : TCompromissoController;

      property Operacao : TTipoOperacaoController read FOperacao;
      property Attributes : TCompromissoModel read  FModel;
      property Lista : TList<TCompromissoModel> read FLista;

      procedure New;
      procedure Load(const aQuantidadeRegistros: Integer; aAno, aMes : Word; aTipo : TTipoCompromisso;
        var aTotal : TTotalCompromissos; out aErro : String);
      procedure RemoverObservador(Observer   : IObserverCompromissoController);
  end;

implementation

uses
    DataModule.Conexao
  , FMX.Graphics
  , System.DateUtils
  , System.Math;

{ TCompromissoController }

const
  FLAG_SIM = 'S';
  FLAG_NAO = 'N';

class function TCompromissoController.GetInstance(Observer: IObserverCompromissoController): TCompromissoController;
begin
  if not Assigned(_instance) then
    _instance := TCompromissoController.Create;

  _instance.AdicionarObservador(Observer);
  Result := _instance;
end;

procedure TCompromissoController.Load(const aQuantidadeRegistros: Integer; aAno, aMes: Word; aTipo: TTipoCompromisso;
  var aTotal: TTotalCompromissos; out aErro: String);
begin
  ;
end;

procedure TCompromissoController.AdicionarObservador(Observer: IObserverCompromissoController);
begin
  if (FObservers.IndexOf(Observer) = -1) then
    FObservers.Add(Observer);
end;

constructor TCompromissoController.Create;
begin
  FObservers := TList<IObserverCompromissoController>.Create;
  FOperacao  := TTipoOperacaoController.operControllerBrowser;
  FDDL       := TScriptDDL.getInstance();
  FModel     := TCompromissoModel.New;
  FLista     := TList<TCompromissoModel>.Create;

  TDMConexao
    .GetInstance()
    .Conn
    .ExecSQL(TScriptDDL.getInstance().getCreateTableCompromisso.Text, True);
end;

destructor TCompromissoController.Destroy;
var
  aObj : TCompromissoModel;
  I : Integer;
begin
  RemoverTodosObservadores;
  FObservers.DisposeOf;

  FDDL.DisposeOf;
  FModel.DisposeOf;

  if Assigned(FLista) then
  begin
    for I := 0 to FLista.Count - 1 do
    begin
      aObj := FLista.Items[I];
      FLista.Delete(I);
      aObj.DisposeOf;
    end;

    FLista.Clear;
    FLista.TrimExcess;
    FLista.DisposeOf;
  end;

  inherited;
end;

function TCompromissoController.Find(aID: TGUID; aCodigo: Integer; out aErro: String;
  const RETURN_ATTRIBUTES: Boolean): Boolean;
var
  aQry : TFDQuery;
begin
  Result := False;

  FOperacao := TTipoOperacaoController.operControllerBrowser;

  aQry := TFDQuery.Create(nil);
  try
    aQry.Connection := TDMConexao.GetInstance().Conn;

    try
      with aQry, SQL do
      begin
        BeginUpdate;
        Clear;
        Add('Select ');
        Add('    a.id_compromisso');
        Add('  , a.cd_compromisso');
        Add('  , a.tp_compromisso');
        Add('  , a.ds_compromisso');
        Add('  , a.dt_compromisso');
        Add('  , a.vl_compromisso');
        Add('  , a.sn_realizado');
        Add('  , a.cd_categoria ');
        Add('  , c.ds_categoria ');
        Add('  , c.ic_categoria ');
        Add('from ' + FDDL.getTableNameCompromisso + ' a');
        Add('  left join ' + FDDL.getTableNameCategoria + ' c on (c.cd_categoria = a.cd_categoria)');
        Add('where (a.id_compromisso = :id_compromisso)');
        Add('   or (a.cd_compromisso = :cd_compromisso)');
        EndUpdate;

        ParamByName('id_compromisso').AsString  := aID.ToString;
        ParamByName('cd_compromisso').AsInteger := aCodigo;

        Open;

        Result := not IsEmpty;

        if Result and RETURN_ATTRIBUTES then
          SetAtributes(aQry, FModel);
      end;
    except
      On E : Exception do
        aErro := 'Erro ao tentar localizar o compromisso: ' + E.Message;
    end;
  finally
    aQry.Close;
    aQry.DisposeOf;
  end;
end;

procedure TCompromissoController.New;
begin
  FModel := TCompromissoModel.New;
end;

procedure TCompromissoController.Notificar;
var
  Observer : IObserverCompromissoController;
begin
  try
    for Observer in FObservers do
      Observer.AtualizarCompromisso;
  except
    Exit;
  end;
end;

procedure TCompromissoController.RemoverObservador(Observer: IObserverCompromissoController);
begin
  if (FObservers.IndexOf(Observer) > -1) then
  begin
    FObservers.Delete(FObservers.IndexOf(Observer));
    FObservers.TrimExcess;
  end;
end;

procedure TCompromissoController.RemoverTodosObservadores;
var
  I : Integer;
begin
  for I := 0 to (FObservers.Count - 1) do
    FObservers.Delete(I);

  FObservers.TrimExcess;
end;

procedure TCompromissoController.SetAtributes(const aDataSet: TDataSet; aModel: TCompromissoModel);
begin
  with aDataSet, aModel do
  begin
    ID     := StringToGUID(FieldByName('id_compromisso').AsString);
    Codigo := FieldByName('cd_compromisso').AsInteger;
    Tipo   := TTipoCompromisso(FieldByName('tp_compromisso').AsInteger);
    Descricao := FieldByName('ds_compromisso').AsString;
    Data      := FieldByName('dt_compromisso').AsDateTime;
    Valor     := FieldByName('vl_compromisso').AsCurrency;
    Realizado := (FieldByName('sn_realizado').AsString = FLAG_SIM);

    Categoria.Codigo    := FieldByName('cd_categoria').AsInteger;
    Categoria.Descricao := FieldByName('ds_categoria').AsString;

    // #0#0#0#0'IEND®B`‚'
    if (Trim(FieldByName('ic_categoria').AsString) <> EmptyStr) then
    begin
      Categoria.Icone := TBitmap.Create;
      Categoria.Icone.LoadFromStream( CreateBlobStream(FieldByName('ic_categoria'), TBlobStreamMode.bmRead) );
    end
    else
      Categoria.Icone := nil;
  end;
end;

end.
