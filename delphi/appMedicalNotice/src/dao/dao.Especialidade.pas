unit dao.Especialidade;

interface

uses
  classes.ScriptDDL,
  model.Especialidade,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TEspecialidadeDao = class(TObject)
    strict private
      aDDL   : TScriptDDL;
      aModel : TEspecialidade;
      aLista : TEspecialidades;
      constructor Create();
      class var aInstance : TEspecialidadeDao;
    public
      property Model : TEspecialidade read aModel write aModel;
      property Lista : TEspecialidades read aLista write aLista;

      procedure Load(); virtual; abstract;
      procedure Insert();
      procedure Update();
      procedure AddLista;

      function Find(const aCodigo : Integer; const IsLoadModel : Boolean) : Boolean;

      class function GetInstance : TEspecialidadeDao;
  end;

implementation

{ TEspecialidadeDao }

uses
  UDados;

procedure TEspecialidadeDao.AddLista;
var
  I : Integer;
  o : TEspecialidade;
begin
  I := High(aLista) + 2;
  o := TEspecialidade.Create;

  if (I <= 0) then
    I := 1;

  SetLength(aLista, I);
  aLista[I - 1] := o;
end;

constructor TEspecialidadeDao.Create();
begin
  inherited Create;
  aDDL   := TScriptDDL.GetInstance;
  aModel := TEspecialidade.Create;
  SetLength(aLista, 0);
end;

function TEspecialidadeDao.Find(const aCodigo: Integer;
  const IsLoadModel : Boolean): Boolean;
var
  aSQL : TStringList;
  aRetorno : Boolean;
begin
  aRetorno := False;
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Select * ');
    aSQL.Add('from ' + aDDL.getTableNameEspecialidade);
    aSQL.Add('where cd_especialidade = ' + IntToStr(aCodigo));
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      if qrySQL.OpenOrExecute then
      begin
        aRetorno := (qrySQL.RecordCount > 0);
        if aRetorno and IsLoadModel then
        begin
          Model.Codigo    := FieldByName('cd_especialidade').AsInteger;
          Model.Descricao := FieldByName('ds_especialidade').AsString;
        end;
      end;
      qrySQL.Close;
    end;
  finally
    aSQL.Free;
    Result := aRetorno;
  end;
end;

class function TEspecialidadeDao.GetInstance: TEspecialidadeDao;
begin
  if not Assigned(aInstance) then
    aInstance := TEspecialidadeDao.Create();

  Result := aInstance;
end;

procedure TEspecialidadeDao.Insert;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Insert Into ' + aDDL.getTableNameEspecialidade + '(');
    aSQL.Add('    cd_especialidade ');
    aSQL.Add('  , ds_especialidade ');
    aSQL.Add(') values (');
    aSQL.Add('    :cd_especialidade ');
    aSQL.Add('  , :ds_especialidade ');
    aSQL.Add(')');
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('cd_especialidade').AsInteger := Model.Codigo;
      ParamByName('ds_especialidade').AsString  := Model.Descricao;
      ExecSQL;
    end;
  finally
    aSQL.Free;
  end;
end;

procedure TEspecialidadeDao.Update;
var
  aSQL : TStringList;
begin
  aSQL := TStringList.Create;
  try
    aSQL.BeginUpdate;
    aSQL.Add('Update ' + aDDL.getTableNameEspecialidade + ' Set');
    aSQL.Add('  ds_especialidade     = :ds_especialidade');
    aSQL.Add('where cd_especialidade = :cd_especialidade');
    aSQL.EndUpdate;
    with DtmDados, qrySQL do
    begin
      qrySQL.Close;
      qrySQL.SQL.Text := aSQL.Text;

      ParamByName('cd_especialidade').AsInteger := Model.Codigo;
      ParamByName('ds_especialidade').AsString  := Model.Descricao;
      ExecSQL;
    end;
  finally
    aSQL.Free;
  end;
end;

end.
