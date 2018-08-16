unit classes.HttpConnect;

interface

uses
  REST.Client,
  Web.HTTPApp,
  REST.Types,
  classes.Constantes,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  THttpConnectJSON = class(TObject)
    strict private
      aRESTClient   : TRESTClient;
      aRESTRequest  : TRESTRequest;
      aRESTResponse : TRESTResponse;
      aServerBaseURL,
      aKey          : String;
      constructor Create(const AOnwer : TComponent;
        const aBaseUrl, aHashKey : String);
      procedure SetKey(Value : String);
      procedure GetServerBaseURL(Value : String);
      class var aInstance : THttpConnectJSON;
    public
      class function GetInstance(const AOnwer : TComponent;
        const aBaseUrl, aHashKey : String) : THttpConnectJSON;
      property ServerBaseURL : String read aServerBaseURL write GetServerBaseURL;
      property Key : String read aKey write SetKey;
  end;

implementation

{ THttpConnectJSON }

constructor THttpConnectJSON.Create(const AOnwer : TComponent;
  const aBaseUrl, aHashKey : String);
begin
  inherited Create;
  aServerBaseURL := Trim(aServerBaseURL);
  aKey := Trim(aHashKey);

  aRESTClient := TRESTClient.Create(aBaseUrl);
  with aRESTClient do
  begin
    Params.Clear;
    Accept         := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
    AcceptCharset  := 'UTF-8, *;q=0.8';
    AcceptEncoding := 'identity';
    BaseURL        := aBaseUrl;
    HandleRedirects     := True;
    RaiseExceptionOn500 := False;
  end;

  aRESTResponse := TRESTResponse.Create(AOnwer);
  aRESTResponse.ContentType := 'application/json';

  aRESTRequest := TRESTRequest.Create(AOnwer);
  with aRESTRequest do
  begin
    Params.Clear;
    Client   := aRESTClient;
    Method   := rmGET;
    Response := aRESTResponse;
    Resource := 'key=' + Trim(aKey);
    SynchronizedEvents := False;
  end;
end;

class function THttpConnectJSON.GetInstance(const AOnwer: TComponent;
  const aBaseUrl, aHashKey: String): THttpConnectJSON;
begin
  if not Assigned(aInstance) then
    aInstance := THttpConnectJSON.Create(AOnwer, aBaseUrl, aHashKey)
  else
  begin
    aInstance.ServerBaseURL := aBaseUrl;
    aInstance.Key := aHashKey;
  end;

  Result := aInstance;
end;

procedure THttpConnectJSON.GetServerBaseURL(Value: String);
begin
  aServerBaseURL := Trim(Value);
  if Assigned(aRESTClient) then
    aRESTClient.BaseURL := aServerBaseURL;
end;

procedure THttpConnectJSON.SetKey(Value: String);
begin
  aKey := Trim(Value);
  if Assigned(aRESTRequest) then
    aRESTRequest.Resource := 'key=' + aKey;
end;

end.
