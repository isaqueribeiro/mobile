unit dao.Notificacao;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Notificacao,

  System.StrUtils,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TNotificacaoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TNotificacao;
      aLista : TNotificacoes;
      aOperacao : TTipoOperacaoDao;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TNotificacao);
      procedure ClearLista;
      class var aInstance : TNotificacaoDao;
    public
      property Model : TNotificacao read aModel write aModel;
      property Lista : TNotificacoes read aLista write aLista;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();
      procedure Delete();
      procedure MarkRead();
      procedure Limpar();
      procedure AddLista; overload;
      procedure AddLista(aNotificacao : TNotificacao); overload;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;
      function GetCountNotRead() : Integer;

      class function GetInstance : TNotificacaoDao;
  end;

implementation

{ TNotificacaoDao }

uses
  UDM;

procedure TNotificacaoDao.AddLista;
var
  I : Integer;
  o : TNotificacao;
begin
  I := High(aLista) + 2;
  o := TNotificacao.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

procedure TNotificacaoDao.AddLista(aNotificacao: TNotificacao);
var
  I : Integer;
begin
  I := High(aLista) + 2;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := aNotificacao;
end;

procedure TNotificacaoDao.ClearLista;
begin
  SetLength(aLista, 0);
end;

constructor TNotificacaoDao.Create;
begin
  inherited Create;
  aDDL   := TScriptDDL.GetInstance;
  aModel := TNotificacao.Create;
  aOperacao := TTipoOperacaoDao.toBrowser;
  SetLength(aLista, 0);
end;

procedure TNotificacaoDao.Delete;
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Delete from ' + aDDL.getTableNameNotificacao);
      SQL.Add('where id_notificacao = :id_notificacao ');
      SQL.EndUpdate;

      ParamByName('id_notificacao').AsString := GUIDToString(aModel.ID);
      ExecSQL;

      aOperacao := TTipoOperacaoDao.toExcluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TNotificacaoDao.Find(const aCodigo: Currency; const IsLoadModel: Boolean): Boolean;
var
  aQry : TFDQuery;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    c.* ');
      SQL.Add('from ' + aDDL.getTableNameNotificacao + ' c');
      SQL.Add('where c.cd_notificacao = ' + CurrToStr(aCodigo));
      SQL.EndUpdate;

      if aQry.OpenOrExecute then
      begin
        aRetorno := (aQry.RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(aQry, aModel);
      end;
      aQry.Close;
    end;
    aOperacao := TTipoOperacaoDao.toBrowser;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TNotificacaoDao.GetCount: Integer;
var
  aRetorno : Integer;
  aQry : TFDQuery;
begin
  aRetorno := 0;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  count(*) as qt_notificacoes');
      SQL.Add('from ' + aDDL.getTableNameNotificacao);
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_notificacoes').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TNotificacaoDao.GetCountNotRead: Integer;
var
  aRetorno : Integer;
  aQry : TFDQuery;
begin
  aRetorno := 0;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  count(*) as qt_notificacoes');
      SQL.Add('from ' + aDDL.getTableNameNotificacao);
      SQL.Add('where sn_lida = :sn_lida');
      SQL.EndUpdate;

      ParamByName('sn_lida').AsString := 'N';
      OpenOrExecute;

      aRetorno := FieldByName('qt_notificacoes').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

class function TNotificacaoDao.GetInstance: TNotificacaoDao;
begin
  if not Assigned(aInstance) then
    aInstance := TNotificacaoDao.Create();

  Result := aInstance;
end;

procedure TNotificacaoDao.Insert;
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Insert Into ' + aDDL.getTableNameNotificacao + '(');
      SQL.Add('    id_notificacao  ');
      SQL.Add('  , cd_notificacao  ');
      SQL.Add('  , dt_notificacao  ');
      SQL.Add('  , ds_titulo       ');
      SQL.Add('  , ds_mensagem     ');
      SQL.Add('  , sn_lida         ');
      SQL.Add('  , sn_destacar     ');
      SQL.Add(') values (');
      SQL.Add('    :id_notificacao ');
      SQL.Add('  , :cd_notificacao ');
      SQL.Add('  , :dt_notificacao ');
      SQL.Add('  , :ds_titulo      ');
      SQL.Add('  , :ds_mensagem    ');
      SQL.Add('  , :sn_lida        ');
      SQL.Add('  , :sn_destacar    ');
      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := GetNewID(aDDL.getTableNameNotificacao, 'cd_notificacao', EmptyStr);

      ParamByName('id_notificacao').AsString   := GUIDToString(aModel.ID);
      ParamByName('cd_notificacao').AsCurrency := aModel.Codigo;
      ParamByName('dt_notificacao').AsDateTime := aModel.Data;
      ParamByName('ds_titulo').AsString        := aModel.Titulo;
      ParamByName('ds_mensagem').AsString      := aModel.Mensagem;
      ParamByName('sn_lida').AsString          := IfThen(aModel.Lida, 'S', 'N');
      ParamByName('sn_destacar').AsString      := IfThen(aModel.Destacar, 'S', 'N');

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TNotificacaoDao.Limpar;
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Delete from ' + aDDL.getTableNameNotificacao);
      SQL.EndUpdate;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluir;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TNotificacaoDao.Load(const aBusca: String);
var
  aQry : TFDQuery;
  aNotificacao : TNotificacao;
  aFiltro  : String;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    aFiltro := AnsiUpperCase(Trim(aBusca));

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select');
      SQL.Add('    c.* ');
      SQL.Add('from ' + aDDL.getTableNameNotificacao + ' c');

      if (StrToCurrDef(aFiltro, 0) > 0) then
        SQL.Add('where c.cd_notificacao = ' + aFiltro)
      else
      if (Trim(aBusca) <> EmptyStr) then
      begin
        aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
        SQL.Add('where (c.ds_titulo like ' + QuotedStr(aFiltro) + ')');
        SQL.Add('   or (c.ds_mensagem like ' + QuotedStr(aFiltro) + ')');
      end;

      SQL.Add('order by');
      SQL.Add('    c.dt_notificacao DESC');

      SQL.EndUpdate;

      if aQry.OpenOrExecute then
      begin
        ClearLista;
        if (aQry.RecordCount > 0) then
          while not aQry.Eof do
          begin
            aNotificacao := TNotificacao.Create;
            SetValues(aQry, aNotificacao);

            AddLista(aNotificacao);
            aQry.Next;
          end;
      end;
      aQry.Close;
    end;
    aOperacao := TTipoOperacaoDao.toBrowser;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TNotificacaoDao.MarkRead;
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Update ' + aDDL.getTableNameNotificacao + ' Set');
      SQL.Add('  sn_lida = :sn_lida  ');
      SQL.Add('where id_notificacao = :id_notificacao ');
      SQL.EndUpdate;

      ParamByName('id_notificacao').AsString := GUIDToString(aModel.ID);
      ParamByName('sn_lida').AsString        := IfThen(aModel.Lida, 'S', 'N');

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TNotificacaoDao.SetValues(const aDataSet: TFDQuery; const aObject: TNotificacao);
begin
  with aDataSet, aObject do
  begin
    ID     := StringToGUID(FieldByName('id_notificacao').AsString);
    Codigo := FieldByName('cd_notificacao').AsCurrency;

    Data   := FieldByName('dt_notificacao').AsDateTime;
    Titulo := FieldByName('ds_titulo').AsString;
    Mensagem := FieldByName('ds_mensagem').AsString;
    Lida     := (AnsiUpperCase(FieldByName('sn_lida').AsString) = 'S');
    Destacar := (AnsiUpperCase(FieldByName('sn_destacar').AsString) = 'S');
  end;
end;

procedure TNotificacaoDao.Update;
var
  aQry : TFDQuery;
begin
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Update ' + aDDL.getTableNameNotificacao + ' Set');
      SQL.Add('    cd_notificacao   = :cd_notificacao ');
      SQL.Add('  , dt_notificacao   = :dt_notificacao ');
      SQL.Add('  , ds_titulo        = :ds_titulo ');
      SQL.Add('  , ds_mensagem      = :ds_mensagem ');
      SQL.Add('  , sn_lida          = :sn_lida ');
      SQL.Add('  , sn_destacar      = :sn_destacar ');
      SQL.Add('where id_notificacao = :id_notificacao ');
      SQL.EndUpdate;

      ParamByName('id_notificacao').AsString   := GUIDToString(aModel.ID);
      ParamByName('cd_notificacao').AsCurrency := aModel.Codigo;
      ParamByName('dt_notificacao').AsDateTime := aModel.Data;
      ParamByName('ds_titulo').AsString        := aModel.Titulo;
      ParamByName('ds_mensagem').AsString      := aModel.Mensagem;
      ParamByName('sn_lida').AsString          := IfThen(aModel.Lida, 'S', 'N');
      ParamByName('sn_destacar').AsString      := IfThen(aModel.Destacar, 'S', 'N');

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
