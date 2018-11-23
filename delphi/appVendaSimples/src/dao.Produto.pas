unit dao.Produto;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Produto,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

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
      procedure AddLista; overload;
      procedure AddLista(aProduto : TProduto); overload;

      function Find(const aCodigo : Currency; const IsLoadModel : Boolean) : Boolean;
      function GetCount() : Integer;

      class function GetInstance : TProdutoDao;
  end;

implementation

{ TProdutoDao }

uses
  UDM;

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

function TProdutoDao.Find(const aCodigo: Currency; const IsLoadModel: Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    p.* ');
    aSQL.Add('from ' + aDDL.getTableNameProduto + ' p');
    aSQL.Add('where p.cd_produto = ' + CurrToStr(aCodigo));
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

function TProdutoDao.GetCount: Integer;
var
  aRetorno : Integer;
  aSQL : TStringList;
begin
  aRetorno := 0;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select ');
    aSQL.Add('  count(*) as qt_produtos');
    aSQL.Add('from ' + aDDL.getTableNameProduto);
    aSQL.EndUpdate;
    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;
      OpenOrExecute;

      aRetorno := FieldByName('qt_produtos').AsInteger;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
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
begin
  ;
end;

procedure TProdutoDao.Load(const aBusca: String);
var
  aSQL : TStringList;
  aProduto : TProduto;
  aFiltro  : String;
begin
  aSQL := TStringList.Create;
  try
    aFiltro := AnsiUpperCase(Trim(aBusca));

    aSQL.BeginUpdate;
    aSQL.Add('Select');
    aSQL.Add('    p.* ');
    aSQL.Add('from ' + aDDL.getTableNameProduto + ' p');

    if (StrToCurrDef(aFiltro, 0) > 0) then
      aSQL.Add('where p.cd_produto = ' + aFiltro)
    else
    if (Trim(aBusca) <> EmptyStr) then
    begin
      aFiltro := '%' + StringReplace(aFiltro, ' ', '%', [rfReplaceAll]) + '%';
      aSQL.Add('where c.ds_produto like ' + QuotedStr(aFiltro));
    end;

    aSQL.Add('order by');
    aSQL.Add('    p.ds_produto ');

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
            aProduto := TProduto.Create;
            SetValues(qrySQL, aProduto);

            AddLista(aProduto);
            qrySQL.Next;
          end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TProdutoDao.SetValues(const aDataSet: TFDQuery; const aObject: TProduto);
begin
  with aDataSet, aObject do
  begin
    ID     := StringToGUID(FieldByName('id_produto').AsString);
    Codigo := FieldByName('cd_produto').AsCurrency;

    Descricao := FieldByName('ds_produto').AsString;
    //Foto      := ?
    Valor     := FieldByName('vl_produto').AsCurrency;
    Ativo        := (AnsiUpperCase(FieldByName('sn_ativo').AsString) = 'S');
    Sincronizado := (AnsiUpperCase(FieldByName('sn_sincronizado').AsString) = 'S');

    if (Trim(FieldByName('cd_referencia').AsString) <> EmptyStr) then
      Referencia := StringToGUID(FieldByName('cd_referencia').AsString)
    else
      Referencia := GUID_NULL;
  end;
end;

procedure TProdutoDao.Update;
begin
  ;
end;

end.
