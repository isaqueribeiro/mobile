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
      class var aInstance : TLojaDao;
    private
      aDDL   : TScriptDDL;
      aModel : TLoja;
      aLista : TLojas;
      aOperacao : TTipoOperacaoDao;
      aEmpresasID : TStringList;
      constructor Create();
      destructor Destroy(); override;

      procedure SetValues(const aDataSet : TFDQuery; const aObject : TLoja);
      procedure ClearValues;
      procedure ClearLista;
    public
      property Model    : TLoja read aModel write aModel;
      property Lista    : TLojas read aLista write aLista;
      property Operacao : TTipoOperacaoDao read aOperacao;
      property EmpresasID : TStringList read aEmpresasID;

      procedure Load(const aBusca : String);
      procedure Limpar();
      procedure Insert();
      procedure Update();
      procedure Delete(); virtual; abstract;

      procedure AddLista; overload;
      procedure AddLista(aLoja : TLoja); overload;

      function Find(const aID : TGUID; const aCpfCnpj : String; const IsLoadModel : Boolean) : Boolean; overload;
      function Find(const aID : String; const IsLoadModel : Boolean) : Boolean; overload;
      function GetCount() : Integer;
      function PodeExcluir : Boolean;

      class function GetInstance : TLojaDao;
  end;

implementation

uses
  UDM;

{ TLojaDao }

procedure TLojaDao.AddLista(aLoja: TLoja);
var
  I : Integer;
begin
  I := High(aLista) + 2;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := aLOja;
end;

procedure TLojaDao.AddLista;
var
  I : Integer;
  o : TLoja;
begin
  I := High(aLista) + 2;
  o := TLoja.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

procedure TLojaDao.ClearLista;
begin
  SetLength(aLista, 0);
end;

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
  aEmpresasID := TStringList.Create;
  SetLength(aLista, 0);
end;

destructor TLojaDao.Destroy;
begin
  aModel.DisposeOf;
  aEmpresasID.DisposeOf;
  inherited Destroy;
end;

function TLojaDao.Find(const aID: String; const IsLoadModel: Boolean): Boolean;
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
      SQL.Add('  e.* ');
      SQL.Add('from ' + aDDL.getTableNameLoja + ' e');
      SQL.Add('where e.id_empresa = :id_empresa');
      SQL.EndUpdate;

      ParamByName('id_empresa').AsString := IfThen(aID = EmptyStr, GUID_NULL.ToString, aID);

      if OpenOrExecute then
      begin
        aEmpresasID.Clear;

        aRetorno := (RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(aQry, aModel)
        else
        if IsLoadModel then
          ClearValues;
      end;
      qrySQL.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TLojaDao.Find(const aID: TGUID; const aCpfCnpj: String; const IsLoadModel: Boolean): Boolean;
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
      SQL.Add('  e.* ');
      SQL.Add('from ' + aDDL.getTableNameLoja + ' e');

      if (aID <> GUID_NULL) then
        SQL.Add('where e.id_empresa = :id_empresa')
      else
      if (Trim(aCpfCnpj) <> EmptyStr) then
        SQL.Add('where e.nr_cnpj_cpf = :nr_cnpj_cpf');

      SQL.Add('order by');
      SQL.Add('  e.id_empresa DESC');
      SQL.EndUpdate;

      if (aID <> GUID_NULL) then
        ParamByName('id_empresa').AsString := GUIDToString(aID)
      else
      if (Trim(aCpfCnpj) <> EmptyStr) then
        ParamByName('nr_cnpj_cpf').AsString := Trim(aCpfCnpj);

      if OpenOrExecute then
      begin
        aEmpresasID.Clear;

        aRetorno := (RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(aQry, aModel)
        else
        if IsLoadModel then
          ClearValues;
      end;
      qrySQL.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TLojaDao.GetCount: Integer;
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
      SQL.Add('  count(*) as qt_lojas');
      SQL.Add('from ' + aDDL.getTableNameLoja);
      SQL.EndUpdate;

      OpenOrExecute;
      aRetorno := FieldByName('qt_lojas').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
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
      SQL.Add('  , nr_cpf_cnpj   ');
      SQL.Add(') values (');
      SQL.Add('    :id_empresa   ');
      SQL.Add('  , :nm_empresa   ');
      SQL.Add('  , :nm_fantasia  ');
      SQL.Add('  , :nr_cpf_cnpj  ');
      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      ParamByName('id_empresa').AsString  := GUIDToString(aModel.ID);
      ParamByName('nm_empresa').AsString  := aModel.Nome;
      ParamByName('nm_fantasia').AsString := aModel.Fantasia;
      ParamByName('nr_cpf_cnpj').AsString := aModel.CpfCnpj;

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
      SQL.Add('  e.id_empresa DESC');
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        ClearLista;
        aEmpresasID.Clear;

        if (RecordCount > 0) then
          while not Eof do
          begin
            aLoja := TLoja.Create;
            SetValues(aQry, aLoja);
            Model := aLoja;

            AddLista(aLoja);
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

function TLojaDao.PodeExcluir: Boolean;
var
  aRetorno : Boolean;
  aQry : TFDQuery;
begin
  aRetorno := True;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  count(id_loja) as qt_pedidos');
      SQL.Add('from ' + aDDL.getTableNamePedido);
      SQL.Add('where id_loja = :id_loja');
      SQL.EndUpdate;

      ParamByName('id_loja').AsString := GUIDToString(aModel.ID);
      OpenOrExecute;

      aRetorno := (FieldByName('qt_pedidos').AsInteger = 0);
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;

    Result := aRetorno;
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

    aEmpresasID.Add( FieldByName('id_empresa').AsString );
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
      SQL.Add('  , nr_cpf_cnpj  = :nr_cpf_cnpj ');
      SQL.Add('where id_empresa = :id_empresa  ');
      SQL.EndUpdate;

      ParamByName('id_empresa').AsString  := GUIDToString(aModel.ID);
      ParamByName('nm_empresa').AsString  := aModel.Nome;
      ParamByName('nm_fantasia').AsString := aModel.Fantasia;
      ParamByName('nr_cpf_cnpj').AsString := aModel.CpfCnpj;

      ExecSQL;
      aOperacao := TTipoOperacaoDao.toEditado;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
