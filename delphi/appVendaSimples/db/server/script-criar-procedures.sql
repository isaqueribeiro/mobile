USE [venda_simples_server]
GO

-- =============================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	31/03/2020
-- Description	:	Validar Usuário/Senha
-- =============================================
CREATE or ALTER PROCEDURE dbo.getDataHora(
	@dh_server	DATETIME	 OUT
  , @data		VARCHAR(10)  OUT
  , @hora		VARCHAR(10)  OUT
  , @data_hora	VARCHAR(20)  OUT
  , @retorno	VARCHAR(250) OUT)
AS
BEGIN TRY
  Set @retorno	= 'OK';

  Select
	  @dh_server = getdate()
	, @data = convert(varchar(10), getdate(), 103)
	, @hora = convert(varchar(10), getdate(), 108)
	, @data_hora = concat(convert(varchar(10), getdate(), 103), ' ', convert(varchar(10), getdate(), 108)) 
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar recuperar a data e hora do servidor';
END CATCH
GO

-- =============================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	27/09/2019
-- Description	:	Validar Usuário/Senha
-- =============================================
CREATE or ALTER PROCEDURE dbo.getValidarLogin(
	@email	 VARCHAR(150)
  , @senha	 VARCHAR(42)
  , @token	 VARCHAR(42)
  , @id		 VARCHAR(38)  OUT
  , @codigo	 BIGINT		  OUT
  , @nome	 VARCHAR(150) OUT
  , @retorno VARCHAR(250) OUT
  , @id_empresa  VARCHAR(38)  OUT
  , @cd_empresa  INT		  OUT 
  , @nm_empresa  VARCHAR(250) OUT
  , @nm_fantasia VARCHAR(150) OUT
  , @nr_cnpj_cpf VARCHAR(25)  OUT)
AS
BEGIN TRY
  Declare @senhaTMP VARCHAR(40);
  Declare @senhaDB VARCHAR(40);

  Set @id		= '{00000000-0000-0000-0000-000000000000}';
  Set @codigo	= 0;
  Set @nome		= '';
  Set @retorno	= 'OK';

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
	Select TOP 1
		@id		= u.id_usuario
	  , @codigo	= u.cd_usuario
	  , @nome		 = u.nm_usuario
	  , @senhaDB	 = u.ds_senha
	  , @id_empresa  = coalesce(e.id_empresa, '{00000000-0000-0000-0000-000000000000}')
	  , @cd_empresa  = coalesce(c.cd_empresa, 0)
	  , @nm_empresa  = c.nm_empresa
	  , @nm_fantasia = c.nm_fantasia
	  , @nr_cnpj_cpf = c.nr_cnpj_cpf
	from dbo.sys_usuario u
	  left join dbo.sys_usuario_empresa e on (e.id_usuario = u.id_usuario and e.sn_ativo = 1)
	  left join dbo.sys_empresa c on (c.id_empresa = e.id_empresa)
	where (u.ds_email = @email);

	If (ISNULL(@codigo, 0) = 0)
	  Set @retorno = 'E-mail inválido';
	Else
	Begin
	  Set @senhaTMP = Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senha)), 3, 40));

	  If ((@senhaTMP = @senhaDB) or (SUBSTRING(@senha, 3, 40) = @senhaDB))
		Set @retorno = 'OK';
	  Else
		Set @retorno = 'E-mail e Senha inválidos'; 
	End
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar validar usuário';
END CATCH
GO

-- =============================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	27/09/2019
-- Description	:	Criar Nova Conta (Login)
-- =============================================
CREATE or ALTER PROCEDURE dbo.setCriarLogin(
    @nome	 VARCHAR(150)
  , @email	 VARCHAR(150)
  , @senha	 VARCHAR(42)
  , @token	 VARCHAR(42)
  , @id		 VARCHAR(38)  OUT
  , @codigo	 BIGINT		  OUT
  , @retorno VARCHAR(250) OUT)
AS
BEGIN TRY
  Declare @validacao VARCHAR(200);

  Set @id		 = '{00000000-0000-0000-0000-000000000000}';
  Set @codigo	 = 0;
  Set @retorno	 = 'OK';
  Set @validacao = '';

  if (trim(@nome) = '')
    Set @validacao = concat(@validacao, 'Nome completo', char(13) + char(10));

  if (trim(@email) = '')
    Set @validacao = concat(@validacao, 'E-mail', char(13) + char(10));

  if (trim(@senha) = '')
    Set @validacao = concat(@validacao, 'Senha', char(13) + char(10));

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  if (@validacao != '')
    Set @retorno  = concat('Este dados são obrigatórios para criação de uma nova conta:', char(13) + char(10), @validacao);
  Else
  Begin
	Select
		@id		= u.id_usuario
	, @codigo	= u.cd_usuario
	from dbo.sys_usuario u
	where (u.ds_email = @email);

	If (ISNULL(@codigo, 0) > 0)
	  Set @retorno = 'Este e-mail já está em uso por outra conta';
	Else
	Begin
	  If (UPPER(SUBSTRING(@senha, 1, 2)) <> '0X') 
		Set @retorno = 'A Senha não está criptografada'
	  Else
	  If (Trim(@senha) = '')
		Set @retorno = 'Senha não informada'
	  Else
	  Begin
		Set @Id = dbo.ufnGetGuidID();

		Insert Into dbo.sys_usuario (
			id_usuario
		  , nm_usuario
		  , ds_email
		  , ds_senha
		) values (
			@id
		  , @nome
		  , LOWER(@email)
		  , UPPER(SUBSTRING(@senha, 3, 40))
		);

		Set @codigo = SCOPE_IDENTITY();
	  End
	End
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar criar nova conta';
END CATCH
GO

-- =============================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	28/09/2019
-- Description	:	Editar Perfil Conta (Login)
-- =============================================
CREATE or ALTER PROCEDURE dbo.setEditarPerfilLogin(
    @id			VARCHAR(38)
  , @nome		VARCHAR(150)
  , @email		VARCHAR(150)
  , @senha		VARCHAR(42)
  , @cpf_cnpj	VARCHAR(25)
  , @empresa	VARCHAR(250)
  , @fantasia	VARCHAR(250)
  , @token		VARCHAR(42)
  , @id_empresa	VARCHAR(38)	 OUT
  , @cd_empresa	INT			 OUT
  , @retorno	VARCHAR(250) OUT)
AS
BEGIN TRY
  Declare @codigo	BIGINT;
  Declare @violar	BIGINT;
  Declare @senhaTMP VARCHAR(40);

  Set @id_empresa	= '{00000000-0000-0000-0000-000000000000}';
  Set @cd_empresa	= 0;
  Set @retorno		= 'OK';

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', @id))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
	Select
		@id		= u.id_usuario
	  , @codigo	= u.cd_usuario
	from dbo.sys_usuario u
	where (u.id_usuario = @id);

	Select
		@violar = u.cd_usuario
	from dbo.sys_usuario u
	where (u.ds_email    = @email)
	  and (u.id_usuario <> @id);

	If (ISNULL(@codigo, 0) = 0)
	  Set @retorno = 'Login inválido';
	Else
	If (ISNULL(@violar, 0) > 0)
	  Set @retorno = 'E-mail já utilizado em outra conta';
	Else
	Begin
	  /*If (UPPER(SUBSTRING(@senha, 1, 2)) <> '0X') 
		Set @retorno = 'A Senha não está criptografada'
	  Else
	  If (Trim(@senha) = '')
		Set @retorno = 'Senha não informada'
	  Else*/
	  Begin
	    -- Identificar a Empresa
		Select
		    @id_empresa = e.id_empresa
		  , @cd_empresa = e.cd_empresa
		from dbo.sys_empresa e
		where (e.nr_cnpj_cpf = @cpf_cnpj);

		-- Inserir/Editar dados da Empresa
		If (ISNULL(@cd_empresa, 0) = 0)
		Begin
		  Set @id_empresa = dbo.ufnGetGuidID();
		  
		  Insert Into dbo.sys_empresa (
			  id_empresa
			, nm_empresa
			, nm_fantasia
			, nr_cnpj_cpf
		  ) values (
			  @id_empresa
			, @empresa
			, @fantasia
			, @cpf_cnpj
		  );

		  Set @cd_empresa = SCOPE_IDENTITY();
		End
		Else
		Begin
		  If (LEN(@cpf_cnpj) = 14) -- Apenas "Empressa pessoal" pode ter os dado alterados pela procedure (Empresa com base no CPF formatado)
		  Begin
		    Update dbo.sys_empresa Set
			    nm_empresa	= @empresa
			  , nm_fantasia	= @fantasia
			  , nr_cnpj_cpf	= @cpf_cnpj
		    where (id_empresa = @id_empresa);
		  End
		End

		-- Atualizar dados do Usuário
		Update dbo.sys_usuario Set
			nm_usuario	= @nome
		  , ds_email	= @email
		where (id_usuario = @id);

		If (Trim(@senha) <> '')
		Begin
		  If (UPPER(SUBSTRING(@senha, 1, 2)) <> '0X') 
			Set @retorno = 'A Senha não está criptografada'
		  Else
		  Begin
			-- Atualizar senha do Usuário
			Update dbo.sys_usuario Set
				ds_senha	= UPPER(SUBSTRING(@senha, 3, 40))
			where (id_usuario = @id);
		  End
		End

		-- Associar Usuário/Empresa
		if (not exists(
		  Select
		    ue.sn_ativo
		  from dbo.sys_usuario_empresa ue
		  where (ue.id_usuario = @id)
		    and (ue.id_empresa = @id_empresa)
		))
		Begin
		  Insert Into dbo.sys_usuario_empresa (
			  id_usuario
			, id_empresa
			, sn_ativo
		  ) values (
			  @id
			, @id_empresa
			, (Case when (LEN(@cpf_cnpj) = 14) then 1 else 0 end) -- Se for CPF (000.000.000-00)
		  );
		End
	  End
	End
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar editar perfil do usuário';
END CATCH
GO

-- =============================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	06/04/2020
-- Description	:	Listar Empresas do Usuário
-- =============================================
CREATE or ALTER PROCEDURE dbo.getListarEmpresas(
	@usuario	VARCHAR(38)
  , @token		VARCHAR(42)
  , @retorno	VARCHAR(250) OUT)
AS
BEGIN TRY
  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
	Set @retorno = 'OK';

	Select 
		e.id_empresa
	  , trim(cast(e.cd_empresa as varchar(10))) as cd_empresa
	  , e.nm_empresa
	  , e.nm_fantasia
	  , e.nr_cnpj_cpf
	from dbo.sys_usuario u
	  inner join dbo.sys_usuario_empresa x on (x.id_usuario = u.id_usuario)
	  inner join dbo.sys_empresa e on (e.id_empresa = x.id_empresa)
	where (u.id_usuario = @usuario);
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar listar a(s) empresa(s) do usuário';
END CATCH
GO

-- =================================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	02/10/2019
-- Description	:	Listar Notificões do Usuário
-- =================================================
CREATE or ALTER PROCEDURE dbo.getListarNotificacoes(
	@usuario	VARCHAR(38)
  , @empresa	VARCHAR(38)
  , @token		VARCHAR(42)
  , @retorno	VARCHAR(250) OUT)
AS
BEGIN TRY
  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
	Set @retorno = 'OK';

	Select
	    n.id_notificacao
	  , trim(cast(n.cd_notificacao as varchar(10))) as cd_notificacao
	  , convert(varchar(10), n.dt_notificacao, 103) as dt_notificacao
	  , convert(varchar(10), n.dt_notificacao, 108) as hr_notificacao
	  , n.ds_notificacao
	  , n.tx_notificacao
	  , n.sn_destacada
	from dbo.tb_notificacao n
	where (n.id_usuario = @usuario)
	  and (n.id_empresa = @empresa)
	  and (n.sn_lida = 0);
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar listar notificações do usuário';
END CATCH
GO
