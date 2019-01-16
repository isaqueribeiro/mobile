unit model.Versao;

interface

uses
  System.SysUtils, System.StrUtils, System.Types, System.UITypes, System.Classes,
  System.Variants;

type
  TVersao = class(TObject)
    strict private
      aCodigo    : Integer;
      aDescricao : String;
      aData      : TDateTime;
      constructor Create();
      class var aInstance : TVersao;
    public
      property Codigo    : Integer read aCodigo write aCodigo;
      property Descricao : String read aDescricao write aDescricao;
      property Data      : TDateTime read aData write aData;

      function ToString : String; override;

      class function GetInstance : TVersao;
  end;

implementation

{ TVersao }

constructor TVersao.Create;
begin
  inherited Create;
  aCodigo    := 0;
  aDescricao := EmptyStr;
  aData      := Date;
end;

class function TVersao.GetInstance: TVersao;
begin
  if not Assigned(aInstance) then
    aInstance := TVersao.Create();

  Result := aInstance;
end;

function TVersao.ToString: String;
begin
  Result := aDescricao;
end;

end.
