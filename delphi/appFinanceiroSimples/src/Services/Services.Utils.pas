unit Services.Utils;

interface

uses
  System.SysUtils, FMX.Objects, FMX.Graphics, Soap.EncdDecd;

type
  TServicesUtils = class
    private
    public
      class procedure ResourceImage( aResourceName : String; aImage : TImage);
      class function Base64FromBitmap(aBitmap : TBitmap) : String;
      class function BitmapFromBase64(const aBase64 : String) : TBitmap;

  end;
implementation

uses
    System.Classes
  , System.Types;

{ TServicesUtils }

class function TServicesUtils.Base64FromBitmap(aBitmap: TBitmap): String;
var
  aRestorno : String;
  Input  : TBytesStream;
  Output : TStringStream;
begin
  aRestorno := EmptyStr;
  try
    Input := TBytesStream.Create;
    aBitmap.SaveToStream(Input);
    Input.Position := 0;

    Output := TStringStream.Create('', TEncoding.ASCII);
    Soap.EncdDecd.EncodeStream(Input, Output);

    aRestorno := Output.DataString;
  finally
    Input.DisposeOf;
    Output.DisposeOf;

    Result := aRestorno;
  end;
end;

class function TServicesUtils.BitmapFromBase64(const aBase64: String): TBitmap;
var
  aRestorno : TBitmap;
  aInput  : TStringStream;
  aOutput : TBytesStream;
begin
  aRestorno := nil;
  aInput    := TStringStream.Create(aBase64, TEncoding.ASCII);
  aOutput   := TBytesStream.Create;
  try
    Soap.EncdDecd.DecodeStream(aInput, aOutput);
    aOutput.Position := 0;

    aRestorno := TBitmap.Create;
    aRestorno.LoadFromStream(aOutput);
  finally
    aOutput.DisposeOf;
    aInput.DisposeOf;

    Result := aRestorno;
  end;
end;

class procedure TServicesUtils.ResourceImage(aResourceName: String; aImage: TImage);
var
  Resource : TResourceStream;
begin
  Resource := TResourceStream.Create(HInstance, aResourceName, RT_RCDATA);
  try
    aImage.Bitmap.LoadFromStream(Resource);
  finally
    Resource.DisposeOf;
  end;
end;

end.
