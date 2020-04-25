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

-- =================================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	16/04/2020
-- Description	:	Processar upload de clientes
-- =================================================
CREATE or ALTER PROCEDURE dbo.spProcessarClientes(
	@usuario	VARCHAR(38)
  , @empresa	VARCHAR(38)
  , @token		VARCHAR(42)
  , @id			VARCHAR(38)  OUT
  , @data		VARCHAR(10)  OUT
  , @retorno	VARCHAR(250) OUT)
AS
DECLARE 
  @id_cliente		VARCHAR(38),
  @cd_cliente		INT,
  @nm_cliente		VARCHAR(250),
  @nr_cnpj_cpf		VARCHAR(25),
  @nm_contato		VARCHAR(50),
  @nr_telefone		VARCHAR(25),
  @nr_celular		VARCHAR(25),
  @ds_email			VARCHAR(150),
  @ds_endereco		VARCHAR(500),
  @ds_observacao	VARCHAR(500),
  @sn_ativo			CHAR(1);
BEGIN TRY
  Declare cursor_clientes CURSOR FOR
	Select
	    x.id_cliente
	  , x.nm_cliente
	  , x.nr_cnpj_cpf
	  , x.nm_contato
	  , x.nr_telefone
	  , x.nr_celular
	  , x.ds_email
	  , x.ds_endereco
	  , x.ds_observacao
	  , x.sn_ativo		
	from dbo.tb_cliente_temp x
	where (x.id_usuario = @usuario)
	  and (x.id_empresa = @empresa);

  Declare @id_usuario VARCHAR(38);
  Declare @cd_usuario BIGINT;
  Declare @id_empresa VARCHAR(38);
  Declare @cd_empresa INT;

  Set @id_usuario = '{00000000-0000-0000-0000-000000000000}';
  Set @cd_usuario = 0;
  Set @id_empresa = '{00000000-0000-0000-0000-000000000000}';
  Set @cd_empresa = 0;

  Set @id = dbo.ufnGetGuidID();
  Set @data = convert(varchar(10), getdate(), 103);
  Set @retorno = 'OK';

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
	Select
	    @id_usuario = usr.id_usuario
	  , @cd_usuario	= usr.cd_usuario
	from dbo.sys_usuario usr
	where (usr.id_usuario = @usuario);

	Select
	    @id_empresa = emp.id_empresa
	  , @cd_empresa	= emp.cd_empresa
	from dbo.sys_empresa emp
	where (emp.id_empresa = @empresa);

	If (ISNULL(@cd_usuario, 0) = 0)
	  Set @retorno = 'Usuário não registrado';
	Else
	Begin   
	  Open cursor_clientes; 
	  Fetch cursor_clientes Into
		  @id_cliente
		, @nm_cliente
		, @nr_cnpj_cpf
		, @nm_contato
		, @nr_telefone
		, @nr_celular
		, @ds_email
		, @ds_endereco
		, @ds_observacao
		, @sn_ativo;
      
	  while (@@FETCH_STATUS <> -1) 
	  Begin
	    
	    -- Cadastrar Cliente
		if (not exists(
		  Select
		    c.id_cliente
		  from dbo.tb_cliente c
		  where c.id_cliente = @id_cliente
		))
		Begin
		  Insert Into dbo.tb_cliente (
			  id_cliente
			, nm_cliente
			, nr_cnpj_cpf
			, nm_contato
			, nr_telefone
			, nr_celular
			, ds_email
			, ds_endereco
			, ds_observacao
			, dt_ult_edicao
			, sn_ativo
		  ) values (
			  @id_cliente --dbo.ufnGetGuidID()
			, @nm_cliente
			, @nr_cnpj_cpf
			, @nm_contato
			, @nr_telefone
			, @nr_celular
			, @ds_email
			, @ds_endereco
			, @ds_observacao
			, getdate()
			, Case when @sn_ativo = 'S' then 1 else 0 end
		  );
		End 
	    Else 
		Begin
		  Update dbo.tb_cliente Set
		      nm_cliente	= @nm_cliente
		    , nr_cnpj_cpf	= @nr_cnpj_cpf
		    , nm_contato	= @nm_contato
		    , nr_telefone	= @nr_telefone
		    , nr_celular	= @nr_celular
		    , ds_email		= @ds_email
		    , ds_endereco	= @ds_endereco
		    , ds_observacao	= @ds_observacao
		    , sn_ativo		= Case when @sn_ativo = 'S' then 1 else 0 end
			, dt_ult_edicao = getdate()
		  where (id_cliente = @id_cliente);
		End
	    
	    -- Associar Cliente x Usuário
		if (not exists(
		  Select
		    u.id_cliente
		  from dbo.tb_cliente_usuario u
		  where u.id_cliente = @id_cliente
		    and u.id_usuario = @id_usuario
		))	  
	    Begin
		  Insert Into dbo.tb_cliente_usuario (
		      id_cliente
			, id_usuario
		  ) values (
		      @id_cliente
			, @id_usuario
		  );
		End
	    
	    -- Associar Cliente x Empresa, caso ela esteja cadastrada
	    If (ISNULL(@cd_empresa, 0) > 0)
		Begin
		  if (not exists(
			Select
			  e.id_cliente
			from dbo.tb_cliente_empresa e
			where e.id_cliente = @id_cliente
			  and e.id_empresa = @id_empresa
		  ))	  
		  Begin
			Insert Into dbo.tb_cliente_empresa (
				id_cliente
			  , id_empresa
			) values (
				@id_cliente
			  , @id_empresa
			);
		  End
		End
		
		Fetch cursor_clientes Into
		    @id_cliente
		  , @nm_cliente
		  , @nr_cnpj_cpf
		  , @nm_contato
		  , @nr_telefone
		  , @nr_celular
		  , @ds_email
		  , @ds_endereco
		  , @ds_observacao
		  , @sn_ativo;
	  End
	  
	  Close cursor_clientes;
	  Deallocate cursor_clientes;  
    End 
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar processar os clientes enviados';
END CATCH
GO

-- =================================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	17/04/2020
-- Description	:	Listar Clientes do Usuário
-- =================================================
CREATE or ALTER PROCEDURE dbo.getListarClientes(
	@usuario	VARCHAR(38)
  , @empresa	VARCHAR(38)
  , @data		VARCHAR(25)
  , @token		VARCHAR(42)
  , @atualizacao DATETIME OUT
  , @retorno	 VARCHAR(250) OUT)
AS
DECLARE 
  @data_atualizacao DATETIME;
BEGIN TRY
  Set @atualizacao = getdate();

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
    If (coalesce(trim(@data), '') <> '')
	  Set @data_atualizacao = convert(DATETIME, @data, 103);

	Set @retorno = 'OK';

	Select
	    c.id_cliente
	  , trim(cast(c.cd_ciente as varchar(10))) as cd_cliente
	  , isnull(c.nm_cliente, '')    as nm_cliente
	  , isnull(c.nr_cnpj_cpf, '')   as nr_cnpj_cpf
	  , isnull(c.nm_contato, '')    as nm_contato
	  , isnull(c.nr_telefone, '')   as nr_telefone
	  , isnull(c.nr_celular, '')    as nr_celular
	  , isnull(c.ds_email, '')      as ds_email
	  , isnull(c.ds_endereco, '')   as ds_endereco
	  , isnull(c.ds_observacao, '') as ds_observacao
	  , c.sn_ativo
	from dbo.tb_cliente c
	  inner join (
	    Select distinct
		  z.id_cliente
		from (
  		  Select
			u.id_cliente
		  from dbo.tb_cliente_usuario u
		  where u.id_usuario = @usuario

		  union

		  Select 
			e.id_cliente
		  from dbo.tb_cliente_empresa e 
		  where e.id_empresa = @empresa
		) z
	  ) a on (a.id_cliente = c.id_cliente)
	where (c.sn_ativo = 1)
	  and ((c.dt_ult_edicao > @data_atualizacao) or (@data_atualizacao is null));
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar listar clientes do usuário';
END CATCH
GO

-- =================================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	22/04/2020
-- Description	:	Processar upload de Produtos
-- =================================================
CREATE or ALTER PROCEDURE dbo.spProcessarProdutos(
	@usuario	VARCHAR(38)
  , @empresa	VARCHAR(38)
  , @token		VARCHAR(42)
  , @id			VARCHAR(38)  OUT
  , @data		DATETIME	 OUT
  , @retorno	VARCHAR(250) OUT)
AS
DECLARE 
  @id_produto		VARCHAR(38),
  @cd_produto		INT,
  @br_produto		VARCHAR(38),
  @ds_produto		VARCHAR(200),
  @ft_produto		VARCHAR(MAX),
  @vl_produto		NUMERIC(18,2),
  @sn_ativo			CHAR(1);
BEGIN TRY
  Declare cursor_produtos CURSOR FOR
	Select
	    x.id_produto
	  , x.br_produto
	  , x.ds_produto
	  , x.ft_produto
	  , x.vl_produto
	  , x.sn_ativo
	from dbo.tb_produto_temp x
	where (x.id_usuario = @usuario)
	  and (x.id_empresa = @empresa);

  Declare @id_usuario VARCHAR(38);
  Declare @cd_usuario BIGINT;
  Declare @id_empresa VARCHAR(38);
  Declare @cd_empresa INT;

  Set @id_usuario = '{00000000-0000-0000-0000-000000000000}';
  Set @cd_usuario = 0;
  Set @id_empresa = '{00000000-0000-0000-0000-000000000000}';
  Set @cd_empresa = 0;

  Set @id = dbo.ufnGetGuidID();
  Set @data = getdate();
  Set @retorno = 'OK';

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
	Select
	    @id_usuario = usr.id_usuario
	  , @cd_usuario	= usr.cd_usuario
	from dbo.sys_usuario usr
	where (usr.id_usuario = @usuario);

	Select
	    @id_empresa = emp.id_empresa
	  , @cd_empresa	= emp.cd_empresa
	from dbo.sys_empresa emp
	where (emp.id_empresa = @empresa);

	If (ISNULL(@cd_usuario, 0) = 0)
	  Set @retorno = 'Usuário não registrado';
	Else
	Begin   
	  Open cursor_produtos; 
	  Fetch cursor_produtos Into
		  @id_produto
		, @br_produto
		, @ds_produto
		, @ft_produto
		, @vl_produto
		, @sn_ativo;
      
	  while (@@FETCH_STATUS <> -1) 
	  Begin
	    
	    -- Cadastrar Produto
		if (not exists(
		  Select
		    p.id_produto
		  from dbo.tb_produto p
		  where p.id_produto = @id_produto
		))
		Begin
		  Insert Into dbo.tb_produto (
			  id_produto
			, ds_produto
		    , br_produto
			, vl_produto
			, dt_ult_edicao
		  ) values (
			  @id_produto
			, @ds_produto
			, @br_produto
			, @vl_produto
			, getdate()
		  );
		End 
	    Else 
		Begin
		  Update dbo.tb_produto Set
		      ds_produto	= @ds_produto
			, br_produto	= @br_produto
			, vl_produto	= @vl_produto
			, dt_ult_edicao = getdate()
		  where (id_produto = @id_produto);
		End
	    
	    -- Associar Produto x Usuário
		if (not exists(
		  Select
		    u.id_produto
		  from dbo.tb_produto_usuario u
		  where u.id_produto = @id_produto
		    and u.id_usuario = @id_usuario
		))	  
	    Begin
		  Insert Into dbo.tb_produto_usuario (
		      id_produto
			, id_usuario
			, ft_produto
			, vl_produto
			, sn_ativo
		  ) values (
		      @id_produto
			, @id_usuario
			, @ft_produto
			, @vl_produto
			, Case when @sn_ativo = 'S' then 1 else 0 end
		  );
		End
		Else
		Begin
		  Update dbo.tb_produto_usuario Set
			  ft_produto = @ft_produto
			, vl_produto = @vl_produto
			, sn_ativo	 = Case when @sn_ativo = 'S' then 1 else 0 end
		  where id_produto = @id_produto
		    and id_usuario = @id_usuario;
		End
	    
	    -- Associar Produto x Empresa, caso ela esteja cadastrada
	    If (ISNULL(@cd_empresa, 0) > 0)
		Begin
		  if (not exists(
			Select
			  e.id_produto
			from dbo.tb_produto_empresa e
			where e.id_produto = @id_produto
			  and e.id_empresa = @id_empresa
		  ))	  
		  Begin
			Insert Into dbo.tb_produto_empresa (
				id_produto
			  , id_empresa
			  , ft_produto
			  , vl_produto
			  , sn_ativo
			) values (
				@id_produto
			  , @id_empresa
			  , @ft_produto
			  , @vl_produto
			  , Case when @sn_ativo = 'S' then 1 else 0 end
			);
		  End
		  Else
		  Begin
		    Update dbo.tb_produto_empresa Set
			    ft_produto = @ft_produto
			  , vl_produto = @vl_produto
			  , sn_ativo   = Case when @sn_ativo = 'S' then 1 else 0 end
			where id_produto = @id_produto
			  and id_empresa = @id_empresa;
		  End
		End
		
		Fetch cursor_produtos Into
			@id_produto
		  , @br_produto
		  , @ds_produto
		  , @ft_produto
		  , @vl_produto
		  , @sn_ativo;
	  End
	  
	  Close cursor_produtos;
	  Deallocate cursor_produtos;  
    End 
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar processar os produtos enviados';
END CATCH
GO

-- =================================================
-- Author		:	Isaque M. Ribeiro
-- Create date	:	25/04/2020
-- Description	:	Listar Produtos do Usuário
-- =================================================
CREATE or ALTER PROCEDURE dbo.getListarProdutos(
	@usuario	VARCHAR(38)
  , @empresa	VARCHAR(38)
  , @data		VARCHAR(25)
  , @token		VARCHAR(42)
  , @atualizacao DATETIME OUT
  , @retorno	 VARCHAR(250) OUT)
AS
DECLARE 
  @data_atualizacao DATETIME;
BEGIN TRY
  Set @atualizacao = getdate();

  if (@token != UPPER(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', concat('TheLordIsGod', convert(varchar(10), getdate(), 103))))))
    Set @retorno = 'Token Inválido';
  Else
  Begin
    If (coalesce(trim(@data), '') <> '')
	  Set @data_atualizacao = convert(DATETIME, @data, 103);
	Else
	  Set @data_atualizacao = NULL;

	Set @retorno = 'OK';

	Select
	    p.id_produto
	  , trim(cast(p.cd_produto as varchar(10))) as cd_produto
	  , isnull(p.ds_produto, '')   as ds_produto
	  , isnull(p.br_produto, '')   as br_produto
	  , coalesce(e.ft_produto, u.ft_produto, '') as ft_produto
	  , convert(varchar(20), convert(BIGINT, coalesce(e.vl_produto, u.vl_produto, p.vl_produto, 0) * 100)) as vl_produto
	  , coalesce(e.sn_ativo, u.sn_ativo, 0) as sn_ativo
	from dbo.tb_produto p
	  inner join (
	    Select distinct
		  z.id_produto
		from (
  		  Select
			u.id_produto
		  from dbo.tb_produto_usuario u
		  where u.id_usuario = @usuario

		  union

		  Select 
			e.id_produto
		  from dbo.tb_produto_empresa e 
		  where e.id_empresa = @empresa
		) z
	  ) a on (a.id_produto = p.id_produto)

	  left join dbo.tb_produto_usuario u on (u.id_produto = p.id_produto and u.id_usuario = @usuario)
	  left join dbo.tb_produto_empresa e on (e.id_produto = p.id_produto and e.id_empresa = @empresa)

	where (coalesce(e.sn_ativo, u.sn_ativo, 0) = 1)
	  and ((p.dt_ult_edicao > @data_atualizacao) or (@data_atualizacao is null));
  End
END TRY

BEGIN CATCH
  Set @retorno = 'Erro ao tentar listar produtos do usuário';
END CATCH
GO
