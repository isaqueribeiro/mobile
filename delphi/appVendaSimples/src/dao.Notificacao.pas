unit dao.Notificacao;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Notificacao,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TNotificacaoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TNotificacao;
      aLista : TNotificacoes;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TNotificacao);
      procedure ClearLista;
      class var aInstance : TNotificacaoDao;
    public
      property Model : TNotificacao read aModel write aModel;
      property Lista : TNotificacoes read aLista write aLista;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();
      procedure AddLista; overload;
      procedure AddLista(aNotificacao : TNotificacao); overload;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;

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
  SetLength(aLista, 0);
end;

function TNotificacaoDao.Find(const aCodigo: Currency; const IsLoadModel: Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    c.* ');
    aSQL.Add('from ' + aDDL.getTableNameNotificacao + ' c');
    aSQL.Add('where c.cd_notificacao = ' + CurrToStr(aCodigo));
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(qrySQL, aModel);
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
    Result := aRetorno;
  end;
end;

function TNotificacaoDao.GetCount: Integer;
var
  aRetorno : Integer;
  aSQL : TStringList;
begin
  aRetorno := 0;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select ');
    aSQL.Add('  count(*) as qt_notificacoes');
    aSQL.Add('from ' + aDDL.getTableNameNotificacao);
    aSQL.EndUpdate;
    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;
      OpenOrExecute;

      aRetorno := FieldByName('qt_notificacoes').AsInteger;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
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
begin
  ;
end;

procedure TNotificacaoDao.Load(const aBusca: String);
var
  aSQL : TStringList;
  aNotificacao : TNotificacao;
  aFiltro  : String;
begin
  aSQL := TStringList.Create;
  try
    aFiltro := AnsiUpperCase(Trim(aBusca));

    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    c.* ');
    aSQL.Add('from ' + aDDL.getTableNameNotificacao + ' c');

    if (StrToCurrDef(aFiltro, 0) > 0) then
      aSQL.Add('where c.cd_notificacao = ' + aFiltro)
    else
    if (Trim(aBusca) <> EmptyStr) then
    begin
      aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
      aSQL.Add('where (c.ds_titulo like ' + QuotedStr(aFiltro) + ')');
      aSQL.Add('   or (c.ds_mensagem like ' + QuotedStr(aFiltro) + ')');
    end;

    aSQL.Add('order by');
    aSQL.Add('    c.dt_notificacao DESC');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        ClearLista;
        if (qrySQL.RecordCount > 0) then
          while not qrySQL.Eof do
          begin
            aNotificacao := TNotificacao.Create;
            SetValues(qrySQL, aNotificacao);

            AddLista(aNotificacao);
            qrySQL.Next;
          end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
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
begin
  ;
end;

end.
