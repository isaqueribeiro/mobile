unit classes.ScriptDDL;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TScriptDDL = class(TObject)
    strict private
      class var aInstance : TScriptDDL;
      const
        NUMBER_VERSION_DB = 1;
        TABLE_VERSAO      = 'app_versao';
        TABLE_CONFIG      = 'app_configuracao';
        TABLE_NOTIFICACAO = 'app_notificacao';
        TABLE_USUARIO     = 'tbl_usuario';
        TABLE_LOJA        = 'tbl_empresa';
        TABLE_PEDIDO      = 'tbl_pedido';
        TABLE_PEDIDO_ITEM = 'tbl_pedido_item';
        TABLE_CLIENTE     = 'tbl_cliente';
        TABLE_PRODUTO     = 'tbl_produto';
    public
      class function GetInstance : TScriptDDL;

      function getCreateTableVersao : TStringList;
      function getCreateTableConfiguracao : TStringList;
      function getCreateTableNotificacao : TStringList;
      function getCreateTableUsuario : TStringList;
      function getCreateTableLoja : TStringList;
      function getCreateTablePedido : TStringList;
      function getCreateTablePedidoItem : TStringList;
      function getCreateTableCliente : TStringList;
      function getCreateTableProduto : TStringList;

      function getUpgradeTableVersao : TStringList;

      function getTableNameVersao : String;
      function getTableNameConfiguracao : String;
      function getTableNameNotificacao : String;
      function getTableNameUsuario : String;
      function getTableNameLoja : String;
      function getTableNamePedido : String;
      function getTableNamePedidoItem : String;
      function getTableNameCliente : String;
      function getTableNameProduto : String;
  end;

implementation

{ TScriptDDL }

uses
  UConstantes;

function TScriptDDL.getCreateTableCliente: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_CLIENTE + ' (');
    aSQL.Add('      id_cliente       VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_cliente       BIGINT  (10) UNIQUE ON CONFLICT ROLLBACK');
    aSQL.Add('    , nm_cliente       VARCHAR (150)');
    aSQL.Add('    , tp_cliente       CHAR(1) DEFAULT (' + QuotedStr('F') + ') NOT NULL'); // F - Pessoa Física, J - Pessoa Jurídica
    aSQL.Add('    , nr_cpf_cnpj      VARCHAR (20)');
    aSQL.Add('    , ds_contato       VARCHAR (100)');
    aSQL.Add('    , nr_telefone      VARCHAR (20)');
    aSQL.Add('    , nr_celular       VARCHAR (20)');
    aSQL.Add('    , ds_email         VARCHAR (150)');
    aSQL.Add('    , ds_endereco      VARCHAR (500)');
    aSQL.Add('    , ds_observacao    VARCHAR (500)');
    aSQL.Add('    , sn_ativo         CHAR(1) DEFAULT (' + QuotedStr(FLAG_SIM) + ') NOT NULL');
    aSQL.Add('    , sn_sincronizado  CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL');
    aSQL.Add('    , cd_referencia    VARCHAR (38)'); // Referência do Cliente no Servidor Web (ID)
    aSQL.Add('    , dt_ultima_compra DATE');
    aSQL.Add('    , vl_ultima_compra NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableConfiguracao: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_CONFIG + ' (');
    aSQL.Add('      ky_campo VARCHAR (50) NOT NULL PRIMARY KEY');
    aSQL.Add('    , vl_campo VARCHAR (250)');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableLoja: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_LOJA + ' (');
    aSQL.Add('      id_empresa    VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , nm_empresa    VARCHAR (250)');
    aSQL.Add('    , nm_fantasia   VARCHAR (150)');
    aSQL.Add('    , nr_cpf_cnpj   VARCHAR (25)');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableNotificacao: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_NOTIFICACAO + ' (');
    aSQL.Add('      id_notificacao VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_notificacao BIGINT  (10) UNIQUE ON CONFLICT ROLLBACK');
    aSQL.Add('    , dt_notificacao DATE  NOT NULL');
    aSQL.Add('    , ds_titulo      VARCHAR (150)');
    aSQL.Add('    , ds_mensagem    VARCHAR (500)');
    aSQL.Add('    , sn_lida        CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL');
    aSQL.Add('    , sn_destacar    CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTablePedido: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_PEDIDO + ' (');
    aSQL.Add('      id_pedido       VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_pedido       BIGINT  (10) UNIQUE ON CONFLICT ROLLBACK');
    aSQL.Add('    , nr_pedido       VARCHAR (20)');
    aSQL.Add('    , tp_pedido       CHAR(1) DEFAULT (' + QuotedStr('O') + ') NOT NULL'); // O - Orçamento, P - Pedido
    aSQL.Add('    , id_cliente      VARCHAR (38) NOT NULL');
    aSQL.Add('    , ds_contato      VARCHAR (100)');
    aSQL.Add('    , ds_observacao   VARCHAR (500)');
    aSQL.Add('    , dt_pedido       DATE');
    aSQL.Add('    , vl_total        NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_desconto     NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_pedido       NUMERIC (15,2) DEFAULT (0)'); //  (vl_pedido = vl_total -  vl_desconto)
    aSQL.Add('    , sn_ativo        CHAR(1) DEFAULT (' + QuotedStr(FLAG_SIM) + ') NOT NULL');
    aSQL.Add('    , sn_faturado     CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL'); // Pedido Faturado na Loja ?
    aSQL.Add('    , sn_entregue     CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL'); // Pedido Entregue ao Cliente ?
    aSQL.Add('    , sn_sincronizado CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL');
    aSQL.Add('    , cd_referencia   VARCHAR (38)'); // Referência do Pedido no Servidor Web (ID)
    aSQL.Add('    , id_loja         VARCHAR (38)');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTablePedidoItem: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_PEDIDO_ITEM + ' (');
    aSQL.Add('      id_item         VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_item         INTEGER NOT NULL');
    aSQL.Add('    , id_pedido       VARCHAR (38) NOT NULL');
    aSQL.Add('    , id_produto      VARCHAR (38) NOT NULL');
    aSQL.Add('    , qt_item         NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_item         NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_total        NUMERIC (15,2) DEFAULT (0)'); // (vl_total   = qt_item * vl_item)
    aSQL.Add('    , vl_desconto     NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_liquido      NUMERIC (15,2) DEFAULT (0)'); // (vl_liquido = vl_total - vl_desconto)
    aSQL.Add('    , ds_observacao   VARCHAR (500)');
    aSQL.Add('    , cd_referencia   VARCHAR (38)'); // Referência do Item do Pedido no Servidor Web (ID)
    aSQL.Add('    , FOREIGN KEY (   ');
    aSQL.Add('        id_pedido     ');
    aSQL.Add('      )               ');
    aSQL.Add('      REFERENCES ' + TABLE_PEDIDO + ' (id_pedido) ON DELETE CASCADE ');
    aSQL.Add('    , FOREIGN KEY (   ');
    aSQL.Add('        id_produto    ');
    aSQL.Add('      )               ');
    aSQL.Add('      REFERENCES ' + TABLE_PRODUTO + ' (id_produto) ');
    aSQL.Add(');');

    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_PEDIDO_ITEM + '_temp (');
    aSQL.Add('      id_item         VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_item         INTEGER NOT NULL');
    aSQL.Add('    , id_pedido       VARCHAR (38)');
    aSQL.Add('    , id_produto      VARCHAR (38) NOT NULL');
    aSQL.Add('    , qt_item         NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_item         NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_total        NUMERIC (15,2) DEFAULT (0)'); // (vl_total   = qt_item * vl_item)
    aSQL.Add('    , vl_desconto     NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , vl_liquido      NUMERIC (15,2) DEFAULT (0)'); // (vl_liquido = vl_total - vl_desconto)
    aSQL.Add('    , ds_observacao   VARCHAR (500)');
    aSQL.Add('    , cd_referencia   VARCHAR (38)'); // Referência do Item do Pedido no Servidor Web (ID)
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableProduto: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_PRODUTO + ' (');
    aSQL.Add('      id_produto      VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_produto      BIGINT  (10) UNIQUE ON CONFLICT ROLLBACK');
    aSQL.Add('    , br_produto      VARCHAR (15)');  // Código de Barras (ean13)
    aSQL.Add('    , ds_produto      VARCHAR (250)');
    aSQL.Add('    , ft_produto      IMAGE');
    aSQL.Add('    , vl_produto      NUMERIC (15,2) DEFAULT (0)');
    aSQL.Add('    , sn_ativo        CHAR(1) DEFAULT (' + QuotedStr(FLAG_SIM) + ') NOT NULL');
    aSQL.Add('    , sn_sincronizado CHAR(1) DEFAULT (' + QuotedStr(FLAG_NAO) + ') NOT NULL');
    aSQL.Add('    , cd_referencia   VARCHAR (38)'); // Referência do Produto no Servidor Web (ID)
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableUsuario: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_USUARIO + ' (');
    aSQL.Add('      id_usuario     VARCHAR (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , nm_usuario     VARCHAR (100)');
    aSQL.Add('    , ds_email       VARCHAR (150)');
    aSQL.Add('    , ds_senha       VARCHAR (100)');
    aSQL.Add('    , nr_celular     VARCHAR (50)');
    aSQL.Add('    , nr_cpf         VARCHAR (15)');
    aSQL.Add('    , tk_dispositivo VARCHAR (250)');
    aSQL.Add('    , sn_ativo       CHAR (1) DEFAULT (' + QuotedStr(FLAG_SIM) + ') NOT NULL');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

function TScriptDDL.getCreateTableVersao: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_VERSAO + ' (');
    aSQL.Add('      cd_versao INTEGER NOT NULL PRIMARY KEY');
    aSQL.Add('    , ds_versao VARCHAR (30)');
    aSQL.Add('    , dt_versao DATE');
    aSQL.Add(');');
    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

class function TScriptDDL.GetInstance: TScriptDDL;
begin
  if not Assigned(aInstance) then
    aInstance := TScriptDDL.Create;

  Result := aInstance;
end;

function TScriptDDL.getTableNameCliente: String;
begin
  Result := TABLE_CLIENTE;
end;

function TScriptDDL.getTableNameConfiguracao: String;
begin
  Result := TABLE_CONFIG;
end;

function TScriptDDL.getTableNameLoja: String;
begin
  Result := TABLE_LOJA;
end;

function TScriptDDL.getTableNameNotificacao: String;
begin
  Result := TABLE_NOTIFICACAO;
end;

function TScriptDDL.getTableNamePedido: String;
begin
  Result := TABLE_PEDIDO;
end;

function TScriptDDL.getTableNamePedidoItem: String;
begin
  Result := TABLE_PEDIDO_ITEM;
end;

function TScriptDDL.getTableNameProduto: String;
begin
  Result := TABLE_PRODUTO;
end;

function TScriptDDL.getTableNameUsuario: String;
begin
  Result := TABLE_USUARIO;
end;

function TScriptDDL.getTableNameVersao: String;
begin
  Result := TABLE_VERSAO;
end;

function TScriptDDL.getUpgradeTableVersao: TStringList;
var
  aSQL : TStringList;
begin
  // Modelo de script para atualização de estruturas de tabelas no SQLite
  aSQL := TStringList.Create;
  try
    aSQL := TStringList.Create;
    aSQL.Clear;
    aSQL.BeginUpdate;

    // 1. Desativar chaves estrangeiras
    aSQL.Add('PRAGMA foreign_keys = 0;');
    // 2. Criar tabela temporária com os dados existentes
    aSQL.Add('CREATE TABLE sqlitestudio_temp_' + getTableNameVersao + ' AS SELECT * FROM ' + getTableNameVersao + ';');
    // 3. Deletar tabela atual da base
    aSQL.Add('DROP TABLE ' + getTableNameVersao + ';');
    // 4. Criar tabela como nova estrutura
    aSQL.AddStrings( getCreateTableVersao );
    // 5. Inserir dados na tabela temporária na nova tabela
    aSQL.Add('INSERT INTO ' + getTableNameVersao + ' (');
    aSQL.Add('    cd_versao ');
    aSQL.Add('  , ds_versao ');
    aSQL.Add('  , dt_versao ');
    aSQL.Add(')                  ');
    aSQL.Add('SELECT             ');
    aSQL.Add('    cd_versao ');
    aSQL.Add('  , ds_versao ');
    aSQL.Add('  , dt_versao ');
    aSQL.Add('FROM sqlitestudio_temp_' + getTableNameVersao + ';');
    // 6. Deletar tabela temporári da base
    aSQL.Add('DROP TABLE sqlitestudio_temp_' + getTableNameVersao + ';');
    // 7. Reativar as chaves estrangeiras
    aSQL.Add('PRAGMA foreign_keys = 1;');

    aSQL.EndUpdate;
  finally
    Result := aSQL;
  end;
end;

end.
