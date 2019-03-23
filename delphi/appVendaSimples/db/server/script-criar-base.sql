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

IF OBJECT_ID (N'dbo.sys_empresa') IS NOT NULL  
    DROP FUNCTION dbo.sys_empresa;  
GO
CREATE TABLE dbo.sys_empresa (
    id_empresa	VARCHAR(38) PRIMARY KEY 
  , cd_empresa	INT IDENTITY(1,1) NOT NULL UNIQUE
  , nm_empresa	VARCHAR(250)
  , nm_fantasia	VARCHAR(150)
  , nr_cnpj_cpf	VARCHAR(25) UNIQUE
)
GO

IF OBJECT_ID (N'dbo.sys_usuario') IS NOT NULL  
	DROP FUNCTION dbo.sys_usuario;  
GO
CREATE TABLE dbo.sys_usuario (
    id_usuario		VARCHAR(38) PRIMARY KEY 
  , cd_usuario		INT IDENTITY(1,1) NOT NULL UNIQUE
  , nm_usuario		VARCHAR(150)
  , ds_email		VARCHAR(150) UNIQUE NOT NULL
  , ds_senha		VARCHAR(250)
  , id_token		VARCHAR(250)
  , tp_plataforma	SMALLINT DEFAULT 0 NOT NULL
)
GO

IF OBJECT_ID (N'dbo.sys_usuario_empresa') IS NOT NULL  
	DROP FUNCTION dbo.sys_usuario_empresa;  
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

IF OBJECT_ID (N'dbo.tb_cliente') IS NOT NULL  
    DROP FUNCTION dbo.tb_cliente;  
GO
CREATE TABLE dbo.tb_cliente (
    id_cliente		VARCHAR(38) PRIMARY KEY 
  , cd_ciente		INT IDENTITY(1,1) NOT NULL UNIQUE
  , nm_cliente		VARCHAR(250)
  , nr_cnpj_cpf		VARCHAR(25)
  , nr_telefone		VARCHAR(25)
  , ds_email		VARCHAR(150)
  , ds_endereco		VARCHAR(500)
  , ds_observacao	VARCHAR(500)
  , dt_ult_compra	DATETIME
  , vl_ult_compra	NUMERIC(18,2)
)
GO

IF OBJECT_ID (N'dbo.tb_cliente_empresa') IS NOT NULL  
	DROP FUNCTION dbo.tb_cliente_empresa;  
GO
CREATE TABLE dbo.tb_cliente_empresa (
    id_cliente		VARCHAR(38) NOT NULL
  , id_empresa		VARCHAR(38) NOT NULL
)
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

IF OBJECT_ID (N'dbo.tb_pedido') IS NOT NULL  
    DROP FUNCTION dbo.tb_pedido;  
GO
CREATE TABLE dbo.tb_pedido (
    id_pedido		VARCHAR(38) PRIMARY KEY 
  , cd_pedido		INT IDENTITY(1,1) NOT NULL UNIQUE
  , id_empresa		VARCHAR(38) NOT NULL
  , id_cliente		VARCHAR(38) NOT NULL
  , tp_pedido		SMALLINT DEFAULT 0 NOT NULL
  , dt_pedido		DATETIME
  , ds_contato		VARCHAR(150)
  , ds_observacao	VARCHAR(500)
  , vl_total_bruto		NUMERIC(18,2)
  , vl_total_desconto	NUMERIC(18,2)
  , vl_total_pedido		NUMERIC(18,2)
  , sn_entregue			SMALLINT DEFAULT 0 NOT NULL
  , id_usuario		VARCHAR(38) NOT NULL
)
GO

ALTER TABLE dbo.tb_pedido ADD FOREIGN KEY (id_empresa)
	REFERENCES dbo.sys_empresa (id_empresa)     
GO
ALTER TABLE dbo.tb_pedido ADD FOREIGN KEY (id_cliente)
	REFERENCES dbo.tb_cliente (id_cliente)     
GO

