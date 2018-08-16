unit classes.ScriptDDL;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TScriptDDL = class(TObject)
    private
      class var aInstance : TScriptDDL;
      const
        TABLE_USUARIO       = 'app_usuario';
        TABLE_ESPECIALIDADE = 'app_especialidade';
    public
      class function GetInstance : TScriptDDL;
      function getCreateTableEspecialidade : TStringList;
      function getCreateTableUsuario : TStringList;
  end;

implementation

{ TScriptDDL }

function TScriptDDL.getCreateTableEspecialidade: TStringList;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.Clear;
    aSQL.BeginUpdate;
    aSQL.Add('CREATE TABLE IF NOT EXISTS ' + TABLE_ESPECIALIDADE + ' (');
    aSQL.Add('      cd_especialidade INTEGER NOT NULL PRIMARY KEY');
    aSQL.Add('    , ds_especialidade STRING (50)');
    aSQL.Add(')');
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
    aSQL.Add('      id_usuario    STRING (38) NOT NULL PRIMARY KEY');
    aSQL.Add('    , cd_usuario    STRING (30) NOT NULL');
    aSQL.Add('    , nm_usuario    STRING (50)');
    aSQL.Add('    , ds_email      STRING (50)');
    aSQL.Add('    , ds_senha      STRING (100)');
    aSQL.Add('    , cd_prestador  NUMERIC');
    aSQL.Add('    , ds_observacao STRING (50)');
    aSQL.Add('    , sn_ativo      STRING (1) NOT NULL');
    aSQL.Add(')');
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

end.
