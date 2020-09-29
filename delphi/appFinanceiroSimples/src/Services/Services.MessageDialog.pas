unit Services.MessageDialog;

interface

uses
  Services.ComplexTypes;

type
  TServicesMessageDialog = class
    private
    public
      class procedure Inform(aTitle, aMessage : String);
      class procedure Alert(aTitle, aMessage : String);
      class procedure Error(aTitle, aMessage : String);
      class procedure Sucess(aTitle, aMessage : String);
      class procedure Confirm(aTitle, aMessage : String; aCallbackProcedure : TCallbackProcedureObject);
  end;

implementation

uses
  Views.Mensagem;

{ TServicesMessageDialog }

class procedure TServicesMessageDialog.Alert(aTitle, aMessage: String);
begin
  TViewMensagem
    .GetInstance()
    .Tipo(TTipoMensagem.tipoMensagemAlerta)
    .Titulo(aTitle)
    .Mensagem(aMessage)
    .&End;
end;

class procedure TServicesMessageDialog.Confirm(aTitle, aMessage: String; aCallbackProcedure : TCallbackProcedureObject);
begin
  TViewMensagem
    .GetInstance()
    .Tipo(TTipoMensagem.tipoMensagemPergunta)
    .Titulo(aTitle)
    .Mensagem(aMessage)
    .CallbackProcedure(aCallbackProcedure)
    .&End;
end;

class procedure TServicesMessageDialog.Error(aTitle, aMessage: String);
begin
  TViewMensagem
    .GetInstance()
    .Tipo(TTipoMensagem.tipoMensagemErro)
    .Titulo(aTitle)
    .Mensagem(aMessage)
    .&End;
end;

class procedure TServicesMessageDialog.Inform(aTitle, aMessage: String);
begin
  TViewMensagem
    .GetInstance()
    .Tipo(TTipoMensagem.tipoMensagemInformacao)
    .Titulo(aTitle)
    .Mensagem(aMessage)
    .&End;
end;

class procedure TServicesMessageDialog.Sucess(aTitle, aMessage: String);
begin
  TViewMensagem
    .GetInstance()
    .Tipo(TTipoMensagem.tipoMensagemSucesso)
    .Titulo(aTitle)
    .Mensagem(aMessage)
    .&End;
end;

end.
