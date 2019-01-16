unit dao.Versao;

interface

uses
  UConstantes,
  classes.ScriptDDL,
  model.Versao,

  System.StrUtils, System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants, FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TVersaoDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TVersao;
      constructor Create();
      class var aInstance : TVersaoDao;
    public
      property Model : TVersao read aModel write aModel;

      procedure Load();
      procedure Delete();
      procedure Insert();

      class function GetInstance : TVersaoDao;
  end;

implementation

uses
  UDM;

{ TVersaoDao }

constructor TVersaoDao.Create;
begin
  inherited Create;
  aDDL   := TScriptDDL.GetInstance;
  aModel := TVersao.GetInstance;
end;

procedure TVersaoDao.Delete();
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Delete from ' + aDDL.getTableNameVersao);
    aSQL.EndUpdate;
    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;
      qrySQL.ExecSQL;
    end;
  finally
    aSQL.Free;
  end;
end;

class function TVersaoDao.GetInstance: TVersaoDao;
begin
  if not Assigned(aInstance) then
    aInstance := TVersaoDao.Create();

  Result := aInstance;
end;

procedure TVersaoDao.Insert();
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Insert Into ' + aDDL.getTableNameVersao + '(');
    aSQL.Add('    cd_versao  ');
    aSQL.Add('  , ds_versao  ');
    aSQL.Add('  , dt_versao  ');
    aSQL.Add(') values (     ');
    aSQL.Add('    :cd_versao ');
    aSQL.Add('  , :ds_versao ');
    aSQL.Add('  , :dt_versao ');
    aSQL.Add(')');
    aSQL.EndUpdate;

    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if (aModel.Codigo = 0) then
      begin
        aModel.Codigo    := VERSION_CODE;
        aModel.Descricao := VERSION_NAME;
      end;

      ParamByName('cd_versao').AsInteger  := aModel.Codigo;
      ParamByName('ds_versao').AsString   := aModel.Descricao;
      ParamByName('dt_versao').AsDateTime := aModel.Data;
      ExecSQL;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TVersaoDao.Load;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select * ');
    aSQL.Add('from ' + aDDL.getTableNameVersao);
    aSQL.EndUpdate;
    with DM, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno then
        begin
          Model.Codigo    := FieldByName('cd_versao').AsInteger;
          Model.Descricao := FieldByName('ds_versao').AsString;
          Model.Data      := FieldByName('dt_versao').AsDateTime;
        end
        else
        begin
          Model.Codigo    := 0;
          Model.Descricao := EmptyStr;
          Model.Data      := Date;
        end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
  end;
end;

end.
