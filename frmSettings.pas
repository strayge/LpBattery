unit frmSettings;

interface

uses
  SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uSettings, ComCtrls, StdCtrls, MMSystem;

type
  TForm2 = class(TForm)
    tbAlpha: TTrackBar;
    btnOk: TButton;
    Label1: TLabel;
    edtAlpha: TEdit;
    edtWidth: TEdit;
    edtHeight: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    edtBatteryMin: TEdit;
    btnCancel: TButton;
    gbxSound: TGroupBox;
    cbxSound1: TCheckBox;
    lblSound1Percent: TLabel;
    edtSound1Percent: TEdit;
    lblSound1File: TLabel;
    edtSound1File: TEdit;
    dlgOpen1: TOpenDialog;
    btnSound1Select: TButton;
    btnSound1Test: TButton;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    cbxShowText: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure tbAlphaChange(Sender: TObject);
    procedure btnSound1SelectClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSound1TestClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

procedure TForm2.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TForm2.btnOkClick(Sender: TObject);
begin
  uSettings.alpha:= tbAlpha.Position;
  uSettings.width:=  StrToInt(edtWidth.Text);
  uSettings.height:= StrToInt(edtHeight.Text);
  uSettings.battery_minimum := StrToInt(edtBatteryMin.Text);

  if cbxsound1.Checked then
    uSettings.sound1enable:=1
  else
    uSettings.sound1enable:=0;
  uSettings.sound1percent:=StrToInt(edtSound1Percent.Text);
  uSettings.sound1file:=edtSound1file.Text;

  uSettings.showText:=cbxShowText.Checked;

  uSettings.SaveSettings();

  Close;
end;

procedure TForm2.btnSound1SelectClick(Sender: TObject);
begin
if dlgOpen1.Execute() then
  edtSound1File.Text:=dlgOpen1.FileName;
end;

procedure TForm2.btnSound1TestClick(Sender: TObject);
begin
  sndPlaySound( PChar(edtSound1File.Text)  ,
              SND_NODEFAULT Or SND_ASYNC);
end;

procedure TForm2.FormShow(Sender: TObject);
begin
  tbAlpha.Position:=uSettings.alpha;
  edtWidth.Text:=IntToStr(uSettings.width);
  edtHeight.Text:=IntToStr(uSettings.height);
  edtBatteryMin.Text:=IntToStr(uSettings.battery_minimum);

  if uSettings.sound1enable>0 then
    cbxsound1.Checked:=true
  else
    cbxsound1.Checked:=false;
  edtSound1Percent.Text:=IntToStr(uSettings.sound1percent);
  edtSound1file.Text:=uSettings.sound1file;

  cbxShowText.Checked:=uSettings.showText;
end;

procedure TForm2.tbAlphaChange(Sender: TObject);
begin
  edtAlpha.Text:=IntToStr(tbAlpha.Position);
end;

end.
