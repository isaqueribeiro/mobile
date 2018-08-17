unit model.Especialidade;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TEspecialidade = class(TObject)
    private
      aCodigo    : Integer;
      aDescricao : String;
      procedure SetDescricao(const Value: String);
    public
      constructor Create; overload;

      property Codigo    : Integer read aCodigo write aCodigo;
      property Descricao : String read aDescricao write SetDescricao;

      function ToString : String; override;
  end;

  TEspecialidades = Array of TEspecialidade;

implementation

{ TEspecialidade }

constructor TEspecialidade.Create;
begin
  inherited Create;
  aCodigo    := 0;
  aDescricao := EmptyStr;
end;

procedure TEspecialidade.SetDescricao(const Value: String);
begin
  aDescricao := Trim(Value);
end;

function TEspecialidade.ToString: String;
begin
  Result := aDescricao;
end;

end.
