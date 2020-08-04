USE [venda_simples_server]
GO

CREATE OR ALTER VIEW dbo.vw_guid_id
AS
  SELECT '{' + CAST(NEWID() AS varchar(38)) + '}' AS guid_id
GO

IF OBJECT_ID (N'dbo.ufnGetGuidID', N'FN') IS NOT NULL  
    DROP FUNCTION dbo.ufnGetGuidID;  
GO  
CREATE OR ALTER FUNCTION dbo.ufnGetGuidID()
RETURNS varchar(38)
AS   
BEGIN  
  DECLARE @ret varchar(38);  
  SELECT @ret = guid_id from dbo.vw_guid_id;
  RETURN @ret;  
END;
GO

CREATE OR ALTER PROCEDURE dbo.spDocumentarCampo
	@source_table	nvarchar (386)
  , @source_field	nvarchar (386)
  , @description	nvarchar (386)
AS
BEGIN
  Declare @existe nvarchar (386);

  if ((@source_table <> '') and (@source_field <> '') and (@description <> ''))
  Begin
	Select 
	  @existe = x.name
	from fn_listextendedproperty('MS_Description', 'SCHEMA', 'dbo', 'TABLE', @source_table, 'COLUMN', @source_field) x;
	
	If (coalesce(@existe, '') <> '') 
	Begin
	  EXEC sys.sp_dropextendedproperty 
		  @name=N'MS_Description'
		, @level0type=N'SCHEMA'
		, @level0name=N'dbo'
		, @level1type=N'TABLE'
		, @level1name=@source_table
		, @level2type=N'COLUMN'
		, @level2name=@source_field;
    End;

	EXEC sys.sp_addextendedproperty 
		  @name=N'MS_Description'
		, @value=@description
		, @level0type=N'SCHEMA'
		, @level0name=N'dbo'
		, @level1type=N'TABLE'
		, @level1name=@source_table
		, @level2type=N'COLUMN'
		, @level2name=@source_field
  End
END

/*Excluir Tabelas*/
/*

IF OBJECT_ID (N'dbo.tb_pedido_item') IS NOT NULL  
    DROP TABLE dbo.tb_pedido_item;  
GO
IF OBJECT_ID (N'dbo.tb_pedido') IS NOT NULL  
    DROP TABLE dbo.tb_pedido;  
GO
IF OBJECT_ID (N'dbo.tb_produto_empresa') IS NOT NULL  
    DROP TABLE dbo.tb_produto_empresa;  
GO
IF OBJECT_ID (N'dbo.tb_produto') IS NOT NULL  
    DROP TABLE dbo.tb_produto;  
GO
IF OBJECT_ID (N'dbo.tb_cliente_empresa') IS NOT NULL  
	DROP TABLE dbo.tb_cliente_empresa;  
GO
IF OBJECT_ID (N'dbo.tb_cliente') IS NOT NULL  
    DROP TABLE dbo.tb_cliente;  
GO
IF OBJECT_ID (N'dbo.tb_notificacao') IS NOT NULL  
	DROP TABLE dbo.tb_notificacao;  
GO
IF OBJECT_ID (N'dbo.sys_usuario_empresa') IS NOT NULL  
	DROP TABLE dbo.sys_usuario_empresa;  
GO
IF OBJECT_ID (N'dbo.sys_usuario') IS NOT NULL  
	DROP TABLE dbo.sys_usuario;  
GO
IF OBJECT_ID (N'dbo.sys_empresa') IS NOT NULL  
    DROP TABLE dbo.sys_empresa;  
GO

*/

/*Criar Tabelas*/

IF OBJECT_ID (N'dbo.sys_empresa') IS NULL
BEGIN
	CREATE TABLE dbo.sys_empresa (
		id_empresa	VARCHAR(38) NOT NULL PRIMARY KEY 
	  , cd_empresa	INT IDENTITY(1,1) NOT NULL UNIQUE
	  , nm_empresa	VARCHAR(250)
	  , nm_fantasia	VARCHAR(150)
	  , nr_cnpj_cpf	VARCHAR(25) UNIQUE
	);

	CREATE TABLE dbo.sys_empresa_sequencia (
	    id_empresa	VARCHAR(38) NOT NULL PRIMARY KEY
	  , nr_pedido	BIGINT NOT NULL DEFAULT 0
	);

	ALTER TABLE dbo.sys_empresa_sequencia ADD FOREIGN KEY (id_empresa)
		REFERENCES dbo.sys_empresa (id_empresa)     
		ON DELETE CASCADE    
		ON UPDATE CASCADE;
END
GO

IF OBJECT_ID (N'dbo.sys_usuario') IS NULL
BEGIN
	CREATE TABLE dbo.sys_usuario (
		id_usuario		VARCHAR(38) PRIMARY KEY 
	  , cd_usuario		BIGINT IDENTITY(1,1) NOT NULL UNIQUE
	  , nm_usuario		VARCHAR(150)
	  , ds_email		VARCHAR(150) UNIQUE NOT NULL
	  , ds_senha		VARCHAR(40)
	  , id_token		VARCHAR(250)
	  , tp_plataforma	SMALLINT DEFAULT 0 NOT NULL CHECK (tp_plataforma between 0 and 3) 
	);

	Execute dbo.spDocumentarCampo N'sys_usuario', N'id_token',		N'TokenID do Dispositivo';
	Execute dbo.spDocumentarCampo N'sys_usuario', N'tp_plataforma',	N'Plataforma:
	0 - A Definir
	1 - Android
	2 - iSO
	3 - Windows';
END
GO

CREATE TABLE dbo.sys_usuario_empresa (
    id_usuario		VARCHAR(38) NOT NULL
  , id_empresa		VARCHAR(38) NOT NULL
  , sn_ativo		SMALLINT DEFAULT 0 NOT NULL
)
GO

ALTER TABLE dbo.sys_usuario_empresa ADD PRIMARY KEY (id_usuario, id_empresa)
GO

ALTER TABLE dbo.sys_usuario_empresa ADD FOREIGN KEY (id_usuario)
	REFERENCES dbo.sys_usuario (id_usuario)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO
ALTER TABLE dbo.sys_usuario_empresa ADD FOREIGN KEY (id_empresa)
	REFERENCES dbo.sys_empresa (id_empresa)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO

CREATE TABLE dbo.tb_notificacao (
    id_notificacao	VARCHAR(38) PRIMARY KEY
  , id_empresa		VARCHAR(38) NOT NULL
  , id_usuario		VARCHAR(38) NOT NULL
  , cd_notificacao	BIGINT IDENTITY(1,1)
  , dt_notificacao	DATETIME
  , ds_notificacao	VARCHAR(100)
  , tx_notificacao	VARCHAR(500)
  , sn_lida			SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_lida = 0) or (sn_lida = 1))
  , sn_destacada	SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_destacada = 0) or (sn_destacada = 1))
)
GO

ALTER TABLE dbo.tb_notificacao ADD FOREIGN KEY (id_empresa)
	REFERENCES dbo.sys_empresa (id_empresa)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO
ALTER TABLE dbo.tb_notificacao ADD FOREIGN KEY (id_usuario)
	REFERENCES dbo.sys_usuario (id_usuario)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO

IF OBJECT_ID (N'dbo.tb_produto') IS NULL
BEGIN
	CREATE TABLE dbo.tb_produto (
		id_produto		VARCHAR(38) PRIMARY KEY 
	  , cd_produto		INT IDENTITY(1,1) NOT NULL UNIQUE
	  , ds_produto		VARCHAR(200)
	  , vl_produto		NUMERIC(18,2)
	  , br_produto		VARCHAR(38) 
	  , dt_ult_edicao	DATETIME
	)

	Execute dbo.spDocumentarCampo N'tb_produto', N'id_produto',	N'ID';
	Execute dbo.spDocumentarCampo N'tb_produto', N'id_produto',	N'Código';
	Execute dbo.spDocumentarCampo N'tb_produto', N'id_produto',	N'Descrição';
	Execute dbo.spDocumentarCampo N'tb_produto', N'id_produto',	N'Valor (R$)';
	Execute dbo.spDocumentarCampo N'tb_produto', N'br_produto',	N'Código EAN';

	-- ALTER TABLE dbo.tb_produto ADD br_produto VARCHAR(38);
	-- ALTER TABLE dbo.tb_produto ADD dt_ult_edicao	DATETIME;
END
GO

IF OBJECT_ID (N'dbo.tb_produto_empresa') IS NULL
BEGIN
	CREATE TABLE dbo.tb_produto_empresa (
		id_produto		VARCHAR(38) NOT NULL
	  , id_empresa		VARCHAR(38) NOT NULL
	  , ft_produto		VARCHAR(MAX)
	  , vl_produto		NUMERIC(18,2)
	  , sn_ativo		SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_ativo = 0) or (sn_ativo = 1))
	);

	ALTER TABLE dbo.tb_produto_empresa ADD 
	  vl_produto NUMERIC(18,2);
  
	ALTER TABLE dbo.tb_produto_empresa ADD PRIMARY KEY (id_produto, id_empresa);

	ALTER TABLE dbo.tb_produto_empresa ADD FOREIGN KEY (id_produto)
		REFERENCES dbo.tb_produto (id_produto)     
		ON DELETE CASCADE    
		ON UPDATE CASCADE;

	ALTER TABLE dbo.tb_produto_empresa ADD FOREIGN KEY (id_empresa)
		REFERENCES dbo.sys_empresa (id_empresa)     
		ON DELETE CASCADE    
		ON UPDATE CASCADE;

	-- ALTER TABLE dbo.tb_produto_empresa REMOVE br_produto;
END
GO

IF OBJECT_ID (N'dbo.tb_produto_usuario') IS NULL
BEGIN
	CREATE TABLE dbo.tb_produto_usuario (
		id_produto	VARCHAR(38) NOT NULL
	  , id_usuario	VARCHAR(38) NOT NULL
	  , ft_produto	VARCHAR(MAX)
	  , vl_produto	NUMERIC(18,2)
	  , sn_ativo	SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_ativo = 0) or (sn_ativo = 1))
	);

	ALTER TABLE dbo.tb_produto_usuario ADD PRIMARY KEY (id_produto, id_usuario);

	ALTER TABLE dbo.tb_produto_usuario ADD FOREIGN KEY (id_produto)
		REFERENCES dbo.tb_produto (id_produto)     
		ON DELETE CASCADE    
		ON UPDATE CASCADE;

	ALTER TABLE dbo.tb_produto_usuario ADD FOREIGN KEY (id_usuario)
		REFERENCES dbo.sys_usuario (id_usuario)     
		ON DELETE CASCADE    
		ON UPDATE CASCADE;
END
GO

IF OBJECT_ID (N'dbo.tb_cliente') IS NULL
BEGIN
	CREATE TABLE dbo.tb_cliente (
		id_cliente		VARCHAR(38) PRIMARY KEY 
	  , cd_ciente		INT IDENTITY(1,1) NOT NULL UNIQUE
	  , nm_cliente		VARCHAR(250)
	  , nr_cnpj_cpf		VARCHAR(25) NOT NULL
	  , nm_contato		VARCHAR(50)
	  , nr_telefone		VARCHAR(25)
	  , nr_celular		VARCHAR(25)
	  , ds_email		VARCHAR(150)
	  , ds_endereco		VARCHAR(500)
	  , ds_observacao	VARCHAR(500)
	  , sn_ativo		SMALLINT DEFAULT 1 NOT NULL
	  , dt_ult_compra	DATETIME
	  , vl_ult_compra	NUMERIC(18,2)
	  , dt_ult_edicao	DATETIME
	);

	Execute dbo.spDocumentarCampo N'tb_cliente', N'id_cliente',		N'ID (GUID)';
	Execute dbo.spDocumentarCampo N'tb_cliente', N'cd_ciente',		N'Código';
	Execute dbo.spDocumentarCampo N'tb_cliente', N'nm_cliente',		N'Nome / Razão Social';
	Execute dbo.spDocumentarCampo N'tb_cliente', N'nr_cnpj_cpf',	N'CPF / CNPJ';
	Execute dbo.spDocumentarCampo N'tb_cliente', N'sn_ativo',		N'Ativo:
	0 - Não
	1 - Sim';

	/*
	ALTER TABLE dbo.tb_cliente
	  ADD nm_contato VARCHAR(50);
	GO

	ALTER TABLE dbo.tb_cliente
	  ADD nr_celular VARCHAR(25);
	GO

	ALTER TABLE dbo.tb_cliente
	  ADD sn_ativo SMALLINT Default 1 NOT NULL;
	GO

	ALTER TABLE dbo.tb_cliente
	  ADD dt_ult_edicao	DATETIME;
	GO
	*/

	CREATE TABLE dbo.tb_cliente_empresa (
		id_cliente		VARCHAR(38) NOT NULL
	  , id_empresa		VARCHAR(38) NOT NULL
	);
END
GO

ALTER TABLE dbo.tb_cliente_empresa ADD PRIMARY KEY (id_cliente, id_empresa)
GO

ALTER TABLE dbo.tb_cliente_empresa ADD FOREIGN KEY (id_cliente)
	REFERENCES dbo.tb_cliente (id_cliente)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO
ALTER TABLE dbo.tb_cliente_empresa ADD FOREIGN KEY (id_empresa)
	REFERENCES dbo.sys_empresa (id_empresa)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO

CREATE TABLE dbo.tb_cliente_usuario (
    id_cliente	VARCHAR(38) NOT NULL
  , id_usuario	VARCHAR(38) NOT NULL
)
GO

ALTER TABLE dbo.tb_cliente_usuario ADD PRIMARY KEY (id_cliente, id_usuario)
GO

ALTER TABLE dbo.tb_cliente_usuario ADD FOREIGN KEY (id_cliente)
	REFERENCES dbo.tb_cliente (id_cliente)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO
ALTER TABLE dbo.tb_cliente_usuario ADD FOREIGN KEY (id_usuario)
	REFERENCES dbo.sys_usuario (id_usuario)     
    ON DELETE CASCADE    
    ON UPDATE CASCADE
GO

IF OBJECT_ID (N'dbo.tb_pedido') IS NULL
BEGIN
	CREATE TABLE dbo.tb_pedido (
		id_pedido			VARCHAR(38) PRIMARY KEY 
	  , cd_pedido			INT IDENTITY(1,1) NOT NULL UNIQUE
	  , id_empresa			VARCHAR(38) NOT NULL
	  , id_cliente			VARCHAR(38) NOT NULL
	  , tp_pedido			SMALLINT DEFAULT 0 NOT NULL
	  , dt_pedido			DATETIME
	  , ds_contato			VARCHAR(150)
	  , ds_observacao		VARCHAR(500)
	  , vl_total_bruto		NUMERIC(18,2)
	  , vl_total_desconto	NUMERIC(18,2)
	  , vl_total_pedido		NUMERIC(18,2)
	  , sn_faturado			SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_faturado = 0) or (sn_faturado = 1))
	  , sn_entregue			SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_entregue = 0) or (sn_entregue = 1))
	  , id_usuario			VARCHAR(38) NOT NULL
	  , cd_pedido_app		INT
	  , nr_pedido			BIGINT
	  , dt_ult_edicao		DATETIME
	);
	/*
	ALTER TABLE dbo.tb_pedido
	  ADD cd_pedido_app	INT;

	ALTER TABLE dbo.tb_pedido
	  ADD nr_pedido	BIGINT;

	ALTER TABLE dbo.tb_pedido
	  ADD dt_ult_edicao	DATETIME;

	ALTER TABLE dbo.tb_pedido
	  ADD sn_faturado SMALLINT DEFAULT 0 NOT NULL CHECK ((sn_faturado = 0) or (sn_faturado = 1));
	*/
	Execute dbo.spDocumentarCampo N'tb_pedido', N'id_pedido',		N'ID (GUID)';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'cd_pedido',		N'Código';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'id_empresa',		N'Empresa';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'id_cliente',		N'Cliente';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'tp_pedido',		N'Tipo:
	0 - Orçamento
	1 - Venda';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'dt_pedido',			N'Data Emissão';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'ds_contato',			N'Contato';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'ds_observacao',		N'Observações';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'vl_total_bruto',		N'Valor Total (R$)';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'vl_total_desconto',	N'Descontos (R$)';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'vl_total_pedido',		N'Valor Pedido (R$)';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'sn_faturado',			N'Faturado:
	0 - Não
	1 - Sim';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'sn_entregue',			N'Entregue ao cliente:
	0 - Não
	1 - Sim';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'cd_pedido_app',		N'Código do Pedido no aplicativo';
	Execute dbo.spDocumentarCampo N'tb_pedido', N'nr_pedido',			N'Número do Pedido na Empresa';

	ALTER TABLE dbo.tb_pedido ADD FOREIGN KEY (id_empresa)
		REFERENCES dbo.sys_empresa (id_empresa);

	ALTER TABLE dbo.tb_pedido ADD FOREIGN KEY (id_cliente)
		REFERENCES dbo.tb_cliente (id_cliente);

	ALTER TABLE dbo.tb_pedido ADD FOREIGN KEY (id_usuario)
		REFERENCES dbo.sys_usuario (id_usuario);
END
GO

IF OBJECT_ID (N'dbo.tb_pedido_item') IS NULL
BEGIN
	CREATE TABLE dbo.tb_pedido_item (
		id_item				VARCHAR(38) PRIMARY KEY 
	  , cd_item				INT NOT NULL 
	  , id_pedido			VARCHAR(38) NOT NULL
	  , id_produto			VARCHAR(38) NOT NULL
	  , qt_produto			NUMERIC(18,3) DEFAULT 1 NOT NULL
	  , vl_produto			NUMERIC(18,3) DEFAULT 0.0 NOT NULL
	  , vl_total_bruto		NUMERIC(18,2) DEFAULT 0.0 NOT NULL
	  , vl_total_desconto	NUMERIC(18,2) DEFAULT 0.0 NOT NULL
	  , vl_total_produto	NUMERIC(18,2) DEFAULT 0.0 NOT NULL
	);

	ALTER TABLE dbo.tb_pedido_item ADD FOREIGN KEY (id_pedido)
		REFERENCES dbo.tb_pedido (id_pedido)     
		ON DELETE CASCADE    
		ON UPDATE CASCADE;

	ALTER TABLE dbo.tb_pedido_item ADD FOREIGN KEY (id_produto)
		REFERENCES dbo.tb_produto (id_produto);
END
GO


CREATE TABLE dbo.tb_cliente_temp (
    id_usuario		VARCHAR(38) NOT NULL
  , id_empresa		VARCHAR(38) NOT NULL
  , id_cliente		VARCHAR(38) NOT NULL
  , cd_cliente		INT 
  , nm_cliente		VARCHAR(250)
  , nr_cnpj_cpf		VARCHAR(25)
  , nm_contato		VARCHAR(50)
  , nr_telefone		VARCHAR(25)
  , nr_celular		VARCHAR(25)
  , ds_email		VARCHAR(150)
  , ds_endereco		VARCHAR(500)
  , ds_observacao	VARCHAR(500)
  , sn_ativo		CHAR(1)
)
GO

ALTER TABLE dbo.tb_cliente_temp ADD PRIMARY KEY (id_usuario, id_empresa, id_cliente)
GO


CREATE TABLE dbo.tb_produto_temp (
    id_usuario		VARCHAR(38) NOT NULL
  , id_empresa		VARCHAR(38) NOT NULL
  , id_produto		VARCHAR(38) NOT NULL
  , br_produto		VARCHAR(38)
  , cd_produto		INT 
  , ds_produto		VARCHAR(200)
  , ft_produto		VARCHAR(MAX)
  , vl_produto		NUMERIC(18,2)
  , sn_ativo		CHAR(1)
)
GO

ALTER TABLE dbo.tb_produto_temp ADD PRIMARY KEY (id_usuario, id_empresa, id_produto)
GO

CREATE TABLE dbo.tb_pedido_temp (
	  id_usuario		VARCHAR(38) NOT NULL
	, id_empresa		VARCHAR(38) NOT NULL
	, id_pedido			VARCHAR(38) NOT NULL
	, cd_pedido			INT 
	, id_loja			VARCHAR(38) NOT NULL
	, id_cliente		VARCHAR(38) NOT NULL
	, tp_pedido			SMALLINT DEFAULT 0 NOT NULL
	, dt_pedido			DATETIME
	, ds_contato		VARCHAR(150)
	, ds_observacao		VARCHAR(500)
	, vl_total_bruto	NUMERIC(18,2)
	, vl_total_desconto	NUMERIC(18,2)
	, vl_total_pedido	NUMERIC(18,2)
	, sn_entregue		CHAR(1)
)
GO

ALTER TABLE dbo.tb_pedido_temp ADD PRIMARY KEY (id_usuario, id_empresa, id_pedido)
GO

CREATE TABLE dbo.tb_pedido_item_temp (
	  id_usuario		VARCHAR(38) NOT NULL
	, id_empresa		VARCHAR(38) NOT NULL
	, id_item			VARCHAR(38) NOT NULL
	, cd_item			INT NOT NULL 
	, id_pedido			VARCHAR(38) NOT NULL
	, id_produto		VARCHAR(38) NOT NULL
	, qt_produto		NUMERIC(18,3) DEFAULT 1 NOT NULL
	, vl_produto		NUMERIC(18,3) DEFAULT 0.0 NOT NULL
	, vl_total_bruto	NUMERIC(18,2) DEFAULT 0.0 NOT NULL
	, vl_total_desconto	NUMERIC(18,2) DEFAULT 0.0 NOT NULL
	, vl_total_produto	NUMERIC(18,2) DEFAULT 0.0 NOT NULL
);

ALTER TABLE dbo.tb_pedido_item_temp ADD PRIMARY KEY (id_usuario, id_empresa, id_item)
GO
