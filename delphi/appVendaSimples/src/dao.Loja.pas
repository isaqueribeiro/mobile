unit dao.Loja;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Loja,

  System.StrUtils, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TLojaDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TLoja;
      aOperacao : TTipoOperacaoDao;
      constructor Create();
      destructor Destroy(); override;


      procedure SetValues(const aDataSet : TFDQuery; const aObject : TLoja);
      procedure ClearValues;

      class var aInstance : TLojaDao;
    public
      property Model    : TLoja read aModel write aModel;
      property Operacao : TTipoOperacaoDao read aOperacao;

      procedure Load(const aBusca : String);
      procedure Limpar();
      procedure Insert();
      procedure Update();

      function Find(const aID : TGUID; const aCpfCnpj : String; const IsLoadModel : Boolean) : Boolean;

      class function GetInstance : TLojaDao;
  end;

implementation

uses
  UDM;

{ TLojaDao }

procedure TLojaDao.ClearValues;
begin
  with aModel do
  begin
    ID       := GUID_NULL;
    Nome     := EmptyStr;
    Fantasia := EmptyStr;
    CpfCnpj  := EmptyStr;
  end;
end;

constructor TLojaDao.Create;
begin
  inherited Create;
  aDDL      := TScriptDDL.GetInstance;
  aModel    := TLoja.Create;
  aOperacao := TTipoOperacaoDao.toBrowser;
end;

destructor TLojaDao.Destroy;
begin
  aModel.DisposeOf;
  inherited Destroy;
end;

function TLojaDao.Find(const aID: TGUID; const aCpfCnpj: String; const IsLoadModel: Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    e.* ');
    aSQL.Add('from ' + aDDL.getTableNameLoja + ' e');

    if (aID <> GUID_NULL) then
      aSQL.Add('where e.id_empresa = :id_empresa')
    else
    if (Trim(aCpfCnpj) <> EmptyStr) then
      aSQL.Add('where e.nr_cnpj_cpf = :nr_cnpj_cpf');

    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aID <> GUID_NULL) then
        ParamByName('id_empresa').AsString := GUIDToString(aID)
      else
      if (Trim(aCpfCnpj) <> EmptyStr) then
        ParamByName('nr_cnpj_cpf').AsString := Trim(aCpfCnpj);

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(qrySQL, aModel)
        else
          ClearValues;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.DisposeOf;
    Result := aRetorno;
  end;
end;

class function TLojaDao.GetInstance: TLojaDao;
begin
  if not Assigned(aInstance) then
    aInstance := TLojaDao.Create();

  Result := aInstance;
end;

procedure TLojaDao.Insert;
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
      SQL.Add('Insert Into ' + aDDL.getTableNameLoja + '(');
      SQL.Add('    id_empresa    ');
      SQL.Add('  , nm_empresa    ');
      SQL.Add('  , nm_fantasia   ');
      SQL.Add('  , nr_cnpj_cpf   ');
      SQL.Add(') values (');
      SQL.Add('    :id_empresa   ');
      SQL.Add('  , :nm_empresa   ');
      SQL.Add('  , :nm_fantasia  ');
      SQL.Add('  , :nr_cnpj_cpf  ');
      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      ParamByName('id_empresa').AsString  := GUIDToString(aModel.ID);
      ParamByName('nm_empresa').AsString  := aModel.Nome;
      ParamByName('nm_fantasia').AsString := aModel.Fantasia;
      ParamByName('nr_cnpj_cpf').AsString := aModel.CpfCnpj;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toIncluido;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TLojaDao.Limpar;
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
      SQL.Add('Delete from ' + aDDL.getTableNameLoja);
      SQL.EndUpdate;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toExcluir;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TLojaDao.Load(const aBusca: String);
var
  aQry    : TFDQuery;
  aLoja   : TLoja;
  aFiltro : String;
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
      SQL.Add('    e.* ');
      SQL.Add('from ' + aDDL.getTableNameLoja + ' e');

      if (Trim(aBusca) <> EmptyStr) then
      begin
        aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
        SQL.Add('where (e.nm_empresa like ' + QuotedStr(aFiltro) + ')');
      end;

      SQL.Add('order by');
      SQL.Add('    e.nm_empresa ');
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        if (RecordCount > 0) then
          while not Eof do
          begin
            aLoja := TLoja.Create;
            SetValues(aQry, aLoja);
            aQry.Next;
          end
        else
          ClearValues;
      end;

      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TLojaDao.SetValues(const aDataSet: TFDQuery; const aObject: TLoja);
begin
  with aDataSet, aObject do
  begin
    ID       := StringToGUID(FieldByName('id_empresa').AsString);
    Nome     := FieldByName('nm_empresa').AsString;
    Fantasia := FieldByName('nm_fantasia').AsString;
    CpfCnpj  := FieldByName('nr_cpf_cnpj').AsString;
  end;
end;

procedure TLojaDao.Update;
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
      SQL.Add('Update ' + aDDL.getTableNameLoja + ' Set');
      SQL.Add('    nm_empresa   = :nm_empresa  ');
      SQL.Add('  , nm_fantasia  = :nm_fantasia ');
      SQL.Add('  , nr_cnpj_cpf  = :nr_cnpj_cpf ');
      SQL.Add('where id_empresa = :id_empresa  ');
      SQL.EndUpdate;

      ParamByName('id_empresa').AsString  := GUIDToString(aModel.ID);
      ParamByName('nm_empresa').AsString  := aModel.Nome;
      ParamByName('nm_fantasia').AsString := aModel.Fantasia;
      ParamByName('nr_cnpj_cpf').AsString := aModel.CpfCnpj;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
