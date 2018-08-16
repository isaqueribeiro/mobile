unit dao.Especialidade;

interface

uses
  model.Especialidade,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TEspecialidadeDao = class(TObject)
    strict private
      aModel : TEspecialidade;
      aLista : TEspecialidades;
      constructor Create();
      class var aInstance : TEspecialidadeDao;
    public
      property Model : TEspecialidade read aModel write aModel;
      property Lista : TEspecialidades read aLista write aLista;

      procedure Load(); virtual; abstract;
      procedure Insert(); virtual; abstract;
      procedure Update(); virtual; abstract;

      function Find(const aCodigo : Integer) : Boolean; virtual; abstract;

      class function GetInstance : TEspecialidadeDao;
  end;

implementation

{ TEspecialidadeDao }

uses
  UDados;

constructor TEspecialidadeDao.Create();
begin
  inherited Create;
  aModel := TEspecialidade.Create;
  SetLength(aLista, 1);
  aLista[0] := aModel;
end;

class function TEspecialidadeDao.GetInstance: TEspecialidadeDao;
begin
  if not Assigned(aInstance) then
    aInstance := TEspecialidadeDao.Create();

  Result := aInstance;
end;

end.
