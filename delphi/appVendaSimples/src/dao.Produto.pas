unit dao.Produto;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Produto,

  System.StrUtils, System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TProdutoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TProduto;
      aLista : TProdutos;
      constructor Create();
      procedure SetValues(const aDataSet : TFDQuery; const aObject : TProduto);
      procedure ClearLista;
      class var aInstance : TProdutoDao;
    public
      property Model : TProduto read aModel write aModel;
      property Lista : TProdutos read aLista write aLista;

      procedure Load(const aBusca : String);
      procedure Insert();
      procedure Update();
      procedure Delete();
      procedure AddLista; overload;
      procedure AddLista(aProduto : TProduto); overload;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;
      function GetCountSincronizar() : Integer;
      function PodeExcluir : Boolean;

      class function GetInstance : TProdutoDao;
  end;

implementation

{ TProdutoDao }

uses
  UDM, app.Funcoes;

procedure TProdutoDao.AddLista;
var
  I : Integer;
  o : TProduto;
begin
  I := High(aLista) + 2;
  o := TProduto.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

procedure TProdutoDao.AddLista(aProduto: TProduto);
var
  I : Integer;
begin
  I := High(aLista) + 2;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := aProduto;
end;

procedure TProdutoDao.ClearLista;
begin
  SetLength(aLista, 0);
end;

constructor TProdutoDao.Create;
begin
  inherited Create;
  aDDL   := TScriptDDL.GetInstance;
  aModel := TProduto.Create;
  SetLength(aLista, 0);
end;

procedure TProdutoDao.Delete;
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
      SQL.Add('Delete from ' + aDDL.getTableNameProduto);
      SQL.Add('where id_produto    = :id_produto      ');
      SQL.EndUpdate;

      ParamByName('id_produto').AsString      := GUIDToString(aModel.ID);

      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TProdutoDao.Find(const aCodigo: Currency; const IsLoadModel: Boolean): Boolean;
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
      SQL.Add('    p.* ');
      SQL.Add('from ' + aDDL.getTableNameProduto + ' p');
      SQL.Add('where p.cd_produto = ' + CurrToStr(aCodigo));
      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        aRetorno := (RecordCount > 0);
        if aRetorno and IsLoadModel then
          SetValues(aQry, aModel);
      end;
      qrySQL.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TProdutoDao.GetCount: Integer;
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
      SQL.Add('  count(*) as qt_produtos');
      SQL.Add('from ' + aDDL.getTableNameProduto);
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_produtos').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TProdutoDao.GetCountSincronizar: Integer;
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
      SQL.Add('  count(*) as qt_produtos');
      SQL.Add('from ' + aDDL.getTableNameProduto);
      SQL.Add('where (sn_sincronizado = ' + QuotedStr(FLAG_NAO) +')');
      SQL.EndUpdate;

      OpenOrExecute;

      aRetorno := FieldByName('qt_produtos').AsInteger;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

class function TProdutoDao.GetInstance: TProdutoDao;
begin
  if not Assigned(aInstance) then
    aInstance := TProdutoDao.Create();

  Result := aInstance;
end;

procedure TProdutoDao.Insert;
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
      SQL.Add('Insert Into ' + aDDL.getTableNameProduto + '(');
      SQL.Add('    id_produto      ');
      SQL.Add('  , cd_produto      ');
      SQL.Add('  , br_produto      ');
      SQL.Add('  , ds_produto      ');
      SQL.Add('  , vl_produto      ');
      SQL.Add('  , sn_ativo        ');
      SQL.Add('  , sn_sincronizado ');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , cd_referencia   ');

      if (aModel.Foto <> nil) then
        SQL.Add('  , ft_produto    ');

      SQL.Add(') values (');
      SQL.Add('    :id_produto     ');
      SQL.Add('  , :cd_produto     ');
      SQL.Add('  , :br_produto     ');
      SQL.Add('  , :ds_produto     ');
      SQL.Add('  , :vl_produto     ');
      SQL.Add('  , :sn_ativo       ');
      SQL.Add('  , :sn_sincronizado');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , :cd_referencia  ');

      if (aModel.Foto <> nil) then
        SQL.Add('  , :ft_produto   ');

      SQL.Add(')');
      SQL.EndUpdate;

      if (aModel.ID = GUID_NULL) then
        aModel.NewID;

      if (aModel.Codigo = 0) then
        aModel.Codigo := GetNewID(aDDL.getTableNameProduto, 'cd_produto', EmptyStr);

      ParamByName('id_produto').AsString      := GUIDToString(aModel.ID);
      ParamByName('cd_produto').AsCurrency    := aModel.Codigo;
      ParamByName('br_produto').AsString      := aModel.CodigoEan;
      ParamByName('ds_produto').AsString      := aModel.Descricao;
      ParamByName('vl_produto').AsCurrency    := aModel.Valor;
      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := IfThen(aModel.Sincronizado, FLAG_SIM, FLAG_NAO);

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      if (aModel.Foto <> nil) then
        ParamByName('ft_produto').LoadFromStream(aModel.Foto, TFieldType.ftBlob);

      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

procedure TProdutoDao.Load(const aBusca: String);
var
  aQry : TFDQuery;
  aProduto : TProduto;
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
      SQL.Add('    p.* ');
      SQL.Add('from ' + aDDL.getTableNameProduto + ' p');

      if (StrToCurrDef(aFiltro, 0) > 0) then
        SQL.Add('where p.cd_produto = ' + aFiltro)
      else
      if StrIsGUID(aFiltro) then
        SQL.Add('where p.id_produto = ' + QuotedStr(aFiltro))
      else
      if (Trim(aBusca) <> EmptyStr) then
      begin
        aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
        SQL.Add('where p.ds_produto like ' + QuotedStr(aFiltro));
      end;

      SQL.Add('order by');
      SQL.Add('    p.ds_produto ');

      SQL.EndUpdate;

      if OpenOrExecute then
      begin
        ClearLista;
        if (RecordCount > 0) then
          while not Eof do
          begin
            aProduto := TProduto.Create;
            SetValues(aQry, aProduto);

            AddLista(aProduto);
            Next;
          end;
      end;
      Close;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

function TProdutoDao.PodeExcluir: Boolean;
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
      SQL.Add('  count(id_produto) as qt_produtos');
      SQL.Add('from ' + aDDL.getTableNamePedidoItem);
      SQL.Add('where id_produto = :id_produto');
      SQL.EndUpdate;

      ParamByName('id_produto').AsString := GUIDToString(aModel.ID);
      OpenOrExecute;

      aRetorno := (FieldByName('qt_produtos').AsInteger = 0);

      aQry.Close;
    end;
  finally
    aQry.DisposeOf;

    Result := aRetorno;
  end;
end;

procedure TProdutoDao.SetValues(const aDataSet: TFDQuery; const aObject: TProduto);
begin
  with aDataSet, aObject do
  begin
    ID     := StringToGUID(FieldByName('id_produto').AsString);
    Codigo := FieldByName('cd_produto').AsCurrency;

    CodigoEan := FieldByName('br_produto').AsString;
    Descricao := FieldByName('ds_produto').AsString;
    Valor     := FieldByName('vl_produto').AsCurrency;
    Ativo        := (AnsiUpperCase(FieldByName('sn_ativo').AsString) = 'S');
    Sincronizado := (AnsiUpperCase(FieldByName('sn_sincronizado').AsString) = 'S');

    if (Trim(FieldByName('cd_referencia').AsString) <> EmptyStr) then
      Referencia := StringToGUID(FieldByName('cd_referencia').AsString)
    else
      Referencia := GUID_NULL;

    if (not FieldByName('ft_produto').IsNull) then
    begin
      Foto := TStream.Create;
      Foto := CreateBlobStream(FieldByName('ft_produto'), TBlobStreamMode.bmRead);
    end
    else
      Foto := nil;
  end;
end;

procedure TProdutoDao.Update;
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
      SQL.Add('Update ' + aDDL.getTableNameProduto + ' Set');
      SQL.Add('    cd_produto      = :cd_produto ');
      SQL.Add('  , br_produto      = :br_produto ');
      SQL.Add('  , ds_produto      = :ds_produto ');
      SQL.Add('  , vl_produto      = :vl_produto ');
      SQL.Add('  , sn_ativo        = :sn_ativo   ');
      SQL.Add('  , sn_sincronizado = :sn_sincronizado ');

      if (aModel.Referencia <> GUID_NULL) then
        SQL.Add('  , cd_referencia   = :cd_referencia   ');

      if (aModel.Foto <> nil) then
        SQL.Add('  , ft_produto    = :ft_produto ');

      SQL.Add('where id_produto    = :id_produto      ');
      SQL.EndUpdate;

      ParamByName('id_produto').AsString      := GUIDToString(aModel.ID);
      ParamByName('cd_produto').AsCurrency    := aModel.Codigo;
      ParamByName('br_produto').AsString      := aModel.CodigoEan;
      ParamByName('ds_produto').AsString      := aModel.Descricao;
      ParamByName('vl_produto').AsCurrency    := aModel.Valor;
      ParamByName('sn_ativo').AsString        := IfThen(aModel.Ativo, FLAG_SIM, FLAG_NAO);
      ParamByName('sn_sincronizado').AsString := IfThen(aModel.Sincronizado, FLAG_SIM, FLAG_NAO);

      if (aModel.Referencia <> GUID_NULL) then
        ParamByName('cd_referencia').AsString := GUIDToString(aModel.Referencia);

      if (aModel.Foto <> nil) then
        ParamByName('ft_produto').LoadFromStream(aModel.Foto, TFieldType.ftBlob);

      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
