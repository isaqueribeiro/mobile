SELECT 
    sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'minhaSenha')) as md50
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'minhaSenha')), 3, 32) as md51
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('MD5', 'minhaSenha')), 3, 32)) as md52
  , sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'minhaSenha')) as sha10
  , SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'minhaSenha')), 3, 40) as sha11
  , Upper(SUBSTRING(sys.fn_sqlvarbasetostr(HASHBYTES('SHA1', 'minhaSenha')), 3, 40)) as sha12


-- 1234567890123456789012345678901234567890
-- 25EEF25B04B2113A23697A1E81453201
-- 25EEF25B04B2113A23697A1E81453201
-- FB5F1FE7AB91EC34F226281AEF83FC3A20B96F51
-- FB5F1FE7AB91EC34F226281AEF83FC3A20B96F51