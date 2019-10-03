SELECT
    1 as id
  , sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'minhaSenha')) as md50
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'minhaSenha')), 3, 32) as md51
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'minhaSenha')), 3, 32)) as md52
  , sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'minhaSenha')) as sha10
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'minhaSenha')), 3, 40) as sha11
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'minhaSenha')), 3, 40)) as sha12

Union

SELECT 
    2 as id
  , sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'admin')) as md50
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'admin')), 3, 32) as md51
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'admin')), 3, 32)) as md52
  , sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'admin')) as sha10
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'admin')), 3, 40) as sha11
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'admin')), 3, 40)) as sha12

Union

SELECT 
    3 as id
  , sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'TheLordIsGod')) as md50
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'TheLordIsGod')), 3, 32) as md51
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'TheLordIsGod')), 3, 32)) as md52
  , sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'TheLordIsGod')) as sha10
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'TheLordIsGod')), 3, 40) as sha11
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'TheLordIsGod')), 3, 40)) as sha12

Union

SELECT 
    4 as id
  , sys.fn_sqlvarbasetostr(HASHBYTES('MD5', '0x231c5c6b82dff43b908876db4c57a9ad7129beb5')) as md50
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', '0x231c5c6b82dff43b908876db4c57a9ad7129beb5')), 3, 32) as md51
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', '0x231c5c6b82dff43b908876db4c57a9ad7129beb5')), 3, 32)) as md52
  , sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', '0x231c5c6b82dff43b908876db4c57a9ad7129beb5')) as sha10
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', '0x231c5c6b82dff43b908876db4c57a9ad7129beb5')), 3, 40) as sha11
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', '0x231c5c6b82dff43b908876db4c57a9ad7129beb5')), 3, 40)) as sha12

--         10        20        30        40
-- 1234567890123456789012345678901234567890
-- 25EEF25B04B2113A23697A1E81453201
-- 25EEF25B04B2113A23697A1E81453201
-- FB5F1FE7AB91EC34F226281AEF83FC3A20B96F51
-- FB5F1FE7AB91EC34F226281AEF83FC3A20B96F51
-- 231C5C6B82DFF43B908876DB4C57A9AD7129BEB5
-- 242F335B8F9A04CE6C018BCE073974A824513179

