unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Menus, frmSettings, uSettings,
  MMSystem;

type

  { TForm1 }

  TForm1 = class(TForm)
    Image1: TImage;
    PopupMenu1: TPopupMenu;
    itemExit: TMenuItem;
    itemAbout: TMenuItem;
    itemSettings: TMenuItem;
    TrayIcon1: TTrayIcon;
    timerUpdate: TTimer;
    lblCharge: TLabel;
    itemShowHide: TMenuItem;
    PopupMenu2: TPopupMenu;
    itemShowHide2: TMenuItem;
    itemSettings2: TMenuItem;
    itemAbout2: TMenuItem;
    itemExit2: TMenuItem;
    itemDebug2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure itemExitClick(Sender: TObject);
    procedure itemAboutClick(Sender: TObject);
    procedure itemSettingsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure timerUpdateTimer(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure itemShowHideClick(Sender: TObject);
    procedure itemDebugClick(Sender: TObject);
  private
    procedure PowerStatusChange(var Message: TMessage);
      message WM_POWERBROADCAST;
    procedure UpdateInfo();
    procedure UpdateView(charge: Integer; width: Integer);
    procedure SetSettings(first: Boolean);
    procedure ChangeIcon(charge: Integer);
    procedure SetShowWindow(show: Boolean);
  public
    XPos, YPos: Integer;
    Moving: Boolean;
    { Public declarations }
  end;

var
  Form1: TForm1;
  sound1Played: Boolean;

const
  DEBUG=false;

implementation

{$R *.lfm}

procedure ShowMessage(msg: Integer); overload;
begin
  Dialogs.ShowMessage(IntToStr(msg));
end;

procedure ShowMessage(msg: String); overload;
begin
  Dialogs.ShowMessage(msg);
end;

procedure ShowMessage(msg: Double); overload;
begin
  Dialogs.ShowMessage(FloatToStr(msg));
end;

//procedure DragWindow();
//begin
//  ReleaseCapture;
//  Form1.Perform(WM_SYSCOMMAND, SC_MOVE + 2, 0);
//end;

procedure TForm1.UpdateView(charge: Integer; width: Integer);
var
  t, i: Integer;
begin
  Image1.Canvas.Brush.Color := RGB(120, 255, 107);
  Image1.Canvas.Rectangle(0, 0, width, Image1.Height);
  t := width div 10;
  for i := 1 to 9 do
  begin
    Image1.Canvas.MoveTo(i * t, 0);
    Image1.Canvas.LineTo(i * t, Image1.Height);
  end;
  Form1.width := (charge div 10) * t + (charge mod 10) * (t div 10) + 1;
  lblCharge.Caption := IntToStr(charge);
end;

procedure TForm1.SetSettings(first: Boolean);
begin
  Form1.AlphaBlendValue := uSettings.alpha;
  Form1.width := uSettings.width;
  Form1.Height := uSettings.Height;
  Image1.width := Form1.width;
  Image1.Height := Form1.Height;
  if first then
  begin
    Form1.Left := uSettings.X;
    Form1.Top := uSettings.Y;
  end
  else
  begin
    Image1.Picture.Graphic.width := Form1.width;
    Image1.Picture.Graphic.Height := Form1.Height;
  end;
  sound1Played := false;

  lblCharge.Visible := uSettings.showText;

  SetShowWindow(showMainWindow);

  UpdateInfo();
end;

procedure TForm1.SetShowWindow(show: Boolean);
begin
  ShowMainWindow:=show;
  if show then begin
    Form1.Show;
    itemShowHide.Caption:='Hide';
    itemShowHide2.Caption:='Hide';
  end
  else begin
    Form1.Hide;
    itemShowHide.Caption:='Show';
    itemShowHide2.Caption:='Show';
  end;
end;

procedure TForm1.timerUpdateTimer(Sender: TObject);
begin
  UpdateInfo();
end;

procedure TForm1.TrayIcon1DblClick(Sender: TObject);
begin
  SetShowWindow(not Form1.Showing);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  uSettings.X := Form1.Left;
  uSettings.Y := Form1.Top;
  uSettings.SaveSettings();
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  itemDebug2.Visible:=debug;

  uSettings.path := extractfilepath(application.exename);
  uSettings.LoadSettings();
  SetSettings(true);
  // Form1.Left:=uSettings.x;
  // Form1.Top:=uSettings.y;
  // Form1.Width:=uSettings.width;
  // Form1.Height:=uSettings.height;

  // UpdateInfo();
  application.HintPause := 50;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  ShowWindow(Application.MainForm.Handle, SW_HIDE);
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //DragWindow();
  XPos:=X;
  YPos:=Y;
  Moving:=True;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  If Moving then Form1.Left:=Form1.Left+X-XPos;
  If Moving then Form1.Top:=Form1.Top+Y-YPos;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Moving:=False;
end;

procedure TForm1.itemAboutClick(Sender: TObject);
begin
  MessageBox(application.MainForm.Handle,
    'LpBattery 0.4' + #10#13 + 'Created by Str@y' + #10#13 + '2012', 'About',
    MB_OK);
end;

procedure TForm1.itemDebugClick(Sender: TObject);
var
  st: TSystemPowerStatus;
  str: string;
  percent, time: string;
  charge: Integer;
  LifeTime: Cardinal;
begin
  GetSystemPowerStatus(st{%H-}); // Получить информацию
  // Пересчет процентов с учетом минимума
  charge := Round(100 * (st.BatteryLifePercent - uSettings.battery_minimum) /
      (100 - uSettings.battery_minimum));
  if charge > 100 then
    charge := 100
  else if charge < 0 then
    charge := 0;
  percent := IntToStr(charge) + '%';

  if charge = 0 then
    LifeTime := 0
  else
    LifeTime := Round(st.BatteryLifeTime / charge * (charge - 30));

  time := TimeToStr(LifeTime / SecsPerDay);

  if (st.BatteryFlag and 128) <> 0 then
    str := 'no battery found'
  else if (st.BatteryFlag and 8) <> 0 then
    str := 'charging, ' + percent
  else if st.ACLineStatus = 1 then
    str := 'AC, ' + percent
  else
    str := percent + ' ' + time;

  str:= str + ' "' + IntToStr(st.BatteryFlag)+'"';

  ShowMessage(str);
end;

procedure TForm1.itemExitClick(Sender: TObject);
begin
  Close();
end;

procedure TForm1.itemSettingsClick(Sender: TObject);
begin
  Form2.ShowModal;
  SetSettings(false);
end;

procedure TForm1.itemShowHideClick(Sender: TObject);
begin
  SetShowWindow(not Form1.Showing);
end;

procedure TForm1.PowerStatusChange(var Message: TMessage);
begin
  // Пришло сообщение WM_POWERBROADCAST - нужно обновить информацию
  UpdateInfo();
end;

procedure TForm1.UpdateInfo();
// Получаем и выводим информацию о батарее в TStrings
var
  st: TSystemPowerStatus;
  str: string;
  percent, time: string;
  charge: Integer;
  LifeTime: Cardinal;
begin
  GetSystemPowerStatus(st{%H-}); // Получить информацию
  // Пересчет процентов с учетом минимума
  charge := Round(100 * (st.BatteryLifePercent - uSettings.battery_minimum) /
      (100 - uSettings.battery_minimum));
  if charge > 100 then
    charge := 100
  else if charge < 0 then
    charge := 0;
  percent := IntToStr(charge) + '%';

  if charge = 0 then
    LifeTime := 0
  else
    LifeTime := Round(st.BatteryLifeTime / charge * (charge - 30));

  time := TimeToStr(LifeTime / SecsPerDay);

  if (st.BatteryFlag and 128) <> 0 then
    str := 'no battery found'
  else if (st.BatteryFlag and 8) <> 0 then
    str := 'charging, ' + percent
  else if st.ACLineStatus = 1 then
    str := 'AC, ' + percent
  else
    str := percent + ' ' + time;
  // Form1.Hint:=str;
  Image1.Hint := str;
  TrayIcon1.Hint:=str;
  // sound1
  if uSettings.sound1enable > 0 then
  begin
    if charge = uSettings.sound1percent then
    begin
      if not sound1Played then
      begin
        // play
        sndPlaySound(PChar(uSettings.sound1file),
          SND_NODEFAULT Or SND_ASYNC);
        sound1Played := true;
      end;
    end
    else
    begin
      sound1Played := false;
    end;
  end;
  UpdateView(charge, uSettings.width);
  ChangeIcon(charge);
end;

procedure TForm1.ChangeIcon(charge: Integer);
begin
  if charge = 100 then
    TrayIcon1.Icon.LoadFromResourceName(hInstance, 'BATT4')
  else if charge > 80 then
    TrayIcon1.Icon.LoadFromResourceName(hInstance, 'BATT3')
  else if charge > 60 then
    TrayIcon1.Icon.LoadFromResourceName(hInstance, 'BATT2')
  else if charge > 20 then
    TrayIcon1.Icon.LoadFromResourceName(hInstance, 'BATT1')
  else
    TrayIcon1.Icon.LoadFromResourceName(hInstance, 'BATT0');

  //TrayIcon1.SetDefaultIcon;
end;

end.
