unit Classes.ScriptDDL;

interface

uses
  System.SysUtils, System.Classes;

type
  TScriptDDL = class
  strict private
    class var _instance : TScriptDDL;
    const
      NUMBER_VERSION_DB  = 1;
      TABLE_CONFIGURACAO = 'app_configuracao';
      TABLE_VERSAO       = 'app_versao';
      TABLE_CATEGORIA    = 'tbl_categoria';
      TABLE_LANCAMENTO   = 'tbl_lancamento';
  private

  public
    class function getInstance() : TScriptDDL;

    function getTableNameConfiguracao : String;
    function getTableNameCategoria : String;
    function getTableNameLancamento : String;

    function getCreateTableCategoria : TStringList;
    function getCreateTableLancamento : TStringList;
  end;
implementation

{ TScriptDDL }

function TScriptDDL.getCreateTableCategoria: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_CATEGORIA + ' (');
    aSQL.Add('    cd_categoria INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT');
    aSQL.Add('  , ds_categoria VARCHAR (50)');
    aSQL.Add('  , ic_categoria BLOB');
    aSQL.Add('  , ix_categoria INTEGER');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableLancamento: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_LANCAMENTO + ' (');
    aSQL.Add('    id_lancamento VARCHAR (38) NOT NULL PRIMARY KEY ');
    aSQL.Add('  , cd_lancamento INTEGER NOT NULL AUTOINCREMENT');
    aSQL.Add('  , tp_lancamento CHAR(1) NOT NULL ');
    aSQL.Add('  , ds_lancamento VARCHAR (100)');
    aSQL.Add('  , dt_lancamento DATE');
    aSQL.Add('  , cd_categoria  INTEGER');
    aSQL.Add('  , vl_lancamento NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

class function TScriptDDL.getInstance: TScriptDDL;
begin
  if not Assigned(_instance) then
    _instance := TScriptDDL.Create;

  Result := _instance;
end;

function TScriptDDL.getTableNameCategoria: String;
begin
  Result := TABLE_CATEGORIA;
end;

function TScriptDDL.getTableNameConfiguracao: String;
begin
  Result := TABLE_CONFIGURACAO;
end;

function TScriptDDL.getTableNameLancamento: String;
begin
  Result := TABLE_LANCAMENTO;
end;

end.
