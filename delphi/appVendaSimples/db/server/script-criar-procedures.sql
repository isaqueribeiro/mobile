-- =============================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	27/09/2019
-- Description	:	Validar Usuário/Senha
-- =============================================
CREATE or ALTER PROCEDURE dbo.getValidarLogin(
	@email	 VARCHAR(150)
  , @senha	 VARCHAR(40)
  , @id		 VARCHAR(38)  OUT
  , @codigo	 BIGINT		  OUT
  , @nome	 VARCHAR(150) OUT
  , @retorno VARCHAR(250) OUT)
AS
BEGIN TRY
  Declare @senhaTMP VARCHAR(40);
  Declare @senhaDB VARCHAR(40);

  Set @id		= '{00000000-0000-0000-0000-000000000000}';
  Set @codigo	= 0;
  Set @nome		= '';
  Set @retorno	= 'OK';

  Select
      @id		= u.id_usuario
	, @codigo	= u.cd_usuario
	, @nome		= u.nm_usuario
	, @senhaDB	= u.ds_senha
  from dbo.sys_usuario u
  where (u.ds_email = @email);

  If (ISNULL(@codigo, 0) = 0)
  Begin
    Set @retorno = 'E-mail inválido';
  End 
  Else
  Begin
	Set @senhaTMP = Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', @senha)), 3, 40));

	If ((@senhaTMP = @senhaDB) or (SUBSTRING(@senha, 3, 40) = @senhaDB))
	  Set @retorno = 'OK';
	Else
	  Set @retorno = 'E-mail/Senha inválidos'; 
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
  , @senha	 VARCHAR(40)
  , @id		 VARCHAR(38)  OUT
  , @codigo	 BIGINT		  OUT
  , @retorno VARCHAR(250) OUT)
AS
BEGIN TRY
  Declare @senhaTMP VARCHAR(40);

  Set @id		= '{00000000-0000-0000-0000-000000000000}';
  Set @codigo	= 0;
  Set @retorno	= 'OK';

  Select
      @id		= u.id_usuario
	, @codigo	= u.cd_usuario
  from dbo.sys_usuario u
  where (u.ds_email = @email);

  If (ISNULL(@codigo, 0) > 0)
  Begin
    Set @retorno = 'E-mail/Conta já está em uso';
  End 
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
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar criar usuário';
END CATCH
GO
