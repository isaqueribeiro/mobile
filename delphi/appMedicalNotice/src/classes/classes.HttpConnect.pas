unit classes.HttpConnect;

interface

uses
  REST.Client,
  REST.Types,
  Web.HTTPApp,
  System.JSON,
  classes.Constantes,

  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants;

type
  THttpConnectJSON = class(TObject)
    strict private
      aRESTClient   : TRESTClient;
      aRESTRequest  : TRESTRequest;
      aRESTResponse : TRESTResponse;
      aKeyHash : String;
      procedure SetBaseURL(Value : String);
      procedure SetResourcePage(Value : String);

      function GetBaseURL : String;
      function GetResourcePage : String;
      constructor Create(const AOnwer : TComponent;
        const aBaseUrl, aHash : String);
      class var aInstance : THttpConnectJSON;
    public
      property BaseURL      : String read GetBaseURL write SetBaseURL;
      property ResourcePage : String read GetResourcePage write SetResourcePage;
      property KeyHash : String read aKeyHash write aKeyHash;

      function Get(const aResourcePage, aHash, aSampleParams : String) : TJSONValue;

      class function GetInstance(const AOnwer : TComponent;
        const aBaseUrl, aHash : String) : THttpConnectJSON;
  end;

implementation

{ THttpConnectJSON }

constructor THttpConnectJSON.Create(const AOnwer : TComponent;
  const aBaseUrl, aHash : String);
begin
  inherited Create;
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
    Resource := EmptyStr;
    SynchronizedEvents := False;
  end;

  BaseURL  := Trim(aBaseUrl);
  aKeyHash := Trim(aHash);
end;

function THttpConnectJSON.Get(const aResourcePage, aHash,
  aSampleParams: String): TJSONValue;
var
  aRetorno     : TJSONValue;
  sHash        ,
  sSampleParams,
  sParams      : String;
begin
  aRetorno := TJSONValue.Create;
  try
    sHash         := Trim(aHash);
    sSampleParams := Trim(aSampleParams);
    if (sHash <> EmptyStr) or (sSampleParams <> EmptyStr) then
      sParams := '?';
    if (sHash <> EmptyStr) then
      sParams := sParams + 'hash={hash}&';
    if (sSampleParams <> EmptyStr) then
      sParams := sParams + sSampleParams + '&';

    if (Copy(sParams, Length(sParams), 1) = '&') then
      sParams := Copy(sParams, 1, Length(sParams) - 1);

    ResourcePage := Trim(aResourcePage) + sParams;

    aRESTRequest.Method := rmGET;
    if (sHash <> EmptyStr) then
      aRESTRequest.Params.AddUrlSegment('hash', sHash);
    aRESTRequest.Execute;

    aRetorno := aRESTRequest.Response.JSONValue;
  finally
    Result := aRetorno;
  end;
end;

function THttpConnectJSON.GetBaseURL: String;
begin
  if Assigned(aRESTClient) then
    Result := Trim(aRESTClient.BaseURL)
  else
    Result := EmptyStr;
end;

class function THttpConnectJSON.GetInstance(const AOnwer: TComponent;
  const aBaseUrl, aHash : String): THttpConnectJSON;
begin
  if not Assigned(aInstance) then
    aInstance := THttpConnectJSON.Create(AOnwer, aBaseUrl, aHash)
  else
    aInstance.BaseURL := aBaseUrl;

  Result := aInstance;
end;

function THttpConnectJSON.GetResourcePage: String;
var
  aStr : String;
begin
  if Assigned(aRESTRequest) then
  begin
    aStr := Trim(aRESTRequest.Resource);
    if (Pos('?', aStr) > 0) then
      aStr := Copy(aStr, 1, Pos('?', aStr) - 1);
    Result := aStr;
  end
  else
    Result := EmptyStr;
end;

procedure THttpConnectJSON.SetBaseURL(Value: String);
begin
  if Assigned(aRESTClient) then
    aRESTClient.BaseURL := Trim(Value);
end;

procedure THttpConnectJSON.SetResourcePage(Value: String);
begin
  if Assigned(aRESTRequest) then
    aRESTRequest.Resource := Trim(Value);
end;

end.
