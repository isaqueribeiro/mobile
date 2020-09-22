unit Services.Format;

interface

type
  TTypeFormat = (typeFormatDate, typeFormatMoney);
  TServicesFormat = class
    private
    public
      class procedure Format(const aType : TTypeFormat; aSender : TObject);
  end;

implementation

{ TServicesFormat }

class procedure TServicesFormat.Format(const aType: TTypeFormat; aSender: TObject);
begin
  ;
end;

end.
