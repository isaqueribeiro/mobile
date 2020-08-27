unit Services.Utils;

interface

uses
  FMX.Objects;

type
  TServicesUtils = class
    private
    public
      class procedure ResourceImage( aResourceName : String; aImage : TImage);

  end;
implementation

uses
    System.Classes
  , System.Types;

{ TServicesUtils }

class procedure TServicesUtils.ResourceImage(aResourceName: String; aImage: TImage);
var
  Resource : TResourceStream;
begin
  Resource := TResourceStream.Create(HInstance, aResourceName, RT_RCDATA);
  try
    aImage.Bitmap.LoadFromStream(Resource);
  finally
    Resource.Free;
  end;
end;

end.
