unit dao.Configuracao;

interface

uses
  UConstantes,
  classes.ScriptDDL,

  System.StrUtils,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet, UDM;

type
  TConfiguracaoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aOperacao : TTipoOperacaoDao;
      constructor Create();

      class var aInstance : TConfiguracaoDao;
    public
      procedure Delete(const aKey : String);

      function SetValue(const aKey, aValue : String) : Boolean;
      function GetValue(const aKey : String) : String;

      class function GetInstance : TConfiguracaoDao;
  end;

implementation

{ TConfiguracaoDao }

constructor TConfiguracaoDao.Create;
begin
  inherited Create;
  aDDL := TScriptDDL.GetInstance;
end;

procedure TConfiguracaoDao.Delete(const aKey: String);
var
  aRetorno : String;
  aQry : TFDQuery;
begin
  aRetorno := EmptyStr;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Delete from ' + aDDL.getTableNameConfiguracao);
      SQL.Add('where ky_campo = :ky_campo');
      SQL.EndUpdate;

      ParamByName('ky_campo').AsString := aKey.Trim.ToUpper;
      ExecSQL;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

class function TConfiguracaoDao.GetInstance: TConfiguracaoDao;
begin
  if not Assigned(aInstance) then
    aInstance := TConfiguracaoDao.Create();

  Result := aInstance;
end;

function TConfiguracaoDao.GetValue(const aKey: String): String;
var
  aRetorno : String;
  aQry : TFDQuery;
begin
  aRetorno := EmptyStr;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      SQL.BeginUpdate;
      SQL.Add('Select ');
      SQL.Add('  vl_campo');
      SQL.Add('from ' + aDDL.getTableNameConfiguracao);
      SQL.Add('where ky_campo = :ky_campo');
      SQL.EndUpdate;

      ParamByName('ky_campo').AsString := aKey.Trim.ToUpper;
      OpenOrExecute;

      aRetorno := FieldByName('vl_campo').AsString.Trim;
      aQry.Close;
    end;
  finally
    aQry.DisposeOf;
    Result := aRetorno;
  end;
end;

function TConfiguracaoDao.SetValue(const aKey, aValue: String): Boolean;
var
  aStr : String;
  aQry : TFDQuery;
begin
  Result := False;

  aStr := GetValue(aKey).Trim;
  aQry := TFDQuery.Create(DM);
  try
    aQry.Connection  := DM.conn;
    aQry.Transaction := DM.trans;
    aQry.UpdateTransaction := DM.trans;

    with DM, aQry do
    begin
      if (aStr = EmptyStr) then
      begin
        SQL.BeginUpdate;
        SQL.Add('Insert Into ' + aDDL.getTableNameConfiguracao + '(');
        SQL.Add('    ky_campo    ');
        SQL.Add('  , vl_campo    ');
        SQL.Add(') values (');
        SQL.Add('    :ky_campo   ');
        SQL.Add('  , :vl_campo   ');
        SQL.Add(')');
        SQL.EndUpdate;

        ParamByName('ky_campo').AsString  := aKey.Trim.ToUpper;
        ParamByName('vl_campo').AsString  := aValue.Trim;
      end
      else
      begin
        SQL.BeginUpdate;
        SQL.Add('Update ' + aDDL.getTableNameConfiguracao + ' Set');
        SQL.Add('    vl_campo   = :vl_campo  ');
        SQL.Add('where ky_campo = :ky_campo  ');
        SQL.EndUpdate;

        ParamByName('ky_campo').AsString  := aKey.Trim.ToUpper;
        ParamByName('vl_campo').AsString  := aValue.Trim;
      end;

      ExecSQL;
      Result := True;
    end;
  finally
    aQry.DisposeOf;
  end;
end;

end.
