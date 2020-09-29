unit Model.Lista.Generics;

interface

type
  TListaModel<T : class, constructor> = class
    private
      FLista : T;
    protected
      constructor Create;
    public
      destructor Destroy; override;
      procedure Add(aModel : T);
  end;
implementation

{ TListaModel<T> }

procedure TListaModel<T>.Add(aModel: T);
var
  I : Integer;
begin
  FLista[I] := aModel;
end;

constructor TListaModel<T>.Create;
begin
  FLista := T.Create;
  SetLength(FLista, 0);
end;

destructor TListaModel<T>.Destroy;
var
  I : Integer;
begin
  for I := Low(FLista) to High(FLista) do
    TObject(FLista[I]).DisposeOf;

  inherited;
end;

end.
