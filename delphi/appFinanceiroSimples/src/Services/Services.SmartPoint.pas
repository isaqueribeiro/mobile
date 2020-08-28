unit Services.SmartPoint;

// DICA:
// https://www.youtube.com/watch?v=H2iDz8q-E6o

interface

type
  TSmartPointer<T : class, constructor> = record
    strict private
      FClasse : T;
      FFreeTheClasse : IInterface;
      function GetClasse : T;
    public
      class operator Implicit(smart : TSmartPointer<T>) : T;
      class operator Implicit(Value : T) : TSmartPointer<T>;

      constructor Create(Value : T);

      property Classe : T read GetClasse;
  end;

  TFreeTheClasse = class(TInterfacedObject)
    private
      FObjectToFree : TObject;
    public
      constructor Create(anObjectToFree : TObject);
      destructor Destroy; override;
  end;

implementation

{ TSmartPointer<T> }

constructor TSmartPointer<T>.Create(Value: T);
begin
  FClasse := Value;
  FFreeTheClasse := TFreeTheClasse.Create(FClasse);
end;

function TSmartPointer<T>.GetClasse: T;
begin
  if not Assigned(FFreeTheClasse) then
    Self := TSmartPointer<T>.Create(T.Create);

  Result := FClasse;
end;

class operator TSmartPointer<T>.Implicit(Value: T): TSmartPointer<T>;
begin
  Result := TSmartPointer<T>.Create(Value);
end;

class operator TSmartPointer<T>.Implicit(smart: TSmartPointer<T>): T;
begin
  Result := smart.Classe;
end;

{ TFreeTheClasse }

constructor TFreeTheClasse.Create(anObjectToFree: TObject);
begin
  FObjectToFree := anObjectToFree;
end;

destructor TFreeTheClasse.Destroy;
begin
  FObjectToFree.DisposeOf;
  inherited;
end;

end.
