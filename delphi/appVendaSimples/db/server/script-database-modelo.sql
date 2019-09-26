
/****** Object:  Table [dbo].[GER_EMAIL_ENVIO]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GER_EMAIL_ENVIO](
	[SEQ_EMAIL] [int] IDENTITY(1,1) NOT NULL,
	[STATUS] [char](1) NULL,
	[DT_GERACAO] [datetime] NULL,
	[COD_USUARIO] [int] NULL,
	[COD_EMPRESA] [int] NULL,
	[EMAIL_DE] [varchar](100) NULL,
	[NOME_DE] [varchar](100) NULL,
	[EMAIL_PARA] [varchar](100) NULL,
	[NOME_PARA] [varchar](100) NULL,
	[ASSUNTO] [varchar](500) NULL,
	[TEXTO] [varchar](150) NULL,
	[ERRO] [varchar](2000) NULL,
	[DT_ENVIO] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SEQ_EMAIL] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[GER_PUSH_ENVIO]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GER_PUSH_ENVIO](
	[SEQ_PUSH] [int] IDENTITY(1,1) NOT NULL,
	[STATUS] [char](1) NULL,
	[DT_GERACAO] [datetime] NULL,
	[COD_USUARIO] [int] NULL,
	[COD_EMPRESA] [int] NULL,
	[PLATAFORMA] [varchar](20) NULL,
	[TEXTO] [varchar](8000) NULL,
	[ERRO] [varchar](2000) NULL,
	[DT_ENVIO] [datetime] NULL,
	[BADGE_CONT] [int] NULL,
	[NUM_PEDIDO] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[SEQ_PUSH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[GER_SMS_ENVIO]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[GER_SMS_ENVIO](
	[SEQ_SMS] [int] IDENTITY(1,1) NOT NULL,
	[STATUS] [char](1) NULL,
	[DT_GERACAO] [datetime] NULL,
	[COD_USUARIO] [int] NULL,
	[COD_EMPRESA] [int] NULL,
	[FONE] [varchar](20) NULL,
	[TEXTO] [varchar](150) NULL,
	[ID_MENSAGEM] [varchar](50) NULL,
	[ERRO] [varchar](2000) NULL,
	[DT_ENVIO] [datetime] NULL,
	[RETORNO] [varchar](500) NULL,
PRIMARY KEY CLUSTERED 
(
	[SEQ_SMS] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_CLIENTE]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_CLIENTE](
	[COD_EMPRESA] [int] NOT NULL,
	[COD_CLIENTE] [int] NOT NULL,
	[CNPJ_CPF] [varchar](20) NULL,
	[NOME] [varchar](100) NULL,
	[FONE] [varchar](20) NULL,
	[EMAIL] [varchar](100) NULL,
	[ENDERECO] [varchar](500) NULL,
	[OBS] [varchar](1000) NULL,
	[DATA_ULT_COMPRA] [datetime] NULL,
	[VALOR_ULT_COMPRA] [decimal](12, 2) NULL,
	[DATA_ULT_ALTERACAO] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC,
	[COD_CLIENTE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_CLIENTE_TEMP]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_CLIENTE_TEMP](
	[COD_EMPRESA] [int] NULL,
	[COD_USUARIO] [int] NULL,
	[COD_CLIENTE] [int] NULL,
	[CNPJ_CPF] [varchar](20) NULL,
	[NOME] [varchar](100) NULL,
	[FONE] [varchar](20) NULL,
	[EMAIL] [varchar](100) NULL,
	[ENDERECO] [varchar](500) NULL,
	[OBS] [varchar](1000) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_EMPRESA]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_EMPRESA](
	[COD_EMPRESA] [int] IDENTITY(1,1) NOT NULL,
	[NOME] [varchar](100) NULL,
	[CNPJ_CPF] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_NOTIFICACAO]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_NOTIFICACAO](
	[COD_NOTIFICACAO] [int] IDENTITY(1,1) NOT NULL,
	[COD_EMPRESA] [int] NULL,
	[COD_USUARIO] [int] NULL,
	[DATA_NOTIFICACAO] [datetime] NULL,
	[TITULO] [varchar](100) NULL,
	[TEXTO] [varchar](500) NULL,
	[IND_LIDO] [char](1) NULL,
	[IND_DESTAQUE] [char](1) NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_NOTIFICACAO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PEDIDO]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PEDIDO](
	[COD_EMPRESA] [int] NOT NULL,
	[NUM_PEDIDO] [int] NOT NULL,
	[COD_CLIENTE] [int] NULL,
	[TIPO_PEDIDO] [char](1) NULL,
	[DATA_PEDIDO] [datetime] NULL,
	[CONTATO] [varchar](100) NULL,
	[OBS] [varchar](500) NULL,
	[IND_ENTREGUE] [char](1) NULL,
	[VALOR_TOTAL] [decimal](12, 2) NULL,
	[COD_USUARIO] [int] NULL,
	[DATA_ULT_ALTERACAO] [datetime] NULL,
	[PEDIDO_LOCAL] [varchar](20) NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC,
	[NUM_PEDIDO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PEDIDO_ITEM]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PEDIDO_ITEM](
	[COD_EMPRESA] [int] NOT NULL,
	[NUM_PEDIDO] [int] NOT NULL,
	[SEQ_ITEM] [int] NOT NULL,
	[COD_PRODUTO] [int] NULL,
	[QTD] [int] NULL,
	[VALOR_UNIT] [decimal](12, 2) NULL,
	[VALOR_TOTAL] [decimal](12, 2) NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC,
	[NUM_PEDIDO] ASC,
	[SEQ_ITEM] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PEDIDO_ITEM_TEMP]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PEDIDO_ITEM_TEMP](
	[COD_EMPRESA] [int] NULL,
	[COD_USUARIO] [int] NULL,
	[PEDIDO_LOCAL] [varchar](20) NULL,
	[NUM_PEDIDO] [int] NULL,
	[SEQ_ITEM] [int] NULL,
	[COD_PRODUTO] [int] NULL,
	[QTD] [int] NULL,
	[VALOR_UNIT] [decimal](12, 2) NULL,
	[VALOR_TOTAL] [decimal](12, 2) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PEDIDO_SEQUENCE]    Script Date: 4/16/2019 12:29:35 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PEDIDO_SEQUENCE](
	[COD_EMPRESA] [int] NOT NULL,
	[NUM_PEDIDO] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC,
	[NUM_PEDIDO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PEDIDO_TEMP]    Script Date: 4/16/2019 12:29:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PEDIDO_TEMP](
	[COD_EMPRESA] [int] NULL,
	[NUM_PEDIDO] [int] NULL,
	[COD_CLIENTE] [int] NULL,
	[TIPO_PEDIDO] [char](1) NULL,
	[DATA_PEDIDO] [datetime] NULL,
	[CONTATO] [varchar](100) NULL,
	[OBS] [varchar](500) NULL,
	[IND_ENTREGUE] [char](1) NULL,
	[VALOR_TOTAL] [decimal](12, 2) NULL,
	[COD_USUARIO] [int] NULL,
	[PEDIDO_LOCAL] [varchar](20) NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PRODUTO]    Script Date: 4/16/2019 12:29:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PRODUTO](
	[COD_EMPRESA] [int] NOT NULL,
	[COD_PRODUTO] [int] NOT NULL,
	[DESCRICAO] [varchar](200) NULL,
	[VALOR] [decimal](12, 2) NULL,
	[FOTO] [varchar](max) NULL,
	[DATA_ULT_ALTERACAO] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC,
	[COD_PRODUTO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_PRODUTO_TEMP]    Script Date: 4/16/2019 12:29:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_PRODUTO_TEMP](
	[COD_EMPRESA] [int] NULL,
	[COD_USUARIO] [int] NULL,
	[COD_PRODUTO] [int] NOT NULL,
	[DESCRICAO] [varchar](200) NULL,
	[VALOR] [decimal](12, 2) NULL,
	[FOTO] [varchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[TAB_USUARIO]    Script Date: 4/16/2019 12:29:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TAB_USUARIO](
	[COD_EMPRESA] [int] NOT NULL,
	[COD_USUARIO] [int] NOT NULL,
	[NOME] [varchar](100) NULL,
	[EMAIL] [varchar](100) NULL,
	[SENHA] [varchar](50) NULL,
	[TOKEN_ID] [varchar](200) NULL,
	[PLATAFORMA] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[COD_EMPRESA] ASC,
	[COD_USUARIO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



/****** Object:  StoredProcedure [dbo].[USUARIO_CRIAR_CONTA]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_CRIAR_CONTA]( @NOME			VARCHAR(100), 
									  @EMAIL		VARCHAR(100), 
									  @SENHA		VARCHAR(50), 
									  @COD_USUARIO	INT OUT,
									  @COD_EMPRESA	INT OUT,
									  @RETORNO		VARCHAR(1000) OUT
) AS

BEGIN TRY
		SET @RETORNO = 'OK'


		-- VALIDAR EMAIL EXISTENTE --
		IF EXISTS(	SELECT *
					FROM	TAB_USUARIO
					WHERE	EMAIL = @EMAIL )
		BEGIN
				SET @RETORNO = 'Esse email j� est� em uso por outra conta.'
				RETURN(0)
		END


		-- CADASTRA NOVA EMPRESA AUTOMATICAMENTE --
		INSERT INTO TAB_EMPRESA(NOME, CNPJ_CPF)
		VALUES(@NOME, '')
		

		-- BUSCA COD. EMPRESA GERADO --
		SET @COD_EMPRESA = SCOPE_IDENTITY()


		-- TRATAR SEQUENCE DA EMPRESA --
		INSERT INTO TAB_PEDIDO_SEQUENCE(COD_EMPRESA, NUM_PEDIDO)
		VALUES(@COD_EMPRESA, 0)


		-- CALCULA SEQ. USUARIO --
		SELECT	@COD_USUARIO = ISNULL(MAX(COD_USUARIO), 0)
		FROM	TAB_USUARIO
		WHERE	COD_EMPRESA = @COD_EMPRESA

		SET @COD_USUARIO = @COD_USUARIO + 1



		INSERT INTO TAB_USUARIO(COD_EMPRESA, COD_USUARIO, NOME, EMAIL, SENHA)
		VALUES(@COD_EMPRESA, @COD_USUARIO, @NOME, @EMAIL, @SENHA)

END TRY
BEGIN CATCH
		SET @RETORNO = 'Erro ao criar o usu�rio'
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_IMPORTAR_CLIENTE]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_IMPORTAR_CLIENTE](	@COD_EMPRESA	INT, 
											@COD_USUARIO	INT, 
											@DATA_ULT_ALTERACAO DATETIME OUT,
											@RETORNO		VARCHAR(1000) OUT
) AS

DECLARE	@COD_CLIENTE	INT,
		@CNPJ_CPF		VARCHAR(20),
		@NOME			VARCHAR(100),
		@FONE			VARCHAR(20),
		@EMAIL			VARCHAR(100),
		@ENDERECO		VARCHAR(500),
		@OBS			VARCHAR(1000)		

BEGIN TRY
		SET @RETORNO = 'OK'
		SET @DATA_ULT_ALTERACAO = GETDATE()

		DECLARE C_CLIENTE CURSOR FOR
			SELECT	COD_CLIENTE, CNPJ_CPF, NOME, FONE, EMAIL, ENDERECO, OBS
			FROM	TAB_CLIENTE_TEMP
			WHERE	COD_EMPRESA = @COD_EMPRESA
			AND		COD_USUARIO = @COD_USUARIO

		OPEN C_CLIENTE
		FETCH C_CLIENTE INTO @COD_CLIENTE, @CNPJ_CPF, @NOME, @FONE, @EMAIL, @ENDERECO, @OBS
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
				-- SE ENCONTRAR O CLIENTE CADASTRADO --
				IF EXISTS(	SELECT	COD_CLIENTE
							FROM	TAB_CLIENTE
							WHERE	COD_EMPRESA = @COD_EMPRESA
							AND		COD_CLIENTE = @COD_CLIENTE )
				BEGIN
						UPDATE	TAB_CLIENTE
						SET		CNPJ_CPF=@CNPJ_CPF, NOME=@NOME, FONE=@FONE, EMAIL=@EMAIL, 
								ENDERECO=@ENDERECO, OBS=@OBS, DATA_ULT_ALTERACAO=@DATA_ULT_ALTERACAO
						WHERE	COD_EMPRESA = @COD_EMPRESA
						AND		COD_CLIENTE = @COD_CLIENTE 
				END
				ELSE
				-- CADASTRA UM NOVO CLIENTE --
				BEGIN
						INSERT INTO TAB_CLIENTE(COD_EMPRESA, COD_CLIENTE, CNPJ_CPF, NOME, FONE, EMAIL, ENDERECO, OBS, DATA_ULT_ALTERACAO)
						VALUES(@COD_EMPRESA, @COD_CLIENTE, @CNPJ_CPF, @NOME, @FONE, @EMAIL, @ENDERECO, @OBS, @DATA_ULT_ALTERACAO)
				END


				FETCH C_CLIENTE INTO @COD_CLIENTE, @CNPJ_CPF, @NOME, @FONE, @EMAIL, @ENDERECO, @OBS
		END
		CLOSE C_CLIENTE
		DEALLOCATE C_CLIENTE



END TRY
BEGIN CATCH
		SET @RETORNO = 'Erro ao importar os clientes'
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_IMPORTAR_PEDIDO]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_IMPORTAR_PEDIDO](	@COD_EMPRESA	INT, 
											@COD_USUARIO	INT											
) AS

DECLARE	@DATA_ULT_ALTERACAO DATETIME,
		@RETORNO		VARCHAR(1000),
		@NUM_PEDIDO		INT, 
		@COD_CLIENTE	INT,
		@TIPO_PEDIDO	CHAR(1),
		@DATA_PEDIDO	DATETIME,
		@CONTATO		VARCHAR(100),
		@OBS			VARCHAR(500),
		@VALOR_TOTAL	DECIMAL(12,2),
		@PEDIDO_LOCAL	VARCHAR(20),
		---
		@SEQ_ITEM		INT, 
		@COD_PRODUTO	INT, 
		@QTD			INT, 
		@VALOR_UNIT		DECIMAL(12,2)		

BEGIN TRY
		SET @RETORNO = 'OK'
		SET @DATA_ULT_ALTERACAO = GETDATE()

		DECLARE C_PEDIDO CURSOR FOR
			SELECT	NUM_PEDIDO, COD_CLIENTE, TIPO_PEDIDO, DATA_PEDIDO, CONTATO, OBS, VALOR_TOTAL, PEDIDO_LOCAL
			FROM	TAB_PEDIDO_TEMP
			WHERE	COD_EMPRESA = @COD_EMPRESA
			AND		COD_USUARIO = @COD_USUARIO

		OPEN C_PEDIDO
		FETCH C_PEDIDO INTO @NUM_PEDIDO, @COD_CLIENTE, @TIPO_PEDIDO, @DATA_PEDIDO, @CONTATO, @OBS, @VALOR_TOTAL, @PEDIDO_LOCAL
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
				-- GRAVA NOVO PEDIDO --
				IF @NUM_PEDIDO IS NULL
				BEGIN
						-- GERAR UM NOVO NUMERO --
						SELECT	@NUM_PEDIDO = ISNULL(NUM_PEDIDO + 1, 1)
						FROM	TAB_PEDIDO_SEQUENCE (UPDLOCK)
						WHERE	COD_EMPRESA = @COD_EMPRESA

						UPDATE	TAB_PEDIDO_SEQUENCE
						SET		NUM_PEDIDO = @NUM_PEDIDO
						WHERE	COD_EMPRESA = @COD_EMPRESA


						INSERT INTO TAB_PEDIDO(COD_EMPRESA, NUM_PEDIDO, COD_CLIENTE, TIPO_PEDIDO, DATA_PEDIDO, CONTATO, 
												OBS, IND_ENTREGUE, VALOR_TOTAL, COD_USUARIO, DATA_ULT_ALTERACAO, PEDIDO_LOCAL)
						VALUES(@COD_EMPRESA, @NUM_PEDIDO, @COD_CLIENTE, 'P', @DATA_PEDIDO, @CONTATO, 
								@OBS, 'N', @VALOR_TOTAL, @COD_USUARIO, @DATA_ULT_ALTERACAO, @PEDIDO_LOCAL)


						-- ATUALIZA NUMERO DE PEDIDO GERADO --
						UPDATE	TAB_PEDIDO_TEMP
						SET		NUM_PEDIDO = @NUM_PEDIDO
						WHERE	COD_EMPRESA = @COD_EMPRESA
						AND		COD_USUARIO = @COD_USUARIO
						AND		PEDIDO_LOCAL = @PEDIDO_LOCAL
				END
				ELSE
				BEGIN
						UPDATE	TAB_PEDIDO
						SET		COD_CLIENTE=@COD_CLIENTE, TIPO_PEDIDO=@TIPO_PEDIDO, DATA_PEDIDO=@DATA_PEDIDO, 
								CONTATO=@CONTATO, OBS=@OBS, VALOR_TOTAL=@VALOR_TOTAL, DATA_ULT_ALTERACAO=@DATA_ULT_ALTERACAO,
								PEDIDO_LOCAL=@PEDIDO_LOCAL
						WHERE	COD_EMPRESA = @COD_EMPRESA
						AND		NUM_PEDIDO = @NUM_PEDIDO
				END


				-- TRATA ITENS DO PEDIDO --
				DELETE
				FROM	TAB_PEDIDO_ITEM
				WHERE	COD_EMPRESA = @COD_EMPRESA
				AND		NUM_PEDIDO = @NUM_PEDIDO

				DECLARE C_ITENS CURSOR FOR
					SELECT	SEQ_ITEM, COD_PRODUTO, QTD, VALOR_UNIT, VALOR_TOTAL
					FROM	TAB_PEDIDO_ITEM_TEMP
					WHERE	COD_EMPRESA = @COD_EMPRESA
					AND		COD_USUARIO = @COD_USUARIO
					AND		PEDIDO_LOCAL = @PEDIDO_LOCAL

				OPEN C_ITENS
				FETCH C_ITENS INTO @SEQ_ITEM, @COD_PRODUTO, @QTD, @VALOR_UNIT, @VALOR_TOTAL
				WHILE (@@FETCH_STATUS <> -1)
				BEGIN
						INSERT INTO TAB_PEDIDO_ITEM(COD_EMPRESA, NUM_PEDIDO, SEQ_ITEM, COD_PRODUTO, QTD, VALOR_UNIT, VALOR_TOTAL)
						VALUES(@COD_EMPRESA, @NUM_PEDIDO, @SEQ_ITEM, @COD_PRODUTO, @QTD, @VALOR_UNIT, @VALOR_TOTAL)


						FETCH C_ITENS INTO @SEQ_ITEM, @COD_PRODUTO, @QTD, @VALOR_UNIT, @VALOR_TOTAL
				END
				CLOSE C_ITENS
				DEALLOCATE C_ITENS

											

				FETCH C_PEDIDO INTO @NUM_PEDIDO, @COD_CLIENTE, @TIPO_PEDIDO, @DATA_PEDIDO, @CONTATO, @OBS, @VALOR_TOTAL, @PEDIDO_LOCAL
		END
		CLOSE C_PEDIDO
		DEALLOCATE C_PEDIDO



		-- DEVOLVE VALORES PARA O WS --
		SELECT	@RETORNO AS RETORNO,
				@DATA_ULT_ALTERACAO AS DATA_ULT_ALTERACAO,
				PEDIDO_LOCAL,
				NUM_PEDIDO
		FROM	TAB_PEDIDO_TEMP
		WHERE	COD_EMPRESA = @COD_EMPRESA
		AND		COD_USUARIO = @COD_USUARIO


END TRY
BEGIN CATCH
		SET @RETORNO = 'Erro ao importar os pedidos'
		SET @DATA_ULT_ALTERACAO = GETDATE()
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_IMPORTAR_PRODUTO]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_IMPORTAR_PRODUTO](	@COD_EMPRESA	INT, 
											@COD_USUARIO	INT, 
											@DATA_ULT_ALTERACAO DATETIME OUT,
											@RETORNO		VARCHAR(1000) OUT
) AS

DECLARE	@COD_PRODUTO	INT,
		@DESCRICAO		VARCHAR(200),
		@VALOR			DECIMAL(12,2),
		@FOTO			VARCHAR(MAX)

BEGIN TRY
		SET @RETORNO = 'OK'
		SET @DATA_ULT_ALTERACAO = GETDATE()

		DECLARE C_PRODUTO CURSOR FOR
			SELECT	COD_PRODUTO, DESCRICAO, VALOR, FOTO
			FROM	TAB_PRODUTO_TEMP
			WHERE	COD_EMPRESA = @COD_EMPRESA
			AND		COD_USUARIO = @COD_USUARIO

		OPEN C_PRODUTO
		FETCH C_PRODUTO INTO @COD_PRODUTO, @DESCRICAO, @VALOR, @FOTO
		WHILE (@@FETCH_STATUS <> -1)
		BEGIN
				-- SE ENCONTRAR O PRODUTO CADASTRADO --
				IF EXISTS(	SELECT	COD_PRODUTO
							FROM	TAB_PRODUTO
							WHERE	COD_EMPRESA = @COD_EMPRESA
							AND		COD_PRODUTO = @COD_PRODUTO )
				BEGIN
						UPDATE	TAB_PRODUTO
						SET		DESCRICAO = @DESCRICAO, VALOR = @VALOR, FOTO=@FOTO, DATA_ULT_ALTERACAO = @DATA_ULT_ALTERACAO
						WHERE	COD_EMPRESA = @COD_EMPRESA
						AND		COD_PRODUTO = @COD_PRODUTO
				END
				ELSE
				-- CADASTRA UM NOVO PRODUTO --
				BEGIN
						INSERT INTO TAB_PRODUTO(COD_EMPRESA, COD_PRODUTO, DESCRICAO, VALOR, FOTO, DATA_ULT_ALTERACAO)
						VALUES(@COD_EMPRESA, @COD_PRODUTO, @DESCRICAO, @VALOR, @FOTO, @DATA_ULT_ALTERACAO)
				END


				FETCH C_PRODUTO INTO @COD_PRODUTO, @DESCRICAO, @VALOR, @FOTO
		END
		CLOSE C_PRODUTO
		DEALLOCATE C_PRODUTO



END TRY
BEGIN CATCH
		SET @RETORNO = 'Erro ao importar os produtos'
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_LISTA_CLIENTE_DOWNLOAD]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_LISTA_CLIENTE_DOWNLOAD](	@COD_EMPRESA			INT, 
													@COD_USUARIO			INT,
													@DATA_ULT_ATUALIACAO	DATETIME
) AS
BEGIN
		SELECT	COD_CLIENTE, ISNULL(CNPJ_CPF, ''), ISNULL(NOME, ''), ISNULL(FONE, ''), 
				ISNULL(EMAIL, ''), ISNULL(ENDERECO, ''), ISNULL(OBS, '')
		FROM	TAB_CLIENTE
		WHERE	COD_EMPRESA = @COD_EMPRESA
		AND		(DATA_ULT_ALTERACAO > @DATA_ULT_ATUALIACAO OR @DATA_ULT_ATUALIACAO IS NULL)
		AND		COD_CLIENTE NOT IN (	SELECT	COD_CLIENTE
										FROM	TAB_CLIENTE_TEMP
										WHERE	COD_EMPRESA = @COD_EMPRESA
										AND		COD_USUARIO = @COD_USUARIO)


		ORDER BY COD_CLIENTE
END
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_LISTA_NOTIFICACAO]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_LISTA_NOTIFICACAO] (@COD_EMPRESA	INT, 
											@COD_USUARIO	INT
) AS
BEGIN
		SELECT	COD_NOTIFICACAO, DATA_NOTIFICACAO, TITULO, TEXTO, IND_DESTAQUE
		FROM	TAB_NOTIFICACAO
		WHERE	COD_EMPRESA = @COD_EMPRESA
		AND		COD_USUARIO = @COD_USUARIO
		AND		IND_LIDO = 'N'
		ORDER BY DATA_NOTIFICACAO

		-- ATUALIZAR NOTIFICACOES PARA LIDAS --
		UPDATE	TAB_NOTIFICACAO
		SET		IND_LIDO = 'S'
		WHERE	COD_EMPRESA = @COD_EMPRESA
		AND		COD_USUARIO = @COD_USUARIO
		AND		IND_LIDO = 'N'
		
END
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_LISTA_PRODUTO_DOWNLOAD]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_LISTA_PRODUTO_DOWNLOAD](	@COD_EMPRESA			INT, 
													@COD_USUARIO			INT,
													@DATA_ULT_ATUALIACAO	DATETIME
) AS
BEGIN
		SELECT	COD_PRODUTO, ISNULL(DESCRICAO, ''), ISNULL(VALOR, 0), ISNULL(FOTO, '')
		FROM	TAB_PRODUTO
		WHERE	COD_EMPRESA = @COD_EMPRESA
		AND		(DATA_ULT_ALTERACAO > @DATA_ULT_ATUALIACAO OR @DATA_ULT_ATUALIACAO IS NULL)
		AND		COD_PRODUTO NOT IN (	SELECT	COD_PRODUTO
										FROM	TAB_PRODUTO_TEMP
										WHERE	COD_EMPRESA = @COD_EMPRESA
										AND		COD_USUARIO = @COD_USUARIO)


		ORDER BY COD_PRODUTO
END
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_PEDIDO_ENTREGUE]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[USUARIO_PEDIDO_ENTREGUE](	@COD_EMPRESA	INT,
											@NUM_PEDIDO		INT,
											@RETORNO		VARCHAR(1000) OUT
) AS
BEGIN TRY
		SET @RETORNO = 'OK'


		-- ATUALIZA DADOS DO PEDIDO --
		UPDATE	TAB_PEDIDO
		SET		IND_ENTREGUE = 'S',
				DATA_ULT_ALTERACAO = GETDATE()
		WHERE	COD_EMPRESA = @COD_EMPRESA
		AND		NUM_PEDIDO = @NUM_PEDIDO


		-- ENVIA NOTIFICACAO PUSH PARA O VENDEDOR --


END TRY
BEGIN CATCH
		SET @RETORNO = 'Erro ao marcar pedido como entregue'
END CATCH
GO

/****** Object:  StoredProcedure [dbo].[USUARIO_VALIDA_LOGIN]    Script Date: 4/16/2019 12:27:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[USUARIO_VALIDA_LOGIN](	@EMAIL		VARCHAR(100), 
										@SENHA		VARCHAR(100),
										@COD_USUARIO INT OUT, 
										@NOME		VARCHAR(100) OUT,
										@COD_EMPRESA INT OUT,
										@RETORNO	VARCHAR(1000) OUT
	
) AS
BEGIN TRY
		SET @RETORNO = 'OK'
		SET @COD_USUARIO = 0
		SET @COD_EMPRESA = 0
		SET @NOME = ''


		-- VALIDAR LOGIN DO USUARIO --
		SELECT	@COD_EMPRESA = COD_EMPRESA,
				@COD_USUARIO = COD_USUARIO,
				@NOME = NOME
		FROM	TAB_USUARIO
		WHERE	EMAIL = @EMAIL
		AND		SENHA = @SENHA


		IF ISNULL(@COD_USUARIO, 0) = 0
		BEGIN		
				SET @RETORNO = 'Email ou senha inv�lida'
				RETURN(0)
		END

END TRY
BEGIN CATCH
		SET @RETORNO = 'Ocorreu um erro ao validar usu�rio'
END CATCH

GO
