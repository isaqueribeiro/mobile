unit model.Notificacao;

interface

uses
  UConstantes,
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  TNotificacao = class(TObject)
    private
      aID     : TGUID;
      aCodigo : Currency;
      aData   : TDateTime;
      aTitulo   ,
      aMensagem : String;
      aLida     ,
      aDestacar : Boolean;

      procedure SetTitulo(Value : String);
      procedure SetMensagem(Value : String);
    public
      constructor Create; overload;

      property ID     : TGUID read aID write aID;
      property Codigo : Currency read aCodigo write aCodigo;
      property Data   : TDateTime read aData write aData;
      property Titulo : String read aTitulo write SetTitulo;
      property Mensagem : String read aMensagem write SetMensagem;
      property Lida     : Boolean read aLida write aLida;
      property Destacar : Boolean read aDestacar write aDestacar;

      procedure NewID;

      function ToString : String; override;
  end;

  TNotificacoes = Array of TNotificacao;

implementation

{ TNotificacao }

constructor TNotificacao.Create;
begin
  inherited Create;
  aId       := GUID_NULL;
  aCodigo   := 0;
  aData     := StrToDate(EMPTY_DATE);
  aTitulo   := EmptyStr;
  aMensagem := EmptyStr;
  aLida     := False;
  aDestacar := False;
end;

procedure TNotificacao.NewID;
var
  aGuid : TGUID;
begin
  CreateGUID(aGuid);
  aId := aGuid;
end;

procedure TNotificacao.SetMensagem(Value: String);
begin
  aMensagem := Trim(Value);
end;

procedure TNotificacao.SetTitulo(Value: String);
begin
  aTitulo := Trim(Value);
end;

function TNotificacao.ToString: String;
begin
  Result := 'Notigicação #' + FormatFloat('##000', aCodigo) + ' - ' + aTitulo;
end;

end.
