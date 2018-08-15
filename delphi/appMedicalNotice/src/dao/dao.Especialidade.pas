unit dao.Especialidade;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  model.Especialidade;

type
  TEspecialidadeDao = class(TObject)
    private
      aModel : TEspecialidade;
      aLista : TEspecialidades;

      constructor Create; overload;
    public
      property Model : TEspecialidade read aModel write aModel;
      property Lista : TEspecialidades read aLista write aLista;
  end;

implementation

{ TEspecialidadeDao }

uses UDados;

constructor TEspecialidadeDao.Create;
begin
  inherited Create;
  aModel := TEspecialidade.Create;
  SetLength(aLista, 0);
end;

end.
